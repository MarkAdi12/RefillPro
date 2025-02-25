import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controller/cart_controller.dart';
import '../../cart/cart_screen.dart';
import '../order.dart';

class ProductDetails extends StatefulWidget {
  final dynamic product; 

  ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;

  final CartController cartController = Get.put(CartController());

  void _showAddToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add to Cart Successful!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content:
              const Text('Would you like to view your cart or add more items?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrderScreen()),
                );
              },
              child: const Text(
                'Add More',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              child: const Text(
                'View Cart',
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/slim.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.product['name'],
                          style: const TextStyle(
                              fontSize: 26, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.product['description'] ??
                          'No description available',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              '${double.parse(widget.product['weight']).toInt()}ml',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              '₱${widget.product['price']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    const SizedBox(height: 40),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          for (int i = 0; i < quantity; i++) {
                            cartController.addToCart(widget.product);
                          }
                          _showAddToCartDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20), // Adjust height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 16, color: kPrimaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
