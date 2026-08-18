import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../models/habit_model.dart';
import '../../providers/habit_provider.dart';
import 'add_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitModel habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadStats(widget.habit.id);
      context.read<HabitProvider>().loadHistory(widget.habit.id, days: 30);
    });
  }

  Future<void> _toggleToday() async {
    try {
      await context.read<HabitProvider>().toggleHabitToday(widget.habit.id);
    } catch (_) {}
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit?'),
        content: const Text(
          'This will permanently remove the habit and all history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<HabitProvider>().deleteHabit(widget.habit.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit deleted successfully')),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final stats = provider.habitStats;
    final isLoadingStats = provider.isLoadingStats;
    final history = provider.history;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddHabitScreen(habit: widget.habit),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.habit.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.habit.description.isNotEmpty)
              Text(widget.habit.description),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Category', value: widget.habit.category),
                _InfoChip(label: 'Frequency', value: widget.habit.frequency),
                _InfoChip(
                  label: 'Status',
                  value: widget.habit.isActive ? 'Active' : 'Inactive',
                ),
              ],
            ),
            if (widget.habit.frequency == 'weekly' &&
                widget.habit.targetDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Target days: ${widget.habit.targetDays.map((day) => _weekdayLabel(day)).join(', ')}',
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleToday,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Toggle today'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteHabit,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Progress',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (isLoadingStats)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatTile(
                    icon: Icons.local_fire_department,
                    iconColor: AppColors.peach900,
                    label: 'Current Streak',
                    value: '${stats['currentStreak'] ?? 0} days',
                  ),
                  _StatTile(
                    icon: Icons.emoji_events_outlined,
                    label: 'Best Streak',
                    value: '${stats['bestStreak'] ?? 0} days',
                  ),
                  _StatTile(
                    icon: Icons.trending_up_rounded,
                    label: 'Completion',
                    value: '${stats['completionRate'] ?? 0}%',
                  ),
                  _StatTile(
                    icon: Icons.task_alt_outlined,
                    label: 'Completed',
                    value:
                        '${stats['completedDays'] ?? 0}/${stats['totalTrackedDays'] ?? 0}',
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Text(
              'History (last 30 days)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (provider.isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (history.isEmpty)
              const Text('No activity yet')
            else
              ...history.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat(
                            'MMM d',
                          ).format(DateTime.parse('${entry.date}T00:00:00Z')),
                        ),
                      ),
                      Icon(
                        entry.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: entry.completed ? Colors.green : Colors.grey,
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

  String _weekdayLabel(int day) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[day.clamp(0, 6)];
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
