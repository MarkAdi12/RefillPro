import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Order Summary',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          GetBuilder<CartController>(
            builder: (controller) {
              return Column(
                children: controller.cartItems.map((item) {
                  double price =
                      double.tryParse(item['price'].toString()) ?? 0.0;
                  int quantity = item['quantity'] as int;
                  double totalPrice = price * quantity;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$quantity x ${item['name']}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          '₱${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(fontSize: 16)),
              Text(
                '₱${cartController.calculateTotal()}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 16)),
              Text(
                '₱${cartController.calculateTotal()}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(thickness: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
