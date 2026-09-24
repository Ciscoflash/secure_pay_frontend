import 'package:get/get.dart';
import '../models/wallet.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import 'auth_controller.dart';
import 'dashboard_controller.dart' show Section;
class WalletController extends GetxController {
  WalletController(this._service, this._auth);
  final DashboardService _service;
  final AuthController _auth;
  final account = Rx<Section<WalletAccount>>(const Section.loading());
  @override
  void onInit() {
    super.onInit();
    load();
  }
  Future<void> load() async {
    account.value = Section.loading(account.value.data);
    try {
      account.value = Section.data(await _authed(_service.wallet));
    } on ApiException catch (e) {
      account.value = Section.error(e.message, account.value.data);
    }
  }
  Future<String?> fundWallet(double amountNaira) async {
    try {
      final balance = await _authed(
        (token) => _service.fundWallet(token, amountNaira),
      );
      _apply((wallet) => wallet.copyWith(balance: balance));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
  void _apply(WalletAccount Function(WalletAccount w) change) {
    final current = account.value.data;
    if (current == null) return;
    account.value = Section.data(change(current));
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