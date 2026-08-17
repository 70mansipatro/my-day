import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Habit creation will be implemented in Phase 2.
            },
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.track_changes_outlined,
        title: 'No habits yet',
        message: 'Start building a habit and track your progress here.',
      ),
    );
  }
}
