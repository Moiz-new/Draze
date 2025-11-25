// Add these fields to your existing Tenant model class

class Tenant {
  final String? id;
  final String propertyId;
  final String roomId;
  final String name;
  final String email;
  final String phone;
  final TenantStatus status;
  final DateTime startDate;
  final double monthlyRent;
  final double deposit;
  final String? notes;
  final List<String>? dueIds; // NEW: List of assigned due IDs
  final Map<String, double>? dueAmounts; // NEW: Map of dueId to amount (for variable dues)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tenant({
    this.id,
    required this.propertyId,
    required this.roomId,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.startDate,
    required this.monthlyRent,
    required this.deposit,
    this.notes,
    this.dueIds,
    this.dueAmounts,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Tenant to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'roomId': roomId,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'monthlyRent': monthlyRent,
      'deposit': deposit,
      'notes': notes,
      'dueIds': dueIds,
      'dueAmounts': dueAmounts,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create Tenant from JSON
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      propertyId: json['propertyId'],
      roomId: json['roomId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      status: TenantStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => TenantStatus.pending,
      ),
      startDate: DateTime.parse(json['startDate']),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      deposit: (json['deposit'] as num).toDouble(),
      notes: json['notes'],
      dueIds: json['dueIds'] != null
          ? List<String>.from(json['dueIds'])
          : null,
      dueAmounts: json['dueAmounts'] != null
          ? Map<String, double>.from(
        (json['dueAmounts'] as Map).map(
              (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ),
      )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Copy with method for easy updates
  Tenant copyWith({
    String? id,
    String? propertyId,
    String? roomId,
    String? name,
    String? email,
    String? phone,
    TenantStatus? status,
    DateTime? startDate,
    double? monthlyRent,
    double? deposit,
    String? notes,
    List<String>? dueIds,
    Map<String, double>? dueAmounts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      deposit: deposit ?? this.deposit,
      notes: notes ?? this.notes,
      dueIds: dueIds ?? this.dueIds,
      dueAmounts: dueAmounts ?? this.dueAmounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TenantStatus {
  active,
  pending,
  inactive;

  String get displayName {
    switch (this) {
      case TenantStatus.active:
        return 'Active';
      case TenantStatus.pending:
        return 'Pending';
      case TenantStatus.inactive:
        return 'Inactive';
    }
  }
}