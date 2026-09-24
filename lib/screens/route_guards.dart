import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import 'routes.dart';

/// Sends signed-out visitors to sign in (e.g. a bookmarked /dashboard).
class RequireAuth extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<AuthController>().isAuthenticated
      ? null
      : const RouteSettings(name: Routes.signIn);
}

/// The dashboard is only for verified, signed-in users: unverified accounts
/// are redirected to the code prompt.
class RequireVerified extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) return const RouteSettings(name: Routes.signIn);
    if (!auth.isVerified) return const RouteSettings(name: Routes.verifyEmail);
    return null;
  }
}

/// The code prompt is off-limits to verified users and guests.
class RequireUnverified extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) return const RouteSettings(name: Routes.signIn);
    if (auth.isVerified) return const RouteSettings(name: Routes.dashboard);
    return null;
  }
}

/// Keeps signed-in users off the sign-in and sign-up pages.
class RequireGuest extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<AuthController>().isAuthenticated
      ? const RouteSettings(name: Routes.dashboard)
      : null;
}
