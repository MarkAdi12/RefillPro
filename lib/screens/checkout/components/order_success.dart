import 'package:flutter/material.dart';
import 'package:customer_frontend/screens/init_screen.dart'; 

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const InitScreen(initialIndex: 1)),
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
              "Order Placed Successfully!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
