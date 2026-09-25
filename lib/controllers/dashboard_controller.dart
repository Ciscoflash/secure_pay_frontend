import 'package:get/get.dart';
import '../models/dashboard.dart';
import '../models/section.dart';
import '../models/shipment.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import '../services/shipment_service.dart';
import '../services/wallet_service.dart';
import 'authenticated_controller.dart';
class DashboardController extends AuthenticatedController {
  DashboardController({
    required this.dashboard,
    required this.shipmentService,
    required this.wallet,
    required super.auth,
  });
  final DashboardService dashboard;
  final ShipmentService shipmentService;
  final WalletService wallet;
  static const recentLimit = 3;
  static const expandedLimit = 20;
  final period = Period.month.obs;
  final range = Period.year.obs;
  final showAllShipments = false.obs;
  final overview = Rx<Section<Overview>>(const Section.loading());
  final growth = Rx<Section<Growth>>(const Section.loading());
  final shipments = Rx<Section<ShipmentPage>>(const Section.loading());
  final paying = <String>{}.obs;
  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }
  Future<void> refreshAll() =>
      Future.wait([loadOverview(), loadGrowth(), loadShipments()]);
  void setPeriod(Period value) {
    if (period.value == value) return;
    period.value = value;
    loadOverview();
  }
  void setRange(Period value) {
    if (range.value == value) return;
    range.value = value;
    loadGrowth();
  }
  void toggleShowAll() {
    showAllShipments.toggle();
    loadShipments();
  }
  Future<void> loadOverview() => _load(
    overview,
    (token) => dashboard.overview(token, period.value),
  );
  Future<void> loadGrowth() =>
      _load(growth, (token) => dashboard.growth(token, range.value));
  Future<void> loadShipments() => _load(
    shipments,
    (token) => shipmentService.shipments(
      token,
      limit: showAllShipments.value ? expandedLimit : recentLimit,
    ),
  );
  Future<Shipment> shipmentDetails(String id) =>
      authed((token) => shipmentService.shipment(token, id));
  Future<String?> payShipment(Shipment shipment) async {
    paying.add(shipment.id);
    try {
      final result = await authed(
        (token) => shipmentService.payShipment(token, shipment.id),
      );
      _replaceShipment(result.shipment);
      _setBalance(result.balance);
      return null;
    } on ApiException catch (error) {
      return error.message;
    } finally {
      paying.remove(shipment.id);
    }
  }
  Future<String?> fundWallet(double amountNaira) async {
    try {
      final balance = await authed(
        (token) => wallet.fundWallet(token, amountNaira),
      );
      _setBalance(balance);
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }
  void _setBalance(int balance) {
    final current = overview.value.data;
    if (current != null) {
      overview.value = Section.data(current.copyWith(balance: balance));
    }
  }
  void _replaceShipment(Shipment updated) {
    final page = shipments.value.data;
    if (page == null) return;
    shipments.value = Section.data(
      ShipmentPage(
        items: [for (final s in page.items) s.id == updated.id ? updated : s],
        total: page.total,
      ),
    );
  }
  Future<void> _load<T>(
    Rx<Section<T>> section,
    Future<T> Function(String token) fetch,
  ) async {
    section.value = Section.loading(section.value.data);
    try {
      section.value = Section.data(await authed(fetch));
    } on ApiException catch (error) {
      section.value = Section.error(error.message, section.value.data);
    }
  }
}