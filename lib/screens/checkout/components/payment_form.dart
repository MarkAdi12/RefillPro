import 'dart:io';
import 'package:customer_frontend/screens/checkout/components/order_success.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/payment_controller.dart';
import 'package:path/path.dart' as path;
import '../../../services/payment_service.dart';

class PaymentForm extends StatefulWidget {
  final String amount;
  final int orderID; // Receive amount as a parameter

  const PaymentForm({super.key, required this.orderID, required this.amount});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final PaymentController paymentController = Get.put(PaymentController());
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      paymentController.setProofFile(selectedFile);
    }
  }

  Future<void> submitPayment() async {
    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      Get.snackbar("Error", "Authentication token not found.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (paymentController.selectedFile.value == null) {
      Get.snackbar("Error", "Please upload proof of payment.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    bool success = await PaymentService.submitPayment(
      orderId: widget.orderID,
      amount: widget.amount, // Using widget.amount directly
      proofFile: paymentController.selectedFile.value!,
      token: token,
      paymentMethod: '1',
      remarks: '',
      refCode: '',
    );

    if (success) {
      Get.snackbar("Success", "Payment submitted successfully.",
          backgroundColor: Colors.green, colorText: Colors.white);
      paymentController.clearPaymentData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
      );
    } else {
      Get.snackbar("Error", "Failed to submit payment. Try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Payment Proof"), automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Amount:",
                    style: const TextStyle(
                      fontSize: 16,
                    )),
                Text("₱${widget.amount}", style: const TextStyle(fontSize: 16)),
              ],
            ),
            Divider(),
            const SizedBox(height: 10),
            Obx(() => paymentController.selectedFile.value == null
                ? const Text("No file selected")
                : Text(
                    "File: ${path.basename(paymentController.selectedFile.value!.path)}")),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Proof"),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: (paymentController.selectedFile.value == null)
                      ? null
                      : () async {
                          await submitPayment();
                        },
                  child: const Text("Submit Payment"),
                )),
          ],
        ),
      ),
    );
  }
}
