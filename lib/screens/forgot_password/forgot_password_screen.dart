import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'components/forgot_pass_form.dart';

class ForgotPasswordScreen extends StatelessWidget {

  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: const CustomAppBar(title: "Reset Password"),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Please enter your email and we will send \nyou a link to return to your account",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ForgotPassForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
