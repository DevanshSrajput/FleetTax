class Vehicle {
  final int? id;
  final String reg;
  final String type;
  final String taxPeriod;
  final String lastPaid;
  final String? notes;
  final String? receiptRef;
  final String createdAt;
  final String? permitExpiry; // Vahan official permit expiry date

  // Cached computed values
  DateTime? _cachedExpiryDate;
  int? _cachedDaysLeft;
  String? _cachedStatus;

  Vehicle({
    this.id,
    required this.reg,
    required this.type,
    required this.taxPeriod,
    required this.lastPaid,
    this.notes,
    this.receiptRef,
    required this.createdAt,
    this.permitExpiry,
  });

  /// Returns the expiry date using 28-day-per-month arithmetic.
  DateTime get expiryDate {
    _cachedExpiryDate ??= _computeExpiryDate();
    return _cachedExpiryDate!;
  }

  DateTime _computeExpiryDate() {
    if (permitExpiry != null && permitExpiry!.isNotEmpty) {
      return DateTime.parse(permitExpiry!);
    }

    final d = DateTime.parse(lastPaid);
    final cycles = switch (taxPeriod) {
      'monthly' => 1,
      'quarterly' => 3,
      _ => 12,
    };

    // Start counting from the day AFTER payment, then add 28-day cycles
    return d.add(Duration(days: 1 + (cycles * 28)));
  }

  int get daysLeft {
    _cachedDaysLeft ??= _computeDaysLeft();
    return _cachedDaysLeft!;
  }

  int _computeDaysLeft() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  String get status {
    _cachedStatus ??= _computeStatus();
    return _cachedStatus!;
  }

  String _computeStatus() {
    if (daysLeft < 0) return 'expired';
    if (daysLeft <= 10) return 'soon';
    return 'valid';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'reg': reg,
        'type': type,
        'tax_period': taxPeriod,
        'last_paid': lastPaid,
        'notes': notes,
        'receipt_ref': receiptRef,
        'created_at': createdAt,
        'permit_expiry': permitExpiry,
      };

  factory Vehicle.fromMap(Map<String, dynamic> m) => Vehicle(
        id: m['id'],
        reg: m['reg'],
        type: m['type'],
        taxPeriod: m['tax_period'],
        lastPaid: m['last_paid'],
        notes: m['notes'],
        receiptRef: m['receipt_ref'],
        createdAt: m['created_at'],
        permitExpiry: m['permit_expiry'],
      );

  Vehicle copyWith({
    int? id,
    String? reg,
    String? type,
    String? taxPeriod,
    String? lastPaid,
    String? notes,
    String? receiptRef,
    String? createdAt,
    String? permitExpiry,
  }) {
    return Vehicle(
      id: id ?? this.id,
      reg: reg ?? this.reg,
      type: type ?? this.type,
      taxPeriod: taxPeriod ?? this.taxPeriod,
      lastPaid: lastPaid ?? this.lastPaid,
      notes: notes ?? this.notes,
      receiptRef: receiptRef ?? this.receiptRef,
      createdAt: createdAt ?? this.createdAt,
      permitExpiry: permitExpiry ?? this.permitExpiry,
    );
  }
}