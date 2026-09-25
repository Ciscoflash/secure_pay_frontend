import 'api_client.dart';
import 'dashboard_service.dart';
import 'notification_service.dart';
import 'shipment_service.dart';
import 'wallet_service.dart';
class DataServices {
  DataServices({ApiClient? client})
    : dashboard = DashboardService(client: client),
      shipments = ShipmentService(client: client),
      wallet = WalletService(client: client),
      notifications = NotificationService(client: client);
  final DashboardService dashboard;
  final ShipmentService shipments;
  final WalletService wallet;
  final NotificationService notifications;
}