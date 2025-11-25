// lib/landlord/models/LandloardReelModel.dart
class LandloardReelModel {
  final String id;
  final String landlordId;
  final String title;
  final String? description;
  final PropertyInfo? propertyInfo; // Changed from String to PropertyInfo
  final String videoKey;
  final String videoUrl;
  final String? thumbnailKey;
  final String? thumbnailUrl;
  final double duration;
  final int views;
  final int totalLikes;
  final int totalComments;
  final int totalShares;
  final int totalSaves;
  final String status;
  final List<String> tags;
  final List<LikeModel> likes;
  final List<dynamic> comments;
  final List<dynamic> shares;
  final List<dynamic> saves;
  final String createdAt;
  final String updatedAt;

  LandloardReelModel({
    required this.id,
    required this.landlordId,
    required this.title,
    this.description,
    this.propertyInfo, // Changed from propertyId
    required this.videoKey,
    required this.videoUrl,
    this.thumbnailKey,
    this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
    required this.totalSaves,
    required this.status,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saves,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LandloardReelModel.fromJson(Map<String, dynamic> json) {
    return LandloardReelModel(
      id: json['_id'] ?? '',
      landlordId: json['landlordId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      propertyInfo: json['propertyId'] != null
          ? (json['propertyId'] is Map<String, dynamic>
          ? PropertyInfo.fromJson(json['propertyId'])
          : null)
          : null,
      videoKey: json['videoKey'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailKey: json['thumbnailKey'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: (json['duration'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      totalLikes: json['totalLikes'] ?? json['likesCount'] ?? 0,
      totalComments: json['totalComments'] ?? json['commentsCount'] ?? 0,
      totalShares: json['totalShares'] ?? json['sharesCount'] ?? 0,
      totalSaves: json['totalSaves'] ?? json['savesCount'] ?? 0,
      status: json['status'] ?? 'active',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      likes: (json['likes'] as List<dynamic>?)
          ?.map((e) => LikeModel.fromJson(e))
          .toList() ?? [],
      comments: (json['comments'] as List<dynamic>?) ?? [],
      shares: (json['shares'] as List<dynamic>?) ?? [],
      saves: (json['saves'] as List<dynamic>?) ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class PropertyInfo {
  final String id;
  final String name;
  final String type;
  final String address;
  final String city;

  PropertyInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
  });

  factory PropertyInfo.fromJson(Map<String, dynamic> json) {
    return PropertyInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class LikeModel {
  final String userId;
  final String userType;
  final String createdAt;
  final String id;

  LikeModel({
    required this.userId,
    required this.userType,
    required this.createdAt,
    required this.id,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      createdAt: json['createdAt'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}