import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'routes.dart';
class RequireAuth extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<AuthController>().isAuthenticated
      ? null
      : const RouteSettings(name: Routes.signIn);
}
class RequireVerified extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) return const RouteSettings(name: Routes.signIn);
    if (!auth.isVerified) return const RouteSettings(name: Routes.verifyEmail);
    return null;
  }
}
class RequireUnverified extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) return const RouteSettings(name: Routes.signIn);
    if (auth.isVerified) return const RouteSettings(name: Routes.dashboard);
    return null;
  }
}
class RequireGuest extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<AuthController>().isAuthenticated
      ? const RouteSettings(name: Routes.dashboard)
      : null;
}
