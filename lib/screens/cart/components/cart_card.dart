import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:customer_frontend/constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartCard extends StatefulWidget {
  const CartCard({super.key});

  @override
  State<CartCard> createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  final CartController cartController = Get.find();

  Future<Map<String, dynamic>?> _getProductById(int productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedProducts = prefs.getString('stored_products');

    if (storedProducts != null) {
      List<dynamic> products = json.decode(storedProducts);

      return products.firstWhere(
        (product) => product['id'] == productId,
        orElse: () => null,
      );
    }
    return null;
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
                                    item['name'].length > 25
                                        ? '${item['name'].substring(0, item['name'].length > 30 ? 30 : item['name'].length)}...'
                                        : item['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Spacer(),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Remove Item",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                content: Text(
                                                  "Are you sure you want to remove this item from the cart?",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      cartController
                                                          .removeFromCart(
                                                              index);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text("Yes"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'PHP ${totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: kPrimaryColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                cartController
                                                    .decreaseQuantity(index);
                                              },
                                              child: Icon(
                                                Icons.remove,
                                                color: Colors.grey,
                                                size: 18,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            InkWell(
                                              onTap: () async {
                                                Map<String, dynamic>? product =
                                                    await _getProductById(
                                                  cartController
                                                      .cartItems[index]['id'],
                                                );

                                                if (product != null &&
                                                    product['stock'] > 0) {
                                                  int defaultLimit = product[
                                                              'name']
                                                          .toLowerCase()
                                                          .contains(
                                                              'water bottle')
                                                      ? 100
                                                      : 20;
                                                  int limit =
                                                      (product['stock'] <
                                                              defaultLimit)
                                                          ? product['stock']
                                                          : defaultLimit;

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      TextEditingController
                                                          controller =
                                                          TextEditingController(
                                                        text:
                                                            quantity.toString(),
                                                      );

                                                      return AlertDialog(
                                                        title: const Text(
                                                          "Enter Quantity",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        content: TextField(
                                                          controller:
                                                              controller,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              const InputDecoration(
                                                            hintText:
                                                                "Enter quantity",
                                                          ),
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly,
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              int enteredQuantity =
                                                                  int.tryParse(
                                                                          controller
                                                                              .text) ??
                                                                      quantity;

                                                              // Apply the same limit logic as the add button
                                                              if (enteredQuantity >
                                                                  limit) {
                                                                enteredQuantity =
                                                                    limit;
                                                              }

                                                              if (enteredQuantity >=
                                                                  1) {
                                                                // Update the quantity in the cart
                                                                cartController
                                                                    .updateQuantity(
                                                                        index,
                                                                        enteredQuantity);
                                                              } else {
                                                                // Remove item if quantity is 0
                                                                cartController
                                                                    .removeFromCart(
                                                                        index);
                                                              }

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                "OK"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Out of stock or product not found.")),
                                                  );
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                                child: Text(
                                                  '$quantity',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            GestureDetector(
                                              onTap: () async {
                                                Map<String, dynamic>? product =
                                                    await _getProductById(
                                                  cartController
                                                      .cartItems[index]['id'],
                                                );
                                                if (product != null &&
                                                    product['stock'] > 0) {
                                                  int defaultLimit = product[
                                                              'name']
                                                          .toLowerCase()
                                                          .contains(
                                                              'water bottle')
                                                      ? 100
                                                      : 20;
                                                  int limit =
                                                      (product['stock'] <
                                                              defaultLimit)
                                                          ? product['stock']
                                                          : defaultLimit;

                                                  if (cartController
                                                              .cartItems[index]
                                                          ['quantity'] <
                                                      limit) {
                                                    cartController
                                                        .increaseQuantity(
                                                            index);
                                                  } else {
                                                    print(
                                                        "Cannot add more. Reached the limit of $limit.");
                                                  }
                                                } else {
                                                  print(
                                                      "Out of stock or product not found.");
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                color: kPrimaryColor,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
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
}
