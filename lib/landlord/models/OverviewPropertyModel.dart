class OverviewPropertyModel {
  final String id;
  final String propertyId;
  final String? pinCode;
  final String landlordId;
  final String name;
  final String type;
  final String address;
  final String pincode;
  final String city;
  final String state;
  final String description;
  final List<String>? images;
  final int totalRooms;
  final int totalBeds;
  final double monthlyCollection;
  final double pendingDues;
  final int totalCapacity;
  final int occupiedSpace;
  final bool isActive;
  final List<dynamic> rooms;
  final RatingSummary? ratingSummary;
  final int commentCount;
  final String? contactNumber;
  final String? email;
  final List<String>? amenities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OverviewPropertyModel({
    required this.id,
    this.pinCode,
    required this.propertyId,
    required this.landlordId,
    required this.name,
    required this.type,
    required this.address,
    required this.pincode,
    required this.city,
    required this.state,
    required this.description,
    this.images,
    required this.totalRooms,
    required this.totalBeds,
    required this.monthlyCollection,
    required this.pendingDues,
    required this.totalCapacity,
    required this.occupiedSpace,
    required this.isActive,
    required this.rooms,
    this.ratingSummary,
    required this.commentCount,
    this.contactNumber,
    this.email,
    this.amenities,
    this.createdAt,
    this.updatedAt,
  });

  factory OverviewPropertyModel.fromJson(Map<String, dynamic> json) {
    return OverviewPropertyModel(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      pincode: json['pinCode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds'] ?? 0,
      monthlyCollection: (json['monthlyCollection'] ?? 0).toDouble(),
      pendingDues: (json['pendingDues'] ?? 0).toDouble(),
      totalCapacity: json['totalCapacity'] ?? 0,
      pinCode: json['pinCode'] as String?,
      occupiedSpace: json['occupiedSpace'] ?? 0,
      isActive: json['isActive'] ?? false,
      rooms: json['rooms'] ?? [],
      ratingSummary:
          json['ratingSummary'] != null
              ? RatingSummary.fromJson(json['ratingSummary'])
              : null,
      commentCount: json['commentCount'] ?? 0,
      contactNumber: json['contactNumber'],
      email: json['email'],
      amenities:
          json['amenities'] != null
              ? List<String>.from(json['amenities'])
              : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'propertyId': propertyId,
      'landlordId': landlordId,
      'name': name,
      'type': type,
      'address': address,
      'pinCode': pincode,
      'city': city,
      'state': state,
      'description': description,
      'images': images,
      'totalRooms': totalRooms,
      'totalBeds': totalBeds,
      'monthlyCollection': monthlyCollection,
      'pendingDues': pendingDues,
      'totalCapacity': totalCapacity,
      'occupiedSpace': occupiedSpace,
      'isActive': isActive,
      'rooms': rooms,
      'ratingSummary': ratingSummary?.toJson(),
      'commentCount': commentCount,
      'contactNumber': contactNumber,
      'email': email,
      'amenities': amenities,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OverviewPropertyModel copyWith({
    String? id,
    String? propertyId,
    String? landlordId,
    String? name,
    String? type,
    String? address,
    String? pincode,
    String? city,
    String? state,
    String? description,
    List<String>? images,
    int? totalRooms,
    int? totalBeds,
    double? monthlyCollection,
    double? pendingDues,
    int? totalCapacity,
    int? occupiedSpace,
    bool? isActive,
    List<dynamic>? rooms,
    RatingSummary? ratingSummary,
    int? commentCount,
    String? contactNumber,
    String? email,
    List<String>? amenities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OverviewPropertyModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      state: state ?? this.state,
      description: description ?? this.description,
      images: images ?? this.images,
      totalRooms: totalRooms ?? this.totalRooms,
      totalBeds: totalBeds ?? this.totalBeds,
      monthlyCollection: monthlyCollection ?? this.monthlyCollection,
      pendingDues: pendingDues ?? this.pendingDues,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      occupiedSpace: occupiedSpace ?? this.occupiedSpace,
      isActive: isActive ?? this.isActive,
      rooms: rooms ?? this.rooms,
      ratingSummary: ratingSummary ?? this.ratingSummary,
      commentCount: commentCount ?? this.commentCount,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RatingSummary {
  final double averageRating;
  final int totalRatings;
  final RatingDistribution ratingDistribution;

  RatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingDistribution: RatingDistribution.fromJson(
        json['ratingDistribution'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution.toJson(),
    };
  }

  RatingSummary copyWith({
    double? averageRating,
    int? totalRatings,
    RatingDistribution? ratingDistribution,
  }) {
    return RatingSummary(
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }
}

class RatingDistribution {
  final int one;
  final int two;
  final int three;
  final int four;
  final int five;

  RatingDistribution({
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
  });

  factory RatingDistribution.fromJson(Map<String, dynamic> json) {
    return RatingDistribution(
      one: json['1'] ?? 0,
      two: json['2'] ?? 0,
      three: json['3'] ?? 0,
      four: json['4'] ?? 0,
      five: json['5'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'1': one, '2': two, '3': three, '4': four, '5': five};
  }

  RatingDistribution copyWith({
    int? one,
    int? two,
    int? three,
    int? four,
    int? five,
  }) {
    return RatingDistribution(
      one: one ?? this.one,
      two: two ?? this.two,
      three: three ?? this.three,
      four: four ?? this.four,
      five: five ?? this.five,
    );
  }

  // Helper method to get total count
  int get totalCount => one + two + three + four + five;

  // Helper method to get count by rating
  int getCountByRating(int rating) {
    switch (rating) {
      case 1:
        return one;
      case 2:
        return two;
      case 3:
        return three;
      case 4:
        return four;
      case 5:
        return five;
      default:
        return 0;
    }
  }

  // Helper method to get percentage by rating
  double getPercentageByRating(int rating) {
    if (totalCount == 0) return 0.0;
    return (getCountByRating(rating) / totalCount) * 100;
  }
}
