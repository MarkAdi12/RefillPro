import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:customer_frontend/screens/cancellation/components/cancel_list.dart';
import 'package:flutter/material.dart';

class CancelScreen extends StatefulWidget {
  const CancelScreen({super.key});

  @override
  State<CancelScreen> createState() => _CancelScreenState();
}

class _CancelScreenState extends State<CancelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Cancellation'),
      body: CancelList(),
    );
  }
}