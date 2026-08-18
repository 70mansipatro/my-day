import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/note_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/note_card.dart';
import '../../widgets/screen_header_image.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final provider = context.read<NoteProvider>();
    String category = provider.categoryFilter;
    bool favoriteOnly = provider.favoriteOnly;

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
                    'Filter Notes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'all',
                          'General',
                          'Study',
                          'Work',
                          'Personal',
                          'Ideas',
                        ].map((option) {
                          final value = option == 'all' ? 'all' : option;
                          return ChoiceChip(
                            label: Text(option == 'all' ? 'All' : option),
                            selected: category == value,
                            onSelected: (_) =>
                                setSheetState(() => category = value),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Favorites only'),
                    value: favoriteOnly,
                    onChanged: (value) =>
                        setSheetState(() => favoriteOnly = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            provider.filterByCategory('all');
                            provider.filterFavorites(false);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear filters'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            provider.filterByCategory(category);
                            provider.filterFavorites(favoriteOnly);
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
    final provider = context.read<NoteProvider>();
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
                    'Sort Notes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (value) {
                      final nextValue = value ?? 'newest';
                      setSheetState(() => selected = nextValue);
                      provider.sortNotes(nextValue);
                      Navigator.of(context).pop();
                    },
                    child: Column(
                      children: ['newest', 'oldest', 'favorite']
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
      case 'favorite':
        return 'Favorites';
      default:
        return value;
    }
  }

  Future<void> _refreshNotes() async {
    await context.read<NoteProvider>().loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;
    final errorMessage = provider.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: RefreshIndicator(
        onRefresh: _refreshNotes,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ScreenHeaderImage(asset: 'assets/images/FJRyR.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchNotes('');
                          },
                        )
                      : null,
                ),
                onChanged: provider.searchNotes,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openSortSheet,
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort'),
                    ),
                  ),
                ],
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(errorMessage),
                ),
              ),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notes.isEmpty
                  ? const EmptyState(
                      icon: Icons.note_outlined,
                      title: 'No notes yet',
                      message: 'Create your first note',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NoteCard(
                            title: note.title,
                            content: note.content,
                            isFavorite: note.isFavorite,
                            category: note.category,
                            updatedAt:
                                note.updatedAt ??
                                note.createdAt ??
                                DateTime.now(),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NoteDetailScreen(note: note),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddNoteScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
