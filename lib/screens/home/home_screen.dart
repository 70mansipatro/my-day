import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
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
      body: SafeArea(child: IndexedStack(index: _selectedIndex, children: _tabs)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = AppDateUtils.greetingForNow(now);
    final today = AppDateUtils.formatFullDate(now);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          greeting,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          today,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        const _SummaryCard(
          icon: Icons.check_circle_outline,
          title: "Today's Tasks",
          subtitle: 'No tasks yet',
        ),
        const SizedBox(height: 12),
        const _SummaryCard(
          icon: Icons.track_changes_outlined,
          title: 'Habits',
          subtitle: 'No habits yet',
        ),
        const SizedBox(height: 12),
        const _SummaryCard(
          icon: Icons.note_outlined,
          title: 'Quick Notes',
          subtitle: 'No notes yet',
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
