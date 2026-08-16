import 'package:flutter/material.dart';

class SymptomTrackerScreen extends StatelessWidget {
  const SymptomTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Tracker')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sick, size: 64, color: Color(0xFF9B59B6)),
            SizedBox(height: 16),
            Text('Symptom Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
          ],
        ),
      ),
    );
  }
}
