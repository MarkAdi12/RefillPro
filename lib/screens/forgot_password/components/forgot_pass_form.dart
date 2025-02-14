import 'package:customer_frontend/screens/otp/otp_screen.dart';
import 'package:flutter/material.dart';
import '../../../components/no_account_text.dart';

class ForgotPassForm extends StatelessWidget {
  const ForgotPassForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone",
              hintText: "Enter your phone number",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: Icon(Icons.phone_iphone_rounded, size: 22),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(flowType: "register"),));
            },
            child: const Text("Continue"),
          ),
          const SizedBox(height: 16),
          const NoAccountText(),
        ],
      ),
    );
  }
}