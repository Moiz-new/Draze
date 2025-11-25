class LandlordData {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String? regionId;
  final String? regionName;

  LandlordData({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    this.regionId,
    this.regionName,
  });

  factory LandlordData.fromJson(Map<String, dynamic> json) {
    return LandlordData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      regionId: json['regionId'],
      regionName: null,
    );
  }
}

// Verification Model
class VerificationRegion {
  final String id;
  final String name;
  final String code;
  final String documentUrl;
  final String description;
  final bool isActive;

  VerificationRegion({
    required this.id,
    required this.name,
    required this.code,
    required this.documentUrl,
    required this.description,
    required this.isActive,
  });

  factory VerificationRegion.fromJson(Map<String, dynamic> json) {
    return VerificationRegion(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      documentUrl: json['documentUrl'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  // Override equality operators to ensure proper comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRegion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
