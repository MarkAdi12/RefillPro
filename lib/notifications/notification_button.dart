import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

// Function to send a notification
Future<void> sendNotification() async {
  // FCM TOKEN
  String? fcmToken = await FirebaseMessaging.instance.getToken();
  // const String fcmToken = 'f9keAaESRXasmZGjUc0-UX:APA91bEhzcfDAlb3jkwJbRbYtvITUMNsl-HmRqGSo27lRMI2ZBH9nkHFxtsbIrQZtmkhkfQg_XE45zxGMlV3FRUNLsR5UHm1QaAG-ZoXpRuWNh5n59IEIN0';
  // Real Device const url = 'http://192.168.1.3:3000/send-notification';
  // Emulator
     const url = 'http://10.0.2.2:3000/send-notification';
  
  final data = {
    "token": fcmToken,
    "title": "TESTING LANG TROPA",
    "body": "TESTING LANG TO MAMEN"
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully!");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
