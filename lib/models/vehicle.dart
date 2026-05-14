class Vehicle {
  final int? id;
  final String reg;
  final String type;
  final String taxPeriod;
  final String lastPaid;
  final String? notes;
  final String? receiptRef;
  final String createdAt;

  Vehicle({
    this.id,
    required this.reg,
    required this.type,
    required this.taxPeriod,
    required this.lastPaid,
    this.notes,
    this.receiptRef,
    required this.createdAt,
  });

  DateTime get expiryDate {
    final d = DateTime.parse(lastPaid);
    if (taxPeriod == 'monthly') {
      return DateTime(d.year, d.month + 1, d.day);
    }
    if (taxPeriod == 'quarterly') {
      return DateTime(d.year, d.month + 3, d.day);
    }
    return DateTime(d.year + 1, d.month, d.day);
  }

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  String get status {
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
    );
  }
}