import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'init_screen.dart'; 
import 'login/sign_in_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(Duration(seconds: 3));

    String? accessToken = await _secureStorage.read(key: 'access_token');

    if (accessToken != null && !_isTokenExpired(accessToken)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InitScreen()),
      );
    } else {
      await _logoutUser(); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  bool _isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  Future<void> _logoutUser() async {
    await _secureStorage.delete(key: 'access_token');
    print("🔓 Access token deleted");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF06297B),
        ),
        child: Image.asset(
          'assets/icon.png',
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
