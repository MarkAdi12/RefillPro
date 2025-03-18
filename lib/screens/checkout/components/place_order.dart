import 'package:customer_frontend/constants.dart';
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

class PlaceOrderCard extends StatefulWidget {
  PlaceOrderCard({super.key});

  @override
  State<PlaceOrderCard> createState() => _PlaceOrderCardState();
}

class _PlaceOrderCardState extends State<PlaceOrderCard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final CartController cartController = Get.put(CartController());
  final PaymentController paymentController = Get.put(PaymentController());

  bool _isProcessing = false; // To control multiple clicks

  Future<bool> _hasPendingOrder(String accessToken) async {
    final orders = await OrderListService().fetchOrders(accessToken);
    return orders.any((order) => [0, 1, 2, 3].contains(order['status']));
  }

  Future<void> _updateOrderStatusInFirebase(String orderId, int status) async {
    await _database.child('orders/$orderId').set({
      'status': status,
    });
    print('Order $orderId status updated to $status');
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
                  MaterialPageRoute(builder: (context) => const InitScreen()),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    setState(() {
      _isProcessing = true; // Disable the button
    });

    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      print("No access token found!");
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    bool hasPendingOrder = await _hasPendingOrder(accessToken);
    if (hasPendingOrder) {
      _showPendingOrderDialog(context);
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      int? orderId = await PlaceOrderService.placeOrder(accessToken);
      print('Order ID received: $orderId');

      if (orderId == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Center(child: Text("Failed to place order. Please try again.")),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      await _secureStorage.write(
          key: 'tracking_order_id', value: orderId.toString());
      print('Tracking Order ID saved: $orderId');

      Navigator.pop(context); // Close the loading dialog
      cartController.clearCart();
      _updateOrderStatusInFirebase(orderId.toString(), 0);

      // Navigate based on payment method
      String totalAmount = cartController.calculateTotal();
      if (paymentController.selectedPaymentMethod.value == 'Online Payment') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PaymentForm(orderID: orderId, amount: totalAmount),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to place order.")),
      );
    } finally {
      setState(() {
        _isProcessing = false; // Enable the button again
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isProcessing ? null : () => _placeOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isProcessing ? Colors.grey : kPrimaryColor,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : const Text("Place Order"),
            ),
          ],
        ),
      ),
    );
  }
}
