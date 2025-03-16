// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/order_list_service.dart';
import '../../constants.dart';
import '../../controller/cart_controller.dart';
import 'components/order_history_widget.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final OrderListService _orderListService = OrderListService();
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  String formatDateTime(dynamic dateTime) {
    if (dateTime == null || dateTime.toString().isEmpty) {
      return "No delivery date";
    }
    try {
      DateTime parsedDate = DateTime.parse(dateTime.toString()).toLocal();
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      debugPrint("Error parsing date: $e");
      return "Invalid date";
    }
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
        if (order['status'] != 4) continue;

        List<Map<String, dynamic>> orderItems = [];
        for (var item in order['order_details']) {
          orderItems.add({
            'id': item['product']['id'],
            'name': item['product']['name'] ?? "Unknown Product",
            'quantity': (item['quantity'] is int)
                ? item['quantity']
                : double.parse(item['quantity']).toInt(),
            'price': double.parse(item['total_price']) /
                double.parse(item['quantity']),
          });
        }

        orders.add({
          'delivery_datetime': formatDateTime(order['delivery_datetime']),
          'orderNo': order['id'].toString(),
          'customerName': customerName,
          'address': customerData?['address'] ?? 'No address provided',
          'orderItems': orderItems,
        });
      }

      orders.sort(
          (a, b) => int.parse(b['orderNo']).compareTo(int.parse(a['orderNo'])));

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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: const BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OrderHistoryWidgets.buildOrderDetail(
                                      order['delivery_datetime']),
                                  Text(
                                    "Order ID: ${order['orderNo']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 122, 122, 122),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OrderHistoryWidgets.buildOrderItems(
                                      order['orderItems']),
                                  const Divider(
                                      thickness: 1, color: Colors.grey),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Subtotal:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        '₱${subtotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  OrderHistoryWidgets.buildTotalSection(
                                      subtotal),
                                  const SizedBox(height: 8),
                                  Obx(() => ElevatedButton(
                                        onPressed: Get.find<CartController>()
                                                .isLoading
                                                .value
                                            ? null // Completely disables the button
                                            : () async {
                                                final CartController
                                                    cartController =
                                                    Get.find<CartController>();
                                                cartController.isLoading.value =
                                                    true;

                                                await cartController.reorder(
                                                    order['orderItems']);

                                                cartController.isLoading.value =
                                                    false; // Re-enable button

                                                OrderHistoryWidgets()
                                                    .showCheckoutDialog(
                                                        context);
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Get.find<
                                                      CartController>()
                                                  .isLoading
                                                  .value
                                              ? kPrimaryColor // Disabled color
                                              : kPrimaryColor, // Normal color
                                        ),
                                        child: Text(
                                          'Reorder',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
