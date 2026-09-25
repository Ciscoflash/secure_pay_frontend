import '../models/user.dart';
import 'api_client.dart';
class AuthResult {
  const AuthResult({
    required this.token,
    required this.user,
    this.verificationCode,
  });
  final String token;
  final AuthUser user;
  final String? verificationCode;
}
class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final envelope = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _toResult(envelope);
  }
  Future<AuthResult> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
  }) async {
    final envelope = await _client.post('/auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'password': password,
    });
    return _toResult(envelope);
  }
  Future<AuthUser> verifyEmail({required String code, required String token}) async {
    final envelope = await _client.post(
      '/auth/verify-email',
      {'code': code},
      token: token,
    );
    return AuthUser.fromJson(ApiClient.dataOf(envelope));
  }
  Future<String?> resendVerification({required String token}) async {
    final envelope = await _client.post(
      '/auth/resend-verification',
      const {},
      token: token,
    );
    return ApiClient.dataOf(envelope)['verificationCode']?.toString();
  }
  Future<AuthUser> me(String token) async {
    final envelope = await _client.get('/auth/me', token: token);
    return AuthUser.fromJson(ApiClient.dataOf(envelope));
  }
  AuthResult _toResult(Map<String, dynamic> envelope) {
    final data = ApiClient.dataOf(envelope);
    return AuthResult(
      token: data['token']?.toString() ?? '',
      user: AuthUser.fromJson(
        (data['user'] as Map<String, dynamic>?) ?? const {},
      ),
      verificationCode: data['verificationCode']?.toString(),
    );
  }
}
