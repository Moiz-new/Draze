// lib/landlord/models/due_model.dart

class Due {
  final String id;
  final String landlordId;
  final String name;
  final String type; // 'fixed' or 'variable'
  final String status; // 'ACTIVE' or 'INACTIVE'
  final double? amount; // Only for fixed type
  final DateTime createdAt;
  final DateTime updatedAt;

  Due({
    required this.id,
    required this.landlordId,
    required this.name,
    required this.type,
    required this.status,
    this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Due.fromJson(Map<String, dynamic> json) {
    return Due(
      id: json['_id'] ?? '',
      landlordId: json['landlordId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'fixed',
      status: json['status'] ?? 'ACTIVE',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'landlordId': landlordId,
      'name': name,
      'type': type,
      'status': status,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Due copyWith({
    String? id,
    String? landlordId,
    String? name,
    String? type,
    String? status,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Due(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isFixed => type == 'fixed';
  bool get isVariable => type == 'variable';
}