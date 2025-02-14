import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/order_list_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controller/cart_controller.dart';
import 'components/order_history_widget.dart';
import '../../services/auth_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final OrderListService _orderListService = OrderListService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _orderHistory = [];

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
      // Only include orders with status 1
      if (order['status'] != 1) continue;

      List<Map<String, dynamic>> orderItems = [];
      for (var item in order['order_details']) {
        orderItems.add({
          'id': item['product']['id'],
          'name': item['product']['name'] ?? "Unknown Product",
          'quantity': (item['quantity'] is int)
              ? item['quantity']
              : double.parse(item['quantity']).toInt(),
          'price': (item['product']['price'] is double
              ? item['product']['price']
              : double.parse(item['product']['price'])),
        });
      }

      orders.add({
        'date': 'February 01, 2025',
        'orderNo': order['id'].toString(),
        'customerName': customerName,
        'address': customerData?['address'] ?? 'No address provided',
        'orderItems': orderItems,
        'isExpanded': false,
      });
    }

    setState(() {
      _orderHistory = orders;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint("Error loading orders: $e");
    setState(() {
      _isLoading = false;
      _errorMessage = "Failed to load orders.";
    });
  }
}

  void toggleExpand(int index) {
    setState(() {
      _orderHistory[index]['isExpanded'] = !_orderHistory[index]['isExpanded'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ListView.builder(
                    itemCount: _orderHistory.length,
                    itemBuilder: (context, index) {
                      final order = _orderHistory[index];
                      double subtotal = 0.0;
                      for (var item in order['orderItems']) {
                        subtotal += item['price'] * item['quantity'];
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OrderHistoryWidgets.buildOrderDetail(
                                    "Order #", order['orderNo']),
                                GestureDetector(
                                  onTap: () => toggleExpand(index),
                                  child: Icon(
                                    order['isExpanded']
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Divider(thickness: 1, color: Colors.grey[300]),
                            if (order['isExpanded']) ...[
                              const SizedBox(height: 8),
                              OrderHistoryWidgets.buildOrderDetail(
                                  "Customer:", order['customerName']),
                              OrderHistoryWidgets.buildOrderDetail(
                                  "Address:", order['address']),
                              Divider(thickness: 1, color: Colors.grey[300]),
                              OrderHistoryWidgets.buildOrderItems(
                                  order['orderItems']),
                              Divider(thickness: 1, color: Colors.grey[300]),
                              OrderHistoryWidgets.buildTotalSection(subtotal),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  OrderHistoryWidgets().showCheckoutDialog(context);
                                  final CartController cartController =
                                      Get.find<CartController>();
                                  cartController.reorder(order[
                                      'orderItems']); 
                                },
                                child: const Text('Reorder',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
