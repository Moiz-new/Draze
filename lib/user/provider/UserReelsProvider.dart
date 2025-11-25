import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../app/api_constants.dart';

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
      name: json['name']?.toString() ?? 'Unknown Seller',
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

  LandlordInfo copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? profilePhoto,
  }) {
    return LandlordInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

class CommentModel {
  final String id;
  final String userName;
  final String? userPhoto;
  final String text;
  final String createdAt;

  CommentModel({
    required this.id,
    required this.userName,
    this.userPhoto,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userName:
          json['userName']?.toString() ??
          json['user']?['name']?.toString() ??
          'Anonymous',
      userPhoto:
          json['userPhoto']?.toString() ??
          json['user']?['profilePhoto']?.toString(),
      text: json['text']?.toString() ?? json['comment']?.toString() ?? '',
      createdAt:
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userPhoto': userPhoto,
      'text': text,
      'createdAt': createdAt,
    };
  }
}

class UserReelModel {
  final String id;
  final LandlordInfo? landlordId;
  final String title;
  final String description;
  final String? propertyId;
  final String videoUrl;
  final String? thumbnailUrl;
  final double duration;
  final int views;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final String status;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserReelModel({
    required this.id,
    this.landlordId,
    required this.title,
    required this.description,
    this.propertyId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.savesCount,
    required this.status,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserReelModel.fromJson(Map<String, dynamic> json) {
    // Parse landlordId properly - it can be either an object or a string
    LandlordInfo? landlord;
    if (json['landlordId'] != null) {
      if (json['landlordId'] is Map<String, dynamic>) {
        // It's an object with landlord details
        landlord = LandlordInfo.fromJson(json['landlordId']);
      } else if (json['landlordId'] is String) {
        // It's just an ID string, create a minimal LandlordInfo
        landlord = LandlordInfo(
          id: json['landlordId'].toString(),
          name: 'Seller ${json['landlordId'].toString().substring(0, 8)}',
        );
      }
    }

    return UserReelModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      landlordId: landlord,
      title: json['title']?.toString() ?? 'Property Video',
      description: json['description']?.toString() ?? '',
      propertyId: json['propertyId']?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      duration: double.tryParse(json['duration']?.toString() ?? '0') ?? 0.0,
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      likesCount:
          int.tryParse(
            json['totalLikes']?.toString() ??
                json['likesCount']?.toString() ??
                '0',
          ) ??
          0,
      commentsCount:
          int.tryParse(
            json['totalComments']?.toString() ??
                json['commentsCount']?.toString() ??
                '0',
          ) ??
          0,
      sharesCount:
          int.tryParse(
            json['totalShares']?.toString() ??
                json['sharesCount']?.toString() ??
                '0',
          ) ??
          0,
      savesCount:
          int.tryParse(
            json['totalSaves']?.toString() ??
                json['savesCount']?.toString() ??
                '0',
          ) ??
          0,
      status: json['status']?.toString() ?? 'active',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlordId': landlordId?.toJson(),
      'title': title,
      'description': description,
      'propertyId': propertyId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'views': views,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'savesCount': savesCount,
      'status': status,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserReelModel copyWith({
    String? id,
    LandlordInfo? landlordId,
    String? title,
    String? description,
    String? propertyId,
    String? videoUrl,
    String? thumbnailUrl,
    double? duration,
    int? views,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? savesCount,
    String? status,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserReelModel(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      title: title ?? this.title,
      description: description ?? this.description,
      propertyId: propertyId ?? this.propertyId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      savesCount: savesCount ?? this.savesCount,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserReelModel(id: $id, title: $title, landlord: ${landlordId?.name ?? "Unknown"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserReelModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserReelsProvider extends ChangeNotifier {
  List<UserReelModel> _reels = [];
  Map<String, List<CommentModel>> _commentsMap = {};
  Set<String> _likedReels = {};
  Set<String> _savedReels = {};
  bool _isLoading = false;
  bool _isLoadingComments = false;
  bool _isPostingComment = false;
  String? _error;
  int _currentIndex = 0;
  bool _isMuted = false;

  // Getters
  List<UserReelModel> get reels => _reels;

  bool get isLoading => _isLoading;

  bool get isLoadingComments => _isLoadingComments;

  bool get isPostingComment => _isPostingComment;

  String? get error => _error;

  int get currentIndex => _currentIndex;

  bool get isMuted => _isMuted;

  // Check if a reel is liked
  bool isLiked(String reelId) => _likedReels.contains(reelId);

  // Check if a reel is saved
  bool isSaved(String reelId) => _savedReels.contains(reelId);

  // Get comments for a specific reel
  List<CommentModel> getComments(String reelId) {
    return _commentsMap[reelId] ?? [];
  }

  // Set current index
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Toggle mute
  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  // Fetch reels from API
  Future<void> fetchReels() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$base_url/api/reels?sort=latest'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['reels'] != null) {
          final List<dynamic> reelsJson = jsonData['reels'];
          _reels =
              reelsJson.map((json) => UserReelModel.fromJson(json)).toList();
          print('UserReelsProvider: Loaded ${_reels.length} reels');
        } else {
          _error = 'Failed to load reels';
          _reels = [];
        }
      } else {
        _error = 'Failed to load reels: ${response.statusCode}';
        _reels = [];
      }
    } catch (e) {
      print('UserReelsProvider: Error fetching reels: $e');
      _error = 'Error loading reels: $e';
      _reels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle like on a reel
  Future<void> toggleLike(String reelId) async {
    final wasLiked = _likedReels.contains(reelId);

    // Optimistic update
    if (wasLiked) {
      _likedReels.remove(reelId);
    } else {
      _likedReels.add(reelId);
    }

    // Update the reel's like count
    _reels =
        _reels.map((reel) {
          if (reel.id == reelId) {
            return reel.copyWith(
              likesCount: wasLiked ? reel.likesCount - 1 : reel.likesCount + 1,
            );
          }
          return reel;
        }).toList();

    notifyListeners();

    // TODO: Make API call to update like status on server
    try {
      // final response = await http.post(
      //   Uri.parse('$base_url/api/reels/$reelId/like'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      // Handle response
    } catch (e) {
      print('Error toggling like: $e');
      // Revert on error
      if (wasLiked) {
        _likedReels.add(reelId);
      } else {
        _likedReels.remove(reelId);
      }
      _reels =
          _reels.map((reel) {
            if (reel.id == reelId) {
              return reel.copyWith(
                likesCount:
                    wasLiked ? reel.likesCount + 1 : reel.likesCount - 1,
              );
            }
            return reel;
          }).toList();
      notifyListeners();
    }
  }

  // Toggle save on a reel
  Future<void> toggleSave(String reelId) async {
    final wasSaved = _savedReels.contains(reelId);

    // Optimistic update
    if (wasSaved) {
      _savedReels.remove(reelId);
    } else {
      _savedReels.add(reelId);
    }

    // Update the reel's save count
    _reels =
        _reels.map((reel) {
          if (reel.id == reelId) {
            return reel.copyWith(
              savesCount: wasSaved ? reel.savesCount - 1 : reel.savesCount + 1,
            );
          }
          return reel;
        }).toList();

    notifyListeners();

    // TODO: Make API call to update save status on server
    try {
      // final response = await http.post(
      //   Uri.parse('$base_url/api/reels/$reelId/save'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      // Handle response
    } catch (e) {
      print('Error toggling save: $e');
      // Revert on error
      if (wasSaved) {
        _savedReels.add(reelId);
      } else {
        _savedReels.remove(reelId);
      }
      _reels =
          _reels.map((reel) {
            if (reel.id == reelId) {
              return reel.copyWith(
                savesCount:
                    wasSaved ? reel.savesCount + 1 : reel.savesCount - 1,
              );
            }
            return reel;
          }).toList();
      notifyListeners();
    }
  }

  // Increment shares
  void incrementShares(String reelId) {
    _reels =
        _reels.map((reel) {
          if (reel.id == reelId) {
            return reel.copyWith(sharesCount: reel.sharesCount + 1);
          }
          return reel;
        }).toList();
    notifyListeners();

    // TODO: Make API call to update share count on server
    try {
      // http.post(
      //   Uri.parse('$base_url/api/reels/$reelId/share'),
      //   headers: {'Content-Type': 'application/json'},
      // );
    } catch (e) {
      print('Error incrementing shares: $e');
    }
  }

  // Fetch comments for a reel
  Future<void> fetchComments(String reelId) async {
    try {
      _isLoadingComments = true;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('$base_url/api/reels/$reelId/comments'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token if needed
          'Authorization': 'Bearer $token',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['comments'] != null) {
          final List<dynamic> commentsJson = jsonData['comments'];
          _commentsMap[reelId] =
              commentsJson.map((json) => CommentModel.fromJson(json)).toList();
          print(
            'Loaded ${_commentsMap[reelId]?.length ?? 0} comments for reel $reelId',
          );
        } else {
          _commentsMap[reelId] = [];
        }
      } else {
        print('Failed to load comments: ${response.statusCode}');
        _commentsMap[reelId] = [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      _commentsMap[reelId] = [];
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  // Post a comment
  Future<bool> postComment(String reelId, String text) async {
    try {
      _isPostingComment = true;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$base_url/api/reels/$reelId/comment'),
        headers: {
          'Content-Type': 'application/json',
          // Add your auth token if needed
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'text': text}),
      );

      print("$base_url/api/reels/$reelId/comments");
      print(response.body);
      print(token);
      print(reelId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh comments
        await fetchComments(reelId);

        // Update comment count
        _reels =
            _reels.map((reel) {
              if (reel.id == reelId) {
                return reel.copyWith(commentsCount: reel.commentsCount + 1);
              }
              return reel;
            }).toList();

        return true;
      } else {
        print('Failed to post comment: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error posting comment: $e');
      return false;
    } finally {
      _isPostingComment = false;
      notifyListeners();
    }
  }

  // Refresh reels
  Future<void> refreshReels() async {
    await fetchReels();
  }

  // Clear all data
  void clear() {
    _reels = [];
    _commentsMap = {};
    _likedReels = {};
    _savedReels = {};
    _error = null;
    _currentIndex = 0;
    notifyListeners();
  }
}
