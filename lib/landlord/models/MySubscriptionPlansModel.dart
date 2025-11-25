class PaymentInfo {
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  PaymentInfo({
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
    );
  }
}

class PlanId {
  final String id;
  final String name;
  final int price;
  final int durationInDays;
  final int maxBeds;
  final String description;

  PlanId({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInDays,
    required this.maxBeds,
    required this.description,
  });

  factory PlanId.fromJson(Map<String, dynamic> json) {
    return PlanId(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Plan',
      price: json['price'] ?? 0,
      durationInDays: json['durationInDays'] ?? 0,
      maxBeds: json['maxBeds'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class Subscription {
  final String id;
  final String landlordId;
  final PlanId? planId;
  final String planName;
  final int planPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final int bedsUsed;
  final String paymentStatus;
  final PaymentInfo? paymentInfo;

  Subscription({
    required this.id,
    required this.landlordId,
    this.planId,
    required this.planName,
    required this.planPrice,
    this.startDate,
    this.endDate,
    required this.status,
    required this.bedsUsed,
    required this.paymentStatus,
    this.paymentInfo,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? '',
      landlordId: json['landlordId'] ?? '',
      planId: json['planId'] != null ? PlanId.fromJson(json['planId']) : null,
      planName: json['planName'] ?? 'Unknown Plan',
      planPrice: json['planPrice'] ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      status: json['status'] ?? 'unknown',
      bedsUsed: json['bedsUsed'] ?? 0,
      paymentStatus: json['paymentStatus'] ?? 'unknown',
      paymentInfo: json['paymentInfo'] != null
          ? PaymentInfo.fromJson(json['paymentInfo'])
          : null,
    );
  }

  int get daysRemaining {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  double get usagePercentage {
    if (planId?.maxBeds == null || planId!.maxBeds == 0) return 0.0;
    return (bedsUsed / planId!.maxBeds) * 100;
  }
}