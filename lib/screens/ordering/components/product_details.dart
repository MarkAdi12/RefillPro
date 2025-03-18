import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import '../../../controller/cart_controller.dart';
import '../../cart/cart_screen.dart';
import '../order.dart';

class ProductDetails extends StatefulWidget {
  final dynamic product;
  final String imagePath;

  const ProductDetails(
      {Key? key, required this.product, required this.imagePath})
      : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  final CartController cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    _checkStockAndShowAlert();
  }

  void _checkStockAndShowAlert() {
    int stock = widget.product['stock'] ?? 0; // Default to 0 if not provided
    bool waterProduct = widget.product['water_product'] ??
        false; // Default to false if not provided

    if (stock == 0 && !waterProduct) {
      // Show alert ONLY if NOT a water product
      Future.delayed(Duration.zero, () {
        _showOutOfStockAlert();
      });
    }
  }

  void _showOutOfStockAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without user action
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Out of Stock',
            style: TextStyle(fontSize: 18),
          ),
          content: const Text('This product is currently unavailable.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('OK', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

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
        appBar: AppBar(title: const Text('Product Details')),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product['name'],
                            style: const TextStyle(
                                fontSize: 26, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.product['description'] ??
                          'No description available',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₱${widget.product['price']}',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                icon: const Icon(Icons.remove,
                                    color: Colors.white),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    int limit = (widget.product['name']
                                            .toLowerCase()
                                            .contains('water bottle'))
                                        ? 100
                                        : 20;

                                    if (quantity < limit) {
                                      quantity++;
                                    }
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
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          int maxLimit = (widget.product['name']
                                  .toLowerCase()
                                  .contains('water bottle'))
                              ? 100
                              : 20;
                          int currentCartQuantity = 0;
                          final existingIndex = cartController.cartItems
                              .indexWhere(
                                  (item) => item['id'] == widget.product['id']);
                          if (existingIndex != -1) {
                            currentCartQuantity = cartController
                                .cartItems[existingIndex]['quantity'];
                          }
                          int newTotalQuantity = currentCartQuantity + quantity;
                          if (newTotalQuantity > maxLimit) {
                            int allowedQuantity =
                                maxLimit - currentCartQuantity;
                            if (allowedQuantity > 0) {
                              for (int i = 0; i < allowedQuantity; i++) {
                                cartController.addToCart(widget.product);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Limit reached! Added only $allowedQuantity items.')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Cannot add more! Max limit of $maxLimit reached.')),
                              );
                            }
                          } else {
                            for (int i = 0; i < quantity; i++) {
                              cartController.addToCart(widget.product);
                            }
                            _showAddToCartDialog(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
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
            )
          ],
        ));
  }
}
