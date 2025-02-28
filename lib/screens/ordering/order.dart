import 'package:flutter/material.dart';
import 'package:customer_frontend/services/item_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
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
  static List<dynamic> _productList = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (_productList.isNotEmpty) {
      setState(() {
        _products = _productList;
        _isLoading = false;
      });
      return;
    }

    // fetch product
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

      // store products
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

  String getProductImage(String productName) {
    Map<String, String> productImages = {
      "Round Container with Water": "assets/Round Container with Water.png",
      "Slim Container with Water": "assets/Slim Container with Water.png",
      "Water Bottle (500ml)": "assets/Water Bottle.png",
    };

    return productImages[productName] ?? "assets/default.png";
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
                                      ProductDetails(product: product, imagePath: getProductImage(product['name']),),
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
                                    child: Image.asset(
                                      getProductImage(product['name']),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 50, color: Colors.grey),
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
