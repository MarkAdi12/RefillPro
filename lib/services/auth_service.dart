import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final String loginUrl = 'https://refillpro.store/api/v1/login/';
  final String userUrl = 'https://refillpro.store/api/v1/user/';

  // Login Function
  Future<Map<String, dynamic>?> login(String username, String password) async {
    // Post Request for username & password
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Login failed: ${response.body}');
      return null;
    }
  }

  // Sign in with custom token
  Future<User?> signInWithCustomToken(String token) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithCustomToken(token);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with custom token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser(String accessToken) async {
    final response = await http.get(
      Uri.parse(userUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch user data: ${response.body}');
      return null;
    }
  }

  // Edit User Details
  Future<Map<String, dynamic>?> editUser(String accessToken, Map<String, dynamic> updatedData) async {
    final response = await http.post(
      Uri.parse(userUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData), // Send the updated user data in the request body
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Return updated user data
    } else {
      print('Failed to update user data: ${response.body}');
      return null;
    }
  }

  final String logoutUrl = 'https://refillpro.store/api/v1/logout/';
  Future<bool> logout(String token) async {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Logout response: ${response.body}'); // Debugging

    if (response.statusCode == 200) {
      print('Logout successful');
      return true; // Indicate success
    } else {
      print('Logout failed: ${response.body}');
      return false; // Indicate failure
    }
  }
}
