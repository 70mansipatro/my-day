import 'package:flutter/material.dart';

/// A reusable card used to display a single habit.
class HabitCard extends StatelessWidget {
  final String name;
  final String frequency;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.name,
    required this.frequency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.track_changes),
        title: Text(name),
        subtitle: Text(frequency),
      ),
    );
  }
}
