class EnquiryModel {
  final String id;
  final String hotelId;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final int numberOfRooms;
  final String enquiryType;
  final String message;
  final String status;
  final String contactPreference;
  final BudgetRange budgetRange;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  EnquiryModel({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.numberOfRooms,
    required this.enquiryType,
    required this.message,
    required this.status,
    required this.contactPreference,
    required this.budgetRange,
    required this.createdAt,
    required this.updatedAt,
    this.version = 0,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: json['_id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      checkInDate: DateTime.parse(json['checkInDate'] ?? DateTime.now().toIso8601String()),
      checkOutDate: DateTime.parse(json['checkOutDate'] ?? DateTime.now().toIso8601String()),
      numberOfGuests: json['numberOfGuests'] ?? 0,
      numberOfRooms: json['numberOfRooms'] ?? 0,
      enquiryType: json['enquiryType'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      contactPreference: json['contactPreference'] ?? '',
      budgetRange: BudgetRange.fromJson(json['budgetRange'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hotelId': hotelId,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'numberOfRooms': numberOfRooms,
      'enquiryType': enquiryType,
      'message': message,
      'status': status,
      'contactPreference': contactPreference,
      'budgetRange': budgetRange.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  // Utility getters
  bool get isUpcoming => checkInDate.isAfter(DateTime.now());

  bool get isPast => checkOutDate.isBefore(DateTime.now());

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isConfirmed => status.toLowerCase() == 'confirmed';

  bool get isRoomEnquiry => enquiryType.toLowerCase() == 'room';

  bool get isBanquetEnquiry => enquiryType.toLowerCase() == 'banquet';

  String get displayTitle => isRoomEnquiry ? 'Room Booking' : 'Banquet Hall Booking';

  String get displayDate {
    final checkIn = '${checkInDate.day}/${checkInDate.month}/${checkInDate.year}';
    final checkOut = '${checkOutDate.day}/${checkOutDate.month}/${checkOutDate.year}';
    return '$checkIn - $checkOut';
  }

  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;

  String get budgetRangeText => '₹${budgetRange.min} - ₹${budgetRange.max}';
}

class BudgetRange {
  final int min;
  final int max;

  BudgetRange({
    required this.min,
    required this.max,
  });

  factory BudgetRange.fromJson(Map<String, dynamic> json) {
    return BudgetRange(
      min: json['min'] ?? 0,
      max: json['max'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}

// Response wrapper for the API
class EnquiriesResponse {
  final bool success;
  final String message;
  final List<EnquiryModel> data;

  EnquiriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EnquiriesResponse.fromJson(Map<String, dynamic> json) {
    return EnquiriesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((enquiry) => EnquiryModel.fromJson(enquiry as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}