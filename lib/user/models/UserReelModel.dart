class LandlordModel {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String? profilePhoto;

  LandlordModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    this.profilePhoto,
  });

  factory LandlordModel.fromJson(Map<String, dynamic> json) {
    return LandlordModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      profilePhoto: json['profilePhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'profilePhoto': profilePhoto,
    };
  }
}

class UserReelModel {
  final String id;
  final LandlordModel? landlord;
  final String? landlordId;
  final String title;
  final String description;
  final String propertyId;
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
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final double engagementRate;
  final String status;
  final List<String> tags;
  final List<dynamic> viewedBy;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final List<dynamic> shares;
  final List<dynamic> saves;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserReelModel({
    required this.id,
    this.landlord,
    this.landlordId,
    required this.title,
    required this.description,
    required this.propertyId,
    required this.videoKey,
    required this.videoUrl,
    this.thumbnailKey,
    this.thumbnailUrl,
    this.duration = 0.0,
    this.views = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalShares = 0,
    this.totalSaves = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.engagementRate = 0.0,
    required this.status,
    this.tags = const [],
    this.viewedBy = const [],
    this.likes = const [],
    this.comments = const [],
    this.shares = const [],
    this.saves = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserReelModel.fromJson(Map<String, dynamic> json) {
    // Handle landlordId - can be null, string, or object
    LandlordModel? landlordModel;
    String? landlordIdStr;

    if (json['landlordId'] != null) {
      if (json['landlordId'] is Map<String, dynamic>) {
        landlordModel = LandlordModel.fromJson(json['landlordId']);
        landlordIdStr = landlordModel.id;
      } else if (json['landlordId'] is String) {
        landlordIdStr = json['landlordId'];
      }
    }

    return UserReelModel(
      id: json['_id'] ?? json['id'] ?? '',
      landlord: landlordModel,
      landlordId: landlordIdStr,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      propertyId: json['propertyId'] ?? '',
      videoKey: json['videoKey'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailKey: json['thumbnailKey'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: (json['duration'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalSaves: json['totalSaves'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      savesCount: json['savesCount'] ?? 0,
      engagementRate: (json['engagementRate'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      tags: List<String>.from(json['tags'] ?? []),
      viewedBy: List<dynamic>.from(json['viewedBy'] ?? []),
      likes: List<dynamic>.from(json['likes'] ?? []),
      comments: List<dynamic>.from(json['comments'] ?? []),
      shares: List<dynamic>.from(json['shares'] ?? []),
      saves: List<dynamic>.from(json['saves'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlordId': landlord?.toJson() ?? landlordId,
      'title': title,
      'description': description,
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
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'savesCount': savesCount,
      'engagementRate': engagementRate,
      'status': status,
      'tags': tags,
      'viewedBy': viewedBy,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserReelModel copyWith({
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? savesCount,
    int? views,
    int? totalLikes,
    int? totalComments,
    int? totalShares,
    int? totalSaves,
    List<dynamic>? likes,
    List<dynamic>? comments,
    List<dynamic>? shares,
    List<dynamic>? saves,
    List<dynamic>? viewedBy,
    LandlordModel? landlord,
    String? landlordId,
  }) {
    return UserReelModel(
      id: this.id,
      landlord: landlord ?? this.landlord,
      landlordId: landlordId ?? this.landlordId,
      title: this.title,
      description: this.description,
      propertyId: this.propertyId,
      videoKey: this.videoKey,
      videoUrl: this.videoUrl,
      thumbnailKey: this.thumbnailKey,
      thumbnailUrl: this.thumbnailUrl,
      duration: this.duration,
      views: views ?? this.views,
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      totalShares: totalShares ?? this.totalShares,
      totalSaves: totalSaves ?? this.totalSaves,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      savesCount: savesCount ?? this.savesCount,
      engagementRate: this.engagementRate,
      status: this.status,
      tags: this.tags,
      viewedBy: viewedBy ?? this.viewedBy,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }
}

class ReelsResponse {
  final bool success;
  final List<UserReelModel> reels;
  final PaginationModel pagination;

  ReelsResponse({
    required this.success,
    required this.reels,
    required this.pagination,
  });

  factory ReelsResponse.fromJson(Map<String, dynamic> json) {
    return ReelsResponse(
      success: json['success'] ?? false,
      reels: (json['reels'] as List<dynamic>?)
          ?.map((e) => UserReelModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'reels': reels.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class PaginationModel {
  final int totalReels;
  final int totalPages;
  final int currentPage;
  final int limit;

  PaginationModel({
    required this.totalReels,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalReels: json['totalReels'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReels': totalReels,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'limit': limit,
    };
  }
}