import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

class AddRoomImageProvider extends ChangeNotifier {
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  String? _error;
  bool _uploadSuccess = false;

  // Getters
  List<XFile> get selectedImages => _selectedImages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get uploadSuccess => _uploadSuccess;
  bool get hasImages => _selectedImages.isNotEmpty;
  int get imageCount => _selectedImages.length;
  bool get canAddMore => _selectedImages.length < 10;

  // Update selected images
  void updateSelectedImages(List<XFile> images) {
    _selectedImages = images;
    notifyListeners();
  }

  // Add single image
  void addSelectedImage(XFile image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  // Remove image at index
  void removeSelectedImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset all state
  void reset() {
    _selectedImages = [];
    _isLoading = false;
    _error = null;
    _uploadSuccess = false;
    notifyListeners();
  }

  // Upload images to API
  Future<bool> uploadImages(String propertyId, String roomId) async {
    if (_selectedImages.isEmpty) {
      _error = 'Please select at least one image';
      notifyListeners();
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      _error = 'Authentication token not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        '$base_url/api/landlord/properties/$propertyId/rooms/$roomId/images',
      );

      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add all selected images
      for (var imageFile in _selectedImages) {
        final file = File(imageFile.path);
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final mimeTypeData = mimeType.split('/');

        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        _uploadSuccess = true;
        _selectedImages = [];
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = 'Failed to upload images: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error uploading images: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}