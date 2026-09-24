import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

/// Creates the DI graph for the auth session.
class AuthBinding extends Bindings {
  AuthBinding(this.prefs, {this.service});

  final SharedPreferences prefs;

  /// Overridable for tests.
  final AuthService? service;

  @override
  void dependencies() {
    Get.put(AuthController(service ?? AuthService(), prefs), permanent: true);
  }
}
