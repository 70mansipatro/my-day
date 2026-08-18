import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../models/task_model.dart';

/// Task progress card
class TaskProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double completionRate;
  final VoidCallback? onViewTapped;

  const TaskProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.completionRate,
    this.onViewTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.peach100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.peach900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$completed / $total completed',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewTapped,
                child: const Text('View Tasks'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Habit progress card
class HabitProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double completionRate;
  final int bestStreak;
  final VoidCallback? onViewTapped;

  const HabitProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.completionRate,
    required this.bestStreak,
    this.onViewTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Habits",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.peach100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.peach900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$completed / $total completed',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppColors.peach900,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Best current streak: $bestStreak days',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewTapped,
                child: const Text('View Habits'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notes summary card
class NotesSummaryCard extends StatelessWidget {
  final int total;
  final int favorites;
  final VoidCallback? onViewTapped;

  const NotesSummaryCard({
    super.key,
    required this.total,
    required this.favorites,
    this.onViewTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.note_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$total Notes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$favorites Favorites',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
                Icon(
                  Icons.favorite,
                  color: Colors.red.withValues(alpha: 0.6),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewTapped,
                child: const Text('View Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weekly progress visualization card
class WeeklyProgressCard extends StatelessWidget {
  final List<({String day, int value})> data;

  const WeeklyProgressCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxHeight = maxValue > 0 ? maxValue.toDouble() : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (index) {
                final item = data[index];
                final height = (item.value / maxHeight) * 100;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.value.toString(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.peach500,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.day,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent activity item
class RecentActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? time;
  final Color? iconColor;

  const RecentActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.time,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.peach900).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.peach900, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (time != null)
            Text(
              time!,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.gray400),
            ),
        ],
      ),
    );
  }
}

/// Quick actions section
class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddNote;
  final VoidCallback onAddHabit;

  const QuickActionsRow({
    super.key,
    required this.onAddTask,
    required this.onAddNote,
    required this.onAddHabit,
  });

  static ButtonStyle get _style => OutlinedButton.styleFrom(
    side: const BorderSide(color: AppColors.peach500),
    foregroundColor: AppColors.peach900,
    backgroundColor: Colors.transparent,
    overlayColor: AppColors.peach100,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: _style,
            icon: const Icon(Icons.add),
            label: const Text('Task'),
            onPressed: onAddTask,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: _style,
            icon: const Icon(Icons.add),
            label: const Text('Note'),
            onPressed: onAddNote,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: _style,
            icon: const Icon(Icons.add),
            label: const Text('Habit'),
            onPressed: onAddHabit,
          ),
        ),
      ],
    );
  }
}

/// Today's top tasks list — real data from [TaskProvider], filtered by the
/// caller to tasks due today.
class TodayTasksCard extends StatelessWidget {
  final List<TaskModel> tasks;
  final ValueChanged<String> onToggle;
  final VoidCallback onCreateTask;

  const TodayTasksCard({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Top Tasks",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (tasks.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No tasks for today',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.peach500),
                  foregroundColor: AppColors.peach900,
                  overlayColor: AppColors.peach100,
                ),
                onPressed: onCreateTask,
                child: const Text('Create your first task'),
              ),
            ] else
              ...tasks.take(5).map((task) {
                return InkWell(
                  onTap: () => onToggle(task.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          task.completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.completed
                              ? Colors.green
                              : AppColors.peach700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: task.completed
                                          ? AppColors.gray400
                                          : null,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                [
                                  task.priority,
                                  if ((task.category ?? '').isNotEmpty)
                                    task.category!,
                                ].join(' • '),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.gray600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Empty dashboard state
class EmptyDashboardState extends StatelessWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddNote;
  final VoidCallback onAddHabit;

  const EmptyDashboardState({
    super.key,
    required this.onAddTask,
    required this.onAddNote,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_outlined, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'Welcome to MyDay',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start organizing your day by creating a task, note, or habit.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: 24),
            QuickActionsRow(
              onAddTask: onAddTask,
              onAddNote: onAddNote,
              onAddHabit: onAddHabit,
            ),
          ],
        ),
      ),
    );
  }
}
