import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/controller/payment_controller.dart';

class PaymentMethodCard extends StatefulWidget {
  const PaymentMethodCard({super.key});

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  final PaymentController paymentController = Get.put(PaymentController());

  void showPaymentOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Choose Payment Option',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Cash on Delivery',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  paymentController.setPaymentMethod('Cash on Delivery');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'Online Payment',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  paymentController.setPaymentMethod('Online Payment');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Payment Method',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paymentController.selectedPaymentMethod.value,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  paymentController.selectedPaymentMethod.value ==
                                          'Cash on Delivery'
                                      ? 'Pay when you receive the order'
                                      : 'Pay online securely',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            )),
                      ),
                      TextButton(
                        onPressed: () => showPaymentOptions(context),
                        child: Text(
                          'Change',
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
