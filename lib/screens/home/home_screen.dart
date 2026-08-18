import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../providers/habit_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/task_provider.dart';
import '../habits/habits_screen.dart';
import '../notes/notes_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/tasks_screen.dart';

/// Hosts the bottom navigation shell shared by Home, Tasks, Notes, Habits
/// and Profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    TasksScreen(),
    NotesScreen(),
    HabitsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _tabs),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
      context.read<NoteProvider>().loadNotes();
      context.read<HabitProvider>().loadTodayHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final noteProvider = context.watch<NoteProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final now = DateTime.now();
    final greeting = AppDateUtils.greetingForNow(now);
    final today = AppDateUtils.formatFullDate(now);
    final total = taskProvider.totalTasks;
    final completed = taskProvider.completedTasks;
    final pending = taskProvider.pendingTasks;
    final recentNotes = noteProvider.recentNotes;
    final todayHabits = habitProvider.todayHabits;
    final completedHabits = todayHabits.where((habit) => habit.isActive).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          greeting,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          today,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        _SummaryCard(
          icon: Icons.check_circle_outline,
          title: "Today's Tasks",
          subtitle: total == 0
              ? 'No tasks yet'
              : '$completed of $total completed',
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.fact_check_outlined,
          title: 'Total Tasks',
          subtitle: '$total total • $pending pending',
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          icon: Icons.note_outlined,
          title: 'Task Completion',
          subtitle:
              '${taskProvider.completionRate.toStringAsFixed(0)}% complete',
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Habits',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todayHabits.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.track_changes_outlined),
              title: const Text('No habits scheduled for today'),
              subtitle: const Text('Create your first habit'),
            ),
          )
        else ...[
          ...todayHabits
              .take(3)
              .map(
                (habit) => Card(
                  child: ListTile(
                    leading: Icon(
                      habit.isActive
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      color: habit.isActive ? Colors.green : Colors.grey,
                    ),
                    title: Text(habit.name),
                    subtitle: Text(
                      habit.frequency == 'daily' ? 'Daily' : 'Weekly',
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 4),
          Text(
            'Completed: $completedHabits / ${todayHabits.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Notes',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentNotes.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.note_alt_outlined),
              title: const Text('No notes yet'),
              subtitle: const Text('Create your first note'),
            ),
          )
        else
          ...recentNotes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.category),
                  trailing: note.isFavorite
                      ? const Icon(Icons.star, color: Colors.amber)
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
