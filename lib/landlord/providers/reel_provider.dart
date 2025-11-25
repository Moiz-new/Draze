// lib/providers/reel_provider.dart
import 'dart:io';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ReelProperty {
  final String id;
  final String title;
  final String address;

  ReelProperty({
    required this.id,
    required this.title,
    required this.address,
  });

  factory ReelProperty.fromJson(Map<String, dynamic> json) {
    return ReelProperty(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      address: json['address'] ?? json['location'] ?? '',
    );
  }
}

class ReelProvider with ChangeNotifier {
  static final String baseUrl = '$base_url';

  List<ReelProperty> _properties = [];
  bool _isLoadingProperties = false;
  bool _isUploadingReel = false;
  String? _errorMessage;
  String? _successMessage;

  List<ReelProperty> get properties => _properties;
  bool get isLoadingProperties => _isLoadingProperties;
  bool get isUploadingReel => _isUploadingReel;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

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

  Future<void> loadProperties() async {
    _isLoadingProperties = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/landlord/properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['properties'] != null) {
          _properties = (data['properties'] as List)
              .map((json) => ReelProperty.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Error loading properties: ${e.toString()}';
      _properties = [];
    } finally {
      _isLoadingProperties = false;
      notifyListeners();
    }
  }

  Future<bool> uploadReel({
    required File videoFile,
    required String title,
    required String description,
    required String propertyId,
    required List<String> tags,
  }) async {
    _isUploadingReel = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      String? token = await _getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/reels/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
          contentType: MediaType('video', 'mp4'),
        ),
      );

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['propertyId'] = propertyId;

      request.fields['tags'] = json.encode(tags);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _successMessage = data['message'] ?? 'Reel uploaded successfully!';
          _isUploadingReel = false;
          notifyListeners();
          return true;
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to upload reel: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'Failed to upload reel: ${e.toString()}';
      _isUploadingReel = false;
      notifyListeners();
      return false;
    }
  }
}