import 'package:get/get.dart';
import '../models/dashboard.dart';
import '../models/shipment.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import 'auth_controller.dart';
class Section<T> {
  const Section.loading([this.data]) : error = null, isLoading = true;
  const Section.data(T this.data) : error = null, isLoading = false;
  const Section.error(this.error, [this.data]) : isLoading = false;
  final T? data;
  final String? error;
  final bool isLoading;
}
class DashboardController extends GetxController {
  DashboardController(this._service, this._auth);
  final DashboardService _service;
  final AuthController _auth;
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
  Future<void> loadOverview() =>
      _load(overview, (token) => _service.overview(token, period.value));
  Future<void> loadGrowth() =>
      _load(growth, (token) => _service.growth(token, range.value));
  Future<void> loadShipments() => _load(
    shipments,
    (token) => _service.shipments(
      token,
      limit: showAllShipments.value ? expandedLimit : recentLimit,
    ),
  );
  Future<Shipment> shipmentDetails(String id) =>
      _authed((token) => _service.shipment(token, id));
  Future<String?> payShipment(Shipment shipment) async {
    paying.add(shipment.id);
    try {
      final result = await _authed(
        (token) => _service.payShipment(token, shipment.id),
      );
      _replaceShipment(result.shipment);
      _setBalance(result.balance);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      paying.remove(shipment.id);
    }
  }
  Future<String?> fundWallet(double amountNaira) async {
    try {
      final balance = await _authed(
        (token) => _service.fundWallet(token, amountNaira),
      );
      _setBalance(balance);
      return null;
    } on ApiException catch (e) {
      return e.message;
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
      section.value = Section.data(await _authed(fetch));
    } on ApiException catch (e) {
      section.value = Section.error(e.message, section.value.data);
    }
  }
  Future<T> _authed<T>(Future<T> Function(String token) call) async {
    final token = _auth.token;
    if (token == null) {
      await _auth.handleUnauthorized();
      throw ApiException('Please sign in again.', statusCode: 401);
    }
    try {
      return await call(token);
    } on ApiException catch (e) {
      if (e.statusCode == 401) await _auth.handleUnauthorized();
      rethrow;
    }
  }
}
