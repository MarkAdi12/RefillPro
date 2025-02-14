import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderListService {
  static const String ordersUrl = 'https://refillpro.store/api/v1/orders/';

  Future<List<dynamic>> fetchOrders(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(ordersUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data; 
      } else {
        throw Exception('Failed to load orders. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return []; 
    }
  }
}
