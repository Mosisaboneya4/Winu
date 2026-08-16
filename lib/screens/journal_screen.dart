import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Journal')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Color(0xFF9B59B6)),
            SizedBox(height: 16),
            Text('Health Journal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
          ],
        ),
      ),
    );
  }
}
