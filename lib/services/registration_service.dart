import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistrationService {
  static const String _baseUrl = "https://refillpro.store/api/v1/register/";

  // Method to register a new user
  Future<Map<String, dynamic>> registerUser ({
    required String username,
    required String password,
    required String confirmpassword,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required double lat,
    required double long,
  }) async {
    final Map<String, dynamic> payload = {
      'username': username,
      'password': password,
      'confirm_password': confirmpassword,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'address': address,
      'lat': lat,
      'long': long,
    };

    try {
      // POST request on API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // (successful creation)
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'User registered successfully!') {
          print('Registration successful');
          return responseData; 
        } else {
          return {'error': responseData['message'] ?? 'Unexpected response'};
        }
      } else {
        final responseData = json.decode(response.body);
        return {'error': responseData['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      print("Error: $e");
      return {'error': 'An error occurred: $e'};
    }
  }
}
