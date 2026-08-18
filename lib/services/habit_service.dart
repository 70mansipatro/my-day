import '../core/network/api_client.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';
import '../models/habit_stats_model.dart';

class HabitService {
  final ApiClient _apiClient;

  HabitService(this._apiClient);

  Future<List<HabitModel>> getHabits() async {
    final body = await _apiClient.get('/habits', requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final habits = data['habits'] as List<dynamic>? ?? const [];
    return habits
        .map((habit) => HabitModel.fromJson(habit as Map<String, dynamic>))
        .toList();
  }

  Future<List<HabitModel>> getTodayHabits() async {
    final body = await _apiClient.get('/habits/today', requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final habits = data['habits'] as List<dynamic>? ?? const [];
    return habits
        .map((habit) => HabitModel.fromJson(habit as Map<String, dynamic>))
        .toList();
  }

  Future<HabitModel> getHabit(String id) async {
    final body = await _apiClient.get('/habits/$id', requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return HabitModel.fromJson(data['habit'] as Map<String, dynamic>);
  }

  Future<HabitModel> createHabit({
    required String name,
    String? description,
    String category = 'General',
    String frequency = 'daily',
    List<int> targetDays = const [],
    bool isActive = true,
  }) async {
    final body = await _apiClient.post('/habits', {
      'name': name,
      'description': description ?? '',
      'category': category,
      'frequency': frequency,
      'targetDays': targetDays,
      'isActive': isActive,
    }, requiresAuth: true);

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return HabitModel.fromJson(data['habit'] as Map<String, dynamic>);
  }

  Future<HabitModel> updateHabit(
    String id, {
    String? name,
    String? description,
    String? category,
    String? frequency,
    List<int>? targetDays,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'category': category,
      'frequency': frequency,
      'targetDays': targetDays,
      'isActive': isActive,
    }..removeWhere((_, value) => value == null);

    final body = await _apiClient.put(
      '/habits/$id',
      payload,
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return HabitModel.fromJson(data['habit'] as Map<String, dynamic>);
  }

  Future<void> deleteHabit(String id) async {
    await _apiClient.delete('/habits/$id', requiresAuth: true);
  }

  Future<HabitModel> toggleHabitToday(String id) async {
    final body = await _apiClient.patch(
      '/habits/$id/toggle',
      const {},
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return HabitModel.fromJson(data['habit'] as Map<String, dynamic>);
  }

  Future<List<HabitLogModel>> getHabitHistory(
    String id, {
    int days = 30,
  }) async {
    final body = await _apiClient.get(
      '/habits/$id/history?days=$days',
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final history = data['history'] as List<dynamic>? ?? const [];
    return history
        .map((entry) => HabitLogModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<HabitStatsModel> getHabitStats(String id) async {
    final body = await _apiClient.get('/habits/$id/stats', requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return HabitStatsModel.fromJson(data);
  }
}
