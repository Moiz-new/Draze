class User {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profileImage: json['profileImage'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profileImage': profileImage,
      'isVerified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? profileImage,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class ReelModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String location;
  final String propertyType;
  final String currency;
  final String price;
  final User user;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isBookmarked;
  final List<String> tags;
  final DateTime createdAt;
  final double? rating;
  final int? bedrooms;
  final int? bathrooms;
  final String? area;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.location,
    required this.propertyType,
    required this.currency,
    required this.price,
    required this.user,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.tags = const [],
    required this.createdAt,
    this.rating,
    this.bedrooms,
    this.bathrooms,
    this.area,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      propertyType: json['propertyType'] ?? '',
      currency: json['currency'] ?? 'USD',
      price: json['price'] ?? '0',
      user: User.fromJson(json['user'] ?? {}),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      rating: json['rating']?.toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      area: json['area'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'location': location,
      'propertyType': propertyType,
      'currency': currency,
      'price': price,
      'user': user.toJson(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
    };
  }

  ReelModel copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? location,
    String? propertyType,
    String? currency,
    String? price,
    User? user,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isBookmarked,
    List<String>? tags,
    DateTime? createdAt,
    double? rating,
    int? bedrooms,
    int? bathrooms,
    String? area,
  }) {
    return ReelModel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      propertyType: propertyType ?? this.propertyType,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      user: user ?? this.user,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
    );
  }
}
