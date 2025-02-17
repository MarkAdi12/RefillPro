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
        throw Exception(
            'Failed to load orders. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

 Future retrievePayment(String accessToken, int orderId) async {
  final String paymentUrl =
      'https://refillpro.store/api/v1/rider/payments/$orderId/';

  print('Request URL: $paymentUrl');
  try {
    final response = await http.get(
      Uri.parse(paymentUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        print("Received list of payments: $data");

        // Sort payments by `created_at` or `updated_at` in descending order
        data.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['created_at'] ?? a['updated_at']);
          final DateTime dateB = DateTime.parse(b['created_at'] ?? b['updated_at']);
          return dateB.compareTo(dateA); // Sort in descending order
        });

        // Return the latest payment
        return data[0];
      } else if (data is Map) {
        // If it's a single payment, return it as is
        print("Received single payment: $data");
        return data;
      } else {
        print("Unexpected response format: $data");
        return null;
      }
    } else {
      print("Failed to retrieve payment: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error retrieving payment: $e");
    return null;
  }
}
}
