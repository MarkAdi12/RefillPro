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

  bool _isLoading = false;
  String? _errorMessage;

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

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final tokens = await _authService.login(
      _phoneController.text,
      _passwordController.text,
    );

    if (tokens != null) {
      String accessToken = tokens['access'];

      print("✅ Access Token: $accessToken");

      await _secureStorage.write(key: 'access_token', value: accessToken);
      print("🔒 Token stored securely");

      final userData = await _authService.getUser(accessToken);
      if (userData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InitScreen()),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to fetch user data.";
        });
      }
    } else {
      setState(() {
        _errorMessage = "Login failed. Please check your credentials.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController..text = "mark1",
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: "Phone",
              labelStyle: TextStyle(color: kPrimaryColor),
              hintText: "Enter your number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: Icon(Icons.phone_iphone_rounded, size: 22),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController..text = "Teentitans1",
            decoration: const InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: kPrimaryColor),
              hintText: "Enter your password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: Icon(Icons.lock, size: 22),
            ),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
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