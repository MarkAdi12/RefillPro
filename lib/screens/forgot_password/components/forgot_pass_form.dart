import 'package:customer_frontend/screens/forgot_password/new_password_screen.dart';
import 'package:flutter/material.dart';
import '../../../components/no_account_text.dart';
import 'package:customer_frontend/services/auth_service.dart';

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage; // Store error message
  String? email;

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await _authService.requestPassword(emailController.text.trim());
    setState(() {
      email = emailController.text.trim();
      isLoading = false;
      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                    fromForgotPassword: true,
                    email: email!,
                  )),
        );
      } else {
        errorMessage = "No account found with this email.";
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align error text
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email cannot be empty";
              } else if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value)) {
                return "Enter a valid email";
              }
              return null;
            },
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: errorMessage ==
                            "Password reset link sent! Check your email."
                        ? Colors.green
                        : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _requestPasswordReset,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Continue"),
          ),
          const SizedBox(height: 16),
          const NoAccountText(),
        ],
      ),
    );
  }
}
