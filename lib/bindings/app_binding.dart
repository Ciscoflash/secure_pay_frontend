import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../services/data_services.dart';
class AppBinding extends Bindings {
  AppBinding({required this.prefs, this.authService, this.dataServices});
  final SharedPreferences prefs;
  final AuthService? authService;
  final DataServices? dataServices;
  @override
  void dependencies() {
    Get.put<DataServices>(dataServices ?? DataServices(), permanent: true);
    Get.put(AuthController(authService ?? AuthService(), prefs), permanent: true);
  }
}