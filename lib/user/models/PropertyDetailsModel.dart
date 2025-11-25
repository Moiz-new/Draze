class PropertyModel {
  final String id;
  final String propertyId;
  final String name;
  final String type;
  final Location location;
  final String contactNumber;
  final String description;
  final List<String> images;
  final int totalRooms;
  final int totalBeds;
  final Pricing pricing;
  final Landlord landlord;
  final Availability availability;
  final double rating;
  final List<dynamic> reviews;
  final RatingSummary ratingSummary;
  final int commentCount;

  PropertyModel({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.type,
    required this.location,
    required this.contactNumber,
    required this.description,
    required this.images,
    required this.totalRooms,
    required this.totalBeds,
    required this.pricing,
    required this.landlord,
    required this.availability,
    required this.rating,
    required this.reviews,
    required this.ratingSummary,
    required this.commentCount,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      name: json['name'] ?? 'Property Name',
      type: json['type'] ?? 'PG',
      location: Location.fromJson(json['location'] ?? {}),
      contactNumber: json['contactNumber'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds'] ?? 0,
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      landlord: Landlord.fromJson(json['landlord'] ?? {}),
      availability: Availability.fromJson(json['availability'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? [],
      ratingSummary: RatingSummary.fromJson(json['ratingSummary'] ?? {}),
      commentCount: json['commentCount'] ?? 0,
    );
  }
}

class Location {
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String landmark;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.landmark,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      landmark: json['landmark'] ?? '',
    );
  }
}

class Pricing {
  final PriceRange rooms;
  final PriceRange beds;

  Pricing({
    required this.rooms,
    required this.beds,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      rooms: PriceRange.fromJson(json['rooms'] ?? {}),
      beds: PriceRange.fromJson(json['beds'] ?? {}),
    );
  }
}

class PriceRange {
  final int min;
  final int max;

  PriceRange({
    required this.min,
    required this.max,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: json['min'] ?? 0,
      max: json['max'] ?? 0,
    );
  }
}

class Landlord {
  final String name;
  final String contactNumber;
  final String email;
  final String? profilePhoto;

  Landlord({
    required this.name,
    required this.contactNumber,
    required this.email,
    this.profilePhoto,
  });

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      name: json['name'] ?? 'Landlord',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      profilePhoto: json['profilePhoto'],
    );
  }
}

class Availability {
  final bool hasAvailableRooms;
  final int availableRoomCount;
  final int availableBedCount;

  Availability({
    required this.hasAvailableRooms,
    required this.availableRoomCount,
    required this.availableBedCount,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      hasAvailableRooms: json['hasAvailableRooms'] ?? false,
      availableRoomCount: json['availableRoomCount'] ?? 0,
      availableBedCount: json['availableBedCount'] ?? 0,
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
      ratingDistribution: Map<String, int>.from(json['ratingDistribution'] ?? {}),
    );
  }
}
