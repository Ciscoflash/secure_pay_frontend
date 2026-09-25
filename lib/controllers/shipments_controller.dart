import 'dart:async';
import 'package:get/get.dart';
import '../models/section.dart';
import '../models/shipment.dart';
import '../services/api_client.dart';
import '../services/shipment_service.dart';
import 'authenticated_controller.dart';
import 'dashboard_controller.dart';
class ShipmentsController extends AuthenticatedController {
  ShipmentsController({required this.service, required super.auth});
  final ShipmentService service;
  static const pageSize = 10;
  final page = Rx<Section<ShipmentPage>>(const Section.loading());
  final status = Rxn<ShipmentStatus>();
  final direction = Rxn<ShipmentDirection>();
  final search = ''.obs;
  final currentPage = 1.obs;
  final paying = <String>{}.obs;
  Timer? _debounce;
  @override
  void onInit() {
    super.onInit();
    load();
  }
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
  void setStatus(ShipmentStatus? value) {
    if (status.value == value) return;
    status.value = value;
    load(page: 1);
  }
  void setDirection(ShipmentDirection? value) {
    if (direction.value == value) return;
    direction.value = value;
    load(page: 1);
  }
  void setSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (search.value == value.trim()) return;
      search.value = value.trim();
      load(page: 1);
    });
  }
  Future<void> goToPage(int page) async {
    final data = this.page.value.data;
    if (data == null || page < 1 || page > data.totalPages) return;
    load(page: page);
  }
  Future<void> load({int? page}) async {
    final target = page ?? currentPage.value;
    final previous = this.page.value;
    this.page.value = Section.loading(previous.data);
    try {
      final result = await authed(
        (token) => service.shipments(
          token,
          page: target,
          limit: pageSize,
          status: status.value,
          direction: direction.value,
          search: search.value,
        ),
      );
      currentPage.value = result.page;
      this.page.value = Section.data(result);
    } on ApiException catch (error) {
      this.page.value = Section.error(error.message, previous.data);
    }
  }
  Future<EstimateResult> estimate({
    required Place pickUp,
    required Place deliveryTo,
  }) => authed(
    (token) => service.estimate(token, pickUp: pickUp, deliveryTo: deliveryTo),
  );
  Future<CreateShipmentResult> create({
    required String sender,
    required String receiver,
    required Place pickUp,
    required Place deliveryTo,
  }) async {
    final result = await authed(
      (token) => service.createShipment(
        token,
        sender: sender,
        receiver: receiver,
        pickUp: pickUp,
        deliveryTo: deliveryTo,
      ),
    );
    await load(page: 1);
    _syncDashboard();
    return result;
  }
  Future<String?> payShipment(Shipment shipment) async {
    paying.add(shipment.id);
    try {
      final result = await authed(
        (token) => service.payShipment(token, shipment.id),
      );
      _replace(result.shipment);
      _syncDashboard();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } finally {
      paying.remove(shipment.id);
    }
  }
  Future<Shipment> shipmentDetails(String id) =>
      authed((token) => service.shipment(token, id));
  void _replace(Shipment updated) {
    final current = page.value.data;
    if (current == null) return;
    page.value = Section.data(
      ShipmentPage(
        items: [
          for (final s in current.items) s.id == updated.id ? updated : s,
        ],
        total: current.total,
        page: current.page,
        totalPages: current.totalPages,
      ),
    );
  }
  void _syncDashboard() {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    dashboard.loadShipments();
    dashboard.loadOverview();
  }
}