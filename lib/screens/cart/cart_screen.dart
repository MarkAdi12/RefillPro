import 'package:flutter/material.dart';
import 'components/cart_card.dart';
import 'components/check_out_card.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cartController = Get.find();

  // ✅ Fixed Price Calculation
  String calculateTotal() {
    double totalPrice = cartController.cartItems.fold(
      0,
      (sum, item) => sum +
          ((double.tryParse(item['price'].toString()) ?? 0.0) *
              (item['quantity'] as int)),
    );
    return totalPrice.toStringAsFixed(2); // Format to 2 decimal points
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          children: [
            const Text(
              "Cart",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Text(
              "${cartController.cartItems.length} item(s)",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (cartController.cartItems.isEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "No items in cart",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: CartCard(),
              ),
            if (cartController.cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GetBuilder<CartController>(
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [Spacer(), Text('Add More?')],
                        ),
                        Divider(thickness: 1, color: Colors.grey[400]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '₱${calculateTotal()}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery Fee',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '₱0.00',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '₱${calculateTotal()}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar:
          cartController.cartItems.isNotEmpty ? CheckoutCard() : null,
    );
  }
}
