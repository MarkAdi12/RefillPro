import 'package:customer_frontend/constants.dart';
import 'package:flutter/material.dart';

class FeedbackWidget {
  static void showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[50],
          title: const Text(
            "Provide Feedback",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.8, // Set the width here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FeedbackCategory(title: "Delivery Speed"),
                const SizedBox(height: 2),
                const FeedbackCategory(title: "Product Service"),
                const SizedBox(height: 2),
                const FeedbackCategory(title: "Overall Experience"),
                const SizedBox(height: 2),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Additional feedback...",
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeedbackCategory extends StatefulWidget {
  final String title;

  const FeedbackCategory({
    super.key,
    required this.title,
  });

  @override
  State<FeedbackCategory> createState() => _FeedbackCategoryState();
}

class _FeedbackCategoryState extends State<FeedbackCategory> {
  int selectedRating = 0; 

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  selectedRating = index + 1;
                });
              },
              icon: Icon(
                index < selectedRating
                    ? Icons.star
                    : Icons.star_border, 
                color: Colors.amber,
                size: 30,
              ),
            );
          }),
        ),
      ],
    );
  }
}
