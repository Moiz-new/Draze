class Visit {
  final String id;
  final String userId;
  final String propertyId;
  final String? landlordId;
  final String? name;
  final String? email;
  final String? mobile;
  final DateTime scheduledDate;
  final DateTime? visitDate;
  final String purpose;
  final String notes;
  final VisitStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final String visitDateFormatted;
  final String statusText;
  final bool isUpcoming;
  final bool isPast;
  final int version;

  Visit({
    required this.id,
    required this.userId,
    required this.propertyId,
    this.landlordId,
    this.name,
    this.email,
    this.mobile,
    required this.scheduledDate,
    this.visitDate,
    required this.purpose,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    required this.visitDateFormatted,
    required this.statusText,
    required this.isUpcoming,
    required this.isPast,
    this.version = 0,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      landlordId: json['landlordId'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      scheduledDate: DateTime.parse(json['scheduledDate'] ?? json['visitDate'] ?? DateTime.now().toIso8601String()),
      visitDate: json['visitDate'] != null ? DateTime.parse(json['visitDate']) : null,
      purpose: json['purpose'] ?? '',
      notes: json['notes'] ?? '',
      status: _parseVisitStatus(json['status'] ?? ''),
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

  static VisitStatus _parseVisitStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending confirmation':
        return VisitStatus.pending;
      case 'confirmed':
        return VisitStatus.confirmed;
      case 'scheduled':
        return VisitStatus.confirmed; // Treating scheduled as confirmed
      case 'completed':
        return VisitStatus.completed;
      case 'cancelled':
        return VisitStatus.cancelled;
      case 'rescheduled':
        return VisitStatus.rescheduled;
      default:
        return VisitStatus.pending;
    }
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
      'scheduledDate': scheduledDate.toIso8601String(),
      'visitDate': visitDate?.toIso8601String(),
      'purpose': purpose,
      'notes': notes,
      'status': _statusToString(status),
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

  String _statusToString(VisitStatus status) {
    switch (status) {
      case VisitStatus.pending:
        return 'pending';
      case VisitStatus.confirmed:
        return 'confirmed';
      case VisitStatus.completed:
        return 'completed';
      case VisitStatus.cancelled:
        return 'cancelled';
      case VisitStatus.rescheduled:
        return 'rescheduled';
    }
  }

  Visit copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? landlordId,
    String? name,
    String? email,
    String? mobile,
    DateTime? scheduledDate,
    DateTime? visitDate,
    String? purpose,
    String? notes,
    VisitStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    String? visitDateFormatted,
    String? statusText,
    bool? isUpcoming,
    bool? isPast,
    int? version,
  }) {
    return Visit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      visitDate: visitDate ?? this.visitDate,
      purpose: purpose ?? this.purpose,
      notes: notes ?? this.notes,
      status: status ?? this.status,
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
}

enum VisitStatus { pending, confirmed, completed, cancelled, rescheduled }

class VisitQuery {
  final String id;
  final String visitId;
  final String visitorName;
  final String message;
  final DateTime createdAt;
  final QueryStatus status;
  final String? response;
  final DateTime? respondedAt;

  VisitQuery({
    required this.id,
    required this.visitId,
    required this.visitorName,
    required this.message,
    required this.createdAt,
    required this.status,
    this.response,
    this.respondedAt,
  });

  factory VisitQuery.fromJson(Map<String, dynamic> json) {
    return VisitQuery(
      id: json['id'],
      visitId: json['visitId'],
      visitorName: json['visitorName'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      status: QueryStatus.values.firstWhere(
            (e) => e.toString() == 'QueryStatus.${json['status']}',
      ),
      response: json['response'],
      respondedAt:
      json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitId': visitId,
      'visitorName': visitorName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'response': response,
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}

enum QueryStatus { pending, responded }

class VisitsResponse {
  final bool success;
  final String message;
  final int totalVisits;
  final List<Visit> visits;
  final Pagination pagination;

  VisitsResponse({
    required this.success,
    required this.message,
    required this.totalVisits,
    required this.visits,
    required this.pagination,
  });

  factory VisitsResponse.fromJson(Map<String, dynamic> json) {
    return VisitsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      totalVisits: json['totalVisits'] ?? 0,
      visits: (json['visits'] as List<dynamic>?)
          ?.map((visit) => Visit.fromJson(visit as Map<String, dynamic>))
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

extension VisitStatusExtension on VisitStatus {
  String get displayName {
    switch (this) {
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.confirmed:
        return 'Confirmed';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
      case VisitStatus.rescheduled:
        return 'Rescheduled';
    }
  }
}

extension QueryStatusExtension on QueryStatus {
  String get displayName {
    switch (this) {
      case QueryStatus.pending:
        return 'Pending';
      case QueryStatus.responded:
        return 'Responded';
    }
  }
}