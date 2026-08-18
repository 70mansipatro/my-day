class HabitLogModel {
  final String date;
  final bool completed;

  const HabitLogModel({required this.date, required this.completed});

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      date: json['date']?.toString() ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }
}
