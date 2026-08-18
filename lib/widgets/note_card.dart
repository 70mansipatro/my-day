import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable card used to display a single note.
class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String category;
  final bool isFavorite;
  final DateTime updatedAt;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.content,
    this.category = 'General',
    this.isFavorite = false,
    required this.updatedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = content.trim();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isFavorite)
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preview.isEmpty ? 'No content' : preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(category),
                  ),
                  const Spacer(),
                  Text(
                    'Updated: ${DateFormat('d MMM yyyy').format(updatedAt)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
