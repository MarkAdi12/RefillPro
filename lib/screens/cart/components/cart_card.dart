import 'package:flutter/material.dart';
import 'package:customer_frontend/constants.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';

class CartCard extends StatelessWidget {
  CartCard({super.key});

  final CartController cartController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CartController>(
        builder: (controller) {
          final groupedItems = _groupItemsByName(controller.cartItems);

          return Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: groupedItems.length,
                  itemBuilder: (context, index) {
                    final item = groupedItems[index];
                    double price =
                        double.tryParse(item['price'].toString()) ?? 0.0;
                    int quantity = item['quantity'] as int;
                    double totalPrice = price * quantity;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [                               
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                      onTap: () {
                                        cartController.removeFromCart(index);
                                      },
                                      child: Icon(Icons.close, size: 16,)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '₱${totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      cartController.decreaseQuantity(index);
                                    },
                                    icon:
                                        Icon(Icons.remove, color: Colors.grey,),
                                  ),
                                  Text(
                                    '$quantity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cartController.increaseQuantity(index);
                                    },
                                    icon: Icon(Icons.add, color: kPrimaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _groupItemsByName(
      List<Map<String, dynamic>> items) {
    Map<String, Map<String, dynamic>> grouped = {};

    for (var item in items) {
      String name = item['name'];

      if (grouped.containsKey(name)) {
        grouped[name]!['quantity'] += item['quantity'] as int;
      } else {
        grouped[name] = {
          'name': name,
          'price': item['price'].toString(),
          'quantity': item['quantity'] as int,
        };
      }
    }
    return grouped.values.toList();
  }
}
