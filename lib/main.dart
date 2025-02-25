// ignore_for_file: unused_import
import 'package:customer_frontend/screens/init_screen.dart';
import 'package:customer_frontend/screens/otp/otp_screen.dart';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:customer_frontend/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'theme.dart'; 
import 'package:get/get.dart';
import 'package:customer_frontend/controller/cart_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();
  Get.put(CartController());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      theme: AppTheme.lightTheme(context), 
      home: const SignInScreen(), 
    );
  }
}


