// lib/providers/reel_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SellerReelProvider with ChangeNotifier {
  bool _isUploading = false;
  String? _errorMessage;
  Map<String, dynamic>? _uploadedReel;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get uploadedReel => _uploadedReel;

  // Upload reel to API
  Future<bool> uploadReel({
    required File videoFile,
    required String propertyId,
    required String baseUrl,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    _uploadedReel = null;
    notifyListeners();

    try {
      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found. Please login again.';
        _isUploading = false;
        notifyListeners();
        return false;
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/seller/upload'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add video file
      final videoStream = http.ByteStream(videoFile.openRead());
      final videoLength = await videoFile.length();
      final multipartFile = http.MultipartFile(
        'video',
        videoStream,
        videoLength,
        filename: videoFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add propertyId
      request.fields['propertyId'] = propertyId;

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout. Please check your connection.');
        },
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          _uploadedReel = jsonData['reel'] as Map<String, dynamic>?;
          _isUploading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message'] as String? ?? 'Upload failed';
          _isUploading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
        _isUploading = false;
        notifyListeners();
        return false;
      } else {
        final jsonData = json.decode(response.body);
        _errorMessage = jsonData['message'] as String? ??
            'Server error: ${response.statusCode}';
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to upload reel: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _isUploading = false;
    _errorMessage = null;
    _uploadedReel = null;
    notifyListeners();
  }
}