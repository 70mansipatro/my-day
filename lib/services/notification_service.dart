import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

class NotificationPage {
  final List<NotificationModel> notifications;
  final int page;
  final int totalPages;

  const NotificationPage({
    required this.notifications,
    required this.page,
    required this.totalPages,
  });
}

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (unreadOnly == true) 'isRead': 'false',
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    final body = await _apiClient.get(
      '${ApiConstants.notifications}?$query',
      requiresAuth: true,
    );

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final notifications = data['notifications'] as List<dynamic>? ?? const [];
    return NotificationPage(
      notifications: notifications
          .map(
            (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: data['page'] as int? ?? page,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<int> getUnreadCount() async {
    final body = await _apiClient.get(
      '${ApiConstants.notifications}/unread-count',
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return data['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch(
      '${ApiConstants.notifications}/$id/read',
      const {},
      requiresAuth: true,
    );
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch(
      '${ApiConstants.notifications}/read-all',
      const {},
      requiresAuth: true,
    );
  }

  Future<void> deleteNotification(String id) async {
    await _apiClient.delete(
      '${ApiConstants.notifications}/$id',
      requiresAuth: true,
    );
  }

  Future<NotificationPreferenceModel> getPreferences() async {
    final body = await _apiClient.get(
      ApiConstants.notificationPreferences,
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return NotificationPreferenceModel.fromJson(
      data['preferences'] as Map<String, dynamic>? ?? const {},
    );
  }

  Future<NotificationPreferenceModel> updatePreferences(
    NotificationPreferenceModel preferences,
  ) async {
    final body = await _apiClient.put(
      ApiConstants.notificationPreferences,
      preferences.toJson(),
      requiresAuth: true,
    );
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return NotificationPreferenceModel.fromJson(
      data['preferences'] as Map<String, dynamic>? ?? const {},
    );
  }
}
