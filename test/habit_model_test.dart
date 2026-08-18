import 'package:flutter_test/flutter_test.dart';
import 'package:my_day/models/habit_model.dart';

void main() {
  test('HabitModel parses and serializes habit data correctly', () {
    final habit = HabitModel.fromJson({
      'id': 'habit_123',
      'userId': 'user_456',
      'name': 'Coding',
      'description': 'Practice coding daily',
      'category': 'Study',
      'frequency': 'daily',
      'targetDays': [1, 3, 5],
      'isActive': true,
      'createdAt': '2026-08-18T00:00:00.000Z',
      'updatedAt': '2026-08-18T00:00:00.000Z',
    });

    expect(habit.name, 'Coding');
    expect(habit.frequency, 'daily');
    expect(habit.targetDays, [1, 3, 5]);
    expect(habit.toJson()['category'], 'Study');
  });
}
