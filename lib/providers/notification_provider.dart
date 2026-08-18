import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider({required NotificationService notificationService})
    : _notificationService = notificationService;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

  NotificationPreferenceModel? _preferences;
  bool _isLoadingPreferences = false;
  bool _isSavingPreferences = false;
  String? _preferencesError;

  Timer? _pollTimer;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  NotificationPreferenceModel? get preferences => _preferences;
  bool get isLoadingPreferences => _isLoadingPreferences;
  bool get isSavingPreferences => _isSavingPreferences;
  String? get preferencesError => _preferencesError;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _notificationService.getNotifications(page: 1);
      _notifications = result.notifications;
      _page = result.page;
      _hasMore = result.page < result.totalPages;
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final result = await _notificationService.getNotifications(
        page: nextPage,
      );
      _notifications = [..._notifications, ...result.notifications];
      _page = result.page;
      _hasMore = result.page < result.totalPages;
    } catch (_) {
      // Silently ignore pagination failures — the user can retry by
      // scrolling again or pulling to refresh.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (_) {
      // Swallow errors — this runs silently on a timer and shouldn't
      // surface a snackbar or disrupt whatever screen is visible.
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    final previous = _notifications[index];
    _notifications[index] = previous.copyWith(isRead: true);
    _unreadCount = (_unreadCount - 1).clamp(0, 1 << 31);
    notifyListeners();

    try {
      await _notificationService.markAsRead(id);
    } catch (e) {
      _notifications[index] = previous;
      _unreadCount += 1;
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    final previous = _notifications;
    final previousUnread = _unreadCount;
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      _notifications = previous;
      _unreadCount = previousUnread;
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final removed = _notifications[index];
    _notifications = List<NotificationModel>.from(_notifications)
      ..removeAt(index);
    if (!removed.isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, 1 << 31);
    }
    notifyListeners();

    try {
      await _notificationService.deleteNotification(id);
    } catch (e) {
      _notifications = List<NotificationModel>.from(_notifications)
        ..insert(index, removed);
      if (!removed.isRead) {
        _unreadCount += 1;
      }
      _errorMessage = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadPreferences({bool force = false}) async {
    if (_isLoadingPreferences) return;
    if (!force && _preferences != null) return;

    _isLoadingPreferences = true;
    _preferencesError = null;
    notifyListeners();

    try {
      _preferences = await _notificationService.getPreferences();
    } catch (e) {
      _preferencesError = _friendlyError(e);
    } finally {
      _isLoadingPreferences = false;
      notifyListeners();
    }
  }

  Future<void> updatePreference(
    NotificationPreferenceModel updated,
  ) async {
    final previous = _preferences;
    _preferences = updated;
    _isSavingPreferences = true;
    _preferencesError = null;
    notifyListeners();

    try {
      _preferences = await _notificationService.updatePreferences(updated);
    } catch (e) {
      _preferences = previous;
      _preferencesError = _friendlyError(e);
      rethrow;
    } finally {
      _isSavingPreferences = false;
      notifyListeners();
    }
  }

  void startUnreadPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refreshUnreadCount(),
    );
  }

  void stopUnreadPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
