import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardProvider({required DashboardService dashboardService})
    : _dashboardService = dashboardService;

  DashboardModel? _dashboard;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  /// Load dashboard data from the server
  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _dashboardService.getDashboard();
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data (pull-to-refresh)
  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _dashboardService.getDashboard();
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Convert exceptions to user-friendly error messages
  String _friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error.toString().contains('SocketException')) {
      return 'Unable to connect to server. Check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
