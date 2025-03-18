import 'dart:io';
import 'package:customer_frontend/screens/checkout/components/order_success.dart';
import 'package:customer_frontend/screens/init_screen.dart';
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
  bool isSubmitting = false; // Add this variable

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

    bool success = await PaymentService.submitPayment(
      orderId: widget.orderID,
      amount: widget.amount,
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

    setState(() {
      isSubmitting = false; // Re-enable the button after submission
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  "Payment Failure Notice",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                content: Text(
                    "Failure to provide proof of payment will set the payment method to Cash on Delivery."),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(false), // Stay on page
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InitScreen(
                                  initialIndex: 1,
                                ))),
                    child: const Text("OK"),
                  ),
                ],
              ),
            ) ??
            false;
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Upload Payment Proof"),
          automaticallyImplyLeading: false,
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
                  Text("₱${widget.amount}",
                      style: const TextStyle(fontSize: 16)),
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
                        : const Text("Submit Payment"),
                  )),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "If payment fails, the payment mode will\nbe set to Cash on Delivery.",
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
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
      ),
    );
  }
}
