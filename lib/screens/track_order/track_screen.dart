import 'package:customer_frontend/screens/track_order/components/order_status.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/order_list_service.dart';
import '../../services/auth_service.dart';
import 'components/order_details.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final OrderListService _orderListService = OrderListService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _trackingOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    String? token = await _secureStorage.read(key: 'access_token');
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No authentication token found.";
      });
      return;
    }

    try {
      List<dynamic> items = await _orderListService.fetchOrders(token);
      AuthService authService = AuthService();
      Map<String, dynamic>? customerData = await authService.getUser(token);
      String customerName = customerData != null
          ? "${customerData['first_name']} ${customerData['last_name']}"
          : "Unknown Customer";

      List<Map<String, dynamic>> orders = [];

      for (var order in items) {
        if (order['status'] != 0) continue; // Only track pending orders

        List<Map<String, dynamic>> orderItems = [];
        for (var item in order['order_details']) {
          orderItems.add({
            'name': item['product']['name'] ?? "Unknown Product",
            'quantity': double.parse(item['quantity']).toInt(),
          });
        }

        orders.add({
          'orderNo': order['id'].toString(),
          'customerName': customerName,
          'status': order['status'] == 0 ? "Pending" : "Completed",
          'customerLat': double.parse(order['customer']['lat']),
          'customerLong': double.parse(order['customer']['long']),
          'riderLat': double.parse(order['assigned_to']['lat']),
          'riderLong': double.parse(order['assigned_to']['long']),
          'orderItems': orderItems,
        });
      }

      setState(() {
        _trackingOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading orders: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load tracking orders.";
      });
    }
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
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _trackingOrders.isEmpty
                  ? const Center(child: Text("No pending orders"))
                  : ListView.builder(
                      itemCount: _trackingOrders.length,
                      itemBuilder: (context, index) {
                        final order = _trackingOrders[index];
                        return Column(
                          children: [
                            _buildLocationContainer(
                              order['customerLat'],
                              order['customerLong'],
                              order['riderLat'],
                              order['riderLong'],
                              order['customerName'],
                            ),
                            OrderStatus(
                              status:
                                  int.tryParse(order['status'].toString()) ?? 0,
                            ),
                            OrderDetails(
                              currentStep: order['status'] == "Pending" ? 0 : 1,
                              orderNo: order['orderNo'],
                              customerName: order['customerName'],
                              status: order['status'],
                              orderItems: order['orderItems'],
                            ),
                          ],
                        );
                      },
                    ),
    );
  }

  Widget _buildLocationContainer(
    double customerLat,
    double customerLong,
    double riderLat,
    double riderLong,
    String customerName,
  ) {
    return SizedBox(
      height: 350,
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
              infoWindow:
                  const InfoWindow(title: "Rider", snippet: "Assigned Rider"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          },
        ),
      ),
    );
  }
}
