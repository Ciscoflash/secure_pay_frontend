import 'package:get/get.dart';
import '../services/api_client.dart';
import 'auth_controller.dart';
abstract class AuthenticatedController extends GetxController {
  AuthenticatedController({required this.auth});
  final AuthController auth;
  Future<T> authed<T>(Future<T> Function(String token) call) async {
    final token = auth.token;
    if (token == null) {
      await auth.handleUnauthorized();
      throw ApiException('Please sign in again.', statusCode: 401);
    }
    try {
      return await call(token);
    } on ApiException catch (error) {
      if (error.statusCode == 401) await auth.handleUnauthorized();
      rethrow;
    }
  }
}