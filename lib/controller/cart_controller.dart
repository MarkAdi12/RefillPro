import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/services/item_service.dart';

class CartController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  var cartItems = <Map<String, dynamic>>[].obs;
  var remarks = "".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      final cartData = await _secureStorage.read(key: 'cart_items');
      if (cartData != null) {
        final List<dynamic> decoded = json.decode(cartData);
        cartItems.assignAll(decoded.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  Future<void> _saveCartItems() async {
    try {
      await _secureStorage.write(
        key: 'cart_items',
        value: json.encode(cartItems),
      );
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  void addToCart(Map<String, dynamic> product) {
    final index =
        cartItems.indexWhere((cartItem) => cartItem['id'] == product['id']);

    if (index != -1) {
      cartItems[index]['quantity'] += 1;
    } else {
      var newProduct = {
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      };
      cartItems.add(newProduct);
    }
    _saveCartItems();
    printOrderedItems();
  }

  Future<bool> reorder(List<Map<String, dynamic>> orderItems) async {
    isLoading.value = true;
    final ItemService itemService = ItemService();
    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      print("⚠️ No authentication token found.");
      isLoading.value = false;
      return false;
    }

    List<dynamic> latestItems = await itemService.getItems(token);
    bool itemNotFound = false;

    for (var item in orderItems) {
      var latestItem = latestItems.firstWhere(
        (product) => product['id'] == item['id'],
        orElse: () => null,
      );

      if (latestItem == null) {
        print("⚠️ Item ${item['name']} not found.");
        itemNotFound = true;
        continue;
      }

      double updatedPrice = double.parse(latestItem['price'].toString());
      final index =
          cartItems.indexWhere((cartItem) => cartItem['id'] == item['id']);
      int maxLimit =
          item['name'].toLowerCase().contains('water bottle') ? 100 : 20;
      int stockLimit = latestItem['stock'] ?? maxLimit;
      int limit = (stockLimit < maxLimit) ? stockLimit : maxLimit;
      int newQuantity = item['quantity'];

      if (index != -1) {
        int currentQuantity = cartItems[index]['quantity'];
        int updatedQuantity = currentQuantity + newQuantity;

        if (updatedQuantity > limit) {
          cartItems[index]['quantity'] = limit;
          print("⚠️ Reached the limit of $limit for ${item['name']}.");
        } else {
          cartItems[index]['quantity'] = updatedQuantity;
        }

        cartItems[index]['price'] = updatedPrice;
        cartItems[index]['totalPrice'] =
            updatedPrice * cartItems[index]['quantity'];
      } else {
        if (newQuantity > limit) {
          newQuantity = limit;
          print("⚠️ Reached the limit of $limit for ${item['name']}.");
        }

        cartItems.add({
          'id': item['id'],
          'name': item['name'],
          'price': updatedPrice,
          'quantity': newQuantity,
          'totalPrice': updatedPrice * newQuantity,
        });
      }
    }

    await _saveCartItems();
    isLoading.value = false;
    return !itemNotFound;
  }

  int getQuantity(int productId) {
    var item = cartItems.firstWhere(
      (cartItem) => cartItem['id'] == productId,
      orElse: () => {},
    );
    return item.isNotEmpty ? item['quantity'] : 0;
  }

  void printOrderedItems() {
    print('🛒 Ordered Items:');
    for (var item in cartItems) {
      print('${item['name']} - ₱${item['price']} x ${item['quantity']}');
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      _saveCartItems();
      update();
    }
  }

  void updateRemarks(String newRemarks) {
    remarks.value = newRemarks;
  }

  String calculateTotal() {
    double totalPrice = cartItems.fold(
      0,
      (sum, item) =>
          sum +
          (double.tryParse(item['price'].toString()) ?? 0) *
              (item['quantity'] as int),
    );
    return totalPrice.toStringAsFixed(2);
  }

  void clearCart() {
    cartItems.clear();
    _secureStorage.delete(key: 'cart_items');
    update();
  }

  void increaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      String itemName = cartItems[index]['name'];
      int currentQuantity = cartItems[index]['quantity'];

      int maxLimit = itemName.toLowerCase().contains("water bottle") ? 100 : 20;

      print(
          "🛒 Item: $itemName | Current Qty: $currentQuantity | Limit: $maxLimit");

      if (currentQuantity >= maxLimit) {
        print(" Cannot add more. Reached limit of $maxLimit.");
        return;
      }

      cartItems[index]['quantity'] += 1;
      _saveCartItems();
      update();
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index]['quantity'] = newQuantity;
      _saveCartItems();
      update();
    }
  }

  void decreaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index]['quantity'] -= 1;

      if (cartItems[index]['quantity'] == 0) {
        cartItems.removeAt(index);
      }

      _saveCartItems();
      update();
    }
  }
}
