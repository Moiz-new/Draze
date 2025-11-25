import 'dart:io';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignatureProvider extends ChangeNotifier {
  File? _signatureFile;
  bool _isUploading = false;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _uploadedFilePath;
  String? _signatureUrl;
  String? _errorMessage;

  File? get signatureFile => _signatureFile;
  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get uploadedFilePath => _uploadedFilePath;
  String? get signatureUrl => _signatureUrl;
  String? get errorMessage => _errorMessage;

  final ImagePicker _picker = ImagePicker();

  Future<void> fetchSignature() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        _errorMessage = 'Authentication token not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$base_url/api/landlord/signature'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          _signatureUrl = jsonResponse['signatureUrl'];
          _errorMessage = null;
        } else {
          _errorMessage =
              jsonResponse['message'] ?? 'Failed to fetch signature';
        }
      } else if (response.statusCode == 404) {
        _signatureUrl = null;
        _errorMessage = null;
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _signatureFile = File(pickedFile.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        _signatureFile = File(pickedFile.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to capture image: ${e.toString()}';
      notifyListeners();
    }
  }

  void removeSignature() {
    _signatureFile = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> uploadSignature() async {
    if (_signatureFile == null) {
      _errorMessage = 'Please select a signature image first';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        _errorMessage = 'Authentication token not found';
        _isUploading = false;
        notifyListeners();
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$base_url/api/landlord/signature'),
      );

      request.headers['Authorization'] = 'Bearer $authToken';
      request.files.add(
        await http.MultipartFile.fromPath('profilePhoto', _signatureFile!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          _uploadedFilePath = jsonResponse['filePath'];
          _signatureUrl = jsonResponse['filePath'];
          _signatureFile = null;
          _isUploading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonResponse['message'] ?? 'Upload failed';
          _isUploading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete signature from server
  Future<bool> deleteSignature() async {
    if (_signatureUrl == null || _signatureUrl!.isEmpty) {
      _errorMessage = 'No signature to delete';
      notifyListeners();
      return false;
    }

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        _errorMessage = 'Authentication token not found';
        _isDeleting = false;
        notifyListeners();
        return false;
      }

      final response = await http.delete(
        Uri.parse('$base_url/api/landlord/signature'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          _signatureUrl = null;
          _uploadedFilePath = null;
          _signatureFile = null;
          _errorMessage = null;
          _isDeleting = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonResponse['message'] ?? 'Delete failed';
          _isDeleting = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _isDeleting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _signatureFile = null;
    _isUploading = false;
    _isLoading = false;
    _isDeleting = false;
    _uploadedFilePath = null;
    _signatureUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
}