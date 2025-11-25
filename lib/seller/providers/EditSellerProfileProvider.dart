// edit_seller_profile_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditSellerProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  File? _selectedImage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  File? get selectedImage => _selectedImage;

  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }

  // Pick image from camera
  Future<void> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to capture image: ${e.toString()}';
      notifyListeners();
    }
  }

  // Clear selected image
  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Update seller profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String mobile,
    required String address,
  }) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://api.drazeapp.com/api/seller/profile'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['mobile'] = mobile;
      request.fields['address'] = address;

      // Add image if selected
      if (_selectedImage != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'profileImage',
          _selectedImage!.path,
        );
        request.files.add(imageFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _successMessage = data['message'] ?? 'Profile updated successfully';
          _error = null;
          _selectedImage = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to update profile';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized. Please login again.';
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Invalid data provided';
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _successMessage = null;
    _selectedImage = null;
    notifyListeners();
  }
}