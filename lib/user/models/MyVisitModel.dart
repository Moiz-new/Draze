class MyVisitModel {
  final String id;
  final String userId;
  final String propertyId;
  final String? landlordId;
  final String? name;
  final String? email;
  final String? mobile;
  final DateTime? visitDate;
  final DateTime? scheduledDate;
  final String? purpose;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final String visitDateFormatted;
  final String statusText;
  final bool isUpcoming;
  final bool isPast;
  final int version;

  MyVisitModel({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.landlordId,
    this.name,
    this.email,
    this.mobile,
    this.visitDate,
    this.scheduledDate,
    this.purpose,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    required this.visitDateFormatted,
    required this.statusText,
    required this.isUpcoming,
    required this.isPast,
    this.version = 0,
  });

  factory MyVisitModel.fromJson(Map<String, dynamic> json) {
    return MyVisitModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      landlordId: json['landlordId'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      purpose: json['purpose'],
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      visitDateFormatted: json['visitDateFormatted'] ?? '',
      statusText: json['statusText'] ?? '',
      isUpcoming: json['isUpcoming'] ?? false,
      isPast: json['isPast'] ?? false,
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'propertyId': propertyId,
      'landlordId': landlordId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'visitDate': visitDate?.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'purpose': purpose,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'visitDateFormatted': visitDateFormatted,
      'statusText': statusText,
      'isUpcoming': isUpcoming,
      'isPast': isPast,
      '__v': version,
    };
  }

  MyVisitModel copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? landlordId,
    String? name,
    String? email,
    String? mobile,
    DateTime? visitDate,
    DateTime? scheduledDate,
    String? purpose,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    String? visitDateFormatted,
    String? statusText,
    bool? isUpcoming,
    bool? isPast,
    int? version,
  }) {
    return MyVisitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      visitDate: visitDate ?? this.visitDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      visitDateFormatted: visitDateFormatted ?? this.visitDateFormatted,
      statusText: statusText ?? this.statusText,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      isPast: isPast ?? this.isPast,
      version: version ?? this.version,
    );
  }

  // Utility getters
  DateTime get effectiveDate => visitDate ?? scheduledDate ?? createdAt;

  bool get hasVisitorInfo => name != null && mobile != null;

  String get displayTitle => purpose ?? 'Property Visit';

  String get displayDate => visitDateFormatted.isNotEmpty
      ? visitDateFormatted
      : effectiveDate.toString();

  bool get isConfirmed => status.toLowerCase() == 'confirmed';

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isScheduled => status.toLowerCase() == 'scheduled';
}

// Response wrapper for the API
class MyVisitsResponse {
  final bool success;
  final String message;
  final int totalVisits;
  final List<MyVisitModel> visits;
  final Pagination pagination;

  MyVisitsResponse({
    required this.success,
    required this.message,
    required this.totalVisits,
    required this.visits,
    required this.pagination,
  });

  factory MyVisitsResponse.fromJson(Map<String, dynamic> json) {
    return MyVisitsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalVisits: json['totalVisits'] ?? 0,
      visits: (json['visits'] as List<dynamic>?)
          ?.map((visit) => MyVisitModel.fromJson(visit as Map<String, dynamic>))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

// Optional: If you need to fetch property/landlord details separately
class Property {
  final String id;
  final String name;
  final String address;
  final String? type;
  final String? city;
  final String? state;

  Property({
    required this.id,
    required this.name,
    required this.address,
    this.type,
    this.city,
    this.state,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      type: json['type'],
      city: json['city'],
      state: json['state'],
    );
  }
}

class Landlord {
  final String id;
  final String name;
  final String mobile;
  final String email;

  Landlord({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
  });

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
    );
  }
}