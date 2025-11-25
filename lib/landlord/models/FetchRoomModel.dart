// Main response wrapper
class RoomResponse {
  final bool success;
  final String message;
  final List<FetchRoomModel> rooms;
  final PropertyStats propertyStats;

  RoomResponse({
    required this.success,
    required this.message,
    required this.rooms,
    required this.propertyStats,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    return RoomResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      rooms: (json['rooms'] as List?)
          ?.map((room) => FetchRoomModel.fromJson(room))
          .toList() ??
          [],
      propertyStats: PropertyStats.fromJson(json['propertyStats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'rooms': rooms.map((room) => room.toJson()).toList(),
      'propertyStats': propertyStats.toJson(),
    };
  }
}

// Property Stats Model
class PropertyStats {
  final String id;
  final String propertyId;
  final String name;
  final int totalRooms;
  final int totalBeds;
  final int totalCapacity;
  final String updatedAt;

  PropertyStats({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.totalRooms,
    required this.totalBeds,
    required this.totalCapacity,
    required this.updatedAt,
  });

  factory PropertyStats.fromJson(Map<String, dynamic> json) {
    return PropertyStats(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      name: json['name'] ?? '',
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds'] ?? 0,
      totalCapacity: json['totalCapacity'] ?? 0,
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'name': name,
      'totalRooms': totalRooms,
      'totalBeds': totalBeds,
      'totalCapacity': totalCapacity,
      'updatedAt': updatedAt,
    };
  }
}

// Room Model
class FetchRoomModel {
  final String roomId;
  final String name;
  final String type;
  final String status;
  final double price;
  final int capacity;
  final RoomFacilities facilities;
  final List<Bed> beds;
  final int? floorNumber;
  final String? roomSize;
  final double securityDeposit;
  final int noticePeriod;

  FetchRoomModel({
    required this.roomId,
    required this.name,
    required this.type,
    required this.status,
    required this.price,
    required this.capacity,
    required this.facilities,
    required this.beds,
    this.floorNumber,
    this.roomSize,
    required this.securityDeposit,
    required this.noticePeriod,
  });

  factory FetchRoomModel.fromJson(Map<String, dynamic> json) {
    return FetchRoomModel(
      roomId: json['roomId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 0,
      facilities: RoomFacilities.fromJson(json['facilities'] ?? {}),
      beds: (json['beds'] as List?)
          ?.map((bed) => Bed.fromJson(bed))
          .toList() ??
          [],
      floorNumber: json['floorNumber'],
      roomSize: json['roomSize'],
      securityDeposit: (json['securityDeposit'] ?? 0).toDouble(),
      noticePeriod: json['noticePeriod'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'name': name,
      'type': type,
      'status': status,
      'price': price,
      'capacity': capacity,
      'facilities': facilities.toJson(),
      'beds': beds.map((bed) => bed.toJson()).toList(),
      'floorNumber': floorNumber,
      'roomSize': roomSize,
      'securityDeposit': securityDeposit,
      'noticePeriod': noticePeriod,
    };
  }
}

// Bed Model
class Bed {
  final String bedId;
  final String? name;
  final String status;
  final double price;

  Bed({
    required this.bedId,
    this.name,
    required this.status,
    required this.price,
  });

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      bedId: json['bedId'] ?? '',
      name: json['name'],
      status: json['status'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedId': bedId,
      'name': name,
      'status': status,
      'price': price,
    };
  }
}

// Facilities Model
class RoomFacilities {
  final RoomEssentials roomEssentials;
  final ComfortFeatures comfortFeatures;
  final WashroomHygiene washroomHygiene;
  final UtilitiesConnectivity utilitiesConnectivity;
  final LaundryHousekeeping laundryHousekeeping;
  final SecuritySafety securitySafety;
  final ParkingTransport parkingTransport;
  final PropertySpecific propertySpecific;
  final NearbyFacilities nearbyFacilities;

  RoomFacilities({
    required this.roomEssentials,
    required this.comfortFeatures,
    required this.washroomHygiene,
    required this.utilitiesConnectivity,
    required this.laundryHousekeeping,
    required this.securitySafety,
    required this.parkingTransport,
    required this.propertySpecific,
    required this.nearbyFacilities,
  });

  factory RoomFacilities.fromJson(Map<String, dynamic> json) {
    return RoomFacilities(
      roomEssentials: RoomEssentials.fromJson(json['roomEssentials'] ?? {}),
      comfortFeatures: ComfortFeatures.fromJson(json['comfortFeatures'] ?? {}),
      washroomHygiene: WashroomHygiene.fromJson(json['washroomHygiene'] ?? {}),
      utilitiesConnectivity: UtilitiesConnectivity.fromJson(json['utilitiesConnectivity'] ?? {}),
      laundryHousekeeping: LaundryHousekeeping.fromJson(json['laundryHousekeeping'] ?? {}),
      securitySafety: SecuritySafety.fromJson(json['securitySafety'] ?? {}),
      parkingTransport: ParkingTransport.fromJson(json['parkingTransport'] ?? {}),
      propertySpecific: PropertySpecific.fromJson(json['propertySpecific'] ?? {}),
      nearbyFacilities: NearbyFacilities.fromJson(json['nearbyFacilities'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomEssentials': roomEssentials.toJson(),
      'comfortFeatures': comfortFeatures.toJson(),
      'washroomHygiene': washroomHygiene.toJson(),
      'utilitiesConnectivity': utilitiesConnectivity.toJson(),
      'laundryHousekeeping': laundryHousekeeping.toJson(),
      'securitySafety': securitySafety.toJson(),
      'parkingTransport': parkingTransport.toJson(),
      'propertySpecific': propertySpecific.toJson(),
      'nearbyFacilities': nearbyFacilities.toJson(),
    };
  }
}

// Room Essentials
class RoomEssentials {
  final bool bed;
  final bool mattress;
  final bool pillow;
  final bool blanket;
  final bool fan;
  final bool light;
  final bool chargingPoint;
  final bool cupboardWardrobe;
  final bool tableStudyDesk;
  final bool chair;
  final bool roomLock;

  RoomEssentials({
    required this.bed,
    required this.mattress,
    required this.pillow,
    required this.blanket,
    required this.fan,
    required this.light,
    required this.chargingPoint,
    required this.cupboardWardrobe,
    required this.tableStudyDesk,
    required this.chair,
    required this.roomLock,
  });

  factory RoomEssentials.fromJson(Map<String, dynamic> json) {
    return RoomEssentials(
      bed: json['bed'] ?? false,
      mattress: json['mattress'] ?? false,
      pillow: json['pillow'] ?? false,
      blanket: json['blanket'] ?? false,
      fan: json['fan'] ?? false,
      light: json['light'] ?? false,
      chargingPoint: json['chargingPoint'] ?? false,
      cupboardWardrobe: json['cupboardWardrobe'] ?? false,
      tableStudyDesk: json['tableStudyDesk'] ?? false,
      chair: json['chair'] ?? false,
      roomLock: json['roomLock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bed': bed,
      'mattress': mattress,
      'pillow': pillow,
      'blanket': blanket,
      'fan': fan,
      'light': light,
      'chargingPoint': chargingPoint,
      'cupboardWardrobe': cupboardWardrobe,
      'tableStudyDesk': tableStudyDesk,
      'chair': chair,
      'roomLock': roomLock,
    };
  }
}

// Comfort Features
class ComfortFeatures {
  final bool ac;
  final bool cooler;
  final bool heater;
  final bool ceilingFan;
  final bool window;
  final bool balcony;
  final bool ventilation;
  final bool curtains;

  ComfortFeatures({
    required this.ac,
    required this.cooler,
    required this.heater,
    required this.ceilingFan,
    required this.window,
    required this.balcony,
    required this.ventilation,
    required this.curtains,
  });

  factory ComfortFeatures.fromJson(Map<String, dynamic> json) {
    return ComfortFeatures(
      ac: json['ac'] ?? false,
      cooler: json['cooler'] ?? false,
      heater: json['heater'] ?? false,
      ceilingFan: json['ceilingFan'] ?? false,
      window: json['window'] ?? false,
      balcony: json['balcony'] ?? false,
      ventilation: json['ventilation'] ?? false,
      curtains: json['curtains'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ac': ac,
      'cooler': cooler,
      'heater': heater,
      'ceilingFan': ceilingFan,
      'window': window,
      'balcony': balcony,
      'ventilation': ventilation,
      'curtains': curtains,
    };
  }
}

// Washroom Hygiene
class WashroomHygiene {
  final bool attachedBathroom;
  final bool commonBathroom;
  final bool westernToilet;
  final bool indianToilet;
  final bool geyser;
  final bool water24x7;
  final bool washBasins;
  final bool mirror;
  final bool bucketMug;
  final bool cleaningService;

  WashroomHygiene({
    required this.attachedBathroom,
    required this.commonBathroom,
    required this.westernToilet,
    required this.indianToilet,
    required this.geyser,
    required this.water24x7,
    required this.washBasins,
    required this.mirror,
    required this.bucketMug,
    required this.cleaningService,
  });

  factory WashroomHygiene.fromJson(Map<String, dynamic> json) {
    return WashroomHygiene(
      attachedBathroom: json['attachedBathroom'] ?? false,
      commonBathroom: json['commonBathroom'] ?? false,
      westernToilet: json['westernToilet'] ?? false,
      indianToilet: json['indianToilet'] ?? false,
      geyser: json['geyser'] ?? false,
      water24x7: json['water24x7'] ?? false,
      washBasins: json['washBasins'] ?? false,
      mirror: json['mirror'] ?? false,
      bucketMug: json['bucketMug'] ?? false,
      cleaningService: json['cleaningService'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachedBathroom': attachedBathroom,
      'commonBathroom': commonBathroom,
      'westernToilet': westernToilet,
      'indianToilet': indianToilet,
      'geyser': geyser,
      'water24x7': water24x7,
      'washBasins': washBasins,
      'mirror': mirror,
      'bucketMug': bucketMug,
      'cleaningService': cleaningService,
    };
  }
}

// Utilities Connectivity
class UtilitiesConnectivity {
  final bool wifi;
  final bool powerBackup;
  final bool electricityIncluded;
  final bool waterIncluded;
  final bool gasIncluded;
  final bool maintenanceIncluded;
  final bool tv;
  final bool dthCable;

  UtilitiesConnectivity({
    required this.wifi,
    required this.powerBackup,
    required this.electricityIncluded,
    required this.waterIncluded,
    required this.gasIncluded,
    required this.maintenanceIncluded,
    required this.tv,
    required this.dthCable,
  });

  factory UtilitiesConnectivity.fromJson(Map<String, dynamic> json) {
    return UtilitiesConnectivity(
      wifi: json['wifi'] ?? false,
      powerBackup: json['powerBackup'] ?? false,
      electricityIncluded: json['electricityIncluded'] ?? false,
      waterIncluded: json['waterIncluded'] ?? false,
      gasIncluded: json['gasIncluded'] ?? false,
      maintenanceIncluded: json['maintenanceIncluded'] ?? false,
      tv: json['tv'] ?? false,
      dthCable: json['dthCable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wifi': wifi,
      'powerBackup': powerBackup,
      'electricityIncluded': electricityIncluded,
      'waterIncluded': waterIncluded,
      'gasIncluded': gasIncluded,
      'maintenanceIncluded': maintenanceIncluded,
      'tv': tv,
      'dthCable': dthCable,
    };
  }
}

// Laundry Housekeeping
class LaundryHousekeeping {
  final bool washingMachine;
  final bool laundryArea;
  final bool dryingSpace;
  final bool ironTable;

  LaundryHousekeeping({
    required this.washingMachine,
    required this.laundryArea,
    required this.dryingSpace,
    required this.ironTable,
  });

  factory LaundryHousekeeping.fromJson(Map<String, dynamic> json) {
    return LaundryHousekeeping(
      washingMachine: json['washingMachine'] ?? false,
      laundryArea: json['laundryArea'] ?? false,
      dryingSpace: json['dryingSpace'] ?? false,
      ironTable: json['ironTable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'washingMachine': washingMachine,
      'laundryArea': laundryArea,
      'dryingSpace': dryingSpace,
      'ironTable': ironTable,
    };
  }
}

// Security Safety
class SecuritySafety {
  final bool cctv;
  final bool biometricEntry;
  final bool securityGuard;
  final bool visitorRestricted;
  final bool fireSafety;

  SecuritySafety({
    required this.cctv,
    required this.biometricEntry,
    required this.securityGuard,
    required this.visitorRestricted,
    required this.fireSafety,
  });

  factory SecuritySafety.fromJson(Map<String, dynamic> json) {
    return SecuritySafety(
      cctv: json['cctv'] ?? false,
      biometricEntry: json['biometricEntry'] ?? false,
      securityGuard: json['securityGuard'] ?? false,
      visitorRestricted: json['visitorRestricted'] ?? false,
      fireSafety: json['fireSafety'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cctv': cctv,
      'biometricEntry': biometricEntry,
      'securityGuard': securityGuard,
      'visitorRestricted': visitorRestricted,
      'fireSafety': fireSafety,
    };
  }
}

// Parking Transport
class ParkingTransport {
  final bool bikeParking;
  final bool carParking;
  final bool coveredParking;
  final bool nearBus;
  final bool nearMetro;

  ParkingTransport({
    required this.bikeParking,
    required this.carParking,
    required this.coveredParking,
    required this.nearBus,
    required this.nearMetro,
  });

  factory ParkingTransport.fromJson(Map<String, dynamic> json) {
    return ParkingTransport(
      bikeParking: json['bikeParking'] ?? false,
      carParking: json['carParking'] ?? false,
      coveredParking: json['coveredParking'] ?? false,
      nearBus: json['nearBus'] ?? false,
      nearMetro: json['nearMetro'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bikeParking': bikeParking,
      'carParking': carParking,
      'coveredParking': coveredParking,
      'nearBus': nearBus,
      'nearMetro': nearMetro,
    };
  }
}

// Property Specific
class PropertySpecific {
  final String? sharingType;
  final String? genderSpecific;
  final String? curfewTiming;
  final bool guestAllowed;
  final int? bedrooms;
  final int? bathrooms;
  final bool hall;
  final bool modularKitchen;
  final String? furnishingType;
  final int? propertyFloor;
  final bool liftAvailable;
  final bool separateEntry;

  PropertySpecific({
    this.sharingType,
    this.genderSpecific,
    this.curfewTiming,
    required this.guestAllowed,
    this.bedrooms,
    this.bathrooms,
    required this.hall,
    required this.modularKitchen,
    this.furnishingType,
    this.propertyFloor,
    required this.liftAvailable,
    required this.separateEntry,
  });

  factory PropertySpecific.fromJson(Map<String, dynamic> json) {
    return PropertySpecific(
      sharingType: json['sharingType'],
      genderSpecific: json['genderSpecific'],
      curfewTiming: json['curfewTiming'],
      guestAllowed: json['guestAllowed'] ?? false,
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      hall: json['hall'] ?? false,
      modularKitchen: json['modularKitchen'] ?? false,
      furnishingType: json['furnishingType'],
      propertyFloor: json['propertyFloor'],
      liftAvailable: json['liftAvailable'] ?? false,
      separateEntry: json['separateEntry'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sharingType': sharingType,
      'genderSpecific': genderSpecific,
      'curfewTiming': curfewTiming,
      'guestAllowed': guestAllowed,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'hall': hall,
      'modularKitchen': modularKitchen,
      'furnishingType': furnishingType,
      'propertyFloor': propertyFloor,
      'liftAvailable': liftAvailable,
      'separateEntry': separateEntry,
    };
  }
}

// Nearby Facilities
class NearbyFacilities {
  final bool grocery;
  final bool hospital;
  final bool gym;
  final bool park;
  final bool schoolCollege;
  final bool marketMall;

  NearbyFacilities({
    required this.grocery,
    required this.hospital,
    required this.gym,
    required this.park,
    required this.schoolCollege,
    required this.marketMall,
  });

  factory NearbyFacilities.fromJson(Map<String, dynamic> json) {
    return NearbyFacilities(
      grocery: json['grocery'] ?? false,
      hospital: json['hospital'] ?? false,
      gym: json['gym'] ?? false,
      park: json['park'] ?? false,
      schoolCollege: json['schoolCollege'] ?? false,
      marketMall: json['marketMall'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grocery': grocery,
      'hospital': hospital,
      'gym': gym,
      'park': park,
      'schoolCollege': schoolCollege,
      'marketMall': marketMall,
    };
  }
}