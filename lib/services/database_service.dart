import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_data.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Period entries table
    await db.execute('''
      CREATE TABLE periods (
        id TEXT PRIMARY KEY,
        startDate TEXT NOT NULL,
        endDate TEXT,
        cycleLength INTEGER NOT NULL,
        periodLength INTEGER NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Pill entries table
    await db.execute('''
      CREATE TABLE pills (
        id TEXT PRIMARY KEY,
        scheduledTime TEXT NOT NULL,
        takenTime TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        isSnoozed INTEGER NOT NULL,
        snoozedUntil TEXT
      )
    ''');

    // Pill schedules table
    await db.execute('''
      CREATE TABLE pill_schedules (
        id TEXT PRIMARY KEY,
        pillName TEXT NOT NULL,
        reminderHour INTEGER NOT NULL,
        reminderMinute INTEGER NOT NULL,
        pillCount INTEGER NOT NULL,
        activePills INTEGER NOT NULL,
        placeboPills INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // Symptom entries table
    await db.execute('''
      CREATE TABLE symptoms (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        notes TEXT,
        severity INTEGER NOT NULL
      )
    ''');

    // Mood entries table
    await db.execute('''
      CREATE TABLE moods (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        mood TEXT NOT NULL,
        notes TEXT,
        energyLevel INTEGER NOT NULL,
        stressLevel INTEGER NOT NULL
      )
    ''');

    // Pain entries table
    await db.execute('''
      CREATE TABLE pain (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        painType TEXT NOT NULL,
        severity INTEGER NOT NULL,
        location TEXT,
        notes TEXT,
        startTime TEXT,
        endTime TEXT
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        timeHour INTEGER NOT NULL,
        timeMinute INTEGER NOT NULL,
        doctorName TEXT NOT NULL,
        specialization TEXT NOT NULL,
        location TEXT,
        notes TEXT,
        reminderEnabled INTEGER NOT NULL,
        reminderBeforeMinutes INTEGER,
        isCompleted INTEGER NOT NULL
      )
    ''');

    // Journal entries table
    await db.execute('''
      CREATE TABLE journal (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        mood TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  // Period CRUD operations
  Future<int> createPeriod(PeriodEntry period) async {
    final db = await database;
    return await db.insert('periods', period.toMap());
  }

  Future<PeriodEntry?> readPeriod(String id) async {
    final db = await database;
    final maps = await db.query(
      'periods',
      columns: ['id', 'startDate', 'endDate', 'cycleLength', 'periodLength', 'notes', 'createdAt'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PeriodEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PeriodEntry>> readAllPeriods() async {
    if (kIsWeb) return <PeriodEntry>[];
    final db = await database;
    final result = await db.query('periods', orderBy: 'startDate DESC');
    return result.map((json) => PeriodEntry.fromMap(json)).toList();
  }

  Future<int> updatePeriod(PeriodEntry period) async {
    final db = await database;
    return await db.update(
      'periods',
      period.toMap(),
      where: 'id = ?',
      whereArgs: [period.id],
    );
  }

  Future<int> deletePeriod(String id) async {
    final db = await database;
    return await db.delete(
      'periods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Pill CRUD operations
  Future<int> createPill(PillEntry pill) async {
    final db = await database;
    return await db.insert('pills', pill.toMap());
  }

  Future<PillEntry?> readPill(String id) async {
    final db = await database;
    final maps = await db.query(
      'pills',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PillEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PillEntry>> readAllPills() async {
    final db = await database;
    final result = await db.query('pills', orderBy: 'scheduledTime DESC');
    return result.map((json) => PillEntry.fromMap(json)).toList();
  }

  Future<List<PillEntry>> readPillsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.query(
      'pills',
      where: 'scheduledTime >= ? AND scheduledTime < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'scheduledTime ASC',
    );
    return result.map((json) => PillEntry.fromMap(json)).toList();
  }

  Future<int> updatePill(PillEntry pill) async {
    final db = await database;
    return await db.update(
      'pills',
      pill.toMap(),
      where: 'id = ?',
      whereArgs: [pill.id],
    );
  }

  Future<int> deletePill(String id) async {
    final db = await database;
    return await db.delete(
      'pills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Pill Schedule CRUD operations
  Future<int> createPillSchedule(PillSchedule schedule) async {
    final db = await database;
    return await db.insert('pill_schedules', schedule.toMap());
  }

  Future<PillSchedule?> readPillSchedule(String id) async {
    final db = await database;
    final maps = await db.query(
      'pill_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PillSchedule.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PillSchedule>> readAllPillSchedules() async {
    final db = await database;
    final result = await db.query('pill_schedules', where: 'isActive = ?', whereArgs: [1]);
    return result.map((json) => PillSchedule.fromMap(json)).toList();
  }

  Future<int> updatePillSchedule(PillSchedule schedule) async {
    final db = await database;
    return await db.update(
      'pill_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deletePillSchedule(String id) async {
    final db = await database;
    return await db.delete(
      'pill_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Symptom CRUD operations
  Future<int> createSymptom(SymptomEntry symptom) async {
    final db = await database;
    return await db.insert('symptoms', symptom.toMap());
  }

  Future<List<SymptomEntry>> readSymptomsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.query(
      'symptoms',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.map((json) => SymptomEntry.fromMap(json)).toList();
  }

  Future<List<SymptomEntry>> readAllSymptoms() async {
    final db = await database;
    final result = await db.query('symptoms', orderBy: 'date DESC');
    return result.map((json) => SymptomEntry.fromMap(json)).toList();
  }

  Future<int> updateSymptom(SymptomEntry symptom) async {
    final db = await database;
    return await db.update(
      'symptoms',
      symptom.toMap(),
      where: 'id = ?',
      whereArgs: [symptom.id],
    );
  }

  Future<int> deleteSymptom(String id) async {
    final db = await database;
    return await db.delete(
      'symptoms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mood CRUD operations
  Future<int> createMood(MoodEntry mood) async {
    final db = await database;
    return await db.insert('moods', mood.toMap());
  }

  Future<MoodEntry?> readMoodByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final maps = await db.query(
      'moods',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    if (maps.isNotEmpty) {
      return MoodEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MoodEntry>> readAllMoods() async {
    final db = await database;
    final result = await db.query('moods', orderBy: 'date DESC');
    return result.map((json) => MoodEntry.fromMap(json)).toList();
  }

  Future<int> updateMood(MoodEntry mood) async {
    final db = await database;
    return await db.update(
      'moods',
      mood.toMap(),
      where: 'id = ?',
      whereArgs: [mood.id],
    );
  }

  Future<int> deleteMood(String id) async {
    final db = await database;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Pain CRUD operations
  Future<int> createPain(PainEntry pain) async {
    final db = await database;
    return await db.insert('pain', pain.toMap());
  }

  Future<List<PainEntry>> readPainByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.query(
      'pain',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.map((json) => PainEntry.fromMap(json)).toList();
  }

  Future<List<PainEntry>> readAllPain() async {
    final db = await database;
    final result = await db.query('pain', orderBy: 'date DESC');
    return result.map((json) => PainEntry.fromMap(json)).toList();
  }

  Future<int> updatePain(PainEntry pain) async {
    final db = await database;
    return await db.update(
      'pain',
      pain.toMap(),
      where: 'id = ?',
      whereArgs: [pain.id],
    );
  }

  Future<int> deletePain(String id) async {
    final db = await database;
    return await db.delete(
      'pain',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointment CRUD operations
  Future<int> createAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<Appointment?> readAppointment(String id) async {
    final db = await database;
    final maps = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Appointment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Appointment>> readAllAppointments() async {
    final db = await database;
    final result = await db.query('appointments', orderBy: 'date ASC');
    return result.map((json) => Appointment.fromMap(json)).toList();
  }

  Future<List<Appointment>> readUpcomingAppointments() async {
    final db = await database;
    final now = DateTime.now();
    final result = await db.query(
      'appointments',
      where: 'date >= ? AND isCompleted = ?',
      whereArgs: [now.toIso8601String(), 0],
      orderBy: 'date ASC',
    );
    return result.map((json) => Appointment.fromMap(json)).toList();
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(String id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Journal CRUD operations
  Future<int> createJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal', entry.toMap());
  }

  Future<JournalEntry?> readJournalEntry(String id) async {
    final db = await database;
    final maps = await db.query(
      'journal',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return JournalEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<JournalEntry>> readAllJournalEntries() async {
    final db = await database;
    final result = await db.query('journal', orderBy: 'date DESC');
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  Future<List<JournalEntry>> readJournalEntriesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.query(
      'journal',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return result.map((json) => JournalEntry.fromMap(json)).toList();
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteJournalEntry(String id) async {
    final db = await database;
    return await db.delete(
      'journal',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
