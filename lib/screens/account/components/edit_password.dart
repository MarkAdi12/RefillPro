import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:customer_frontend/services/auth_service.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final AuthService _authService = AuthService();
  final _secureStorage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;
  String? currentPasswordError;
  bool _obscureCurrent = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? currentPassword;

  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentPassword();
  }

  Future<void> _getCurrentPassword() async {
    String? storedPassword = await _secureStorage.read(key: 'user_password');

    setState(() {
      currentPassword = storedPassword;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 capital letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    if (value != currentPassword) {
      return 'Current password is incorrect';
    }
    return null;
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
      errorMessage = null;
      currentPasswordError = null;
    });

    String? accessToken = await _secureStorage.read(key: 'access_token');

    if (accessToken == null) {
      setState(() {
        errorMessage = "No access token found. Please log in again.";
        isLoading = false;
      });
      return;
    }

    if (_passwordController.text == _currentPasswordController.text) {
      setState(() {
        currentPasswordError =
            "New password cannot be the same as the current password.";
        isLoading = false;
      });
      return;
    }

    final updatedData = {
      "password": _passwordController.text,
      "confirm_password": _confirmController.text,
    };

    try {
      final response = await _authService.editUser(accessToken, updatedData);
      if (response != null) {
        await _secureStorage.write(
            key: 'user_password', value: _passwordController.text);

        setState(() {
          isLoading = false; // Hide loading indicator
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully!")),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => InitScreen()));
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false; // Hide loading indicator on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Password'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Edit Password", style: headingStyle),
                  const Text(
                    "Enter your current and new password to update.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrent
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureCurrent = !_obscureCurrent;
                          });
                        },
                      ),
                    ),
                    validator: _validateCurrentPassword,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updatePassword,
                    child: const Text("Change Password"),
                  ),
                  if (currentPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        currentPasswordError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color:
                  Colors.black.withOpacity(0.5), // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
