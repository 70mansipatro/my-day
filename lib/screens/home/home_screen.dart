import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../app/routes.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/screen_header_image.dart';
import '../habits/add_habit_screen.dart';
import '../habits/habits_screen.dart';
import '../notes/add_note_screen.dart';
import '../notes/notes_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/tasks_screen.dart';
import 'dashboard_widgets.dart';

typedef _NavItem = ({IconData icon, IconData selectedIcon, String label});

const List<_NavItem> _navItems = [
  (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
  (
    icon: Icons.check_circle_outline,
    selectedIcon: Icons.check_circle,
    label: 'Tasks',
  ),
  (icon: Icons.note_outlined, selectedIcon: Icons.note, label: 'Notes'),
  (
    icon: Icons.track_changes_outlined,
    selectedIcon: Icons.track_changes,
    label: 'Habits',
  ),
  (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
];

/// Hosts the navigation shell shared by Home, Tasks, Notes, Habits and
/// Profile: a bottom [NavigationBar] on mobile/tablet, a left sidebar on
/// desktop (>1024px). Tab state (`_selectedIndex`/`_tabs`/`IndexedStack`) is
/// identical across both layouts.
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.refreshUnreadCount();
      notificationProvider.startUnreadPolling();
    });
  }

  @override
  void dispose() {
    context.read<NotificationProvider>().stopUnreadPolling();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    if (!isDesktop) {
      return Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _tabs),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: [
            for (final item in _navItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: _selectedIndex,
              onSelect: (index) => setState(() => _selectedIndex = index),
              onOpenSettings: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              onLogout: () => _handleLogout(context),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: IndexedStack(index: _selectedIndex, children: _tabs),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onOpenSettings,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'MyDay',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.peach900,
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          for (var i = 0; i < _navItems.length; i++)
            _SidebarTile(
              icon: selectedIndex == i
                  ? _navItems[i].selectedIcon
                  : _navItems[i].icon,
              label: _navItems[i].label,
              selected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          const Divider(height: 1),
          _SidebarTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            selected: false,
            onTap: onOpenSettings,
          ),
          _SidebarTile(
            icon: Icons.logout_outlined,
            label: 'Logout',
            selected: false,
            onTap: onLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? AppColors.peach100 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.peach900 : AppColors.gray600,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.gray800 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
      context.read<TaskProvider>().loadTasks();
    });
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final local = date.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboard = dashboardProvider.dashboard;
    final isLoading = dashboardProvider.isLoading;
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
            Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
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
              ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
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
        ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        onAddNote: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddNoteScreen())),
        onAddHabit: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddHabitScreen())),
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
        ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        onAddNote: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddNoteScreen())),
        onAddHabit: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddHabitScreen())),
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

    final userName = context.watch<AuthProvider>().currentUser?.name;
    final greeting = userName == null || userName.isEmpty
        ? dashboard.greeting
        : '${dashboard.greeting}, $userName!';

    final todayTasks =
        context
            .watch<TaskProvider>()
            .allTasks
            .where((task) => _isToday(task.dueDate))
            .toList()
          ..sort(
            (a, b) => (a.completed ? 1 : 0).compareTo(b.completed ? 1 : 0),
          );

    final screenSize = Responsive.of(context);
    final contentMaxWidth = switch (screenSize) {
      ScreenSize.mobile => double.infinity,
      ScreenSize.tablet => 700.0,
      ScreenSize.desktop => 900.0,
    };

    final overviewCards = [
      TaskProgressCard(
        completed: dashboard.tasks.completed,
        total: dashboard.tasks.total,
        completionRate: dashboard.tasks.completionRate,
        onViewTapped: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TasksScreen())),
      ),
      NotesSummaryCard(
        total: dashboard.notes.total,
        favorites: dashboard.notes.favorites,
        onViewTapped: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
      ),
      HabitProgressCard(
        completed: dashboard.habits.completedToday,
        total: dashboard.habits.total,
        completionRate: dashboard.habits.completionRate,
        bestStreak: dashboard.streaks.bestCurrentStreak,
        onViewTapped: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HabitsScreen())),
      ),
    ];

    // Render dashboard
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().refreshDashboard(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const ScreenHeaderImage(asset: 'assets/images/ep2vo.jpg'),
              const SizedBox(height: 16),
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's make today productive and meaningful.",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray800),
              ),
              const SizedBox(height: 4),
              Text(
                dashboard.date,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 24),

              Text(
                "Today's Overview",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (screenSize == ScreenSize.mobile)
                Column(
                  children: [
                    for (var i = 0; i < overviewCards.length; i++) ...[
                      overviewCards[i],
                      if (i != overviewCards.length - 1)
                        const SizedBox(height: 16),
                    ],
                  ],
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < overviewCards.length; i++) ...[
                        Expanded(child: overviewCards[i]),
                        if (i != overviewCards.length - 1)
                          const SizedBox(width: 16),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              TodayTasksCard(
                tasks: todayTasks,
                onToggle: (id) => context.read<TaskProvider>().toggleTask(id),
                onCreateTask: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                ),
              ),
              const SizedBox(height: 16),

              WeeklyProgressCard(data: weeklyData),
              const SizedBox(height: 16),

              QuickActionsRow(
                onAddTask: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                ),
                onAddNote: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddNoteScreen()),
                ),
                onAddHabit: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                ),
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
                          iconColor: task.completed
                              ? Colors.green
                              : AppColors.peach700,
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
                          iconColor: note.isFavorite
                              ? Colors.red
                              : AppColors.peach900,
                        );
                      }).toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
