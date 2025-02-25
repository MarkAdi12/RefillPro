import 'package:customer_frontend/screens/ordering/order.dart';
import 'package:customer_frontend/screens/track_order/components/order_status.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/order_list_service.dart';
import '../../services/auth_service.dart';
import 'components/order_details.dart';
import 'package:firebase_database/firebase_database.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final OrderListService _orderListService = OrderListService();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _trackingOrder;
  final Map<int, Map<String, dynamic>> _paymentData = {};
  double _riderLat = 0.0;
  double _riderLong = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTrackingOrder();
    _listenToLocationUpdates();
    _listenToOrderUpdates();
  }

  void _listenToOrderUpdates() {
    DatabaseReference ordersRef = _database.ref('orders');
    ordersRef.onChildChanged.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists &&
          snapshot.key != null &&
          _trackingOrder != null &&
          snapshot.key == _trackingOrder!['orderNo']) {
        print('Order ${snapshot.key} updated in Firebase. Refreshing order...');
        _fetchTrackingOrder();
      }
    });
  }

  void _listenToLocationUpdates() {
    DatabaseReference locationRef = _database.ref('location');
    locationRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value is Map) {
        Map<dynamic, dynamic> locationData = snapshot.value as Map;
        double lat = (locationData['lat'] as num).toDouble();
        double long = (locationData['long'] as num).toDouble();
        setState(() {
          _riderLat = lat;
          _riderLong = long;
        });
        print('Updated Location: $lat, $long');
      } else {
        print('No location data found in Firebase');
      }
    });
  }

  Future<void> _fetchTrackingOrder() async {
    setState(() {
      _isLoading = true;
    });

    String? token = await _secureStorage.read(key: 'access_token');
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No authentication token found.";
      });
      return;
    }

    // Debug: Print all keys in secure storage
    final allKeys = await _secureStorage.readAll();
    print('All keys in secure storage: $allKeys');

    // Debug: Read tracking_order_id
    String? trackingOrderId =
        await _secureStorage.read(key: 'tracking_order_id');
    print('tracking_order_id read in _fetchTrackingOrder: $trackingOrderId');

    if (trackingOrderId == null) {
      print('No tracking order ID found in secure storage');
      setState(() {
        _isLoading = false;
        _trackingOrder = null;
      });
      return;
    }

    try {
      final orders = await _orderListService.fetchOrders(token);

      // Find the specific order by trackingOrderId
      final order = orders.firstWhere(
        (order) => order['id'].toString() == trackingOrderId,
        orElse: () => null,
      );

      if (order == null) {
        // Order not found
        setState(() {
          _isLoading = false;
          _errorMessage = "Order not found.";
        });
        return;
      }

      // Fetch payment data if not already cached
      if (!_paymentData.containsKey(order['id'])) {
        final paymentData =
            await _orderListService.retrievePayment(token, order['id']);
        if (paymentData != null) {
          _paymentData[order['id']] = paymentData;
        }
      }

      // Fetch customer details
      AuthService authService = AuthService();
      Map<String, dynamic>? customerData = await authService.getUser(token);
      String customerName = customerData != null
          ? "${customerData['first_name']} ${customerData['last_name']}"
          : "Unknown Customer";

      //order items
      List<Map<String, dynamic>> orderItems = [];
      double totalPrice = 0.0; // Initialize total price

      for (var item in order['order_details']) {
        double itemTotalPrice = double.parse(item['total_price']);
        totalPrice += itemTotalPrice; // Sum up total prices

        orderItems.add({
          'name': item['product']['name'] ?? "Unknown Product",
          'quantity': double.parse(item['quantity']).toInt(),
          'totalPrice': itemTotalPrice.toString(),
        });
      }

      // Update fetched order
      setState(() {
        _trackingOrder = {
          'orderNo': order['id'].toString(),
          'customerName': customerName,
          'status': order['status'].toString(),
          'customerLat': double.parse(order['customer']['lat']),
          'customerLong': double.parse(order['customer']['long']),
          'orderItems': orderItems,
          'totalPrice': totalPrice.toString(), 
        };
        _isLoading = false;
      });

      if (order['status'] == 4) {
        _showOrderCompletedDialog(context);
      }
      if (order['status'] == 5) {
        _showOrderCancelledDialog(context);
      }
      if (order['status'] == 6) {
        _showOrderCancelledDialog(context);
      }
    } catch (e) {
      debugPrint("Error loading order: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load tracking order.";
      });
    }
  }

  void _showOrderCancelledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Order Cancelled", style: TextStyle(fontSize: 12)),
          content: const Text("Your order has been cancelled. Thank you!"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _secureStorage.delete(key: 'tracking_order_id');
                Navigator.of(context).pop();
                setState(() {
                  _trackingOrder = null;
                });
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  void _showOrderCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Order Completed", style: TextStyle(fontSize: 18)),
          content: const Text("Your order has been completed. Thank you!"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _secureStorage.delete(key: 'tracking_order_id');
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _trackingOrder = null; // Clear the tracking order
                });
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trackingOrder == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage ??
                          "No Active Orders"), // Display error message
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderScreen(),
                              ),
                            );
                          },
                          child: Text('Place An Order'),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      int.parse(_trackingOrder!['status']) == 0 ||
                              int.parse(_trackingOrder!['status']) == 1
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset("assets/prepairing.gif",
                                  width: 300, height: 300),
                            )
                          : _buildLocationContainer(
                              _trackingOrder!['customerLat'],
                              _trackingOrder!['customerLong'],
                              _riderLat,
                              _riderLong,
                              _trackingOrder!['customerName'],
                            ),
                      OrderStatus(status: int.parse(_trackingOrder!['status'])),
                      OrderDetails(
                        currentStep:
                            int.parse(_trackingOrder!['status']) == 0 ? 0 : 1,
                        orderNo: _trackingOrder!['orderNo'],
                        customerName: _trackingOrder!['customerName'],
                        status: _trackingOrder!['status'],
                        orderItems: _trackingOrder!['orderItems'],
                        paymentStatus: _getPaymentStatus(
                            int.parse(_trackingOrder!['orderNo'])), 
                        amount: _trackingOrder!['totalPrice'],
                      ),
                    ],
                  ),
                ),
    );
  }

  // Payment
  String _getPaymentStatus(int orderId) {
    final paymentData = _paymentData[orderId];

    if (paymentData == null || paymentData['status'] == null) {
      return "Cash on Delivery";
    } else {
      switch (paymentData['status']) {
        case 1:
          return "Paid Online";
        case 0:
          return "Pending";
        case 2:
          return "Payment Failed";
        default:
          return "Unknown Status";
      }
    }
  }

  // Map
  Widget _buildLocationContainer(
    double customerLat,
    double customerLong,
    double riderLat,
    double riderLong,
    String customerName,
  ) {
    return SizedBox(
      height: 330,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(customerLat, customerLong),
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("customer_location"),
              position: LatLng(customerLat, customerLong),
              infoWindow: InfoWindow(title: customerName, snippet: "Customer"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
            Marker(
              markerId: const MarkerId("rider_location"),
              position: LatLng(riderLat, riderLong),
              infoWindow: InfoWindow(title: "Rider", snippet: "Assigned Rider"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet),
            ),
          },
        ),
      ),
    );
  }
}
