class BedPlan {
  final String id;
  final String name;
  final int price;
  final int durationInDays;
  final int maxBeds;
  final String description;
  final bool isTrial;  // Added field
  final DateTime createdAt;

  BedPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInDays,
    required this.maxBeds,
    required this.description,
    required this.isTrial,  // Added parameter
    required this.createdAt,
  });

  factory BedPlan.fromJson(Map<String, dynamic> json) {
    return BedPlan(
      id: json['_id'],
      name: json['name'],
      price: json['price'],
      durationInDays: json['durationInDays'],
      maxBeds: json['maxBeds'],
      description: json['description'],
      isTrial: json['isTrial'] ?? false,  // Added with default value
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
class ReelPlan {
  final String id;
  final String name;
  final String description;
  final int pricePerReel;
  final bool firstReelFree;
  final String currency;
  final String status;
  final DateTime createdAt;

  ReelPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerReel,
    required this.firstReelFree,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory ReelPlan.fromJson(Map<String, dynamic> json) {
    return ReelPlan(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      pricePerReel: json['pricePerReel'],
      firstReelFree: json['firstReelFree'],
      currency: json['currency'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}