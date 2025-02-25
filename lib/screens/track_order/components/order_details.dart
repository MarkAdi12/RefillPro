import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/order_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../checkout/components/payment_form.dart';

class OrderDetails extends StatefulWidget {
  final int currentStep;
  final String orderNo;
  final String customerName;
  final String status;
  final List<Map<String, dynamic>> orderItems;
  final String paymentStatus;
  final String amount;

  const OrderDetails({
    super.key,
    required this.currentStep,
    required this.orderNo,
    required this.customerName,
    required this.status,
    required this.orderItems,
    required this.paymentStatus,
    required this.amount,
  });

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool _isOrderCancelled = false;
  String getStatusText(int status) {
    switch (status) {
      case 0:
        return "Pending";
      case 1:
        return "Preparing";
      case 3:
        return "In Transit";
      case 4:
        return "Completed";
      default:
        return "Unknown";
    }
  }

  Future<void> _cancelOrder(BuildContext context, String accessToken,
      int orderId, String remarks) async {
    final PlaceOrderService orderService = PlaceOrderService();
    final bool isCancelled =
        await orderService.cancelOrder(accessToken, orderId, remarks);

    if (isCancelled) {
      setState(() {
        _isOrderCancelled = true;
      });
      _showOrderCancelledDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to cancel order")),
      );
    }
  }

  void _showOrderCancelledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Order Cancelled", style: TextStyle(fontSize: 12)),
          content: const Text("Your order has been cancelled. Thank you!"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await const FlutterSecureStorage()
                    .delete(key: 'tracking_order_id');
                Navigator.of(context).pop();
                setState(() {
                  _isOrderCancelled = true;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => InitScreen()));
                });
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
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
          title: const Text("Cancel Order"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please select a reason for cancellation:"),
              DropdownButton<String>(
                value: selectedReason,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedReason = newValue!;
                  });
                },
                items: reasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
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
            context, accessToken, int.parse(widget.orderNo), confirmedReason);
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
              _buildInfoColumn("Order #", widget.orderNo),
              _buildInfoColumn("Customer", widget.customerName),
              _buildInfoColumn(
                  "Status", getStatusText(int.tryParse(widget.status) ?? 0)),
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
          ...widget.orderItems.map((item) => _buildOrderItem(item)).toList(),
          Row(
            children: [
              const Text('Payment:'),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (widget.paymentStatus == "Payment Failed") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentForm(
                                orderID: int.parse(widget.orderNo),
                                amount: widget.amount,
                              )),
                    );
                  }
                },
                child: Text(
                  widget.paymentStatus == "Payment Failed"
                      ? 'Retry Payment'
                      : widget.paymentStatus,
                  style: TextStyle(
                    color: widget.paymentStatus == "Payment Failed"
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
              onPressed: widget.currentStep >= 1 || _isOrderCancelled
                  ? null
                  : () => _showCancelReasonDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.currentStep >= 1 || _isOrderCancelled
                    ? Colors.grey
                    : Colors.red,
              ),
              child: const Text('Cancel Order', style: TextStyle(fontSize: 16)),
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
