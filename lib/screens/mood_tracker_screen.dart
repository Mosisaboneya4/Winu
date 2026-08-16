import 'package:flutter/material.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_satisfied, size: 64, color: Color(0xFF9B59B6)),
            SizedBox(height: 16),
            Text('Mood Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
          ],
        ),
      ),
    );
  }
}
