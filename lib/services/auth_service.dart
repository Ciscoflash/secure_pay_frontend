import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AuthUser user;
}

/// Talks to the `/auth` endpoints of the backend.
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

  /// Verifies the email with the 5-digit [code] and returns the updated user.
  Future<AuthUser> verifyEmail({required String code, required String token}) async {
    final envelope = await _client.post(
      '/auth/verify-email',
      {'code': code},
      token: token,
    );
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from the server.');
    }
    return AuthUser.fromJson(data);
  }

  /// Sends a fresh verification code to the signed-in user.
  Future<void> resendVerification({required String token}) async {
    await _client.post('/auth/resend-verification', const {}, token: token);
  }

  /// Fetches the signed-in user's profile; throws [ApiException] with
  /// statusCode 401 when the token is invalid or expired.
  Future<AuthUser> me(String token) async {
    final envelope = await _client.get('/auth/me', token: token);
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from the server.');
    }
    return AuthUser.fromJson(data);
  }

  AuthResult _toResult(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from the server.');
    }
    return AuthResult(
      token: data['token']?.toString() ?? '',
      user: AuthUser.fromJson(
        (data['user'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}
