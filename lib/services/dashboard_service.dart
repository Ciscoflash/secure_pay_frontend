import '../models/dashboard.dart';
import '../models/notification.dart';
import '../models/shipment.dart';
import '../models/wallet.dart';
import 'api_client.dart';
class ShipmentPage {
  const ShipmentPage({required this.items, required this.total});
  final List<Shipment> items;
  final int total;
}
class PaymentResult {
  const PaymentResult({required this.shipment, required this.balance});
  final Shipment shipment;
  final int balance;
}
class DashboardService {
  DashboardService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<Overview> overview(String token, Period period) async {
    final envelope = await _client.get(
      '/dashboard/overview',
      token: token,
      query: {'period': period.name},
    );
    return Overview.fromJson(_data(envelope));
  }
  Future<Growth> growth(String token, Period range) async {
    final envelope = await _client.get(
      '/dashboard/growth',
      token: token,
      query: {'range': range.name},
    );
    return Growth.fromJson(_data(envelope));
  }
  Future<ShipmentPage> shipments(
    String token, {
    int page = 1,
    int limit = 3,
  }) async {
    final envelope = await _client.get(
      '/shipments',
      token: token,
      query: {'page': '$page', 'limit': '$limit'},
    );
    final items = envelope['data'];
    final meta = envelope['meta'];
    return ShipmentPage(
      items: [
        if (items is List)
          for (final item in items.whereType<Map<String, dynamic>>())
            Shipment.fromJson(item),
      ],
      total: meta is Map<String, dynamic>
          ? (meta['total'] as num?)?.toInt() ?? 0
          : 0,
    );
  }
  Future<Shipment> shipment(String token, String id) async {
    final envelope = await _client.get(
      '/shipments/${Uri.encodeComponent(id)}',
      token: token,
    );
    return Shipment.fromJson(_data(envelope));
  }
  Future<PaymentResult> payShipment(String token, String id) async {
    final envelope = await _client.post(
      '/shipments/${Uri.encodeComponent(id)}/pay',
      const {},
      token: token,
    );
    final data = _data(envelope);
    return PaymentResult(
      shipment: Shipment.fromJson(
        (data['shipment'] as Map<String, dynamic>?) ?? const {},
      ),
      balance: (data['balance'] as num?)?.toInt() ?? 0,
    );
  }
  Future<int> fundWallet(String token, double amountNaira) async {
    final envelope = await _client.post('/wallet/fund', {
      'amount': amountNaira,
    }, token: token);
    return (_data(envelope)['balance'] as num?)?.toInt() ?? 0;
  }
  Future<WalletAccount> wallet(String token) async {
    final envelope = await _client.get('/wallet', token: token);
    return WalletAccount.fromJson(_data(envelope));
  }
  Future<NotificationPage> notifications(String token) async {
    final envelope = await _client.get('/notifications', token: token);
    final items = envelope['data'];
    final meta = envelope['meta'];
    return NotificationPage(
      items: [
        if (items is List)
          for (final item in items.whereType<Map<String, dynamic>>())
            AppNotification.fromJson(item),
      ],
      unread: meta is Map<String, dynamic>
          ? (meta['unread'] as num?)?.toInt() ?? 0
          : 0,
    );
  }
  Future<void> markNotificationRead(String token, String id) async {
    await _client.post(
      '/notifications/${Uri.encodeComponent(id)}/read',
      const {},
      token: token,
    );
  }
  Future<void> markAllNotificationsRead(String token) async {
    await _client.post(
      '/notifications/read-all',
      const {},
      token: token,
    );
  }
  Map<String, dynamic> _data(Map<String, dynamic> envelope) {
    final data = envelope['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Unexpected response from the server.');
    }
    return data;
  }
}
