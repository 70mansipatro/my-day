import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: const EmptyState(
        icon: Icons.note_outlined,
        title: 'No notes yet',
        message: 'Notes you add will show up here.',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Note creation will be implemented in Phase 2.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
