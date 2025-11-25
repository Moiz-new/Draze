// lib/landlord/models/room_model.dart
import 'package:uuid/uuid.dart';

enum RoomType {
  pg,
  ac,
  singleSharing,
  doubleSharing,
  tripleSharing,
  fourSharing,
  fiveSharing,
  sixSharing,
  moreThanSixSharing,
  privateRoom,
  sharedRoom,
  couple,
  family,
  maleOnly,
  femaleOnly,
  unisex,
  studentOnly,
  workingProfessionalsOnly,
}


enum RoomStatus { available, notAvailable, unavailable, maintenance, reserved }


extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.pg:
        return "PG";
      case RoomType.ac:
        return "AC";
      case RoomType.singleSharing:
        return "Single Sharing";
      case RoomType.doubleSharing:
        return "Double Sharing";
      case RoomType.tripleSharing:
        return "Triple Sharing";
      case RoomType.fourSharing:
        return "Four Sharing";
      case RoomType.fiveSharing:
        return "Five Sharing";
      case RoomType.sixSharing:
        return "Six Sharing";
      case RoomType.moreThanSixSharing:
        return "More Than 6 Sharing";
      case RoomType.privateRoom:
        return "Private Room";
      case RoomType.sharedRoom:
        return "Shared Room";
      case RoomType.couple:
        return "Couple";
      case RoomType.family:
        return "Family";
      case RoomType.maleOnly:
        return "Male Only";
      case RoomType.femaleOnly:
        return "Female Only";
      case RoomType.unisex:
        return "Unisex";
      case RoomType.studentOnly:
        return "Student Only";
      case RoomType.workingProfessionalsOnly:
        return "Working Professionals Only";
    }
  }
}


extension RoomStatusExtension on RoomStatus {
  String get displayName {
    switch (this) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.notAvailable:
        return 'Not Available';
      case RoomStatus.unavailable:
        return 'Unavailable';
      case RoomStatus.maintenance:
        return 'Maintenance';
      case RoomStatus.reserved:
        return 'Reserved';
    }
  }
}

class Room {
  final String id;
  final String propertyId;
  final String roomNumber;
  final RoomType type;
  final RoomStatus status;
  final double rent;
  final double deposit;
  final double area;
  final String description;
  final List<String> amenities;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? currentTenantId;
  final int maxOccupancy;
  final int floor;

  Room({
    String? id,
    required this.propertyId,
    required this.roomNumber,
    required this.type,
    this.status = RoomStatus.available,
    required this.rent,
    required this.deposit,
    required this.area,
    this.description = '',
    this.amenities = const [],
    this.imageUrls = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.currentTenantId,
    this.maxOccupancy = 1,
    this.floor = 1,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Room copyWith({
    String? id,
    String? propertyId,
    String? roomNumber,
    RoomType? type,
    RoomStatus? status,
    double? rent,
    double? deposit,
    double? area,
    String? description,
    List<String>? amenities,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currentTenantId,
    int? maxOccupancy,
    int? floor,
  }) {
    return Room(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      roomNumber: roomNumber ?? this.roomNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      area: area ?? this.area,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentTenantId: currentTenantId ?? this.currentTenantId,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
      floor: floor ?? this.floor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'roomNumber': roomNumber,
      'type': type.index,
      'status': status.index,
      'rent': rent,
      'deposit': deposit,
      'area': area,
      'description': description,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'currentTenantId': currentTenantId,
      'maxOccupancy': maxOccupancy,
      'floor': floor,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      propertyId: map['propertyId'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      type: RoomType.values[map['type'] ?? 0],
      status: RoomStatus.values[map['status'] ?? 0],
      rent: map['rent']?.toDouble() ?? 0.0,
      deposit: map['deposit']?.toDouble() ?? 0.0,
      area: map['area']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      currentTenantId: map['currentTenantId'],
      maxOccupancy: map['maxOccupancy']?.toInt() ?? 1,
      floor: map['floor']?.toInt() ?? 1,
    );
  }
}
