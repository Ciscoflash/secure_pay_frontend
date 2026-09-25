import '../models/dashboard.dart';
import 'api_client.dart';
class DashboardService {
  DashboardService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<Overview> overview(String token, Period period) async {
    final envelope = await _client.get(
      '/dashboard/overview',
      token: token,
      query: {'period': period.name},
    );
    return Overview.fromJson(ApiClient.dataOf(envelope));
  }
  Future<Growth> growth(String token, Period range) async {
    final envelope = await _client.get(
      '/dashboard/growth',
      token: token,
      query: {'range': range.name},
    );
    return Growth.fromJson(ApiClient.dataOf(envelope));
  }
}