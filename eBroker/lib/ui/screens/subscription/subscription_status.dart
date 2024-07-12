import 'package:flutter/material.dart';

enum SubscriptionStaus { success, failed }

class SubscriptionStatusScreen extends StatelessWidget {
  final SubscriptionStaus status;
  const SubscriptionStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text("Success"),
        ),
      );
}
