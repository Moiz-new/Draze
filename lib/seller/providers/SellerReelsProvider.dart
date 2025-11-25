import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/SellerReelModel.dart';

class SellerReelsProvider with ChangeNotifier {
  List<SellerReelModel> _reels = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<SellerReelModel> get reels => _reels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fetch reels from API
  Future<void> fetchReels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/seller/reels'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> reelsJson = data['reels'] ?? [];
          _reels = reelsJson
              .map((json) => SellerReelModel.fromJson(json))
              .toList();
          _errorMessage = null;
        } else {
          throw Exception('Failed to load reels');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load reels: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching reels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a reel
  Future<bool> deleteReel(String reelId) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        _errorMessage = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final response = await http.delete(
        Uri.parse('https://api.drazeapp.com/api/seller/reels/$reelId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove the reel from local list
        _reels.removeWhere((reel) => reel.id == reelId);
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete reel: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh reels
  Future<void> refreshReels() async {
    await fetchReels();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }}
