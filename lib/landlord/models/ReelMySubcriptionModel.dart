class ReelSubscription {
  final String id;
  final String planName;
  final String? description;
  final int pricePerReel;
  final String status;
  final int reelsUploaded;
  final int reelLimit;
  final int remainingReels;
  final String? razorpayPaymentId;
  final int razorpayAmount;
  final DateTime? createdAt;

  ReelSubscription({
    required this.id,
    required this.planName,
    this.description,
    required this.pricePerReel,
    required this.status,
    required this.reelsUploaded,
    required this.reelLimit,
    required this.remainingReels,
    this.razorpayPaymentId,
    required this.razorpayAmount,
    this.createdAt,
  });

  factory ReelSubscription.fromJson(Map<String, dynamic> json) {
    return ReelSubscription(
      id: json['id'] ?? json['_id'] ?? '',
      planName: json['planName'] ?? 'N/A',
      description: json['description'],
      pricePerReel: json['pricePerReel'] ?? 0,
      status: json['status'] ?? 'unknown',
      reelsUploaded: json['reelsUploaded'] ?? 0,
      reelLimit: json['reelLimit'] ?? 0,
      remainingReels: json['remainingReels'] ?? 0,
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpayAmount: json['razorpayAmount'] ?? 0,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  int get daysRemaining {
    return 0;
  }

  bool get hasPaymentInfo =>
      razorpayPaymentId != null && razorpayPaymentId!.isNotEmpty;

  bool get canUploadMoreReels => remainingReels > 0;
}
