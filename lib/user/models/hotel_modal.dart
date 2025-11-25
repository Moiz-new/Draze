class HotelProperty {
  final String id;
  final String name;
  final String description;
  final String location;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final double pricePerNight;
  final double originalPrice;
  final int starRating;
  final List<String> images;
  final List<String> amenities;
  final String contactPhone;
  final String contactEmail;
  final String website;
  final bool isAvailable;
  final String hotelType;
  final List<RoomType> roomTypes;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> nearbyAttractions;
  final bool hasParking;
  final bool hasFreeWifi;
  final bool hasBreakfast;
  final bool hasPool;
  final bool hasGym;
  final bool hasSpa;
  final bool hasRestaurant;
  final bool hasRoomService;
  final bool isVerified;
  final String checkInTime;
  final String checkOutTime;
  final String cancellationPolicy;
  final List<String> languages;
  final bool isPetFriendly;
  final bool hasAirConditioning;
  final double distanceFromCenter;
  final String transportAccess;
  final List<String> certificates;
  final String managerName;
  final String managerPhone;
  final bool hasConferenceRooms;
  final int totalRooms;
  final double discountPercentage;

  HotelProperty({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.originalPrice,
    required this.starRating,
    required this.images,
    required this.amenities,
    required this.contactPhone,
    required this.contactEmail,
    required this.website,
    required this.isAvailable,
    required this.hotelType,
    required this.roomTypes,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.nearbyAttractions,
    required this.hasParking,
    required this.hasFreeWifi,
    required this.hasBreakfast,
    required this.hasPool,
    required this.hasGym,
    required this.hasSpa,
    required this.hasRestaurant,
    required this.hasRoomService,
    required this.isVerified,
    required this.checkInTime,
    required this.checkOutTime,
    required this.cancellationPolicy,
    required this.languages,
    required this.isPetFriendly,
    required this.hasAirConditioning,
    required this.distanceFromCenter,
    required this.transportAccess,
    required this.certificates,
    required this.managerName,
    required this.managerPhone,
    required this.hasConferenceRooms,
    required this.totalRooms,
    required this.discountPercentage,
  });

  factory HotelProperty.fromJson(Map<String, dynamic> json) {
    return HotelProperty(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      pricePerNight: (json['pricePerNight'] ?? 0.0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0.0).toDouble(),
      starRating: json['starRating'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      contactPhone: json['contactPhone'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      website: json['website'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      hotelType: json['hotelType'] ?? '',
      roomTypes:
          (json['roomTypes'] as List? ?? [])
              .map((x) => RoomType.fromJson(x))
              .toList(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      nearbyAttractions: List<String>.from(json['nearbyAttractions'] ?? []),
      hasParking: json['hasParking'] ?? false,
      hasFreeWifi: json['hasFreeWifi'] ?? false,
      hasBreakfast: json['hasBreakfast'] ?? false,
      hasPool: json['hasPool'] ?? false,
      hasGym: json['hasGym'] ?? false,
      hasSpa: json['hasSpa'] ?? false,
      hasRestaurant: json['hasRestaurant'] ?? false,
      hasRoomService: json['hasRoomService'] ?? false,
      isVerified: json['isVerified'] ?? false,
      checkInTime: json['checkInTime'] ?? '14:00',
      checkOutTime: json['checkOutTime'] ?? '12:00',
      cancellationPolicy: json['cancellationPolicy'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      isPetFriendly: json['isPetFriendly'] ?? false,
      hasAirConditioning: json['hasAirConditioning'] ?? false,
      distanceFromCenter: (json['distanceFromCenter'] ?? 0.0).toDouble(),
      transportAccess: json['transportAccess'] ?? '',
      certificates: List<String>.from(json['certificates'] ?? []),
      managerName: json['managerName'] ?? '',
      managerPhone: json['managerPhone'] ?? '',
      hasConferenceRooms: json['hasConferenceRooms'] ?? false,
      totalRooms: json['totalRooms'] ?? 0,
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
    );
  }
}

class RoomType {
  final String id;
  final String name;
  final String description;
  final double pricePerNight;
  final int maxOccupancy;
  final double roomSize;
  final List<String> amenities;
  final List<String> images;
  final bool isAvailable;
  final int availableRooms;

  RoomType({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.maxOccupancy,
    required this.roomSize,
    required this.amenities,
    required this.images,
    required this.isAvailable,
    required this.availableRooms,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerNight: (json['pricePerNight'] ?? 0.0).toDouble(),
      maxOccupancy: json['maxOccupancy'] ?? 0,
      roomSize: (json['roomSize'] ?? 0.0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      isAvailable: json['isAvailable'] ?? false,
      availableRooms: json['availableRooms'] ?? 0,
    );
  }
}
