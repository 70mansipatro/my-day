import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../widgets/full_visible_hero_image.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<String> _presetCategories = const [
    'General',
    'Study',
    'Work',
    'Personal',
    'Ideas',
  ];
  String _selectedCategory = 'General';
  bool _isFavorite = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedCategory = widget.note!.category;
      _categoryController.text = widget.note!.category;
      _isFavorite = widget.note!.isFavorite;
    } else {
      _selectedCategory = 'General';
      _categoryController.text = 'General';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _categoryController.text.trim();

    setState(() => _isSaving = true);

    try {
      if (widget.note == null) {
        await context.read<NoteProvider>().createNote(
          title: title,
          content: content,
          category: category.isEmpty ? 'General' : category,
          isFavorite: _isFavorite,
        );
      } else {
        await context.read<NoteProvider>().updateNote(
          widget.note!.id,
          title: title,
          content: content,
          category: category.isEmpty ? 'General' : category,
          isFavorite: _isFavorite,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.note == null
                ? 'Note created successfully'
                : 'Note updated successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy =
        context.watch<NoteProvider>().isCreating ||
        context.watch<NoteProvider>().isUpdating ||
        _isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FullVisibleHeroImage(
                      imagePath: 'assets/images/yXKYN.jpg',
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value!.trim().length > 150) {
                          return 'Title must be 150 characters or fewer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: 'Content'),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Content is required';
                        }
                        if ((value ?? '').trim().length > 10000) {
                          return 'Content must be 10000 characters or fewer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetCategories.map((category) {
                        final selected = _selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                              _categoryController.text = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Custom category',
                        hintText: 'General',
                      ),
                      onChanged: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isEmpty) {
                          setState(() => _selectedCategory = 'General');
                          return;
                        }
                        setState(() => _selectedCategory = trimmed);
                      },
                      validator: (value) {
                        if ((value ?? '').trim().length > 50) {
                          return 'Category must be 50 characters or fewer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile.adaptive(
                      value: _isFavorite,
                      onChanged: isBusy
                          ? null
                          : (value) => setState(() => _isFavorite = value),
                      title: const Text('Favorite'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isBusy ? null : _submit,
                        icon: isBusy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          isBusy
                              ? 'Saving...'
                              : widget.note == null
                              ? 'Create Note'
                              : 'Save Changes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
