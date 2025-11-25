// seller_profile_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SellerProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _sellerData;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get sellerData => _sellerData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter methods for easy access to seller data
  String get name => _sellerData?['name'] ?? 'N/A';
  String get email => _sellerData?['email'] ?? 'Not provided';
  String get mobile => _sellerData?['mobile'] ?? 'Not provided';
  String get address => _sellerData?['address'] ?? 'Not provided';
  String? get profileImage => _sellerData?['profileImage'];
  String get status => _sellerData?['status'] ?? 'INACTIVE';
  bool get isVerified => _sellerData?['isVerified'] ?? false;
  bool get isRegistered => _sellerData?['isRagistered'] ?? false;
  String? get createdAt => _sellerData?['createdAt'];

  Future<void> fetchSellerProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse('https://api.drazeapp.com/api/seller/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _sellerData = data['seller'];
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load profile';
        }
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized. Please login again.';
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _sellerData = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _sellerData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Helper method to get full profile image URL
  String? getFullProfileImageUrl() {
    if (profileImage != null && profileImage!.isNotEmpty) {
      if (profileImage!.startsWith('http')) {
        return profileImage;
      }
      return 'https://api.drazeapp.com$profileImage';
    }
    return null;
  }
}