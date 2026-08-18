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
    final body = await _apiClient.post(ApiConstants.tasks, {
      'title': title,
      'description': description ?? '',
      'priority': priority,
      'completed': completed,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
    }, requiresAuth: true);

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
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (completed != null) 'completed': completed,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      if (category != null) 'category': category,
    };

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
