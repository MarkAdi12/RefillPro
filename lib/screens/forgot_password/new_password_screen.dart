import 'package:flutter/material.dart';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:customer_frontend/services/auth_service.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<void> _resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    String token = tokenController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;
    // ✅ Frontend Validations
    if (token.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "All fields are required.";
        isLoading = false;
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters.";
        isLoading = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match.";
        isLoading = false;
      });
      return;
    }

    final response =
        await _authService.confirmPassword(token, newPassword, confirmPassword);
      setState(() {
      isLoading = false;
      if (response != null) {
        print("API Response: $response"); 
        if (response.containsKey('error')) {
          errorMessage = response['error'];
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      } else {
        errorMessage = "Failed to reset password. Please try again.";
      }
    });
  }

  @override
  void dispose() {
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: "Reset Token",
                hintText: "Enter reset token",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                hintText: "Enter your new password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Confirm your new password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Reset Password",
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
