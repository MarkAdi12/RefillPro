import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:customer_frontend/services/item_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:customer_frontend/components/custom_appbar.dart';
import 'components/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderScreen extends StatefulWidget {
  final String? autoSelectProductName;

  const OrderScreen({Key? key, this.autoSelectProductName}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ItemService _itemService = ItemService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final CartController cartController = Get.put(CartController());

  List<dynamic> _products = [];
  bool _isLoading = true;
  bool _isSelecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No authentication token found.";
      });
      return;
    }

    try {
      List<dynamic>? items = await _itemService.getItems(token);

      if (items == null || items.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Failed to load products. Please\nCheck Your Internet Connection and try again.";
        });
        return;
      }

      // Filter only active products (status = true)
      List<dynamic> activeProducts =
          items.where((item) => item['status'] == true).toList();

      setState(() {
        _products = activeProducts;
        _isLoading = false;
      });

      // Save the active products in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('stored_products', json.encode(activeProducts));

      if (widget.autoSelectProductName != null) {
        _autoSelectProduct(widget.autoSelectProductName!);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load products. Please try again.";
      });
    }
  }

  void _autoSelectProduct(String productName) {
    setState(() {
      _isSelecting = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      var product = _products.firstWhere(
        (p) => p['name'] == productName,
        orElse: () => null,
      );

      if (product != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              product: product,
              imagePath: getProductImage(product['name']),
            ),
          ),
        );
      } else {
        setState(() {
          _isSelecting = false;
        });
      }
    });
  }

  String getProductImage(String productName) {
    String lowerCaseName = productName.toLowerCase();

    if (lowerCaseName.contains("water bottle")) {
      return "assets/Water Bottle.png";
    } else if (lowerCaseName.contains("slim")) {
      return "assets/Slim Container with Water.png";
    } else if (lowerCaseName.contains("bilog")) {
      return "assets/Round Container with Water.png";
    }

    return "assets/default.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Available Items'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSelecting
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchProducts,
                              child: const Text("Refresh"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildProductList(),
    );
  }

  Widget _buildProductList() {
    return GridView.builder(
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

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetails(
                  product: product,
                  imagePath: getProductImage(product['name']),
                ),
              ),
            );
          },
          child: _buildProductItem(product),
        );
      },
    );
  }

  Widget _buildProductItem(dynamic product) {
    return Container(
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
              child: Image.asset(
                getProductImage(product['name']),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'PHP ${product['price']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
