import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit_model.dart';
import '../../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  final HabitModel? habit;

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  String _frequency = 'daily';
  final List<int> _targetDays = [];
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit != null) {
      _nameController.text = habit.name;
      _descriptionController.text = habit.description;
      _categoryController.text = habit.category;
      _frequency = habit.frequency;
      _targetDays.addAll(habit.targetDays);
      _isActive = habit.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frequency == 'weekly' && _targetDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day for weekly habits'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.habit == null) {
        await context.read<HabitProvider>().createHabit(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? 'General'
              : _categoryController.text.trim(),
          frequency: _frequency,
          targetDays: _targetDays,
          isActive: _isActive,
        );
      } else {
        await context.read<HabitProvider>().updateHabit(
          widget.habit!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? 'General'
              : _categoryController.text.trim(),
          frequency: _frequency,
          targetDays: _targetDays,
          isActive: _isActive,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.habit == null
                ? 'Habit created successfully'
                : 'Habit updated successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is Exception
          ? error.toString()
          : 'Something went wrong';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final isSaving =
        habitProvider.isCreating || habitProvider.isUpdating || _isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Habit name'),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Habit name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if ((value ?? '').trim().length > 500) {
                      return 'Description must be 500 characters or fewer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if ((value ?? '').trim().length > 50) {
                      return 'Category must be 50 characters or fewer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  onChanged: (value) =>
                      setState(() => _frequency = value ?? 'daily'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  ],
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
                const SizedBox(height: 16),
                if (_frequency == 'weekly') ...[
                  const Text(
                    'Target Days',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        const [
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                        ].asMap().entries.map((entry) {
                          final index = entry.key;
                          final label = entry.value;
                          final selected = _targetDays.contains(index);
                          return FilterChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                if (selected) {
                                  _targetDays.remove(index);
                                } else {
                                  _targetDays.add(index);
                                  _targetDays.sort();
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                SwitchListTile(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('Active habit'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : _submit,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : widget.habit == null
                          ? 'Save Habit'
                          : 'Update Habit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
