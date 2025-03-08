import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var remarks = "".obs;

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
  void reorder(List<Map<String, dynamic>> orderItems) {
    for (var item in orderItems) {
      final index =
          cartItems.indexWhere((cartItem) => cartItem['id'] == item['id']);

      int maxLimit = (item['name'] == "Water Bottle") ? 100 : 20;
      int newQuantity = item['quantity']; // Quantity being added

      if (index != -1) {
        // Existing item: Check the total after adding
        int currentQuantity = cartItems[index]['quantity'];
        int updatedQuantity = currentQuantity + newQuantity;

        if (updatedQuantity > maxLimit) {
          print(
              "🚫 Cannot reorder ${item['name']}. Max limit of $maxLimit reached.");
          cartItems[index]['quantity'] = maxLimit; // Set to limit
        } else {
          cartItems[index]['quantity'] = updatedQuantity;
        }

        // Update total price
        cartItems[index]['totalPrice'] =
            cartItems[index]['price'] * cartItems[index]['quantity'];
      } else {
        // New item: Ensure it doesn't exceed the limit
        if (newQuantity > maxLimit) {
          print(
              "⚠️ Adjusting quantity of ${item['name']} to max limit $maxLimit.");
          newQuantity = maxLimit;
        }

        cartItems.add({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'quantity': newQuantity,
          'totalPrice': item['price'] * newQuantity,
        });
      }
    }
    printOrderedItems(); // Ensure updated cart prints correctly
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
