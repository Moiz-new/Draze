class PropertyModel {
  final String id;
  final String propertyId;
  final String sellerId;
  final String name;
  final String type;
  final String address;
  final String pinCode;
  final String city;
  final String state;
  final String landmark;
  final List<String> amenities;
  final String contactNumber;
  final String ownerName;
  final String description;
  final List<String> images;
  final double? latitude;
  final double? longitude;
  final int totalRooms;
  final int totalBeds;
  final int monthlyCollection;
  final int pendingDues;
  final int totalCapacity;
  final int occupiedSpace;
  final bool isActive;
  final RatingSummary ratingSummary;
  final int commentCount;
  final String createdAt;
  final String updatedAt;

  PropertyModel({
    required this.id,
    required this.propertyId,
    required this.sellerId,
    required this.name,
    required this.type,
    required this.address,
    required this.pinCode,
    required this.city,
    required this.state,
    required this.landmark,
    required this.amenities,
    required this.contactNumber,
    required this.ownerName,
    required this.description,
    required this.images,
    this.latitude,
    this.longitude,
    required this.totalRooms,
    required this.totalBeds,
    required this.monthlyCollection,
    required this.pendingDues,
    required this.totalCapacity,
    required this.occupiedSpace,
    required this.isActive,
    required this.ratingSummary,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      pinCode: json['pinCode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      landmark: json['landmark'] ?? '',
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      contactNumber: json['contactNumber'] ?? '',
      ownerName: json['ownerName'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds'] ?? 0,
      monthlyCollection: json['monthlyCollection'] ?? 0,
      pendingDues: json['pendingDues'] ?? 0,
      totalCapacity: json['totalCapacity'] ?? 0,
      occupiedSpace: json['occupiedSpace'] ?? 0,
      isActive: json['isActive'] ?? true,
      ratingSummary: json['ratingSummary'] != null
          ? RatingSummary.fromJson(json['ratingSummary'])
          : RatingSummary.empty(),
      commentCount: json['commentCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class RatingSummary {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingDistribution;

  RatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingDistribution: json['ratingDistribution'] != null
          ? Map<String, int>.from(json['ratingDistribution'])
          : {},
    );
  }

  factory RatingSummary.empty() {
    return RatingSummary(
      averageRating: 0,
      totalRatings: 0,
      ratingDistribution: {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
    );
  }
}