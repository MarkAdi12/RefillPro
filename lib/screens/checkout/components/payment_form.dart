import 'dart:io';
import 'package:customer_frontend/screens/checkout/components/order_success.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/controller/payment_controller.dart';
import 'package:path/path.dart' as path;
import '../../../controller/cart_controller.dart';
import '../../../services/order_service.dart';
import '../../../services/payment_service.dart';

class PaymentForm extends StatefulWidget {
  final String amount;
  final int? orderID;
  const PaymentForm({super.key, this.orderID, required this.amount});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
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

    int? orderID = widget.orderID;

    // ✅ Step 1: If there's no order ID, place the order first
    if (orderID == null) {
      orderID = await placeOrder(token);
      if (orderID == null) {
        Get.snackbar("Error", "Failed to place order.",
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() {
          isSubmitting = false;
        });
        return;
      }
    }

    bool success = await PaymentService.submitPayment(
      orderId: orderID,
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
    }

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
      );
    }
  }

  Future<int?> placeOrder(String token) async {
    try {
      String? accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        print("No access token found!");
      }
      int? newOrderID = await PlaceOrderService.placeOrder(accessToken!);

      if (newOrderID != null) {
        print("✅ Order placed successfully! Order ID: $newOrderID");
        await _secureStorage.write(
            key: 'tracking_order_id', value: newOrderID.toString());
        print('Tracking Order ID saved: $newOrderID');
        cartController.clearCart();
      }

      return newOrderID;
    } catch (e) {
      print("❌ Error placing order: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.amount);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Payment Proof"),
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
                      : const Text("Submit Payment & Place Order"),
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
