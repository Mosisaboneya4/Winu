import 'package:flutter/material.dart';

class PillReminderScreen extends StatelessWidget {
  const PillReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pill Reminders')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Color(0xFF9B59B6)),
            SizedBox(height: 16),
            Text('Pill Reminders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
          ],
        ),
      ),
    );
  }
}
