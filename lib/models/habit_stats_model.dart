class HabitStatsModel {
  final int currentStreak;
  final int bestStreak;
  final int completionRate;
  final int completedDays;
  final int totalTrackedDays;

  const HabitStatsModel({
    required this.currentStreak,
    required this.bestStreak,
    required this.completionRate,
    required this.completedDays,
    required this.totalTrackedDays,
  });

  factory HabitStatsModel.fromJson(Map<String, dynamic> json) {
    return HabitStatsModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      completedDays: json['completedDays'] as int? ?? 0,
      totalTrackedDays: json['totalTrackedDays'] as int? ?? 0,
    );
  }
}
