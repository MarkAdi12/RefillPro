import 'dart:io';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  RxString selectedPaymentMethod = "Cash on Delivery".obs;
  Rx<File?> selectedFile = Rx<File?>(null); 

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void setProofFile(File file) {
    selectedFile.value = file;
  }

  void clearPaymentData() {
    selectedPaymentMethod.value = "Cash on Delivery";
    selectedFile.value = null;
  }


  Future<void> removeProofFile() async {
    if (selectedFile.value != null) {
      try {
        if (await selectedFile.value!.exists()) {
          await selectedFile.value!.delete(); 
          print("Proof file deleted successfully.");
        }
      } catch (e) {
        print("Error deleting proof file: $e");
      }
    }
    selectedFile.value = null; 
  }
}
