// lib/landlord/models/property_model.dart
import 'package:uuid/uuid.dart';

enum PropertyType {
  pg,
  hostel,
  rental,
  oneBhk,
  twoBhk,
  threeBhk,
  fourBhk,
  oneRk,
  studioApartment,
  luxuryBungalows,
  villas,
  builderFloor,
  flat,
  room,
}

extension PropertyTypeExtension on PropertyType {
  String get displayName {
    switch (this) {
      case PropertyType.pg:
        return 'PG';
      case PropertyType.hostel:
        return 'Hostel';
      case PropertyType.rental:
        return 'Rental';
      case PropertyType.oneBhk:
        return '1 BHK';
      case PropertyType.twoBhk:
        return '2 BHK';
      case PropertyType.threeBhk:
        return '3 BHK';
      case PropertyType.fourBhk:
        return '4 BHK';
      case PropertyType.oneRk:
        return '1 RK';
      case PropertyType.studioApartment:
        return 'Studio Apartment';
      case PropertyType.luxuryBungalows:
        return 'Luxury Bungalows';
      case PropertyType.villas:
        return 'Villas';
      case PropertyType.builderFloor:
        return 'Builder Floor';
      case PropertyType.flat:
        return 'Flat';
      case PropertyType.room:
        return 'Room';
    }
  }
}


enum PropertyStatus { active, inactive, rented, maintenance, pending }


extension PropertyStatusExtension on PropertyStatus {
  String get displayName {
    switch (this) {
      case PropertyStatus.active:
        return 'Active';
      case PropertyStatus.inactive:
        return 'Inactive';
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.maintenance:
        return 'Maintenance';
      case PropertyStatus.pending:
        return 'Pending';
    }
  }
}

class Property {
  final String id;
  final String name;
  final PropertyType type;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String description;
  final List<String> imageUrls;
  final double totalArea;
  final int totalRooms;
  final List<String> amenities;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PropertyStatus status;
  final String landlordId;
  final String? contactNumber;
  final String? email;

  Property({
    String? id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.description,
    this.imageUrls = const [],
    required this.totalArea,
    required this.totalRooms,
    this.amenities = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = PropertyStatus.active,
    required this.landlordId,
    this.contactNumber,
    this.email,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Helper getter for backward compatibility
  bool get isActive => status == PropertyStatus.active;

  Property copyWith({
    String? id,
    String? name,
    PropertyType? type,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? description,
    List<String>? imageUrls,
    double? totalArea,
    int? totalRooms,
    List<String>? amenities,
    DateTime? createdAt,
    DateTime? updatedAt,
    PropertyStatus? status,
    String? landlordId,
    String? contactNumber,
    String? email,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      totalArea: totalArea ?? this.totalArea,
      totalRooms: totalRooms ?? this.totalRooms,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      landlordId: landlordId ?? this.landlordId,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'description': description,
      'imageUrls': imageUrls,
      'totalArea': totalArea,
      'totalRooms': totalRooms,
      'amenities': amenities,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'status': status.index,
      'landlordId': landlordId,
      'contactNumber': contactNumber,
      'email': email,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: PropertyType.values[map['type'] ?? 0],
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      totalArea: map['totalArea']?.toDouble() ?? 0.0,
      totalRooms: map['totalRooms']?.toInt() ?? 0,
      amenities: List<String>.from(map['amenities'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      status: PropertyStatus.values[map['status'] ?? 0],
      landlordId: map['landlordId'] ?? '',
      contactNumber: map['contactNumber'],
      email: map['email'],
    );
  }
}
