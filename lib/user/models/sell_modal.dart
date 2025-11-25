class SellProperty {
  final String id;
  final String title;
  final String description;
  final String location;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final double price;
  final double pricePerSquareFeet;
  final int bedrooms;
  final int bathrooms;
  final double areaSquareFeet;
  final String propertyType;
  final List<String> images;
  final List<String> amenities;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final bool isAvailable;
  final String furnishedType;
  final int floorNumber;
  final int totalFloors;
  final String parkingType;
  final int parkingSpaces;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> nearbyPlaces;
  final bool hasGarden;
  final bool hasBalcony;
  final bool isVerified;
  final String constructionStatus;
  final int propertyAge;
  final String facing;
  final bool isPremium;
  final String ownershipType;
  final double maintenanceCharge;
  final List<String> legalDocuments;
  final String brokerName;
  final String brokerPhone;
  final double brokerCommission;
  final bool hasLoan;
  final String bankName;
  final double loanAmount;

  SellProperty({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.pricePerSquareFeet,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSquareFeet,
    required this.propertyType,
    required this.images,
    required this.amenities,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.isAvailable,
    required this.furnishedType,
    required this.floorNumber,
    required this.totalFloors,
    required this.parkingType,
    required this.parkingSpaces,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.nearbyPlaces,
    required this.hasGarden,
    required this.hasBalcony,
    required this.isVerified,
    required this.constructionStatus,
    required this.propertyAge,
    required this.facing,
    required this.isPremium,
    required this.ownershipType,
    required this.maintenanceCharge,
    required this.legalDocuments,
    required this.brokerName,
    required this.brokerPhone,
    required this.brokerCommission,
    required this.hasLoan,
    required this.bankName,
    required this.loanAmount,
  });

  factory SellProperty.fromJson(Map<String, dynamic> json) {
    return SellProperty(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      pricePerSquareFeet: (json['pricePerSquareFeet'] ?? 0.0).toDouble(),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      areaSquareFeet: (json['areaSquareFeet'] ?? 0.0).toDouble(),
      propertyType: json['propertyType'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      furnishedType: json['furnishedType'] ?? 'unfurnished',
      floorNumber: json['floorNumber'] ?? 0,
      totalFloors: json['totalFloors'] ?? 0,
      parkingType: json['parkingType'] ?? 'no parking',
      parkingSpaces: json['parkingSpaces'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      nearbyPlaces: List<String>.from(json['nearbyPlaces'] ?? []),
      hasGarden: json['hasGarden'] ?? false,
      hasBalcony: json['hasBalcony'] ?? false,
      isVerified: json['isVerified'] ?? false,
      constructionStatus: json['constructionStatus'] ?? 'ready',
      propertyAge: json['propertyAge'] ?? 0,
      facing: json['facing'] ?? 'north',
      isPremium: json['isPremium'] ?? false,
      ownershipType: json['ownershipType'] ?? 'freehold',
      maintenanceCharge: (json['maintenanceCharge'] ?? 0.0).toDouble(),
      legalDocuments: List<String>.from(json['legalDocuments'] ?? []),
      brokerName: json['brokerName'] ?? '',
      brokerPhone: json['brokerPhone'] ?? '',
      brokerCommission: (json['brokerCommission'] ?? 0.0).toDouble(),
      hasLoan: json['hasLoan'] ?? false,
      bankName: json['bankName'] ?? '',
      loanAmount: (json['loanAmount'] ?? 0.0).toDouble(),
    );
  }
}
