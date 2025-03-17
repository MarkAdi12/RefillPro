import 'dart:async';
import 'dart:convert';
import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../constants.dart';
import '../../forgot_password/forgot_password_screen.dart';

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>(); // Added form key

  bool _obscureText = true;
  bool _isLoading = false;
  bool _isLocked = false;
  int _failedAttempts = 0;
  String? _errorMessage;
  int _lockTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    String? storedToken = await _secureStorage.read(key: 'access_token');
    if (storedToken != null) {
      print("🔹 Retrieved Stored Token: $storedToken");
      final userData = await _authService.getUser(storedToken);
      if (userData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InitScreen()),
        );
      }
    }
  }

  void _startLockTimer() {
    setState(() {
      _isLocked = true;
      _lockTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockTime > 0) {
        setState(() {
          _lockTime--;
        });
      } else {
        setState(() {
          _isLocked = false;
          _isLoading = false;
        });
        _timer?.cancel();
      }
    });
  }

  void _unlock() {
    _timer?.cancel();
    setState(() {
      _isLocked = false;
      _failedAttempts = 0;
    });
  }

  void _login() async {
    if (_isLocked) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tokens = await _authService.login(
      _phoneController.text,
      _passwordController.text,
    );

    if (tokens != null) {
      setState(() {
        _failedAttempts = 0;
        _isLocked = false;
      });

      String accessToken = tokens['access'];
      print("Access Token: $accessToken");
      await _secureStorage.write(key: 'access_token', value: accessToken);

      final userData = await _authService.getUser(accessToken);
      if (userData != null) {
        await _secureStorage.write(
            key: 'user_data', value: jsonEncode(userData));

        String? fcmToken = await _secureStorage.read(key: 'fcm_token');
        if (fcmToken != null && fcmToken.isNotEmpty) {
          final updatedData = {"firebase_tokens": fcmToken};
          await _authService.editUser(accessToken, updatedData);
        }

        _authService.startLogoutTimer(accessToken, context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InitScreen()),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to retrieve user data.";
        });
      }
    } else {
      setState(() {
        _failedAttempts++;
        _errorMessage = "Login failed. Please check your credentials.";
      });

      if (_failedAttempts >= 3) {
        _startLockTimer();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
        );
        return;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: "Username",
              labelStyle: TextStyle(color: kPrimaryColor),
              hintText: "Enter your Username",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            obscureText: _obscureText,
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: kPrimaryColor),
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_isLocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Try Again in $_lockTime seconds",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_isLoading || _isLocked) ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Continue"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
