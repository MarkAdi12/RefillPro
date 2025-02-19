import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/order_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Future<void> _cancelOrder(BuildContext context, String accessToken,
      int orderId, String remarks) async {
    final PlaceOrderService orderService = PlaceOrderService();
    final bool isCancelled =
        await orderService.cancelOrder(accessToken, orderId, remarks);

    if (isCancelled) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => InitScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to cancel order")),
      );
    }
  }

  Future<void> _showCancelReasonDialog(BuildContext context) async {
    String selectedReason = "Change of mind";
    List<String> reasons = [
      "Change of mind",
      "Ordered by mistake",
      "Delivery taking too long",
      "Other"
    ];
    TextEditingController otherReasonController = TextEditingController();

    String? confirmedReason = await showDialog<String>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Cancel Order",
            style: TextStyle(fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please select a reason for cancellation:", style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: selectedReason,
                isExpanded: true,
                onChanged: (String? newValue) {
                  selectedReason = newValue!;
                  (context as Element).markNeedsBuild();
                },
                items: reasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason, style: TextStyle(fontSize: 18),),
                  );
                }).toList(),
              ),
              if (selectedReason == "Other")
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: otherReasonController,
                    decoration: const InputDecoration(hintText: "Enter reason"),
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String finalReason = selectedReason == "Other"
                    ? otherReasonController.text.trim()
                    : selectedReason;
                Navigator.of(context).pop(finalReason.isNotEmpty
                    ? finalReason
                    : "No reason provided");
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirmedReason != null) {
      String? accessToken =
          await const FlutterSecureStorage().read(key: 'access_token');
      if (accessToken != null) {
        await _cancelOrder(
            context, accessToken, int.parse(orderNo), confirmedReason);
      }
    }
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Order #", orderNo),
              _buildInfoColumn("Customer", customerName),
              _buildInfoColumn("Status", status),
            ],
          ),
          const SizedBox(height: 8),
          Divider(thickness: 1, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Items",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text("Quantity",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ...orderItems.map((item) => _buildOrderItem(item)).toList(),
          Row(
            children: [
              const Text('Payment:'),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (paymentStatus == "Payment Failed") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PaymentForm(orderID: int.parse(orderNo))),
                    );
                  }
                },
                child: Text(
                  paymentStatus == "Payment Failed"
                      ? 'Retry Payment'
                      : paymentStatus,
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
              onPressed: currentStep >= 1
                  ? null
                  : () => _showCancelReasonDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep >= 1 ? Colors.grey : Colors.red,
              ),
              child: const Text(
                'Cancel Order',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(item['name'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text("${item['quantity']}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
