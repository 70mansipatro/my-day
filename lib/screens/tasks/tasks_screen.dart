import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No tasks yet',
        message: 'Tasks you add will show up here.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Task creation will be implemented in Phase 2.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
