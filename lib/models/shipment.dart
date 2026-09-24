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

enum ShipmentDirection { export, import, local }

class Place {
  const Place(this.name, {this.countryCode = 'NG'});

  final String name;

  /// ISO 3166-1 alpha-2 code, used for the flag.
  final String countryCode;

  factory Place.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return Place(
      map['name']?.toString() ?? '',
      countryCode: map['countryCode']?.toString() ?? '',
    );
  }
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
  });

  final String id;
  final String trackingId;
  final String sender;
  final String receiver;
  final Place pickUp;
  final Place deliveryTo;

  /// Kobo.
  final int amount;
  final ShipmentStatus status;
  final ShipmentDirection direction;
  final num processingHours;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime? createdAt;

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
    id: json['id']?.toString() ?? '',
    trackingId: json['trackingId']?.toString() ?? '',
    sender: json['sender']?.toString() ?? '',
    receiver: json['receiver']?.toString() ?? '',
    pickUp: Place.fromJson(json['pickUp']),
    deliveryTo: Place.fromJson(json['deliveryTo']),
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    status: ShipmentStatus.fromApi(json['status']),
    direction: ShipmentDirection.values.firstWhere(
      (d) => d.name == json['direction'],
      orElse: () => ShipmentDirection.local,
    ),
    processingHours: (json['processingHours'] as num?) ?? 0,
    isPaid: json['isPaid'] == true,
    paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? '')?.toLocal(),
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')
        ?.toLocal(),
  );
}
