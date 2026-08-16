import '../models/health_data.dart';

class PredictionEngine {
  DateTime? predictNextPeriod(List<PeriodEntry> periods) {
    if (periods.isEmpty) return null;
    if (periods.length < 2) return periods.first.startDate.add(const Duration(days: 28));

    final cycleLengths = <int>[];
    for (int i = 0; i < periods.length - 1; i++) {
      final days = periods[i + 1].startDate.difference(periods[i].startDate).inDays;
      if (days >= 21 && days <= 35) cycleLengths.add(days);
    }

    if (cycleLengths.isEmpty) return periods.first.startDate.add(const Duration(days: 28));
    final avg = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    return periods.first.startDate.add(Duration(days: avg.round()));
  }

  DateTime? predictOvulation(List<PeriodEntry> periods) {
    final nextPeriod = predictNextPeriod(periods);
    return nextPeriod?.subtract(const Duration(days: 14));
  }

  double calculateCycleRegularity(List<PeriodEntry> periods) {
    if (periods.length < 3) return 0.5;
    final cycleLengths = <int>[];
    for (int i = 0; i < periods.length - 1; i++) {
      final days = periods[i + 1].startDate.difference(periods[i].startDate).inDays;
      if (days >= 21 && days <= 35) cycleLengths.add(days);
    }
    if (cycleLengths.length < 2) return 0.5;
    final avg = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths.map((l) => (l - avg).abs()).reduce((a, b) => a + b) / cycleLengths.length;
    return (1 - (variance / 10)).clamp(0.0, 1.0);
  }

  int calculateAverageCycleLength(List<PeriodEntry> periods) {
    if (periods.length < 2) return 28;
    final cycleLengths = <int>[];
    for (int i = 0; i < periods.length - 1; i++) {
      final days = periods[i + 1].startDate.difference(periods[i].startDate).inDays;
      if (days >= 21 && days <= 35) {
        cycleLengths.add(days);
      }
    }
    if (cycleLengths.isEmpty) return 28;
    return (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();
  }

  HealthInsights generateInsights({
    required List<PeriodEntry> periods,
    required List<PillEntry> pills,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final avgCycle = calculateAverageCycleLength(periods);
    final regularity = calculateCycleRegularity(periods);
    final missedPills = pills.where((p) => p.status == PillStatus.missed).length;
    
    final trends = <String>[];
    final recommendations = <String>[];
    
    if (regularity > 0.8) {
      trends.add('Cycle is very regular');
    } else if (regularity < 0.5) {
      recommendations.add('Track stress to improve regularity');
    }
    
    if (missedPills > 2) {
      recommendations.add('Consider additional pill reminders');
    }

    return HealthInsights(
      period: periodStart,
      averageCycleLength: avgCycle,
      averagePeriodLength: 5,
      cycleRegularity: regularity,
      commonSymptoms: const [],
      averageMood: MoodType.neutral,
      averagePainLevel: 0.0,
      missedPillsCount: missedPills,
      latePillsCount: 0,
      trends: trends,
      recommendations: recommendations,
    );
  }
}
