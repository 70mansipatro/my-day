import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  /// Fetches complete dashboard data for the authenticated user
  Future<DashboardModel> getDashboard() async {
    final body = await _apiClient.get(
      ApiConstants.dashboard,
      requiresAuth: true,
    );

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return DashboardModel.fromJson(data);
  }
}
