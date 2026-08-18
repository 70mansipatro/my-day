import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit_model.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/screen_header_image.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
      context.read<HabitProvider>().loadTodayHabits();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<HabitProvider>().loadHabits(),
      context.read<HabitProvider>().loadTodayHabits(),
    ]);
  }

  void _openFilterSheet() {
    final provider = context.read<HabitProvider>();
    String active = provider.activeFilter;
    String frequency = provider.frequencyFilter;
    String category = provider.categoryFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Habits',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ['all', 'active', 'inactive']
                        .map(
                          (option) => ChoiceChip(
                            label: Text(
                              option == 'all'
                                  ? 'All'
                                  : option[0].toUpperCase() +
                                        option.substring(1),
                            ),
                            selected: active == option,
                            onSelected: (_) =>
                                setSheetState(() => active = option),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Frequency',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ['all', 'daily', 'weekly']
                        .map(
                          (option) => ChoiceChip(
                            label: Text(
                              option == 'all'
                                  ? 'All'
                                  : option[0].toUpperCase() +
                                        option.substring(1),
                            ),
                            selected: frequency == option,
                            onSelected: (_) =>
                                setSheetState(() => frequency = option),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'all',
                              'Study',
                              'Health',
                              'Work',
                              'Personal',
                              'Other',
                              'General',
                            ]
                            .map(
                              (option) => ChoiceChip(
                                label: Text(option == 'all' ? 'All' : option),
                                selected: category == option,
                                onSelected: (_) =>
                                    setSheetState(() => category = option),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            provider.filterHabits(
                              active: 'all',
                              frequency: 'all',
                              category: 'all',
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            provider.filterHabits(
                              active: active,
                              frequency: frequency,
                              category: category,
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openSortSheet() {
    final provider = context.read<HabitProvider>();
    String selected = provider.sortOption;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort Habits',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...['newest', 'oldest', 'nameAsc', 'nameDesc', 'streak'].map(
                    (option) => ListTile(
                      title: Text(_sortLabel(option)),
                      leading: Icon(
                        selected == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      onTap: () {
                        setSheetState(() => selected = option);
                        provider.sortHabits(option);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _sortLabel(String value) {
    switch (value) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'nameAsc':
        return 'Name A-Z';
      case 'nameDesc':
        return 'Name Z-A';
      case 'streak':
        return 'Current Streak';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final todayHabits = provider.todayHabits;
    final habits = provider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AddHabitScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ScreenHeaderImage(asset: 'assets/images/AsoxL.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search habits',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchHabits('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => provider.searchHabits(value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _openFilterSheet,
                      child: const Text('Filter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _openSortSheet,
                      child: const Text('Sort'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(provider.errorMessage!),
                ),
              ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (todayHabits.isEmpty)
                          const Text('No habits scheduled for today')
                        else ...[
                          const Text(
                            'Today\'s Habits',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...todayHabits.map(
                            (habit) => _HabitTile(habit: habit),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          'All Habits',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (habits.isEmpty)
                          const Text('No habits found')
                        else
                          ...habits.map((habit) => _HabitTile(habit: habit)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final HabitModel habit;

  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        ),
        title: Text(habit.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${habit.category} • ${habit.frequency}'),
            const SizedBox(height: 4),
            Text('🔥 ${habit.targetDays.length} day streak'),
          ],
        ),
        trailing: FilledButton(
          onPressed: () async {
            try {
              await context.read<HabitProvider>().toggleHabitToday(habit.id);
            } catch (_) {}
          },
          child: const Text('Done'),
        ),
      ),
    );
  }
}
