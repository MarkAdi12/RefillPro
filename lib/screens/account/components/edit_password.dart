import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:customer_frontend/constants.dart';
import 'package:flutter/material.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  Map<String, bool> isExpanded = {
    "Current Password": false,
    "New Password": true,
    "Confirm Password": true,
  };

  final Map<String, TextEditingController> controllers = {
    "Current Password": TextEditingController(),
    "New Password": TextEditingController(),
    "Confirm Password": TextEditingController(),
  };

  bool isLoading = false; // Tracks loading state
  String? errorMessage; // Tracks error messages

  void toggleExpand(String title) {
    setState(() {
      isExpanded[title] = !(isExpanded[title] ?? false);
    });
  }

  Future<void> updatePassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null; 
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null) // Display error message
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            _buildPasswordCard(
              title: "Current Password",
              controller: controllers["Current Password"]!,
              isExpanded: isExpanded["Current Password"] ?? false,
              onEdit: () => toggleExpand("Current Password"),
            ),
            const SizedBox(height: 16),
            _buildPasswordCard(
              title: "New Password",
              controller: controllers["New Password"]!,
              isExpanded: isExpanded["New Password"] ?? false,
              onEdit: () => toggleExpand("New Password"),
            ),
            const SizedBox(height: 16),
            _buildPasswordCard(
              title: "Confirm Password",
              controller: controllers["Confirm Password"]!,
              isExpanded: isExpanded["Confirm Password"] ?? false,
              onEdit: () => toggleExpand("Confirm Password"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : updatePassword,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard({
    required String title,
    required TextEditingController controller,
    required bool isExpanded,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (title == "Current Password") // Masked sample text
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "••••••••••••••••",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: kPrimaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8.0),
            TextField(
              controller: controller,
                decoration: InputDecoration(
                labelText: "Enter $title",
                labelStyle: const TextStyle(fontSize: 16, color: kPrimaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 28),
              ),
              style: const TextStyle(fontSize: 16),
              obscureText: true, // Masks text for passwords
              onSubmitted: (value) {
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }
}
