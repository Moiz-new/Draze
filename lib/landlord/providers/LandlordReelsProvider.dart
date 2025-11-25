import 'package:draze/app/api_constants.dart';
import 'package:draze/landlord/models/LandloardReelModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LandlordReelsProvider with ChangeNotifier {
  List<LandloardReelModel> _reels = [];
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _errorMessage;

  List<LandloardReelModel> get reels => _reels;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  Future<String?> _getAuthToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      _errorMessage = 'Failed to get authentication token';
      notifyListeners();
      return null;
    }
  }

  Future<void> loadReels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/reels/landlord/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          if (data['reels'] != null && data['reels'] is List) {
            _reels = (data['reels'] as List)
                .map((json) => LandloardReelModel.fromJson(json))
                .toList();

            // Debug print
            print('✅ Loaded ${_reels.length} reels');
            for (var reel in _reels) {
              print('Reel: ${reel.title} - Likes: ${reel.totalLikes}, Views: ${reel.views}, Comments: ${reel.totalComments}');
            }
          } else {
            _reels = [];
          }
          _errorMessage = null;
        } else {
          throw Exception(data['message'] ?? 'Failed to load reels');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Reels not found');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to load reels: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _reels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Delete reel method
  Future<bool> deleteReel(String reelId) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await http.delete(
        Uri.parse('$base_url/api/reels/$reelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Remove the reel from local list
          _reels.removeWhere((reel) => reel.id == reelId);
          print('✅ ${data['message']}');
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete reel');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Reel not found');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to delete reel: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}