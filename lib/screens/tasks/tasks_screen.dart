import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header_image.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final provider = context.read<TaskProvider>();
    String status = provider.statusFilter;
    String priority = provider.priorityFilter;
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
                    'Filter Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    title: 'Status',
                    options: const ['all', 'completed', 'pending'],
                    value: status,
                    onChanged: (value) =>
                        setSheetState(() => status = value ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterSection(
                    title: 'Priority',
                    options: const ['all', 'low', 'medium', 'high'],
                    value: priority,
                    onChanged: (value) =>
                        setSheetState(() => priority = value ?? 'all'),
                  ),
                  const SizedBox(height: 12),
                  _buildFilterSection(
                    title: 'Category',
                    options: const ['all', 'Study', 'Work', 'Personal'],
                    value: category,
                    onChanged: (value) =>
                        setSheetState(() => category = value ?? 'all'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            provider.filterTasks(
                              status: 'all',
                              priority: 'all',
                              category: 'all',
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            provider.filterTasks(
                              status: status,
                              priority: priority,
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
    final provider = context.read<TaskProvider>();
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
                    'Sort Tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (value) {
                      final nextValue = value ?? 'newest';
                      setSheetState(() => selected = nextValue);
                      provider.sortTasks(nextValue);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      children: ['newest', 'oldest', 'dueDate', 'priority']
                          .map(
                            (option) => RadioListTile<String>(
                              title: Text(_sortLabel(option)),
                              value: option,
                            ),
                          )
                          .toList(),
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
      case 'dueDate':
        return 'Due Date';
      case 'priority':
        return 'Priority';
      default:
        return value;
    }
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(
                    option == 'all'
                        ? 'All'
                        : option[0].toUpperCase() + option.substring(1),
                  ),
                  selected: value == option,
                  onSelected: (_) => onChanged(option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _refreshTasks() async {
    await context.read<TaskProvider>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ScreenHeaderImage(asset: 'assets/images/yXKYN.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchTasks('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => provider.searchTasks(value),
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
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.tasks.isEmpty
                  ? const Center(
                      child: EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'No tasks yet',
                        message: 'Create your first task',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.tasks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, index) =>
                          _TaskTile(task: provider.tasks[index]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final taskProvider = context.read<TaskProvider>();
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTaskScreen()));
          if (!context.mounted) return;
          await taskProvider.loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    return Card(
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
          );
          provider.loadTasks();
        },
        leading: Checkbox(
          value: task.completed,
          onChanged: (value) async {
            try {
              await context.read<TaskProvider>().toggleTask(task.id);
            } catch (_) {}
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.trim().isNotEmpty)
              Text(
                task.description!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Badge(label: task.priority.toUpperCase()),
                if (task.category != null && task.category!.trim().isNotEmpty)
                  _Badge(label: task.category!.trim()),
                if (task.dueDate != null)
                  _Badge(label: DateFormat('MMM d').format(task.dueDate!)),
                _Badge(label: task.completed ? 'Completed' : 'Pending'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
