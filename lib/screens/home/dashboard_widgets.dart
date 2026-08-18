import 'package:flutter/material.dart';

/// Summary card for dashboard
class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? Colors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: onTap,
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }
}

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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.green,
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
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.orange,
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
                  color: Colors.red,
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
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
                        color: Colors.blue.withValues(alpha: 0.7),
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
              color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
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
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
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
              ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Task'),
            onPressed: onAddTask,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Note'),
            onPressed: onAddNote,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Habit'),
            onPressed: onAddHabit,
          ),
        ),
      ],
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
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
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
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
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
