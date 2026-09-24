import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../screens/routes.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

/// Owns the auth session: token, user, loading & error state.
///
/// Register/login call the backend through [AuthService], persist the session
/// in [SharedPreferences] (localStorage on web) and expose reactive state so
/// the UI can show spinners and errors.
class AuthController extends GetxController {
  /// [prefs] is loaded before `runApp`, so the stored session is available
  /// synchronously and route guards can decide on the very first frame.
  AuthController(this._service, this._prefs) {
    _restoreSession();
  }

  final AuthService _service;
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final _token = RxnString();
  final _user = Rxn<AuthUser>();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  String? get token => _token.value;
  AuthUser? get user => _user.value;
  bool get isAuthenticated => _token.value != null;
  bool get isVerified => _user.value?.emailVerified ?? false;

  /// Verifies the email with the 5-digit [code] and refreshes the cached
  /// profile so route guards see the user as verified.
  Future<bool> verifyEmail(String code) async {
    final token = _token.value;
    if (token == null) return false;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final user = await _service.verifyEmail(code: code, token: token);
      await _persistSession(token, user);
      return true;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends a fresh verification code to the signed-in user's email.
  Future<bool> resendVerification() async {
    final token = _token.value;
    if (token == null) return false;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _service.resendVerification(token: token);
      return true;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // A stored token may have expired or its user been deleted: confirm it
    // with the server and refresh the cached profile.
    if (isAuthenticated) refreshProfile();
  }

  Future<bool> signIn({required String email, required String password}) =>
      _run(() => _service.login(email: email, password: password));

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
  }) => _run(
    () => _service.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      countryCode: countryCode,
      password: password,
    ),
  );

  /// Re-fetches the profile. Signs out if the server rejects the token;
  /// keeps the cached profile on network errors.
  Future<void> refreshProfile() async {
    final token = _token.value;
    if (token == null) return;
    try {
      final user = await _service.me(token);
      _user.value = user;
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    } on ApiException catch (error) {
      if (error.statusCode == 401) await handleUnauthorized();
    }
  }

  /// Called whenever any request comes back 401: the session is gone, so
  /// clear it and send the user to sign in.
  Future<void> handleUnauthorized() async {
    if (!isAuthenticated) return;
    await logout();
    Get.offAllNamed(Routes.signIn);
    Get.snackbar(
      'Session expired',
      'Please sign in again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Executes an auth call, stores the session on success and returns whether
  /// the call succeeded. On failure, [errorMessage] holds a user-facing string.
  Future<bool> _run(Future<AuthResult> Function() call) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await call();
      await _persistSession(result.token, result.user);
      return true;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
      return false;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _restoreSession() {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return;
    _token.value = token;

    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return;
    try {
      _user.value = AuthUser.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
    } catch (_) {
      // Corrupt cache: keep the token, the profile is re-fetched on ready.
    }
  }

  Future<void> _persistSession(String token, AuthUser user) async {
    _token.value = token;
    _user.value = user;
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _token.value = null;
    _user.value = null;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
