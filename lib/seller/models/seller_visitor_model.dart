class Visit {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyAddress;
  final String visitorName;
  final String visitorEmail;
  final String visitorPhone;
  final DateTime scheduledDate;
  final String timeSlot;
  final VisitStatus status;
  final String? notes;
  final String? specialRequests;
  final DateTime createdAt;
  final String? propertyImage;

  Visit({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyAddress,
    required this.visitorName,
    required this.visitorEmail,
    required this.visitorPhone,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.specialRequests,
    required this.createdAt,
    this.propertyImage,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      propertyId: json['propertyId'],
      propertyTitle: json['propertyTitle'],
      propertyAddress: json['propertyAddress'],
      visitorName: json['visitorName'],
      visitorEmail: json['visitorEmail'],
      visitorPhone: json['visitorPhone'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      timeSlot: json['timeSlot'],
      status: VisitStatus.values.firstWhere(
        (e) => e.toString() == 'VisitStatus.${json['status']}',
      ),
      notes: json['notes'],
      specialRequests: json['specialRequests'],
      createdAt: DateTime.parse(json['createdAt']),
      propertyImage: json['propertyImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'propertyAddress': propertyAddress,
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status.toString().split('.').last,
      'notes': notes,
      'specialRequests': specialRequests,
      'createdAt': createdAt.toIso8601String(),
      'propertyImage': propertyImage,
    };
  }

  Visit copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? propertyAddress,
    String? visitorName,
    String? visitorEmail,
    String? visitorPhone,
    DateTime? scheduledDate,
    String? timeSlot,
    VisitStatus? status,
    String? notes,
    String? specialRequests,
    DateTime? createdAt,
    String? propertyImage,
  }) {
    return Visit(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      visitorName: visitorName ?? this.visitorName,
      visitorEmail: visitorEmail ?? this.visitorEmail,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      propertyImage: propertyImage ?? this.propertyImage,
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
