import 'package:customer_frontend/constants.dart';
import 'package:flutter/material.dart';

class CancelList extends StatefulWidget {
  const CancelList({super.key});

  @override
  State<CancelList> createState() => _CancelListState();
}

class _CancelListState extends State<CancelList> {
  String? selectedReason;

  final List<String> reasons = [
    "Change of mind",
    "Order placed by mistake",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
          const Text(
            "Tell us the reason for cancellation by choosing one of the options below",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reasons.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                value: reasons[index],
                groupValue: selectedReason,
                onChanged: (value) {
                  setState(() {
                    selectedReason = value;
                  });
                },
                activeColor: kPrimaryColor,
                title: Text(
                  reasons[index],
                  style:  TextStyle(fontSize: 16),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: selectedReason == null
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'Confirm Cancellation',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Are you sure you want to cancel the order for the selected reason?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedReason == null ? Colors.grey : kPrimaryColor,
                ),
                child: const Text("Submit"),
              )),
        ],
      ),
    );
  }
}
