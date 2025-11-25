// lib/seller/models/seller_reel_model.dart
class SellerReelModel {
  final String id;
  final String sellerId;
  final String propertyId;
  final String videoKey;
  final String videoUrl;
  final String thumbnailKey;
  final String thumbnailUrl;
  final double duration;
  final int views;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalSaves;
  final String status;
  final List<String> tags;
  final List<String> viewedBy;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final List<dynamic> shares;
  final List<dynamic> saves;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double engagementRate;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;

  SellerReelModel({
    required this.id,
    required this.sellerId,
    required this.propertyId,
    required this.videoKey,
    required this.videoUrl,
    required this.thumbnailKey,
    required this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalSaves,
    required this.status,
    required this.tags,
    required this.viewedBy,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saves,
    required this.createdAt,
    required this.updatedAt,
    required this.engagementRate,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.savesCount,
  });

  factory SellerReelModel.fromJson(Map<String, dynamic> json) {
    return SellerReelModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      videoKey: json['videoKey'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailKey: json['thumbnailKey'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      duration: (json['duration'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalSaves: json['totalSaves'] ?? 0,
      status: json['status'] ?? 'active',
      tags: List<String>.from(json['tags'] ?? []),
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
      likes: json['likes'] ?? [],
      comments: json['comments'] ?? [],
      shares: json['shares'] ?? [],
      saves: json['saves'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      engagementRate: (json['engagementRate'] ?? 0).toDouble(),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      savesCount: json['savesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'propertyId': propertyId,
      'videoKey': videoKey,
      'videoUrl': videoUrl,
      'thumbnailKey': thumbnailKey,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'views': views,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
      'totalShares': totalShares,
      'totalSaves': totalSaves,
      'status': status,
      'tags': tags,
      'viewedBy': viewedBy,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'engagementRate': engagementRate,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'savesCount': savesCount,
    };
  }
}