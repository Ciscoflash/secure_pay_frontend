import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/wallet_controller.dart';
import '../services/dashboard_service.dart';
class DashboardBinding extends Bindings {
  DashboardBinding({this.service});
  final DashboardService? service;
  @override
  void dependencies() {
    Get.lazyPut(
      () => DashboardController(
        service ?? DashboardService(),
        Get.find<AuthController>(),
      ),
    );
    Get.lazyPut(
      () => NotificationsController(
        service ?? DashboardService(),
        Get.find<AuthController>(),
      ),
    );
    Get.lazyPut(
      () => WalletController(
        service ?? DashboardService(),
        Get.find<AuthController>(),
      ),
    );
  }
}
