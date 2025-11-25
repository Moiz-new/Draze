import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Provider for managing registration state
class SellerRegistrationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> registerSeller({
    required String name,
    required String mobile,
    required String email,
    required String address,
    File? profileImageFile,
  }) async {
    setLoading(true);
    clearError();

    try {
      final prefs = await SharedPreferences.getInstance();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$base_url/api/seller/register'),
      );

      // Add form fields
      request.fields['name'] = name;
      request.fields['mobile'] = mobile;
      request.fields['email'] = email;
      request.fields['address'] = address;

      // Add profile image if available
      if (profileImageFile != null) {
        var stream = http.ByteStream(profileImageFile.openRead());
        var length = await profileImageFile.length();
        var multipartFile = http.MultipartFile(
          'profileImage',
          stream,
          length,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Save token and seller data to SharedPreferences
          if (responseData['token'] != null) {
            await prefs.setString('auth_token', responseData['token']);
          }

          if (responseData['seller'] != null) {
            final seller = responseData['seller'];
            await prefs.setString('seller_id', seller['id']?.toString() ?? '');
            await prefs.setString(
              'seller_name',
              seller['name']?.toString() ?? '',
            );
            await prefs.setString(
              'seller_mobile',
              seller['mobile']?.toString() ?? '',
            );
            await prefs.setString(
              'seller_email',
              seller['email']?.toString() ?? '',
            );  await prefs.setString(
              'user_role',
              "seller" ?? '',
            );
            await prefs.setString(
              'seller_address',
              seller['address']?.toString() ?? '',
            );
            await prefs.setBool(
              'seller_verified',
              seller['isVerified'] ?? false,
            );
            await prefs.setBool(
              'seller_registered',
              seller['isRagistered'] ?? false,
            );
            await prefs.setString(
              'seller_profile_image',
              seller['profileImage']?.toString() ?? '',
            );
          }

          setLoading(false);
          return true;
        } else {
          setError(
            responseData['message']?.toString() ?? 'Registration failed',
          );
          setLoading(false);
          return false;
        }
      } else {
        try {
          final responseData = jsonDecode(response.body);
          setError(
            responseData['message']?.toString() ?? 'Server error occurred',
          );
        } catch (e) {
          setError('Server error: ${response.statusCode}');
        }
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Network error: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }
}
