import 'package:get/get.dart';
import '../models/section.dart';
import '../models/wallet.dart';
import '../services/api_client.dart';
import '../services/wallet_service.dart';
import 'authenticated_controller.dart';
class WalletController extends AuthenticatedController {
  WalletController({required this.service, required super.auth});
  final WalletService service;
  final account = Rx<Section<WalletAccount>>(const Section.loading());
  @override
  void onInit() {
    super.onInit();
    load();
  }
  Future<void> load() async {
    account.value = Section.loading(account.value.data);
    try {
      account.value = Section.data(await authed(service.wallet));
    } on ApiException catch (error) {
      account.value = Section.error(error.message, account.value.data);
    }
  }
  Future<String?> fundWallet(double amountNaira) async {
    try {
      final balance = await authed(
        (token) => service.fundWallet(token, amountNaira),
      );
      _apply((wallet) => wallet.copyWith(balance: balance));
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }
  void _apply(WalletAccount Function(WalletAccount w) change) {
    final current = account.value.data;
    if (current == null) return;
    account.value = Section.data(change(current));
  }
}