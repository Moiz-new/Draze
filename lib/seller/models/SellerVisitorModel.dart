class SellerVisitorModel {
  final String id;
  final UserInfo? userId;
  final PropertyInfo? propertyId;
  final String name;
  final String? email;
  final String mobile;
  final DateTime scheduledDate;
  final String purpose;
  final String notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SellerVisitorModel({
    required this.id,
    this.userId,
    this.propertyId,
    required this.name,
    this.email,
    required this.mobile,
    required this.scheduledDate,
    required this.purpose,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerVisitorModel.fromJson(Map<String, dynamic> json) {
    return SellerVisitorModel(
      id: json['_id'] ?? '',
      userId: json['userId'] != null && json['userId'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['userId'])
          : null,
      propertyId: json['propertyId'] != null && json['propertyId'] is Map<String, dynamic>
          ? PropertyInfo.fromJson(json['propertyId'])
          : null,
      name: json['name'] ?? '',
      email: json['email'],
      mobile: json['mobile'] ?? '',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : DateTime.now(),
      purpose: json['purpose'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId?.toJson(),
      'propertyId': propertyId?.toJson(),
      'name': name,
      'email': email,
      'mobile': mobile,
      'scheduledDate': scheduledDate.toIso8601String(),
      'purpose': purpose,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to check if visit is upcoming
  bool get isUpcoming => scheduledDate.isAfter(DateTime.now());

  // Helper method to check if visit is past
  bool get isPast => scheduledDate.isBefore(DateTime.now());

  // Helper method to check if visit is today
  bool get isToday {
    final now = DateTime.now();
    final scheduleDate = scheduledDate;
    return scheduleDate.year == now.year &&
        scheduleDate.month == now.month &&
        scheduleDate.day == now.day;
  }

  // Copy with method for updating
  SellerVisitorModel copyWith({
    String? id,
    UserInfo? userId,
    PropertyInfo? propertyId,
    String? name,
    String? email,
    String? mobile,
    DateTime? scheduledDate,
    String? purpose,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerVisitorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserInfo {
  final String id;
  final String email;

  UserInfo({
    required this.id,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserInfo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PropertyInfo {
  final String id;
  final String name;
  final String address;

  PropertyInfo({
    required this.id,
    required this.name,
    required this.address,
  });

  factory PropertyInfo.fromJson(Map<String, dynamic> json) {
    return PropertyInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PropertyInfo &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}