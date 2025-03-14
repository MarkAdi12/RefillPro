import 'package:customer_frontend/screens/init_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../services/order_list_service.dart';
import '../../../services/order_service.dart';
import 'order_success.dart';
import 'payment_form.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:customer_frontend/controller/payment_controller.dart';

class PlaceOrderCard extends StatelessWidget {
  PlaceOrderCard({super.key});
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<bool> _hasPendingOrder(String accessToken) async {
    final orders = await OrderListService().fetchOrders(accessToken);
    return orders.any((order) => [0, 1, 3].contains(order['status']));
  }

  Future<void> _updateOrderStatusInFirebase(String orderId, int status) async {
    await _database.child('orders/$orderId').set({
      'status': status,
    });
    print('Order $orderId status updated to $status');
  }

  @override
  Widget build(BuildContext context) {
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
    final CartController cartController = Get.put(CartController());
    final PaymentController paymentController = Get.put(PaymentController());

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 12,
            color: Colors.black.withOpacity(0.1),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                String? accessToken =
                    await _secureStorage.read(key: 'access_token');
                if (accessToken == null) {
                  print("No access token found!");
                  return;
                }
               String totalAmount = cartController.calculateTotal();
                bool hasPendingOrder = await _hasPendingOrder(accessToken);
                if (hasPendingOrder) {
                  _showPendingOrderDialog(context);
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                try {
                  int? orderId =
                      await PlaceOrderService.placeOrder(accessToken);
                  print('Order ID received: $orderId');

                  if (orderId == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Center(child: Text("Failed To Place Order. Please try again."))),
                    );
                    return;
                  }

                  // write orderID key
                  await _secureStorage.write(
                      key: 'tracking_order_id', value: orderId.toString());
                  print('tracking_order_id written: $orderId');

                  String? storedOrderId =
                      await _secureStorage.read(key: 'tracking_order_id');
                  print('tracking_order_id read after write: $storedOrderId');

                  Navigator.pop(context);
                  cartController.clearCart();
                  _updateOrderStatusInFirebase(orderId.toString(), 0);

                  // if online payment
                  if (paymentController.selectedPaymentMethod.value ==
                      'Online Payment') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentForm(
                          orderID: orderId,
                          amount: totalAmount,
                        ),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderSuccessScreen(),
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  print("Error placing order: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to place order")),
                  );
                }
              },
              child: const Text("Place Order"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text("Cannot Place Order", style: TextStyle(fontSize: 16)),
          content: const Text(
            "You cannot place a new order because you have a pending order. Please complete or cancel your existing order.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InitScreen()));
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
