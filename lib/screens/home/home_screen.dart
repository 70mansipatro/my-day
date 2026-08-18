import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../../services/dashboard_service.dart';
import '../habits/habits_screen.dart';
import '../notes/notes_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/tasks_screen.dart';
import 'dashboard_widgets.dart';

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
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboard = dashboardProvider.dashboard;
    final isLoading = dashboardProvider.isLoading;
    final isRefreshing = dashboardProvider.isRefreshing;
    final error = dashboardProvider.errorMessage;

    // Show loading state
    if (isLoading && dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (error != null && dashboard == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Unable to load dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.read<DashboardProvider>().loadDashboard(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // No data state
    if (dashboard == null) {
      return EmptyDashboardState(
        onAddTask: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TasksScreen())),
        onAddNote: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
        onAddHabit: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
      );
    }

    // Check if dashboard is empty (no data)
    final isEmpty =
        dashboard.tasks.total == 0 &&
        dashboard.notes.total == 0 &&
        dashboard.habits.total == 0;

    if (isEmpty) {
      return EmptyDashboardState(
        onAddTask: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TasksScreen())),
        onAddNote: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
        onAddHabit: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
      );
    }

    // Build weekly progress data
    final weeklyData = dashboard.weeklyProgress
        .map(
          (item) => (
            day: item.day,
            value: item.tasksCompleted + item.habitsCompleted,
          ),
        )
        .toList();

    // Render dashboard
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().refreshDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Greeting and date
          Text(
            dashboard.greeting,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dashboard.date,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Today's overview card
          DashboardSummaryCard(
            icon: Icons.today_outlined,
            title: "Today's Overview",
            subtitle:
                'Tasks: ${dashboard.todayTasks.completed}/${dashboard.todayTasks.total} • Habits: ${dashboard.habits.completedToday}/${dashboard.habits.total}',
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 16),

          // Task progress card
          TaskProgressCard(
            completed: dashboard.tasks.completed,
            total: dashboard.tasks.total,
            completionRate: dashboard.tasks.completionRate,
            onViewTapped: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TasksScreen())),
          ),
          const SizedBox(height: 16),

          // Habit progress card
          HabitProgressCard(
            completed: dashboard.habits.completedToday,
            total: dashboard.habits.total,
            completionRate: dashboard.habits.completionRate,
            bestStreak: dashboard.streaks.bestCurrentStreak,
            onViewTapped: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
          ),
          const SizedBox(height: 16),

          // Notes card
          NotesSummaryCard(
            total: dashboard.notes.total,
            favorites: dashboard.notes.favorites,
            onViewTapped: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
          ),
          const SizedBox(height: 16),

          // Weekly progress
          WeeklyProgressCard(data: weeklyData),
          const SizedBox(height: 16),

          // Quick actions
          QuickActionsRow(
            onAddTask: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TasksScreen())),
            onAddNote: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
            onAddHabit: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
          ),

          // Recent activity section (if any)
          if (dashboard.recentTasks.isNotEmpty ||
              dashboard.recentNotes.isNotEmpty)
            const SizedBox(height: 24),
          if (dashboard.recentTasks.isNotEmpty ||
              dashboard.recentNotes.isNotEmpty)
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          if (dashboard.recentTasks.isNotEmpty) const SizedBox(height: 12),
          if (dashboard.recentTasks.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: dashboard.recentTasks.take(3).map((task) {
                    return RecentActivityItem(
                      icon: task.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      title: 'Task: ${task.title}',
                      description:
                          '${task.completed ? 'Completed' : 'Pending'} • ${task.priority}',
                      iconColor: task.completed ? Colors.green : Colors.orange,
                    );
                  }).toList(),
                ),
              ),
            ),
          if (dashboard.recentNotes.isNotEmpty) const SizedBox(height: 12),
          if (dashboard.recentNotes.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: dashboard.recentNotes.take(3).map((note) {
                    return RecentActivityItem(
                      icon: Icons.note_outlined,
                      title: 'Note: ${note.title}',
                      description: note.category,
                      iconColor: note.isFavorite ? Colors.red : Colors.blue,
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
