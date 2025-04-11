import 'package:customer_frontend/screens/checkout/checkout.dart';
import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';

class OrderHistoryWidgets {
  static Widget buildOrderDetail(String value) {
    String truncatedValue =
        value.length > 40 ? '${value.substring(0, 37)}...' : value;
    return Text(
      truncatedValue,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }

  static Widget buildOrderItems(List<dynamic> items) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Order Details:",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final truncatedName = item['name'].length > 25
                ? "${item['name'].substring(0, 25)}..."
                : item['name'];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${item['quantity']} x $truncatedName",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "PHP ${item['price'].toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static Widget buildTotalSection(double subtotal) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              "PHP ${subtotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  void showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Reorder Successful!",
            style: TextStyle(fontSize: 18),
          ),
          content: const Text("Do you want to proceed to checkout?",
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No", style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => CheckoutScreen()));
              },
              child: const Text("Yes", style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  void showFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Reorder Failed!",
            style: TextStyle(fontSize: 18),
          ),
          content: const Text(
              "Your previous order can't be reordered due to item(s) being unavailable",
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => InitScreen()));
              },
              child: const Text("OK", style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }
}
