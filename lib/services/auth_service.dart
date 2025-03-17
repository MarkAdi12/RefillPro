import 'dart:async';
import 'dart:convert';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String loginUrl = 'https://refillpro.store/api/v1/login/';
  final String userUrl = 'https://refillpro.store/api/v1/user/';
  final String logoutUrl = 'https://refillpro.store/api/v1/logout/';
  final String requestUrl =
      'https://refillpro.store/api/v1/password-reset/request/';
  final String confirmpasswordUrl =
      'https://refillpro.store/api/v1/password-reset/confirm/';
  final _secureStorage = FlutterSecureStorage();
  Timer? _logoutTimer;

  // Start the logout timer based on the token's expiration time
  void startLogoutTimer(String accessToken, BuildContext context) {
    // Decode the token to get the expiration time
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    int expiry = decodedToken['exp']; // Expiration time in seconds
    var currentTime =
        DateTime.now().millisecondsSinceEpoch / 1000; // Current time in seconds

    // Calculate the remaining time until the token expires
    int remainingTime = (expiry - currentTime).round();

    // Print the remaining time and logout time
    print('Token will expire in: $remainingTime seconds');
    print(
        'Logout will occur at: ${DateTime.fromMillisecondsSinceEpoch(expiry * 1000)}');

    // Set a timer to log the user out when the token expires
    _logoutTimer = Timer(Duration(seconds: remainingTime), () async {
      await _logout(accessToken, context);
    });
  }

  // Cancel the logout timer
  void cancelLogoutTimer() {
    _logoutTimer?.cancel();
    print('Logout timer canceled');
  }

  // Logout function
  Future<void> _logout(String token, BuildContext context) async {
    try {
      // Call the API logout first
      bool apiLogoutSuccess = await logout(token);
      if (!apiLogoutSuccess) {
        throw Exception('API logout failed');
      }

      // Clear local data only if API logout is successful
      await _secureStorage.delete(key: 'access_token'); // Clear the token
      await _secureStorage.delete(key: 'user_data'); // Clear user data

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    } catch (e) {
      print('Error during logout: $e');
      // Optionally, show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

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
      UserCredential userCredential =
          await _firebaseAuth.signInWithCustomToken(token);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with custom token: $e');
      return null;
    }
  }

  // Get user data
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
  Future<Map<String, dynamic>?> editUser(
      String accessToken, Map<String, dynamic> updatedData) async {
    final response = await http.post(
      Uri.parse(userUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final responseData = jsonDecode(response.body);
      if (responseData['email'] != null && responseData['email'].isNotEmpty) {
        throw responseData['email'][0];
      } else if (responseData['username'] != null &&
          responseData['username'].isNotEmpty) {
        throw responseData['username'][0];
      } else {
        throw 'Failed to update user data: ${response.body}';
      }
    }
  }

  // API Logout

  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Logout response: ${response.body}');

      if (response.statusCode == 200) {
        print('Logout successful');
        return true;
      } else {
        print('Logout failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during API logout: $e');
      return false;
    }
  }

  // Request password reset

  Future<Map<String, dynamic>?> requestPassword(String email) async {
    // Request for new password
    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Request Failed: ${response.body}');
      return null;
    }
  }

  // Confirm password reset

  Future<Map<String, dynamic>?> confirmPassword(
      String token, String new_password, String confirm_password) async {
    // Request for new password
    final response = await http.post(
      Uri.parse(confirmpasswordUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'new_password': new_password,
        'confirm_password': confirm_password
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Request Failed: ${response.body}');
      return null;
    }
  }
}
