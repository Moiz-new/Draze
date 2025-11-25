import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../app/api_constants.dart';

class VideoControllersProvider extends ChangeNotifier {
  Map<String, VideoPlayerController> _controllers = {};

  Map<String, VideoPlayerController> get controllers => _controllers;

  void addController(String reelId, VideoPlayerController controller) {
    _controllers[reelId] = controller;
    print('VideoControllersProvider: Added controller for reel $reelId');
    notifyListeners();
  }

  void pauseAll() {
    print('VideoControllersProvider: Pausing all controllers');
    for (final entry in _controllers.entries) {
      try {
        final controller = entry.value;
        if (controller.value.isInitialized && controller.value.isPlaying) {
          print(
            'VideoControllersProvider: Pausing controller for reel ${entry.key}',
          );
          controller.pause();
        }
      } catch (e) {
        print('Error pausing controller ${entry.key}: $e');
      }
    }
  }

  void pauseAllExcept(String exceptReelId) {
    print(
      'VideoControllersProvider: Pausing all controllers except $exceptReelId',
    );
    for (final entry in _controllers.entries) {
      if (entry.key != exceptReelId) {
        try {
          final controller = entry.value;
          if (controller.value.isInitialized && controller.value.isPlaying) {
            print(
              'VideoControllersProvider: Pausing controller for reel ${entry.key}',
            );
            controller.pause();
          }
        } catch (e) {
          print('Error pausing controller ${entry.key}: $e');
        }
      }
    }
  }

  void resume(String reelId) {
    final controller = _controllers[reelId];
    if (controller != null) {
      try {
        if (controller.value.isInitialized && !controller.value.isPlaying) {
          print(
            'VideoControllersProvider: Resuming controller for reel $reelId',
          );
          controller.play();
          controller.setLooping(true);
        }
      } catch (e) {
        print('Error resuming controller $reelId: $e');
      }
    }
  }

  void pause(String reelId) {
    final controller = _controllers[reelId];
    if (controller != null) {
      try {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          print(
            'VideoControllersProvider: Pausing controller for reel $reelId',
          );
          controller.pause();
        }
      } catch (e) {
        print('Error pausing controller $reelId: $e');
      }
    }
  }

  bool isPlaying(String reelId) {
    final controller = _controllers[reelId];
    try {
      return controller != null &&
          controller.value.isInitialized &&
          controller.value.isPlaying;
    } catch (e) {
      print('Error checking if playing $reelId: $e');
      return false;
    }
  }

  bool isInitialized(String reelId) {
    final controller = _controllers[reelId];
    try {
      return controller != null && controller.value.isInitialized;
    } catch (e) {
      print('Error checking if initialized $reelId: $e');
      return false;
    }
  }

  void removeController(String reelId) {
    final controller = _controllers[reelId];
    if (controller != null) {
      print(
        'VideoControllersProvider: Removing and disposing controller for reel $reelId',
      );
      try {
        controller.pause();
        controller.dispose();
      } catch (e) {
        print('Error disposing controller $reelId: $e');
      } finally {
        _controllers.remove(reelId);
        notifyListeners();
      }
    }
  }

  void clearAll() {
    print('VideoControllersProvider: Clearing all controllers');
    for (final entry in _controllers.entries) {
      print(
        'VideoControllersProvider: Disposing controller for reel ${entry.key}',
      );
      try {
        entry.value.pause();
        entry.value.dispose();
      } catch (e) {
        print('Error disposing controller ${entry.key}: $e');
      }
    }
    _controllers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}

// Provider for managing reels
class ReelsProvider extends ChangeNotifier {
  List<ReelModel> _reels = [];
  bool _isLoading = false;
  String? _error;
  int _selectedTab = 0;
  int _currentPageIndex = 0;
  bool _reelsTabActive = false;

  // Getters
  List<ReelModel> get reels => _reels;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get selectedTab => _selectedTab;

  int get currentPageIndex => _currentPageIndex;

  bool get reelsTabActive => _reelsTabActive;

  // Setters
  void setSelectedTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void setCurrentPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  void setReelsTabActive(bool active) {
    _reelsTabActive = active;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  static final String apiUrl = '$base_url/api/reels?sort=latest';

  Future<void> loadReelsFromApi() async {
    try {
      setLoading(true);
      setError(null);
      print('ReelsProvider: Loading reels from API');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['reels'] != null) {
          final List<dynamic> reelsJson = jsonData['reels'];
          _reels =
              reelsJson.map((json) => ReelModel.fromApiJson(json)).toList();
          print('ReelsProvider: Loaded ${_reels.length} reels from API');
        } else {
          print(
            'ReelsProvider: API response success is false or reels is null',
          );
          _reels = [];
        }
      } else {
        print(
          'ReelsProvider: API request failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to load reels: ${response.statusCode}');
      }
    } catch (e) {
      print('ReelsProvider: Error loading reels from API: $e');
      setError('Failed to load reels: $e');
      _reels = [];
    } finally {
      setLoading(false);
    }
  }

  void toggleLike(String reelId) {
    _reels = _reels.map((reel) {
      if (reel.id == reelId) {
        return reel.copyWith(
          isLiked: !reel.isLiked,
          likes: reel.isLiked ? reel.likes - 1 : reel.likes + 1,
        );
      }
      return reel;
    }).toList();
    notifyListeners();
  }

  void toggleBookmark(String reelId) {
    _reels = _reels.map((reel) {
      if (reel.id == reelId) {
        return reel.copyWith(isBookmarked: !reel.isBookmarked);
      }
      return reel;
    }).toList();
    notifyListeners();
  }

  void incrementShare(String reelId) {
    _reels = _reels.map((reel) {
      if (reel.id == reelId) {
        return reel.copyWith(shares: reel.shares + 1);
      }
      return reel;
    }).toList();
    notifyListeners();
  }

  void incrementComment(String reelId) {
    _reels = _reels.map((reel) {
      if (reel.id == reelId) {
        return reel.copyWith(comments: reel.comments + 1);
      }
      return reel;
    }).toList();
    notifyListeners();
  }

  void addReel(ReelModel reel) {
    _reels = [reel, ..._reels];
    notifyListeners();
  }

  void removeReel(String reelId) {
    _reels = _reels.where((reel) => reel.id != reelId).toList();
    notifyListeners();
  }

  Future<void> refreshReels() async {
    print('ReelsProvider: Refreshing reels');
    await loadReelsFromApi();
  }

  Future<void> loadMoreReels() async {
    print('ReelsProvider: Loading more reels');
    // In a real app, this would fetch more reels from API with pagination
    // For now, just reload the same data
    await Future.delayed(const Duration(seconds: 1));
  }
}

// Landlord model for the reel owner
class LandlordInfo {
  final String id;
  final String name;
  final String? mobile;
  final String? email;
  final String? profilePhoto;

  LandlordInfo({
    required this.id,
    required this.name,
    this.mobile,
    this.email,
    this.profilePhoto,
  });

  factory LandlordInfo.fromJson(Map<String, dynamic> json) {
    return LandlordInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      profilePhoto: json['profilePhoto']?.toString(),
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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      profileImage: json['profileImage']?.toString() ?? '',
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
  final String? thumbnailUrl;
  final String title;
  final String description;
  final String location;
  final String propertyType;
  final String currency;
  final String price;
  final User? user;
  final LandlordInfo? landlordId;  // Added landlord info
  final String? propertyId;         // Added property ID
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final bool isLiked;
  final bool isBookmarked;
  final List<String> tags;
  final DateTime createdAt;
  final double? rating;
  final int? bedrooms;
  final int? bathrooms;
  final String? area;
  final String? sellerId;
  final int views;
  final String status;
  final double? duration;

  ReelModel({
    required this.id,
    required this.videoUrl,
    this.thumbnailUrl,
    this.title = '',
    this.description = '',
    this.location = '',
    this.propertyType = '',
    this.currency = 'USD',
    this.price = '0',
    this.user,
    this.landlordId,
    this.propertyId,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.tags = const [],
    required this.createdAt,
    this.rating,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.sellerId,
    this.views = 0,
    this.status = 'active',
    this.duration,
  });

  // Factory constructor for API response with better null safety
  factory ReelModel.fromApiJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      title: json['title']?.toString() ?? 'Property Reel',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      propertyType: json['propertyType']?.toString() ?? 'Property',
      currency: json['currency']?.toString() ?? 'USD',
      price: json['price']?.toString() ?? '0',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      landlordId: json['landlordId'] != null
          ? LandlordInfo.fromJson(json['landlordId'])
          : null,
      propertyId: json['propertyId']?.toString(),
      likes: int.tryParse(
        json['totalLikes']?.toString() ??
            json['likesCount']?.toString() ??
            '0',
      ) ??
          0,
      comments: int.tryParse(
        json['totalComments']?.toString() ??
            json['commentsCount']?.toString() ??
            '0',
      ) ??
          0,
      shares: int.tryParse(
        json['totalShares']?.toString() ??
            json['sharesCount']?.toString() ??
            '0',
      ) ??
          0,
      saves: int.tryParse(
        json['totalSaves']?.toString() ??
            json['savesCount']?.toString() ??
            '0',
      ) ??
          0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      bedrooms: json['bedrooms'] != null
          ? int.tryParse(json['bedrooms'].toString())
          : null,
      bathrooms: json['bathrooms'] != null
          ? int.tryParse(json['bathrooms'].toString())
          : null,
      area: json['area']?.toString(),
      sellerId: json['sellerId']?.toString(),
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'active',
      duration: json['duration'] != null
          ? double.tryParse(json['duration'].toString())
          : null,
    );
  }

  // Original factory constructor for backward compatibility
  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      propertyType: json['propertyType']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      price: json['price']?.toString() ?? '0',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      landlordId: json['landlordId'] != null
          ? LandlordInfo.fromJson(json['landlordId'])
          : null,
      propertyId: json['propertyId']?.toString(),
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      comments: int.tryParse(json['comments']?.toString() ?? '0') ?? 0,
      shares: int.tryParse(json['shares']?.toString() ?? '0') ?? 0,
      saves: int.tryParse(json['saves']?.toString() ?? '0') ?? 0,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      bedrooms: json['bedrooms'] != null
          ? int.tryParse(json['bedrooms'].toString())
          : null,
      bathrooms: json['bathrooms'] != null
          ? int.tryParse(json['bathrooms'].toString())
          : null,
      area: json['area']?.toString(),
      sellerId: json['sellerId']?.toString(),
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'active',
      duration: json['duration'] != null
          ? double.tryParse(json['duration'].toString())
          : null,
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
      'user': user?.toJson(),
      'landlordId': landlordId?.toJson(),
      'propertyId': propertyId,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'sellerId': sellerId,
      'views': views,
      'status': status,
      'duration': duration,
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
    LandlordInfo? landlordId,
    String? propertyId,
    int? likes,
    int? comments,
    int? shares,
    int? saves,
    bool? isLiked,
    bool? isBookmarked,
    List<String>? tags,
    DateTime? createdAt,
    double? rating,
    int? bedrooms,
    int? bathrooms,
    String? area,
    String? sellerId,
    int? views,
    String? status,
    double? duration,
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
      landlordId: landlordId ?? this.landlordId,
      propertyId: propertyId ?? this.propertyId,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      sellerId: sellerId ?? this.sellerId,
      views: views ?? this.views,
      status: status ?? this.status,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() {
    return 'ReelModel(id: $id, title: $title, location: $location, likes: $likes, views: $views)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReelModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}