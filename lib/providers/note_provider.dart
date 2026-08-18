import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _noteService;

  NoteProvider({required NoteService noteService}) : _noteService = noteService;

  List<NoteModel> _allNotes = [];
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _categoryFilter = 'all';
  bool _favoriteOnly = false;
  String _sortOption = 'newest';

  List<NoteModel> get notes => _notes;
  List<NoteModel> get allNotes => _allNotes;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get categoryFilter => _categoryFilter;
  bool get favoriteOnly => _favoriteOnly;
  String get sortOption => _sortOption;

  int get totalNotes => _allNotes.length;
  int get favoriteNotes => _allNotes.where((note) => note.isFavorite).length;
  List<NoteModel> get recentNotes {
    final recent = [..._allNotes];
    recent.sort(
      (a, b) => (b.updatedAt ?? b.createdAt ?? DateTime.now()).compareTo(
        a.updatedAt ?? a.createdAt ?? DateTime.now(),
      ),
    );
    return recent.take(3).toList();
  }

  Future<void> loadNotes() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allNotes = await _noteService.getNotes();
      _applyFilters();
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NoteModel> createNote({
    required String title,
    required String content,
    String category = 'General',
    bool isFavorite = false,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final note = await _noteService.createNote(
        title: title,
        content: content,
        category: category,
        isFavorite: isFavorite,
      );
      _allNotes.insert(0, note);
      _applyFilters();
      _isCreating = false;
      notifyListeners();
      return note;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isCreating = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<NoteModel> updateNote(
    String id, {
    String? title,
    String? content,
    String? category,
    bool? isFavorite,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedNote = await _noteService.updateNote(
        id,
        title: title,
        content: content,
        category: category,
        isFavorite: isFavorite,
      );

      final index = _allNotes.indexWhere((note) => note.id == id);
      if (index != -1) {
        _allNotes[index] = updatedNote;
      }
      _applyFilters();
      _isUpdating = false;
      notifyListeners();
      return updatedNote;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isUpdating = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<NoteModel> toggleFavorite(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedNote = await _noteService.toggleFavorite(id);
      final index = _allNotes.indexWhere((note) => note.id == id);
      if (index != -1) {
        _allNotes[index] = updatedNote;
      }
      _applyFilters();
      notifyListeners();
      return updatedNote;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _noteService.deleteNote(id);
      _allNotes.removeWhere((note) => note.id == id);
      _applyFilters();
      _isDeleting = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _isDeleting = false;
      notifyListeners();
      rethrow;
    }
  }

  void searchNotes(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  void filterFavorites(bool favoritesOnly) {
    _favoriteOnly = favoritesOnly;
    _applyFilters();
    notifyListeners();
  }

  void sortNotes(String sortOption) {
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
    List<NoteModel> result = List<NoteModel>.from(_allNotes);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((note) {
        final title = note.title.toLowerCase();
        final content = note.content.toLowerCase();
        return title.contains(query) || content.contains(query);
      }).toList();
    }

    if (_categoryFilter != 'all') {
      result = result.where((note) {
        return note.category.toLowerCase() == _categoryFilter.toLowerCase();
      }).toList();
    }

    if (_favoriteOnly) {
      result = result.where((note) => note.isFavorite).toList();
    }

    switch (_sortOption) {
      case 'oldest':
        result.sort(
          (a, b) => (a.createdAt ?? a.updatedAt ?? DateTime.now()).compareTo(
            b.createdAt ?? b.updatedAt ?? DateTime.now(),
          ),
        );
        break;
      case 'favorite':
        result.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return (b.updatedAt ?? b.createdAt ?? DateTime.now()).compareTo(
              a.updatedAt ?? a.createdAt ?? DateTime.now(),
            );
          }
          return a.isFavorite ? -1 : 1;
        });
        break;
      case 'newest':
      default:
        result.sort(
          (a, b) => (b.updatedAt ?? b.createdAt ?? DateTime.now()).compareTo(
            a.updatedAt ?? a.createdAt ?? DateTime.now(),
          ),
        );
        break;
    }

    _notes = result;
  }
}
