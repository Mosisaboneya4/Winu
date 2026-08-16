import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastPeriodStart;
  int _cycleLength = 28;
  int _periodLength = 5;
  List<DateTime> _periodDays = [];
  List<String> _symptoms = [];
  final List<String> _availableSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Mood Swings',
    'Fatigue',
    'Back Pain',
    'Acne',
    'Breast Tenderness',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPeriodStartStr = prefs.getString('lastPeriodStart');
    final cycleLength = prefs.getInt('cycleLength');
    final periodLength = prefs.getInt('periodLength');
    final symptomsJson = prefs.getString('symptoms');

    setState(() {
      if (lastPeriodStartStr != null) {
        _lastPeriodStart = DateTime.parse(lastPeriodStartStr);
        _calculatePeriodDays();
      }
      if (cycleLength != null) _cycleLength = cycleLength;
      if (periodLength != null) _periodLength = periodLength;
      if (symptomsJson != null) {
        _symptoms = List<String>.from(json.decode(symptomsJson));
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastPeriodStart != null) {
      await prefs.setString('lastPeriodStart', _lastPeriodStart!.toIso8601String());
    }
    await prefs.setInt('cycleLength', _cycleLength);
    await prefs.setInt('periodLength', _periodLength);
    await prefs.setString('symptoms', json.encode(_symptoms));
  }

  void _calculatePeriodDays() {
    if (_lastPeriodStart == null) return;
    
    _periodDays = [];
    for (int i = 0; i < _periodLength; i++) {
      _periodDays.add(_lastPeriodStart!.add(Duration(days: i)));
    }
  }

  DateTime? _getNextPeriodDate() {
    if (_lastPeriodStart == null) return null;
    return _lastPeriodStart!.add(Duration(days: _cycleLength));
  }

  DateTime? _getOvulationDate() {
    if (_lastPeriodStart == null) return null;
    return _lastPeriodStart!.add(Duration(days: _cycleLength - 14));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  Future<void> _logPeriodStart() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _lastPeriodStart = picked;
        _calculatePeriodDays();
      });
      await _saveData();
    }
  }

  void _showSymptomsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Symptoms'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableSymptoms.map((symptom) {
            return CheckboxListTile(
              title: Text(symptom),
              value: _symptoms.contains(symptom),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _symptoms.add(symptom);
                  } else {
                    _symptoms.remove(symptom);
                  }
                });
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Cycle Length'),
              subtitle: Text('$_cycleLength days'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCycleLength(),
              ),
            ),
            ListTile(
              title: const Text('Period Length'),
              subtitle: Text('$_periodLength days'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editPeriodLength(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCycleLength() async {
    final TextEditingController controller = TextEditingController(text: _cycleLength.toString());
    
    final int? newLength = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cycle Length'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter cycle length in days',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final int? value = int.tryParse(controller.text);
              if (value != null && value >= 21 && value <= 35) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newLength != null) {
      setState(() {
        _cycleLength = newLength;
      });
      await _saveData();
    }
  }

  Future<void> _editPeriodLength() async {
    final TextEditingController controller = TextEditingController(text: _periodLength.toString());
    
    final int? newLength = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Period Length'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter period length in days',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final int? value = int.tryParse(controller.text);
              if (value != null && value >= 2 && value <= 10) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newLength != null) {
      setState(() {
        _periodLength = newLength;
        _calculatePeriodDays();
      });
      await _saveData();
    }
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF9B59B6), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B59B6),
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E44AD),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextPeriod = _getNextPeriodDate();
    final ovulationDate = _getOvulationDate();
    final daysUntilNextPeriod = nextPeriod?.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Period Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Next Period',
                    nextPeriod != null
                        ? DateFormat('MMM dd, yyyy').format(nextPeriod)
                        : 'Not set',
                    daysUntilNextPeriod != null
                        ? '$daysUntilNextPeriod days left'
                        : '',
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Ovulation',
                    ovulationDate != null
                        ? DateFormat('MMM dd').format(ovulationDate)
                        : 'Not set',
                    '',
                    Icons.favorite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calendar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: _onDaySelected,
                  eventLoader: (day) {
                    if (_periodDays.any((d) => isSameDay(d, day))) {
                      return ['period'];
                    }
                    return [];
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF9B59B6).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Color(0xFF9B59B6),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Color(0xFF8E44AD),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Color(0xFF9B59B6)),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: Color(0xFF9B59B6),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _logPeriodStart,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Log Period'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showSymptomsDialog,
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Log Symptoms'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Symptoms Section
            if (_symptoms.isNotEmpty) ...[
              const Text(
                'Current Symptoms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B59B6),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                    children: _symptoms.map((symptom) {
                  return Chip(
                    label: Text(symptom),
                    backgroundColor: const Color(0xFF9B59B6).withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _symptoms.remove(symptom);
                      });
                      _saveData();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Info Card
            Card(
              color: const Color(0xFFF3E5F5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF9B59B6)),
                        SizedBox(width: 8),
                        Text(
                          'Cycle Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9B59B6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cycle Length: $_cycleLength days',
                      style: const TextStyle(color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Period Length: $_periodLength days',
                      style: const TextStyle(color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last Period: ${_lastPeriodStart != null ? DateFormat('MMM dd, yyyy').format(_lastPeriodStart!) : 'Not logged'}',
                      style: const TextStyle(color: Color(0xFF2C3E50)),
                    ),
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
