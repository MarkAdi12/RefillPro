import 'package:flutter/material.dart';
import 'package:customer_frontend/services/item_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:customer_frontend/screens/cart/cart_screen.dart';
import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/components/custom_appbar.dart';
import 'components/product_details.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ItemService _itemService = ItemService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final CartController cartController = Get.put(CartController());

  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Session cache for products
  static List<dynamic> _productList = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    // Use cached products if available
    if (_productList.isNotEmpty) {
      setState(() {
        _products = _productList;
        _isLoading = false;
      });
      return;
    }

    // Fetch products from the API if cache is empty
    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No authentication token found.";
      });
      return;
    }

    try {
      List<dynamic> items = await _itemService.getItems(token);

      // Update session cache
      _productList = items;

      setState(() {
        _products = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load products.";
      });
    }
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
      appBar: CustomAppBar(
        title: 'Available Items',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 16, 
                    mainAxisSpacing: 16, 
                    childAspectRatio: 0.8, 
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    var product = _products[index];
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetails(product: product),
                                ),
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
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
                                const SizedBox(height: 8),
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱ ${product['price']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}