import 'package:flutter/material.dart';

/// A reusable card used to display a single task.
class TaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool completed;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckedChanged;

  const TaskCard({
    super.key,
    required this.title,
    this.description,
    this.completed = false,
    this.onTap,
    this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: completed, onChanged: onCheckedChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: (description != null && description!.isNotEmpty)
            ? Text(description!)
            : null,
      ),
    );
  }
}
