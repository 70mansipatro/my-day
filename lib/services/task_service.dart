import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskService {
  final ApiClient _apiClient;

  TaskService(this._apiClient);

  Future<List<TaskModel>> getTasks() async {
    final body = await _apiClient.get(ApiConstants.tasks, requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final tasks = data['tasks'] as List<dynamic>? ?? const [];
    return tasks
        .map((task) => TaskModel.fromJson(task as Map<String, dynamic>))
        .toList();
  }

  Future<TaskModel> getTask(String id) async {
    final body = await _apiClient.get(
      '${ApiConstants.tasks}/$id',
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String priority = 'medium',
    bool completed = false,
    DateTime? dueDate,
    String? category,
  }) async {
    final categoryValue = category?.trim();
    final payload = <String, dynamic>{
      'title': title,
      'description': description ?? '',
      'priority': priority,
      'completed': completed,
      'dueDate': dueDate?.toIso8601String(),
      'category': categoryValue != null && categoryValue.isNotEmpty
          ? categoryValue
          : null,
    };
    payload.removeWhere((_, value) => value == null);

    final body = await _apiClient.post(
      ApiConstants.tasks,
      payload,
      requiresAuth: true,
    );

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(
    String id, {
    String? title,
    String? description,
    String? priority,
    bool? completed,
    DateTime? dueDate,
    String? category,
  }) async {
    final categoryValue = category?.trim();
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
      'completed': completed,
      'dueDate': dueDate?.toIso8601String(),
      'category': categoryValue != null && categoryValue.isNotEmpty
          ? categoryValue
          : null,
    };
    payload.removeWhere((_, value) => value == null);

    final body = await _apiClient.put(
      '${ApiConstants.tasks}/$id',
      payload,
      requiresAuth: true,
    );

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
  }

  Future<TaskModel> toggleTask(String id) async {
    final body = await _apiClient.patch(
      '${ApiConstants.tasks}/$id/toggle',
      const {},
      requiresAuth: true,
    );

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _apiClient.delete('${ApiConstants.tasks}/$id', requiresAuth: true);
  }
}
