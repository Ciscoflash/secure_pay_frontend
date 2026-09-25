import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/shipments_controller.dart';
import '../controllers/wallet_controller.dart';
import '../services/data_services.dart';
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    final services = Get.find<DataServices>();
    final auth = Get.find<AuthController>();
    Get.lazyPut(
      () => DashboardController(
        dashboard: services.dashboard,
        shipmentService: services.shipments,
        wallet: services.wallet,
        auth: auth,
      ),
    );
    Get.lazyPut(
      () => ShipmentsController(service: services.shipments, auth: auth),
    );
    Get.lazyPut(
      () => NotificationsController(service: services.notifications, auth: auth),
    );
    Get.lazyPut(
      () => WalletController(service: services.wallet, auth: auth),
    );
  }
}