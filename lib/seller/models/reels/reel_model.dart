// lib/models/reel_model.dart
class ReelModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String propertyType;
  final String location;
  final double price;
  final String currency;
  final UserModel user;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final DateTime createdAt;
  final bool isLiked;
  final bool isBookmarked;
  final List<String> tags;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.location,
    required this.price,
    required this.currency,
    required this.user,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    required this.createdAt,
    this.isLiked = false,
    this.isBookmarked = false,
    this.tags = const [],
  });

  ReelModel copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? propertyType,
    String? location,
    double? price,
    String? currency,
    UserModel? user,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    DateTime? createdAt,
    bool? isLiked,
    bool? isBookmarked,
    List<String>? tags,
  }) {
    return ReelModel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      user: user ?? this.user,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final bool isVerified;
  final String userType; // agent, owner, buyer

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    this.isVerified = false,
    required this.userType,
  });
}

// lib/models/comment_model.dart
class CommentModel {
  final String id;
  final UserModel user;
  final String text;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.user,
    required this.text,
    required this.createdAt,
    required this.likes,
    this.isLiked = false,
    this.replies = const [],
  });
}
