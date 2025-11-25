import 'package:draze/app/api_constants.dart';

class SellerListModel {
  final String id;
  final String propertyId;
  final String name;
  final String type;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String landmark;
  final String ownerName;
  final String contactNumber;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final double averageRating;
  final int totalRatings;
  final int commentCount;
  final bool isActive;

  SellerListModel({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.landmark,
    required this.ownerName,
    required this.contactNumber,
    required this.description,
    required this.amenities,
    required this.images,
    required this.averageRating,
    required this.totalRatings,
    required this.commentCount,
    required this.isActive,
  });

  factory SellerListModel.fromJson(Map<String, dynamic> json) {
    // Parse amenities - handle both string and array formats
    List<String> parseAmenities(dynamic amenitiesData) {
      if (amenitiesData == null) return [];

      if (amenitiesData is List) {
        List<String> allAmenities = [];
        for (var item in amenitiesData) {
          if (item is String) {
            // Check if it's a JSON array string
            if (item.trim().startsWith('[') && item.trim().endsWith(']')) {
              try {
                // Remove brackets and quotes, then split
                String cleaned = item.trim().substring(1, item.length - 1);
                List<String> parsed = cleaned
                    .split(',')
                    .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
                    .where((e) => e.isNotEmpty)
                    .toList();
                allAmenities.addAll(parsed);
              } catch (e) {
                // If parsing fails, treat as comma-separated string
                allAmenities.addAll(
                    item.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
                );
              }
            } else {
              // Regular comma-separated string
              allAmenities.addAll(
                  item.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)
              );
            }
          }
        }
        return allAmenities;
      }

      return [];
    }

    // Parse images - convert relative paths to full URLs
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];

      const String imageBaseUrl = 'https://api.drazeapp.com';

      if (imagesData is List) {
        return imagesData
            .where((img) => img != null && img.toString().isNotEmpty)
            .map((img) {
          String imgPath = img.toString();
          // If it's already a full URL, return as is
          if (imgPath.startsWith('http://') || imgPath.startsWith('https://')) {
            return imgPath;
          }
          // If it's a relative path, prepend image base URL
          if (imgPath.startsWith('/')) {
            return '$imageBaseUrl$imgPath';
          }
          // If it doesn't start with /, add it
          return '$imageBaseUrl/$imgPath';
        })
            .toList();
      }

      return [];
    }

    return SellerListModel(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      landmark: json['landmark'] ?? '',
      ownerName: json['ownerName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      description: json['description'] ?? '',
      amenities: parseAmenities(json['amenities']),
      images: parseImages(json['images']),
      averageRating: (json['ratingSummary']?['averageRating'] ?? 0).toDouble(),
      totalRatings: json['ratingSummary']?['totalRatings'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'propertyId': propertyId,
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'landmark': landmark,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'description': description,
      'amenities': amenities,
      'images': images,
      'ratingSummary': {
        'averageRating': averageRating,
        'totalRatings': totalRatings,
      },
      'commentCount': commentCount,
      'isActive': isActive,
    };
  }

  // Helper method to get image count
  int get imageCount => images.length;

  // Helper method to check if property has images
  bool get hasImages => images.isNotEmpty;

  // Helper method to get first image
  String? get firstImage => images.isNotEmpty ? images.first : null;
}