import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';
import '../services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService;

  HabitProvider({required HabitService habitService})
    : _habitService = habitService;

  List<HabitModel> _allHabits = [];
  List<HabitModel> _habits = [];
  List<HabitModel> _todayHabits = [];
  List<HabitLogModel> _history = [];
  Map<String, dynamic> _habitStats = {};
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isLoadingHistory = false;
  bool _isLoadingStats = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _activeFilter = 'active';
  String _frequencyFilter = 'all';
  String _categoryFilter = 'all';
  String _sortOption = 'newest';

  List<HabitModel> get habits => _habits;
  List<HabitModel> get allHabits => _allHabits;
  List<HabitModel> get todayHabits => _todayHabits;
  List<HabitLogModel> get history => _history;
  Map<String, dynamic> get habitStats => _habitStats;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingStats => _isLoadingStats;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get activeFilter => _activeFilter;
  String get frequencyFilter => _frequencyFilter;
  String get categoryFilter => _categoryFilter;
  String get sortOption => _sortOption;

  Future<void> loadHabits() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allHabits = await _habitService.getHabits();
      _applyFilters();
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayHabits() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayHabits = await _habitService.getTodayHabits();
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HabitModel> createHabit({
    required String name,
    String? description,
    String category = 'General',
    String frequency = 'daily',
    List<int> targetDays = const [],
    bool isActive = true,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final habit = await _habitService.createHabit(
        name: name,
        description: description,
        category: category,
        frequency: frequency,
        targetDays: targetDays,
        isActive: isActive,
      );
      _allHabits.insert(0, habit);
      _applyFilters();
      _isCreating = false;
      notifyListeners();
      return habit;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _isCreating = false;
      notifyListeners();
      rethrow;
    }
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
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _habitService.updateHabit(
        id,
        name: name,
        description: description,
        category: category,
        frequency: frequency,
        targetDays: targetDays,
        isActive: isActive,
      );

      final index = _allHabits.indexWhere((habit) => habit.id == id);
      if (index != -1) {
        _allHabits[index] = updated;
      }
      _applyFilters();
      _isUpdating = false;
      notifyListeners();
      return updated;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _isUpdating = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _habitService.deleteHabit(id);
      _allHabits.removeWhere((habit) => habit.id == id);
      _todayHabits.removeWhere((habit) => habit.id == id);
      _applyFilters();
      _isDeleting = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _isDeleting = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<HabitModel> toggleHabitToday(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _habitService.toggleHabitToday(id);
      final index = _allHabits.indexWhere((habit) => habit.id == id);
      if (index != -1) {
        _allHabits[index] = updated;
      }
      await loadTodayHabits();
      notifyListeners();
      return updated;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadHistory(String id, {int days = 30}) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _habitService.getHabitHistory(id, days: days);
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadStats(String id) async {
    _isLoadingStats = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final stats = await _habitService.getHabitStats(id);
      _habitStats = {
        'currentStreak': stats.currentStreak,
        'bestStreak': stats.bestStreak,
        'completionRate': stats.completionRate,
        'completedDays': stats.completedDays,
        'totalTrackedDays': stats.totalTrackedDays,
      };
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  void searchHabits(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void filterHabits({
    required String active,
    required String frequency,
    required String category,
  }) {
    _activeFilter = active;
    _frequencyFilter = frequency;
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  void sortHabits(String sortOption) {
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
    List<HabitModel> result = List<HabitModel>.from(_allHabits);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((habit) {
        final name = habit.name.toLowerCase();
        final description = habit.description.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    if (_activeFilter == 'active') {
      result = result.where((habit) => habit.isActive).toList();
    } else if (_activeFilter == 'inactive') {
      result = result.where((habit) => !habit.isActive).toList();
    }

    if (_frequencyFilter != 'all') {
      result = result
          .where((habit) => habit.frequency == _frequencyFilter)
          .toList();
    }

    if (_categoryFilter != 'all') {
      result = result
          .where(
            (habit) =>
                habit.category.toLowerCase() == _categoryFilter.toLowerCase(),
          )
          .toList();
    }

    switch (_sortOption) {
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'nameAsc':
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'nameDesc':
        result.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case 'streak':
        result.sort(
          (a, b) => b.targetDays.length.compareTo(a.targetDays.length),
        );
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    _habits = result;
  }
}
