import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:customer_frontend/screens/checkout/components/delivery_address.dart';
import 'package:customer_frontend/screens/checkout/components/payment.dart';
import 'package:customer_frontend/screens/checkout/components/place_order.dart';
import 'package:customer_frontend/screens/checkout/components/summary.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              DeliveryAddress(),
              PaymentMethodCard(),
              OrderSummary(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PlaceOrderCard(), 
    );
  }
}
