import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bindings/auth_binding.dart';
import 'bindings/dashboard_binding.dart';
import 'screens/dashboard_screen.dart';
import 'screens/route_guards.dart';
import 'screens/routes.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/verify_email_screen.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'theme/app_theme.dart';
class SecurePayApp extends StatelessWidget {
  const SecurePayApp({
    super.key,
    required this.prefs,
    this.authService,
    this.dashboardService,
  });
  final SharedPreferences prefs;
  final AuthService? authService;
  final DashboardService? dashboardService;
  @override
  Widget build(BuildContext context) {
    final signedIn = prefs.getString('auth_token') != null;
    return GetMaterialApp(
      title: 'SecurePay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialBinding: AuthBinding(prefs, service: authService),
      initialRoute: signedIn
          ? (_cachedUserVerified() ? Routes.dashboard : Routes.verifyEmail)
          : Routes.signIn,
      getPages: [
        GetPage(
          name: Routes.signIn,
          page: () => const SignInScreen(),
          middlewares: [RequireGuest()],
        ),
        GetPage(
          name: Routes.signUp,
          page: () => const SignUpScreen(),
          middlewares: [RequireGuest()],
        ),
        GetPage(
          name: Routes.verifyEmail,
          page: () => const VerifyEmailScreen(),
          middlewares: [RequireUnverified()],
        ),
        GetPage(
          name: Routes.dashboard,
          page: () => const DashboardScreen(),
          binding: DashboardBinding(service: dashboardService),
          middlewares: [RequireVerified()],
        ),
      ],
    );
  }
  bool _cachedUserVerified() {
    final raw = prefs.getString('auth_user');
    if (raw == null) return false;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> && json['emailVerified'] == true;
    } catch (_) {
      return false;
    }
  }
}
