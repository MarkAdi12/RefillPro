import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemService {
  static const String itemUrl = 'https://refillpro.store/api/v1/products/';

  Future<List<dynamic>> getItems(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(itemUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to fetch items: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }
}
