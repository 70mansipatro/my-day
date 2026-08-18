import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  TaskProvider({required TaskService taskService}) : _taskService = taskService;

  List<TaskModel> _allTasks = [];
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _priorityFilter = 'all';
  String _categoryFilter = 'all';
  String _sortOption = 'newest';

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String get priorityFilter => _priorityFilter;
  String get categoryFilter => _categoryFilter;
  String get sortOption => _sortOption;

  int get totalTasks => _allTasks.length;
  int get completedTasks => _allTasks.where((task) => task.completed).length;
  int get pendingTasks => totalTasks - completedTasks;
  double get completionRate =>
      totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;

  Future<void> loadTasks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTasks = await _taskService.getTasks();
      _applyFilters();
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? dueDate,
    String? category,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final task = await _taskService.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        category: category,
      );
      _allTasks.insert(0, task);
      _applyFilters();
      _isCreating = false;
      notifyListeners();
      return task;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isCreating = false;
      notifyListeners();
      rethrow;
    }
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
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await _taskService.updateTask(
        id,
        title: title,
        description: description,
        priority: priority,
        completed: completed,
        dueDate: dueDate,
        category: category,
      );

      final index = _allTasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _allTasks[index] = updatedTask;
      }
      _applyFilters();
      _isUpdating = false;
      notifyListeners();
      return updatedTask;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isUpdating = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<TaskModel> toggleTask(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await _taskService.toggleTask(id);
      final index = _allTasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _allTasks[index] = updatedTask;
      }
      _applyFilters();
      notifyListeners();
      return updatedTask;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskService.deleteTask(id);
      _allTasks.removeWhere((task) => task.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  void searchTasks(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void filterTasks({
    required String status,
    required String priority,
    required String category,
  }) {
    _statusFilter = status;
    _priorityFilter = priority;
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  void sortTasks(String sortOption) {
    _sortOption = sortOption;
    _applyFilters();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  void _applyFilters() {
    List<TaskModel> result = List<TaskModel>.from(_allTasks);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((task) {
        final title = task.title.toLowerCase();
        final description = (task.description ?? '').toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    if (_statusFilter == 'completed') {
      result = result.where((task) => task.completed).toList();
    } else if (_statusFilter == 'pending') {
      result = result.where((task) => !task.completed).toList();
    }

    if (_priorityFilter != 'all') {
      result = result
          .where((task) => task.priority == _priorityFilter)
          .toList();
    }

    if (_categoryFilter != 'all') {
      result = result
          .where(
            (task) =>
                task.category?.toLowerCase() == _categoryFilter.toLowerCase(),
          )
          .toList();
    }

    switch (_sortOption) {
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'dueDate':
        result.sort((a, b) {
          final aDue = a.dueDate ?? DateTime(2100);
          final bDue = b.dueDate ?? DateTime(2100);
          return aDue.compareTo(bDue);
        });
        break;
      case 'priority':
        const order = {'low': 1, 'medium': 2, 'high': 3};
        result.sort(
          (a, b) => (order[b.priority] ?? 0).compareTo(order[a.priority] ?? 0),
        );
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    _tasks = result;
  }
}
