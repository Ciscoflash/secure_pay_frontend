enum ShipmentStatus {
  pending('pending', 'Pending'),
  inTransit('in_transit', 'In-Transit'),
  delayed('delayed', 'Delayed'),
  delivered('delivered', 'Delivered');
  const ShipmentStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;
  static ShipmentStatus fromApi(Object? value) => values.firstWhere(
    (s) => s.apiValue == value,
    orElse: () => ShipmentStatus.pending,
  );
}
enum ShipmentDirection {
  export('export', 'Export'),
  import('import', 'Import'),
  local('local', 'Local');
  const ShipmentDirection(this.apiValue, this.label);
  final String apiValue;
  final String label;
  static ShipmentDirection fromApi(Object? value) => values.firstWhere(
    (d) => d.apiValue == value,
    orElse: () => ShipmentDirection.local,
  );
}
class ShipmentPage {
  const ShipmentPage({
    required this.items,
    required this.total,
    this.page = 1,
    this.totalPages = 1,
  });
  final List<Shipment> items;
  final int total;
  final int page;
  final int totalPages;
}
class PaymentResult {
  const PaymentResult({required this.shipment, required this.balance});
  final Shipment shipment;
  final int balance;
}
class EstimateResult {
  const EstimateResult({required this.amount, required this.direction});
  final int amount;
  final ShipmentDirection direction;
}
class CreateShipmentResult {
  const CreateShipmentResult({required this.shipment, required this.balance});
  final Shipment shipment;
  final int balance;
}
class Place {
  const Place(this.name, {this.countryCode = 'NG'});
  final String name;
  final String countryCode;
  factory Place.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return Place(
      map['name']?.toString() ?? '',
      countryCode: map['countryCode']?.toString() ?? '',
    );
  }
}
class TrackingEvent {
  const TrackingEvent({
    required this.status,
    required this.note,
    required this.at,
  });
  final ShipmentStatus status;
  final String note;
  final DateTime at;
  factory TrackingEvent.fromJson(Map<String, dynamic> json) => TrackingEvent(
    status: ShipmentStatus.fromApi(json['status']),
    note: json['note']?.toString() ?? '',
    at: DateTime.tryParse(json['at']?.toString() ?? '')?.toLocal() ??
        DateTime.now(),
  );
}
class Shipment {
  const Shipment({
    required this.id,
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.pickUp,
    required this.deliveryTo,
    required this.amount,
    required this.status,
    required this.direction,
    required this.processingHours,
    required this.isPaid,
    this.paidAt,
    this.createdAt,
    this.events = const [],
  });
  final String id;
  final String trackingId;
  final String sender;
  final String receiver;
  final Place pickUp;
  final Place deliveryTo;
  final int amount;
  final ShipmentStatus status;
  final ShipmentDirection direction;
  final num processingHours;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final List<TrackingEvent> events;
  factory Shipment.fromJson(Map<String, dynamic> json) {
    final raw = json['events'];
    return Shipment(
      id: json['id']?.toString() ?? '',
      trackingId: json['trackingId']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      receiver: json['receiver']?.toString() ?? '',
      pickUp: Place.fromJson(json['pickUp']),
      deliveryTo: Place.fromJson(json['deliveryTo']),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: ShipmentStatus.fromApi(json['status']),
      direction: ShipmentDirection.fromApi(json['direction']),
      processingHours: (json['processingHours'] as num?) ?? 0,
      isPaid: json['isPaid'] == true,
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? '')?.toLocal(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')
          ?.toLocal(),
      events: raw is List
          ? [
              for (final event in raw.whereType<Map<String, dynamic>>())
                TrackingEvent.fromJson(event),
            ]
          : const [],
    );
  }
}