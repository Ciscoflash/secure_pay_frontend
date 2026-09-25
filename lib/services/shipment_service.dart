import '../models/shipment.dart';
import 'api_client.dart';
class ShipmentService {
  ShipmentService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
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
    return Shipment.fromJson(ApiClient.dataOf(envelope));
  }
  Future<PaymentResult> payShipment(String token, String id) async {
    final envelope = await _client.post(
      '/shipments/${Uri.encodeComponent(id)}/pay',
      const {},
      token: token,
    );
    final data = ApiClient.dataOf(envelope);
    return PaymentResult(
      shipment: Shipment.fromJson(
        (data['shipment'] as Map<String, dynamic>?) ?? const {},
      ),
      balance: (data['balance'] as num?)?.toInt() ?? 0,
    );
  }
}