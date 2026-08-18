/// Dashboard summary for tasks
class TaskSummary {
  final int total;
  final int completed;
  final int pending;
  final double completionRate;

  const TaskSummary({
    required this.total,
    required this.completed,
    required this.pending,
    required this.completionRate,
  });

  factory TaskSummary.fromJson(Map<String, dynamic> json) {
    return TaskSummary(
      total: json['total'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'completed': completed,
    'pending': pending,
    'completionRate': completionRate,
  };
}

/// Summary of today's tasks
class TodayTaskSummary {
  final int total;
  final int completed;
  final int pending;

  const TodayTaskSummary({
    required this.total,
    required this.completed,
    required this.pending,
  });

  factory TodayTaskSummary.fromJson(Map<String, dynamic> json) {
    return TodayTaskSummary(
      total: json['total'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'completed': completed,
    'pending': pending,
  };
}

/// Notes summary
class NoteSummary {
  final int total;
  final int favorites;

  const NoteSummary({required this.total, required this.favorites});

  factory NoteSummary.fromJson(Map<String, dynamic> json) {
    return NoteSummary(
      total: json['total'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'total': total, 'favorites': favorites};
}

/// Summary of habits
class HabitSummary {
  final int total;
  final int completedToday;
  final int pendingToday;
  final double completionRate;

  const HabitSummary({
    required this.total,
    required this.completedToday,
    required this.pendingToday,
    required this.completionRate,
  });

  factory HabitSummary.fromJson(Map<String, dynamic> json) {
    return HabitSummary(
      total: json['total'] as int? ?? 0,
      completedToday: json['completedToday'] as int? ?? 0,
      pendingToday: json['pendingToday'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'completedToday': completedToday,
    'pendingToday': pendingToday,
    'completionRate': completionRate,
  };
}

/// Streak summary
class StreakSummary {
  final int bestCurrentStreak;

  const StreakSummary({required this.bestCurrentStreak});

  factory StreakSummary.fromJson(Map<String, dynamic> json) {
    return StreakSummary(
      bestCurrentStreak: json['bestCurrentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'bestCurrentStreak': bestCurrentStreak};
}

/// Weekly progress for a single day
class WeeklyProgress {
  final String date;
  final String day;
  final int tasksCompleted;
  final int habitsCompleted;

  const WeeklyProgress({
    required this.date,
    required this.day,
    required this.tasksCompleted,
    required this.habitsCompleted,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      date: json['date'] as String? ?? '',
      day: json['day'] as String? ?? '',
      tasksCompleted: json['tasksCompleted'] as int? ?? 0,
      habitsCompleted: json['habitsCompleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'day': day,
    'tasksCompleted': tasksCompleted,
    'habitsCompleted': habitsCompleted,
  };
}

/// Recent task displayed on dashboard
class DashboardTask {
  final String id;
  final String title;
  final bool completed;
  final String priority;
  final DateTime? dueDate;

  const DashboardTask({
    required this.id,
    required this.title,
    required this.completed,
    required this.priority,
    this.dueDate,
  });

  factory DashboardTask.fromJson(Map<String, dynamic> json) {
    return DashboardTask(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      dueDate: json['dueDate'] == null || (json['dueDate'] as String?) == ''
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    'priority': priority,
    if (dueDate != null) 'dueDate': dueDate?.toIso8601String(),
  };
}

/// Recent note displayed on dashboard
class DashboardNote {
  final String id;
  final String title;
  final String category;
  final bool isFavorite;
  final DateTime updatedAt;

  const DashboardNote({
    required this.id,
    required this.title,
    required this.category,
    required this.isFavorite,
    required this.updatedAt,
  });

  factory DashboardNote.fromJson(Map<String, dynamic> json) {
    return DashboardNote(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'isFavorite': isFavorite,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Habit displayed on dashboard
class DashboardHabit {
  final String id;
  final String name;
  final String category;
  final bool completedToday;
  final int currentStreak;

  const DashboardHabit({
    required this.id,
    required this.name,
    required this.category,
    required this.completedToday,
    required this.currentStreak,
  });

  factory DashboardHabit.fromJson(Map<String, dynamic> json) {
    return DashboardHabit(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      completedToday: json['completedToday'] as bool? ?? false,
      currentStreak: json['currentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'completedToday': completedToday,
    'currentStreak': currentStreak,
  };
}

/// Complete dashboard model
class DashboardModel {
  final String greeting;
  final String date;
  final TaskSummary tasks;
  final TodayTaskSummary todayTasks;
  final NoteSummary notes;
  final HabitSummary habits;
  final StreakSummary streaks;
  final List<WeeklyProgress> weeklyProgress;
  final List<DashboardTask> recentTasks;
  final List<DashboardNote> recentNotes;
  final List<DashboardHabit> todayHabits;

  const DashboardModel({
    required this.greeting,
    required this.date,
    required this.tasks,
    required this.todayTasks,
    required this.notes,
    required this.habits,
    required this.streaks,
    required this.weeklyProgress,
    required this.recentTasks,
    required this.recentNotes,
    required this.todayHabits,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      greeting: json['greeting'] as String? ?? 'Good day',
      date: json['date'] as String? ?? '',
      tasks: TaskSummary.fromJson(json['tasks'] as Map<String, dynamic>? ?? {}),
      todayTasks: TodayTaskSummary.fromJson(
        json['todayTasks'] as Map<String, dynamic>? ?? {},
      ),
      notes: NoteSummary.fromJson(json['notes'] as Map<String, dynamic>? ?? {}),
      habits: HabitSummary.fromJson(
        json['habits'] as Map<String, dynamic>? ?? {},
      ),
      streaks: StreakSummary.fromJson(
        json['streaks'] as Map<String, dynamic>? ?? {},
      ),
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>? ?? [])
          .map((item) => WeeklyProgress.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentTasks: (json['recentTasks'] as List<dynamic>? ?? [])
          .map((item) => DashboardTask.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentNotes: (json['recentNotes'] as List<dynamic>? ?? [])
          .map((item) => DashboardNote.fromJson(item as Map<String, dynamic>))
          .toList(),
      todayHabits: (json['todayHabits'] as List<dynamic>? ?? [])
          .map((item) => DashboardHabit.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'greeting': greeting,
    'date': date,
    'tasks': tasks.toJson(),
    'todayTasks': todayTasks.toJson(),
    'notes': notes.toJson(),
    'habits': habits.toJson(),
    'streaks': streaks.toJson(),
    'weeklyProgress': weeklyProgress.map((item) => item.toJson()).toList(),
    'recentTasks': recentTasks.map((item) => item.toJson()).toList(),
    'recentNotes': recentNotes.map((item) => item.toJson()).toList(),
    'todayHabits': todayHabits.map((item) => item.toJson()).toList(),
  };
}
