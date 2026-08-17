import 'package:flutter/material.dart';

/// A reusable card used to display a single note.
class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isFavorite;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    this.isFavorite = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing:
            isFavorite ? const Icon(Icons.star, color: Colors.amber) : null,
      ),
    );
  }
}
