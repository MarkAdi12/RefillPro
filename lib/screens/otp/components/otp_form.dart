import 'package:customer_frontend/screens/forgot_password/new_password_screen.dart';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class OtpForm extends StatefulWidget {
  final String flowType;

  const OtpForm({super.key, required this.flowType});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  FocusNode? pin2FocusNode;
  FocusNode? pin3FocusNode;
  FocusNode? pin4FocusNode;

  @override
  void initState() {
    super.initState();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
  }

  @override
  void dispose() {
    pin2FocusNode!.dispose();
    pin3FocusNode!.dispose();
    pin4FocusNode!.dispose();
    super.dispose();
  }

  void nextField(String value, FocusNode? focusNode) {
    if (value.length == 1) {
      focusNode!.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 40), // Reduced height
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    autofocus: true,
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value) {
                      nextField(value, pin2FocusNode);
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    focusNode: pin2FocusNode,
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value) => nextField(value, pin3FocusNode),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    focusNode: pin3FocusNode,
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value) => nextField(value, pin4FocusNode),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    focusNode: pin4FocusNode,
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: otpInputDecoration,
                    onChanged: (value) {
                      if (value.length == 1) {
                        pin4FocusNode!.unfocus();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
                if (widget.flowType == "register") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  );
                } else if (widget.flowType == "resetPassword") {
                  
                }
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
