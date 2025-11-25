// models/property_model.dart
class PropertyModel {
  final String id;
  final String propertyId;
  final String name;
  final String type;
  final PropertyLocation location;
  final int totalRooms;
  final int totalBeds;
  final int availableRooms;
  final int availableBeds;
  final double lowestPrice;
  final List<String> images;
  final bool hasAvailability;
  final String createdAt;
  final RatingSummary ratingSummary;
  final int commentCount;

  PropertyModel({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.type,
    required this.location,
    required this.totalRooms,
    required this.totalBeds,
    required this.availableRooms,
    required this.availableBeds,
    required this.lowestPrice,
    required this.images,
    required this.hasAvailability,
    required this.createdAt,
    required this.ratingSummary,
    required this.commentCount,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      location: PropertyLocation.fromJson(json['location'] ?? {}),
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds']?.toInt() ?? 0,
      availableRooms: json['availableRooms'] ?? 0,
      availableBeds: json['availableBeds'] ?? 0,
      lowestPrice: (json['lowestPrice'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      hasAvailability: json['hasAvailability'] ?? false,
      createdAt: json['createdAt'] ?? '',
      ratingSummary: RatingSummary.fromJson(json['ratingSummary'] ?? {}),
      commentCount: json['commentCount'] ?? 0,
    );
  }
}

class PropertyLocation {
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String? landmark;

  PropertyLocation({
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    this.landmark,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      landmark: json['landmark'],
    );
  }

  String get fullAddress {
    List<String> addressParts = [address, city, state, pinCode];
    if (landmark != null && landmark!.isNotEmpty) {
      addressParts.insert(0, landmark!);
    }
    return addressParts.where((part) => part.isNotEmpty).join(', ');
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
      ratingDistribution: Map<String, int>.from(json['ratingDistribution'] ?? {}),
    );
  }
}

class PropertiesResponse {
  final bool success;
  final List<PropertyModel> properties;

  PropertiesResponse({
    required this.success,
    required this.properties,
  });

  factory PropertiesResponse.fromJson(Map<String, dynamic> json) {
    return PropertiesResponse(
      success: json['success'] ?? false,
      properties: (json['properties'] as List?)
          ?.map((item) => PropertyModel.fromJson(item))
          .toList() ?? [],
    );
  }
}