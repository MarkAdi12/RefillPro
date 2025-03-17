// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:customer_frontend/screens/init_screen.dart';
import 'package:customer_frontend/screens/ordering/order.dart';
import 'package:customer_frontend/screens/track_order/components/order_status.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _listenToOrderUpdates();
    _listenToRiderLocationUpdates();
  }

  void _listenToOrderUpdates() {
    if (_trackingOrder == null || !_trackingOrder!.containsKey('orderNo')) {
      print('⚠️ No tracking order found');
      return;
    }

    DatabaseReference orderRef =
        _database.ref('orders/${_trackingOrder!['orderNo']}');

    orderRef.onChildChanged.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.key == 'status' &&
          snapshot.exists &&
          snapshot.value != null) {
        int newStatus = snapshot.value as int;

        if (_trackingOrder!['status'] != newStatus) {
          print('🚀 Order status changed to: $newStatus');
          _trackingOrder!['status'] = newStatus;
          _fetchTrackingOrder();
        }
      }
    }).onError((error) {
      print('Error listening to order updates: $error');
    });
  }

// ✅ Listen only for rider location updates
  void _listenToRiderLocationUpdates() {
    if (_trackingOrder == null || !_trackingOrder!.containsKey('orderNo')) {
      print(
          '⚠️ No tracking order found. Cannot listen for rider location updates.');
      return;
    }

    String orderNo = _trackingOrder!['orderNo'];
    print('🔍 Listening for rider location updates for Order ID: $orderNo');

    DatabaseReference orderRef = _database.ref('orders/$orderNo');

    orderRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (!snapshot.exists) {
        print('❌ No data found for Order ID: $orderNo');
        return;
      }

      if (snapshot.value is! Map) {
        print('⚠️ Unexpected data format for Order ID: $orderNo');
        return;
      }

      Map<dynamic, dynamic> orderData = snapshot.value as Map;

      if (!orderData.containsKey('riderLat') ||
          !orderData.containsKey('riderLong')) {
        print('⚠️ Missing rider location data for Order ID: $orderNo');
        return;
      }

      double newLat = (orderData['riderLat'] as num).toDouble();
      double newLong = (orderData['riderLong'] as num).toDouble();

      print(
          '📍 Received new rider location for Order ID: $orderNo → Lat: $newLat, Long: $newLong');

      // ✅ Only update if location actually changed
      if (_riderLat != newLat || _riderLong != newLong) {
        setState(() {
          _riderLat = newLat;
          _riderLong = newLong;
        });
        print(
            '✅ Rider Location Updated for Order ID: $orderNo → Lat: $_riderLat, Long: $_riderLong');
      } else {
        print('ℹ️ Rider location unchanged for Order ID: $orderNo');
      }
    });
  }

  Future<void> _fetchTrackingOrder() async {
    setState(() {
      print('Tracking Order: $_trackingOrder');
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

    String? trackingOrderId =
        await _secureStorage.read(key: 'tracking_order_id');
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
      final order = orders.firstWhere(
        (order) => order['id'].toString() == trackingOrderId,
        orElse: () => {},
      );

      if (order.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to retrieve order.";
        });
        return;
      }

      if (!_paymentData.containsKey(order['id'])) {
        final paymentData =
            await _orderListService.retrievePayment(token, order['id']);
        if (paymentData != null) {
          _paymentData[order['id']] = paymentData;
        }
      }

      AuthService authService = AuthService();
      Map<String, dynamic>? customerData = await authService.getUser(token);
      String customerName = customerData != null
          ? "${customerData['first_name']} ${customerData['last_name']}"
          : "Unknown Customer";

      List<Map<String, dynamic>> orderItems = [];
      double totalPrice = 0.0;

      for (var item in order['order_details']) {
        double itemTotalPrice = double.parse(item['total_price']);
        totalPrice += itemTotalPrice;

        orderItems.add({
          'name': item['product']['name'] ?? "Unknown Product",
          'quantity': double.parse(item['quantity']).toInt(),
          'totalPrice': itemTotalPrice.toString(),
        });
      }

      setState(() {
        // Ensure UI updates by setting a new map reference
        _trackingOrder = {
          'orderNo': order['id'].toString(),
          'customerName': customerName,
          'status':
              order['status'].toString(), // Status will now trigger UI update
          'customerLat': double.parse(order['customer']['lat']),
          'customerLong': double.parse(order['customer']['long']),
          'orderItems': orderItems,
          'totalPrice': totalPrice.toString(),
        };
        _isLoading = false;
      });

      print("✅ Tracking Order Updated: $_trackingOrder");

      _listenToOrderUpdates(); // Add this line
      print(
          'Listening to Firebase path: orders/${_trackingOrder!['orderNo']}/status');
      _listenToRiderLocationUpdates();

      if (order['status'] == 4) {
        _showOrderCompletedDialog(context);
      }
      if (order['status'] == 5 || order['status'] == 6) {
        _showOrderCancelledDialog(context);
        await clearOrderHistory();
      }
    } catch (e) {
      debugPrint("Error loading order: $e");
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Failed to load tracking order. Please check your internet connection and try again.";
      });
    }
  }

  Future<void> clearOrderHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('order_history');
    print("Order history cleared!");
  }

  void _showOrderCancelledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Order Cancelled", style: TextStyle(fontSize: 18)),
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
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        child: Text(
                          _errorMessage ?? "No Active Orders",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(
                                double.infinity, 50), // Ensures full width
                            alignment: Alignment
                                .center, // Centers text inside the button
                          ),
                          onPressed: () {
                            if (_errorMessage ==
                                    "Failed to load tracking order. Please check your internet connection and try again." ||
                                _errorMessage ==
                                    "Failed to retrieve order. Please check your internet connection and try again.") {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InitScreen(
                                            initialIndex: 1,
                                          )));
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderScreen(),
                                ),
                              );
                            }
                          },
                          child: Text(
                            (_errorMessage ==
                                        "Failed to load tracking order. Please check your internet connection and try again." ||
                                    _errorMessage ==
                                        "Failed to retrieve order. Please check your internet connection and try again.")
                                ? "Refresh"
                                : "Place An Order",
                            textAlign: TextAlign.center,
                          ),
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
                              ||
                              int.parse(_trackingOrder!['status']) == 2
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
