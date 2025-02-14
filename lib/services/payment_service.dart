import 'dart:io';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String apiUrl = 'https://refillpro.store/api/v1/payments/';

  static Future<bool> submitPayment({
    required int orderId,
    required String amount,
    required File proofFile,
    required String token,
    required String paymentMethod, // Added
    required String refCode, // Added
    required String remarks, // Added
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['order_id'] = orderId.toString()
        ..fields['amount'] = amount
        ..fields['payment_method'] = paymentMethod
        ..fields['ref_code'] = refCode
        ..fields['remarks'] = remarks
        ..files.add(await http.MultipartFile.fromPath('proof', proofFile.path)); // ✅ Use 'proof'

      var response = await request.send();

  
      String responseBody = await response.stream.bytesToString();
      print("📤 Response Body: $responseBody");

      if (response.statusCode == 201) {
        print("✅ Payment submitted successfully!");
        return true;
      } else {
        print("❌ Failed to submit payment. Status Code: ${response.statusCode}");
        print("❌ Response: $responseBody");
        return false;
      }
    } catch (e) {
      print("❌ Error submitting payment: $e");
      return false;
    }
  }
}
