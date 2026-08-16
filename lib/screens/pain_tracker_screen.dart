import 'package:flutter/material.dart';

class PainTrackerScreen extends StatelessWidget {
  const PainTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pain Tracker')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.healing, size: 64, color: Color(0xFF9B59B6)),
            SizedBox(height: 16),
            Text('Pain Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
          ],
        ),
      ),
    );
  }
}
