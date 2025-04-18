import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class PaymentService {
  static const String apiUrl = 'https://refillpro.store/api/v1/payments/';

  static Future<bool> submitPayment({
    required int orderId,
    String? amount, // Nullable Amount
    File? proofFile,
    required String token,
    required String paymentMethod,
    required String refCode,
    required String remarks,
    String? status, // Nullable Status
    int? paymentId, // Nullable Payment ID
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['order_id'] = orderId.toString()
        ..fields['payment_method'] = paymentMethod
        ..fields['ref_code'] = refCode
        ..fields['remarks'] = remarks;

      // Conditionally add optional fields
      if (amount != null) {
        request.fields['amount'] = amount;
      }
      if (status != null) {
        request.fields['status'] = status;
      }
      if (paymentId != null) {
        request.fields['payment_id'] = paymentId.toString();
      }

      // Attach proof file if available
      if (proofFile != null && proofFile.path.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('proof', proofFile.path));
      }

      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      print("📤 Response Body: $responseBody");

      // Accept both 200 OK and 201 Created as successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Payment submitted successfully!");
        return true;
      } else {
        print(
            "❌ Failed to submit payment. Status Code: ${response.statusCode}");
        print("❌ Response: $responseBody");
        return false;
      }
    } catch (e) {
      print("❌ Error submitting payment: $e");
      return false;
    }
  }

  static Future<bool> resubmit({
    required int paymentId,
    required File proofFile,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['payment_id'] = paymentId.toString()
        ..fields['status'] = "0";

      // Attach proof file
      if (proofFile.path.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('proof', proofFile.path));
      }

      var response = await request.send();
      String responseBody = await response.stream.bytesToString();
      print("📤 Response Body: $responseBody");

      // Accept both 200 OK and 201 Created as successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Payment resubmitted successfully!");
        return true;
      } else {
        print(
            "❌ Failed to resubmit payment. Status Code: ${response.statusCode}");
        print("❌ Response: $responseBody");
        return false;
      }
    } catch (e) {
      print("❌ Error resubmitting payment: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPayment(
      String accessToken, int orderId) async {
    final response = await http.get(
      Uri.parse('$apiUrl?order_id=$orderId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Failed to fetch payment data: ${response.body}');
      return null;
    }
  }
}
