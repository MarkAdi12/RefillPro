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
                    double price = double.tryParse(item['price'].toString()) ?? 0.0;
                    int quantity = item['quantity'] as int;
                    double totalPrice = price * quantity;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['name'], 
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    '₱${totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1),
                              Container(
                                margin: EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        cartController.decreaseQuantity(index);
                                      },
                                      icon: Icon(Icons.remove_circle_outline),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        cartController.increaseQuantity(index);
                                      },
                                      icon: Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
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


  List<Map<String, dynamic>> _groupItemsByName(List<Map<String, dynamic>> items) {
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
