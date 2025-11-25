class VisitorModel {
  final String id;
  final String userId;
  final PropertyInfo? propertyId;
  final LandlordInfo? landlordId;
  final DateTime visitDate;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String visitDateFormatted;
  final String statusText;
  final bool isUpcoming;
  final bool isPast;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final String? completionNotes;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final FeedbackInfo? feedback;

  VisitorModel({
    required this.id,
    required this.userId,
    this.propertyId,
    this.landlordId,
    required this.visitDate,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.visitDateFormatted,
    required this.statusText,
    required this.isUpcoming,
    required this.isPast,
    this.confirmedAt,
    this.completedAt,
    this.completionNotes,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
    this.feedback,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      propertyId: json['propertyId'] != null && json['propertyId'] is Map<String, dynamic>
          ? PropertyInfo.fromJson(json['propertyId'])
          : null,
      landlordId: json['landlordId'] != null && json['landlordId'] is Map<String, dynamic>
          ? LandlordInfo.fromJson(json['landlordId'])
          : null,
      visitDate: json['visitDate'] != null
          ? DateTime.tryParse(json['visitDate']) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      visitDateFormatted: json['visitDateFormatted'] ?? '',
      statusText: json['statusText'] ?? '',
      isUpcoming: json['isUpcoming'] ?? false,
      isPast: json['isPast'] ?? false,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      completionNotes: json['completionNotes'],
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'])
          : null,
      cancelledBy: json['cancelledBy'],
      feedback: json['feedback'] != null && json['feedback'] is Map<String, dynamic>
          ? FeedbackInfo.fromJson(json['feedback'])
          : null,
    );
  }
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
}

class LandlordInfo {
  final String id;
  final String name;
  final String mobile;
  final String email;

  LandlordInfo({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
  });

  factory LandlordInfo.fromJson(Map<String, dynamic> json) {
    return LandlordInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class FeedbackInfo {
  final String comment;
  final DateTime givenAt;

  FeedbackInfo({
    required this.comment,
    required this.givenAt,
  });

  factory FeedbackInfo.fromJson(Map<String, dynamic> json) {
    return FeedbackInfo(
      comment: json['comment'] ?? '',
      givenAt: json['givenAt'] != null
          ? DateTime.tryParse(json['givenAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}