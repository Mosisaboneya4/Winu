import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/prediction_engine.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  DateTime? _nextPeriod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final periods = await DatabaseService.instance.readAllPeriods();
    final nextPeriod = PredictionEngine().predictNextPeriod(periods);
    setState(() {
      _nextPeriod = nextPeriod;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9B59B6)))
          : IndexedStack(index: _selectedIndex, children: [
              _buildHome(),
              const CalendarScreen(),
              // simple placeholder for Insights
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.insights, size: 64, color: Color(0xFF9B59B6)),
                    SizedBox(height: 16),
                    Text('Insights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
                  ],
                ),
              ),
              const SettingsScreen(),
            ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF9B59B6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFF3E5F5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Cycle Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9B59B6))),
                    const SizedBox(height: 16),
                    if (_nextPeriod != null)
                      Text('Next Period: ${DateFormat('MMM d, yyyy').format(_nextPeriod!)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
