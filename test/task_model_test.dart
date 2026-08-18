import 'package:flutter_test/flutter_test.dart';
import 'package:my_day/models/note_model.dart';
import 'package:my_day/models/task_model.dart';

void main() {
  test('TaskModel parses and serializes task data correctly', () {
    final task = TaskModel.fromJson({
      'id': 'task_123',
      'userId': 'user_456',
      'title': 'Learn Flutter APIs',
      'description': 'Practice REST integration',
      'priority': 'high',
      'completed': false,
      'dueDate': '2026-08-20T00:00:00.000Z',
      'category': 'Study',
      'createdAt': '2026-08-18T00:00:00.000Z',
      'updatedAt': '2026-08-18T00:00:00.000Z',
    });

    expect(task.title, 'Learn Flutter APIs');
    expect(task.priority, 'high');
    expect(task.dueDate, isNotNull);
    expect(task.toJson()['category'], 'Study');
  });

  test('NoteModel parses and serializes note data correctly', () {
    final note = NoteModel.fromJson({
      'id': 'note_123',
      'userId': 'user_456',
      'title': 'Flutter API Notes',
      'content': 'REST API integration with Flutter',
      'category': 'Study',
      'isFavorite': true,
      'createdAt': '2026-08-18T00:00:00.000Z',
      'updatedAt': '2026-08-18T00:00:00.000Z',
    });

    expect(note.title, 'Flutter API Notes');
    expect(note.category, 'Study');
    expect(note.isFavorite, isTrue);
    expect(note.toJson()['content'], 'REST API integration with Flutter');
  });
}
