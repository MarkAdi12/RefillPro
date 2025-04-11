import 'dart:io';
import 'package:customer_frontend/screens/checkout/components/order_success.dart';
import 'package:customer_frontend/screens/init_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/payment_controller.dart';
import 'package:path/path.dart' as path;
import '../../../controller/cart_controller.dart';
import '../../../services/order_service.dart';
import '../../../services/payment_service.dart';

class ResubmitPayment extends StatefulWidget {
  final String amount;
  final int? paymentId; // Receive amount as a parameter
  const ResubmitPayment({super.key, this.paymentId, required this.amount});

  @override
  State<ResubmitPayment> createState() => _ResubmitPaymentState();
}

class _ResubmitPaymentState extends State<ResubmitPayment> {
  final PaymentController paymentController = Get.put(PaymentController());
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool isSubmitting = false;
  final CartController cartController = Get.put(CartController());

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
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true; // Disable the button
    });

    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      Get.snackbar("Error", "Authentication token not found.",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() {
        isSubmitting = false;
      });
      return;
    }

    if (paymentController.selectedFile.value == null) {
      Get.snackbar("Error", "Please upload proof of payment.",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() {
        isSubmitting = false;
      });
      return;
    }

    int? paymentsID = widget.paymentId;

    if (paymentsID == null) {
      print("❌ Error: paymentId is null ");
      return; // Exit the function to prevent calling resubmit with null values
    }

    bool success = await PaymentService.resubmit(
      paymentId: paymentsID, // No need for .toInt(), it's already an int
      proofFile: paymentController.selectedFile.value!,
      token: token,
    );

    if (success) {
      Get.snackbar("Success", "Payment submitted successfully.",
          backgroundColor: Colors.green, colorText: Colors.white);
      paymentController.clearPaymentData();
    }

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => InitScreen(
                  initialIndex: 1,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.amount);
    return Scaffold(
      appBar: AppBar(
        title: const Text("ReUpload Payment Proof"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Amount:", style: TextStyle(fontSize: 16)),
                widget.amount.isNotEmpty
                    ? Text("PHP ${widget.amount}")
                    : const CircularProgressIndicator()
              ],
            ),
            const Divider(),
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
                  onPressed: (paymentController.selectedFile.value == null ||
                          isSubmitting)
                      ? null
                      : submitPayment,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Reupload Proof of Payment"),
                )),
            const SizedBox(height: 10),
            const SizedBox(height: 40),
            Center(
              child: Container(
                height: 350,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey, // Light grey background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                alignment: Alignment.center, // Centers the text inside
                child: const Text(
                  "Gcash QR Place Holder",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54, // Slightly darker text
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
