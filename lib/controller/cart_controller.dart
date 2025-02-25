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
      if (index != -1) {
        cartItems[index]['quantity'] += item['quantity']; 
        cartItems[index]['totalPrice'] = cartItems[index]['price'] *
            cartItems[index]
                ['quantity']; 
      } else {
        cartItems.add({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'], 
          'quantity': item['quantity'],
          'totalPrice': item['price'] *
              item['quantity'], 
        });
      }
    }
    printOrderedItems();
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
