import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../services/place_order_service.dart';
import 'order_success.dart';
import 'payment_form.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:customer_frontend/controller/payment_controller.dart';

class PlaceOrderCard extends StatelessWidget {
  const PlaceOrderCard({super.key});

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
                // ✅ Show Loading Dialog
                showDialog(
                  context: context,
                  barrierDismissible: false, // Prevent dismissing
                  builder: (context) {
                    return const Center(
                      child: CircularProgressIndicator(), // Loading spinner
                    );
                  },
                );
                //  Call API
                try {
                  int? orderId = await PlaceOrderService.placeOrder(accessToken);
                  if (orderId == null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to retrieve order ID")),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  cartController.clearCart();

                  if (paymentController.selectedPaymentMethod.value == 'Online Payment') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentForm(orderID: orderId),
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
}
