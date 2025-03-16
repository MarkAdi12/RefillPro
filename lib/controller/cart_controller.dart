import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/services/item_service.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var remarks = "".obs;
  var isLoading = false.obs;

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
    printOrderedItems();
  }

  // Reorder items from order history
  Future<void> reorder(List<Map<String, dynamic>> orderItems) async {
    isLoading.value = true; // Start loading

    final ItemService itemService = ItemService();
    String? token = await FlutterSecureStorage().read(key: 'access_token');

    if (token == null) {
      print("⚠️ No authentication token found.");
      isLoading.value = false; // Stop loading
      return;
    }

    List<dynamic> latestItems = await itemService.getItems(token);

    for (var item in orderItems) {
      var latestItem = latestItems.firstWhere(
        (product) => product['id'] == item['id'],
        orElse: () => null,
      );

      if (latestItem == null) {
        print("⚠️ Item ${item['name']} not found.");
        continue;
      }

      double updatedPrice = double.parse(latestItem['price'].toString());
      final index =
          cartItems.indexWhere((cartItem) => cartItem['id'] == item['id']);
      int maxLimit = (item['name'] == "Water Bottle") ? 100 : 20;
      int newQuantity = item['quantity'];

      if (index != -1) {
        int currentQuantity = cartItems[index]['quantity'];
        int updatedQuantity = currentQuantity + newQuantity;

        if (updatedQuantity > maxLimit) {
          cartItems[index]['quantity'] = maxLimit;
        } else {
          cartItems[index]['quantity'] = updatedQuantity;
        }

        cartItems[index]['price'] = updatedPrice;
        cartItems[index]['totalPrice'] =
            updatedPrice * cartItems[index]['quantity'];
      } else {
        if (newQuantity > maxLimit) {
          newQuantity = maxLimit;
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

    printOrderedItems();
    isLoading.value = false; // Stop loading
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
                (item['quantity'] as int));
    return totalPrice.toStringAsFixed(2);
  }

  void clearCart() {
    cartItems.clear();
    update();
  }

  void increaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      String itemName = cartItems[index]['name'];
      int currentQuantity = cartItems[index]['quantity'];

      int maxLimit = itemName.toLowerCase().contains("water bottle") ? 100 : 20;

      // Log current quantity and limit for debugging
      print(
          "🛒 Item: $itemName | Current Qty: $currentQuantity | Limit: $maxLimit");

      if (currentQuantity >= maxLimit) {
        print(" Cannot add more. Reached limit of $maxLimit.");
        return; // Stop increasing if limit is reached
      }

      cartItems[index]['quantity'] += 1;
      update();
    }
  }

  void decreaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index]['quantity'] -= 1;

      if (cartItems[index]['quantity'] == 0) {
        cartItems.removeAt(index);
      }

      update();
    }
  }
}
