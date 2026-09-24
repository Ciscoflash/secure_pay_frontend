enum Period {
  week('This Week', 'week'),
  month('This Month', 'month'),
  year('This Year', 'year');

  const Period(this.label, this.noun);

  final String label;

  /// Used in "Vs last {noun}".
  final String noun;
}

class StatValue {
  const StatValue({
    required this.current,
    required this.previous,
    this.changePct,
  });

  final int current;
  final int previous;

  /// Null when there is nothing to compare against (previous is zero).
  final int? changePct;

  factory StatValue.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    return StatValue(
      current: (map['current'] as num?)?.toInt() ?? 0,
      previous: (map['previous'] as num?)?.toInt() ?? 0,
      changePct: (map['changePct'] as num?)?.toInt(),
    );
  }
}

class Overview {
  const Overview({
    required this.balance,
    required this.shipments,
    required this.exports,
    required this.imports,
  });

  /// Kobo.
  final int balance;
  final StatValue shipments;
  final StatValue exports;
  final StatValue imports;

  Overview copyWith({int? balance}) => Overview(
    balance: balance ?? this.balance,
    shipments: shipments,
    exports: exports,
    imports: imports,
  );

  factory Overview.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return Overview(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      shipments: StatValue.fromJson(stats['shipments']),
      exports: StatValue.fromJson(stats['exports']),
      imports: StatValue.fromJson(stats['imports']),
    );
  }
}

class Growth {
  const Growth({required this.labels, required this.values});

  final List<String> labels;
  final List<double> values;

  bool get isEmpty => values.every((v) => v == 0);

  factory Growth.fromJson(Map<String, dynamic> json) => Growth(
    labels: [for (final l in (json['labels'] as List? ?? const [])) '$l'],
    values: [
      for (final v in (json['values'] as List? ?? const []))
        (v as num).toDouble(),
    ],
  );
}
