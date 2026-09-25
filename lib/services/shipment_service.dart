import '../models/shipment.dart';
import 'api_client.dart';
class ShipmentService {
  ShipmentService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<ShipmentPage> shipments(
    String token, {
    int page = 1,
    int limit = 3,
    ShipmentStatus? status,
    ShipmentDirection? direction,
    String? search,
  }) async {
    final envelope = await _client.get(
      '/shipments',
      token: token,
      query: {
        'page': '$page',
        'limit': '$limit',
        if (status != null) 'status': status.apiValue,
        if (direction != null) 'direction': direction.apiValue,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
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
      page: meta is Map<String, dynamic>
          ? (meta['page'] as num?)?.toInt() ?? 1
          : 1,
      totalPages: meta is Map<String, dynamic>
          ? (meta['totalPages'] as num?)?.toInt() ?? 1
          : 1,
    );
  }
  Future<Shipment> shipment(String token, String id) async {
    final envelope = await _client.get(
      '/shipments/${Uri.encodeComponent(id)}',
      token: token,
    );
    return Shipment.fromJson(ApiClient.dataOf(envelope));
  }
  Future<EstimateResult> estimate(
    String token, {
    required Place pickUp,
    required Place deliveryTo,
  }) async {
    final envelope = await _client.post(
      '/shipments/estimate',
      {
        'pickUp': {'name': pickUp.name, 'countryCode': pickUp.countryCode},
        'deliveryTo': {
          'name': deliveryTo.name,
          'countryCode': deliveryTo.countryCode,
        },
      },
      token: token,
    );
    final data = ApiClient.dataOf(envelope);
    return EstimateResult(
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      direction: ShipmentDirection.fromApi(data['direction']),
    );
  }
  Future<CreateShipmentResult> createShipment(
    String token, {
    required String sender,
    required String receiver,
    required Place pickUp,
    required Place deliveryTo,
  }) async {
    final envelope = await _client.post(
      '/shipments',
      {
        'sender': sender,
        'receiver': receiver,
        'pickUp': {'name': pickUp.name, 'countryCode': pickUp.countryCode},
        'deliveryTo': {
          'name': deliveryTo.name,
          'countryCode': deliveryTo.countryCode,
        },
      },
      token: token,
    );
    final data = ApiClient.dataOf(envelope);
    return CreateShipmentResult(
      shipment: Shipment.fromJson(
        (data['shipment'] as Map<String, dynamic>?) ?? const {},
      ),
      balance: (data['balance'] as num?)?.toInt() ?? 0,
    );
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