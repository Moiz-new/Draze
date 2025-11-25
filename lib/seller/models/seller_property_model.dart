// lib/seller/models/property_model.dart

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

class Property {
  final String id;
  final String title;
  final String description;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double price;
  final PropertyType propertyType;
  final PropertyStatus status;
  final int bedrooms;
  final int bathrooms;
  final double areaInSqFt;
  final List<String> images;
  final List<String> amenities;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sellerId;
  final double? latitude;
  final double? longitude;
  final int? floorNumber;
  final int? totalFloors;
  final bool? isNegotiable;
  final String? contactNumber;
  final String? contactEmail;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.price,
    required this.propertyType,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaInSqFt,
    required this.images,
    required this.amenities,
    required this.createdAt,
    required this.updatedAt,
    this.sellerId,
    this.latitude,
    this.longitude,
    this.floorNumber,
    this.totalFloors,
    this.isNegotiable,
    this.contactNumber,
    this.contactEmail,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      price: (json['price'] as num).toDouble(),
      propertyType: PropertyType.values.firstWhere(
            (e) => e.name == json['propertyType'],
        orElse: () => PropertyType.apartment,
      ),
      status: PropertyStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => PropertyStatus.active,
      ),
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaInSqFt: (json['areaInSqFt'] as num).toDouble(),
      images: _parseStringList(json['images']),
      amenities: _parseStringList(json['amenities']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sellerId: json['sellerId'] as String?,
      latitude:
      json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude:
      json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      floorNumber: json['floorNumber'] as int?,
      totalFloors: json['totalFloors'] as int?,
      isNegotiable: json['isNegotiable'] as bool?,
      contactNumber: json['contactNumber'] as String?,
      contactEmail: json['contactEmail'] as String?,
    );
  }

  // Helper method to parse string lists that might come as JSON strings or actual lists
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    // If it's already a List
    if (value is List) {
      return value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }

    // If it's a String (JSON string representation)
    if (value is String) {
      // Try to parse as JSON first
      try {
        final parsed = jsonDecode(value);
        if (parsed is List) {
          return parsed.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        }
      } catch (e) {
        // If JSON parsing fails, try manual parsing
        String cleaned = value
            .trim()
            .replaceAll(RegExp(r'^\['), '') // Remove leading [
            .replaceAll(RegExp(r'\]$'), '') // Remove trailing ]
            .replaceAll('"', '')
            .replaceAll("'", '');

        if (cleaned.isEmpty) return [];

        return cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'price': price,
      'propertyType': propertyType.name,
      'status': status.name,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaInSqFt': areaInSqFt,
      'images': images,
      'amenities': amenities,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sellerId': sellerId,
      'latitude': latitude,
      'longitude': longitude,
      'floorNumber': floorNumber,
      'totalFloors': totalFloors,
      'isNegotiable': isNegotiable,
      'contactNumber': contactNumber,
      'contactEmail': contactEmail,
    };
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? price,
    PropertyType? propertyType,
    PropertyStatus? status,
    int? bedrooms,
    int? bathrooms,
    double? areaInSqFt,
    List<String>? images,
    List<String>? amenities,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerId,
    double? latitude,
    double? longitude,
    int? floorNumber,
    int? totalFloors,
    bool? isNegotiable,
    String? contactNumber,
    String? contactEmail,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      price: price ?? this.price,
      propertyType: propertyType ?? this.propertyType,
      status: status ?? this.status,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaInSqFt: areaInSqFt ?? this.areaInSqFt,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerId: sellerId ?? this.sellerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      floorNumber: floorNumber ?? this.floorNumber,
      totalFloors: totalFloors ?? this.totalFloors,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      contactNumber: contactNumber ?? this.contactNumber,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }
}

class CreatePropertyRequest {
  final String title;
  final String description;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double price;
  final PropertyType propertyType;
  final int bedrooms;
  final int bathrooms;
  final double areaInSqFt;
  final List<String> amenities;
  final List<String>? images;
  final double? latitude;
  final double? longitude;
  final int? floorNumber;
  final int? totalFloors;
  final bool? isNegotiable;
  final String? contactNumber;
  final String? contactEmail;

  CreatePropertyRequest({
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.price,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaInSqFt,
    required this.amenities,
    this.images,
    this.latitude,
    this.longitude,
    this.floorNumber,
    this.totalFloors,
    this.isNegotiable,
    this.contactNumber,
    this.contactEmail,
  });

  factory CreatePropertyRequest.fromJson(Map<String, dynamic> json) {
    return CreatePropertyRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      price: (json['price'] as num).toDouble(),
      propertyType: PropertyType.values.firstWhere(
            (e) => e.name == json['propertyType'],
        orElse: () => PropertyType.apartment,
      ),
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaInSqFt: (json['areaInSqFt'] as num).toDouble(),
      amenities: Property._parseStringList(json['amenities']),
      images: json['images'] != null ? Property._parseStringList(json['images']) : null,
      latitude:
      json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude:
      json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      floorNumber: json['floorNumber'] as int?,
      totalFloors: json['totalFloors'] as int?,
      isNegotiable: json['isNegotiable'] as bool?,
      contactNumber: json['contactNumber'] as String?,
      contactEmail: json['contactEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'price': price,
      'propertyType': propertyType.name,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaInSqFt': areaInSqFt,
      'amenities': amenities,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'floorNumber': floorNumber,
      'totalFloors': totalFloors,
      'isNegotiable': isNegotiable,
      'contactNumber': contactNumber,
      'contactEmail': contactEmail,
    };
  }
}

enum PropertyType {
  @JsonValue('apartment')
  apartment,
  @JsonValue('house')
  house,
  @JsonValue('villa')
  villa,
  @JsonValue('plot')
  plot,
  @JsonValue('commercial')
  commercial,
  @JsonValue('office')
  office,
}

enum PropertyStatus {
  @JsonValue('active')
  active,
  @JsonValue('sold')
  sold,
  @JsonValue('inactive')
  inactive,
  @JsonValue('under_review')
  underReview,
}

extension PropertyTypeExtension on PropertyType {
  String get displayName {
    switch (this) {
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.house:
        return 'House';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.plot:
        return 'Plot';
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.office:
        return 'Office';
    }
  }
}

extension PropertyStatusExtension on PropertyStatus {
  String get displayName {
    switch (this) {
      case PropertyStatus.active:
        return 'Active';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.inactive:
        return 'Inactive';
      case PropertyStatus.underReview:
        return 'Under Review';
    }
  }
}