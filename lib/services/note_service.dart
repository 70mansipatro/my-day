import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/note_model.dart';

class NoteService {
  final ApiClient _apiClient;

  NoteService(this._apiClient);

  Future<List<NoteModel>> getNotes() async {
    final body = await _apiClient.get(ApiConstants.notes, requiresAuth: true);
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final notes = data['notes'] as List<dynamic>? ?? const [];
    return notes
        .map((note) => NoteModel.fromJson(note as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel> getNote(String id) async {
    final body = await _apiClient.get(
      '${ApiConstants.notes}/$id',
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return NoteModel.fromJson(data['note'] as Map<String, dynamic>);
  }

  Future<NoteModel> createNote({
    required String title,
    required String content,
    String category = 'General',
    bool isFavorite = false,
  }) async {
    final payload = {
      'title': title.trim(),
      'content': content.trim(),
      'category': category.trim().isEmpty ? 'General' : category.trim(),
      'isFavorite': isFavorite,
    };

    final body = await _apiClient.post(
      ApiConstants.notes,
      payload,
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return NoteModel.fromJson(data['note'] as Map<String, dynamic>);
  }

  Future<NoteModel> updateNote(
    String id, {
    String? title,
    String? content,
    String? category,
    bool? isFavorite,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'content': content,
      'category': category,
      'isFavorite': isFavorite,
    }..removeWhere((_, value) => value == null);

    final body = await _apiClient.put(
      '${ApiConstants.notes}/$id',
      payload,
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return NoteModel.fromJson(data['note'] as Map<String, dynamic>);
  }

  Future<NoteModel> toggleFavorite(String id) async {
    final body = await _apiClient.patch(
      '${ApiConstants.notes}/$id/favorite',
      const {},
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return NoteModel.fromJson(data['note'] as Map<String, dynamic>);
  }

  Future<void> deleteNote(String id) async {
    await _apiClient.delete('${ApiConstants.notes}/$id', requiresAuth: true);
  }
}
