import '../models/wallet.dart';
import 'api_client.dart';
class WalletService {
  WalletService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<int> fundWallet(String token, double amountNaira) async {
    final envelope = await _client.post('/wallet/fund', {
      'amount': amountNaira,
    }, token: token);
    return (ApiClient.dataOf(envelope)['balance'] as num?)?.toInt() ?? 0;
  }
  Future<WalletAccount> wallet(String token) async {
    final envelope = await _client.get('/wallet', token: token);
    return WalletAccount.fromJson(ApiClient.dataOf(envelope));
  }
}