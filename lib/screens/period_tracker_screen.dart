import 'package:flutter/material.dart';

class PeriodTrackerScreen extends StatelessWidget {
  const PeriodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Period Tracker')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Color(0xFF9B59B6)),
            SizedBox(height: 16),
            Text('Period Tracker', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
          ],
        ),
      ),
    );
  }
}
