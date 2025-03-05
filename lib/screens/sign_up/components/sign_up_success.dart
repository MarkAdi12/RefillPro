import 'package:flutter/material.dart';

import '../../login/sign_in_screen.dart';

class SignUpSuccess extends StatefulWidget {
  const SignUpSuccess({super.key});

  @override
  State<SignUpSuccess> createState() => _SignUpSuccessState();
}

class _SignUpSuccessState extends State<SignUpSuccess> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              "Sign Up Succesfully!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "You will be redirected to Sign In page....",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
             SizedBox(height: 12),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
