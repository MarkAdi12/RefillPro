import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:get/get.dart';

class PlaceOrderService {
  static const String itemUrl = 'https://refillpro.store/api/v1/orders/';

  static Future<int?> placeOrder(String accessToken) async {
    final CartController cartController = Get.find();
    
    Map<String, dynamic> orderData = {
      "assigned_to": 1,
      "status": 0,
      "remarks": cartController.remarks.value,
      "order_details": cartController.cartItems.map((item) {
        return {
          "product": item["id"],
          "quantity": item["quantity"],
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(itemUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        int orderId = responseData['id']; 
        print("✅ Order placed successfully! Order ID: $orderId");
        return orderId;
      } else {
        print("❌ Failed to place order. Status: \${response.statusCode}");
        print("Response Body: \${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error placing order: \$e");
      return null;
    }
  }

  Future<bool> cancelOrder(String accessToken, int orderId, String remarks) async {
  final String updateOrderUrl = 'https://refillpro.store/api/v1/orders/$orderId/';
  try {
    final response = await http.post(
      Uri.parse(updateOrderUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'status': 5,
        'action': 'update',
        'remarks': remarks,
      }),
    );

    if (response.statusCode == 200) {
      print("Order cancelled successfully with reason: $remarks");
      return true;
    } else {
      print("Failed to cancel order: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error cancelling order: $e");
    return false;
  }
} 
}
