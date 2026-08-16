import 'package:flutter/material.dart';

// Period tracking model
@immutable
class PeriodEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int periodLength;
  final String? notes;
  final DateTime createdAt;

  const PeriodEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.periodLength,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PeriodEntry.fromMap(Map<String, dynamic> map) {
    return PeriodEntry(
      id: map['id'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      cycleLength: map['cycleLength'] as int,
      periodLength: map['periodLength'] as int,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

// Birth control pill tracking model
@immutable
class PillEntry {
  final String id;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final PillStatus status;
  final String? notes;
  final bool isSnoozed;
  final DateTime? snoozedUntil;

  const PillEntry({
    required this.id,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
    this.isSnoozed = false,
    this.snoozedUntil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'isSnoozed': isSnoozed ? 1 : 0,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
    };
  }

  factory PillEntry.fromMap(Map<String, dynamic> map) {
    return PillEntry(
      id: map['id'] as String,
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      takenTime: map['takenTime'] != null ? DateTime.parse(map['takenTime'] as String) : null,
      status: PillStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PillStatus.pending,
      ),
      notes: map['notes'] as String?,
      isSnoozed: (map['isSnoozed'] as int?) == 1,
      snoozedUntil: map['snoozedUntil'] != null ? DateTime.parse(map['snoozedUntil'] as String) : null,
    );
  }
}

enum PillStatus { pending, taken, missed, late, skipped }

// Pill schedule configuration
@immutable
class PillSchedule {
  final String id;
  final String pillName;
  final TimeOfDay reminderTime;
  final int pillCount; // Number of pills in pack
  final int activePills; // Number of active pills
  final int placeboPills; // Number of placebo pills
  final DateTime startDate;
  final bool isActive;
  final String? notes;

  const PillSchedule({
    required this.id,
    required this.pillName,
    required this.reminderTime,
    required this.pillCount,
    required this.activePills,
    required this.placeboPills,
    required this.startDate,
    this.isActive = true,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pillName': pillName,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
      'pillCount': pillCount,
      'activePills': activePills,
      'placeboPills': placeboPills,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'notes': notes,
    };
  }

  factory PillSchedule.fromMap(Map<String, dynamic> map) {
    return PillSchedule(
      id: map['id'] as String,
      pillName: map['pillName'] as String,
      reminderTime: TimeOfDay(
        hour: map['reminderHour'] as int,
        minute: map['reminderMinute'] as int,
      ),
      pillCount: map['pillCount'] as int,
      activePills: map['activePills'] as int,
      placeboPills: map['placeboPills'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      isActive: (map['isActive'] as int?) == 1,
      notes: map['notes'] as String?,
    );
  }
}

// Symptom tracking model
@immutable
class SymptomEntry {
  final String id;
  final DateTime date;
  final List<SymptomType> symptoms;
  final String? notes;
  final int severity; // 1-10 scale

  const SymptomEntry({
    required this.id,
    required this.date,
    required this.symptoms,
    this.notes,
    this.severity = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'symptoms': symptoms.map((s) => s.name).toList(),
      'notes': notes,
      'severity': severity,
    };
  }

  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    return SymptomEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      symptoms: (map['symptoms'] as List<dynamic>)
          .map((s) => SymptomType.values.firstWhere(
                (e) => e.name == s,
                orElse: () => SymptomType.cramps,
              ))
          .toList(),
      notes: map['notes'] as String?,
      severity: map['severity'] as int? ?? 5,
    );
  }
}

enum SymptomType {
  cramps,
  headache,
  bloating,
  moodSwings,
  fatigue,
  backPain,
  acne,
  breastTenderness,
  nausea,
  constipation,
  diarrhea,
  foodCravings,
  insomnia,
  hotFlashes,
  coldFlashes,
}

// Mood tracking model
@immutable
class MoodEntry {
  final String id;
  final DateTime date;
  final MoodType mood;
  final String? notes;
  final int energyLevel; // 1-10 scale
  final int stressLevel; // 1-10 scale

  const MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    this.notes,
    this.energyLevel = 5,
    this.stressLevel = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood.name,
      'notes': notes,
      'energyLevel': energyLevel,
      'stressLevel': stressLevel,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      mood: MoodType.values.firstWhere(
        (e) => e.name == map['mood'],
        orElse: () => MoodType.neutral,
      ),
      notes: map['notes'] as String?,
      energyLevel: map['energyLevel'] as int? ?? 5,
      stressLevel: map['stressLevel'] as int? ?? 5,
    );
  }
}

enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
  anxious,
  calm,
  energetic,
  tired,
  irritable,
}

// Pain tracking model
@immutable
class PainEntry {
  final String id;
  final DateTime date;
  final PainType painType;
  final int severity; // 0-10 scale
  final String? location;
  final String? notes;
  final DateTime? startTime;
  final DateTime? endTime;

  const PainEntry({
    required this.id,
    required this.date,
    required this.painType,
    required this.severity,
    this.location,
    this.notes,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'painType': painType.name,
      'severity': severity,
      'location': location,
      'notes': notes,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  factory PainEntry.fromMap(Map<String, dynamic> map) {
    return PainEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      painType: PainType.values.firstWhere(
        (e) => e.name == map['painType'],
        orElse: () => PainType.menstrual,
      ),
      severity: map['severity'] as int,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime'] as String) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
    );
  }
}

enum PainType {
  menstrual,
  headache,
  backPain,
  breastPain,
  abdominal,
  joint,
  muscle,
  other,
}

// Doctor appointment model
@immutable
class Appointment {
  final String id;
  final DateTime date;
  final TimeOfDay time;
  final String doctorName;
  final String specialization;
  final String? location;
  final String? notes;
  final bool reminderEnabled;
  final Duration? reminderBefore;
  final bool isCompleted;

  const Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.specialization,
    this.location,
    this.notes,
    this.reminderEnabled = true,
    this.reminderBefore,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'doctorName': doctorName,
      'specialization': specialization,
      'location': location,
      'notes': notes,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderBeforeMinutes': reminderBefore?.inMinutes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      time: TimeOfDay(
        hour: map['timeHour'] as int,
        minute: map['timeMinute'] as int,
      ),
      doctorName: map['doctorName'] as String,
      specialization: map['specialization'] as String,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      reminderEnabled: (map['reminderEnabled'] as int?) == 1,
      reminderBefore: map['reminderBeforeMinutes'] != null
          ? Duration(minutes: map['reminderBeforeMinutes'] as int)
          : null,
      isCompleted: (map['isCompleted'] as int?) == 1,
    );
  }
}

// Journal entry model
@immutable
class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final List<String>? tags;
  final String? mood;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    this.tags,
    this.mood,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'tags': tags,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      content: map['content'] as String,
      tags: map['tags'] != null ? List<String>.from(map['tags'] as List) : null,
      mood: map['mood'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }
}

// Health insights model
@immutable
class HealthInsights {
  final DateTime period;
  final int averageCycleLength;
  final int averagePeriodLength;
  final double cycleRegularity; // 0-1 scale
  final List<SymptomType> commonSymptoms;
  final MoodType averageMood;
  final double averagePainLevel;
  final int missedPillsCount;
  final int latePillsCount;
  final List<String> trends;
  final List<String> recommendations;

  const HealthInsights({
    required this.period,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.cycleRegularity,
    required this.commonSymptoms,
    required this.averageMood,
    required this.averagePainLevel,
    required this.missedPillsCount,
    required this.latePillsCount,
    required this.trends,
    required this.recommendations,
  });
}
