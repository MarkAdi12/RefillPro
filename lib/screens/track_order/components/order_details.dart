import 'package:flutter/material.dart';

import '../../checkout/components/payment_form.dart';

class OrderDetails extends StatelessWidget {
  final int currentStep;
  final String orderNo;
  final String customerName;
  final String status;
  final List<Map<String, dynamic>> orderItems;
  final String paymentStatus;

  const OrderDetails({
    super.key,
    required this.currentStep,
    required this.orderNo,
    required this.customerName,
    required this.status,
    required this.orderItems,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Order Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order #",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderNo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(thickness: 1, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Items",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Quantity",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Dynamic List for Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              final item = orderItems[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${item['quantity']}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            children: [
              Text('Payment:'),
              Spacer(),
              InkWell(
                onTap: () {
                  if (paymentStatus == "Payment Failed") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentForm(orderID: int.parse(orderNo))));
                  }
                },
                child: Text(
                  paymentStatus == "Payment Failed" ? 'Retry Payment' : paymentStatus,
                  style: TextStyle(
                    color: paymentStatus == "Payment Failed"
                        ? Colors.red
                        : Colors.black, 
                  ),
                ),
              ),
            ],
          ),

          Divider(thickness: 1, color: Colors.grey[300]),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: currentStep >= 1 ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep >= 1 ? Colors.grey : Colors.red,
              ),
              child: const Text(
                'Cancel Order',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
