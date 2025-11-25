// lib/seller/providers/SellerAddPropertyProvider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

class SellerAddPropertyProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  Future<void> addProperty(Map<String, dynamic> propertyData, List<File> imageFiles) async {
    _isLoading = true;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$base_url/api/seller/add-property'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = propertyData['name'];
      request.fields['type'] = propertyData['type'];
      request.fields['address'] = propertyData['address'];
      request.fields['city'] = propertyData['city'];
      request.fields['state'] = propertyData['state'];
      request.fields['pinCode'] = propertyData['pinCode'];
      request.fields['landmark'] = propertyData['landmark'];
      request.fields['contactNumber'] = propertyData['contactNumber'];
      request.fields['ownerName'] = propertyData['ownerName'];
      request.fields['description'] = propertyData['description'];
      request.fields['latitude'] = propertyData['latitude'].toString();
      request.fields['longitude'] = propertyData['longitude'].toString();

      // Add amenities as JSON string or multiple fields
      // Option 1: As JSON string
      request.fields['amenities'] = propertyData['amenities'].join(',');

      // Option 2: As multiple fields (uncomment if needed)
      // for (int i = 0; i < propertyData['amenities'].length; i++) {
      //   request.fields['amenities[$i]'] = propertyData['amenities'][i];
      // }

      // Add image files
      for (int i = 0; i < imageFiles.length; i++) {
        var file = imageFiles[i];
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'images', // or 'images[]' depending on your backend
          stream,
          length,
          filename: 'property_image_$i.${file.path.split('.').last}',
        );
        request.files.add(multipartFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      _isLoading = false;

      print(response.body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        _isSuccess = true;
        debugPrint('Property added successfully: ${response.body}');
        notifyListeners();
      } else if (response.statusCode == 401) {
        // Unauthorized
        _errorMessage = 'Session expired. Please login again.';
        notifyListeners();
      } else if (response.statusCode == 400) {
        // Bad request
        _errorMessage = 'Invalid data. Please check all fields.';
        notifyListeners();
      } else if (response.statusCode == 500) {
        // Server error
        _errorMessage = 'Server error. Please try again later.';
        notifyListeners();
      } else {
        // Other errors
        _errorMessage = 'Failed to add property. Status: ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'Invalid response from server. Please try again.';
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      debugPrint('Error adding property: $e');
      notifyListeners();
    }
  }

  void resetState() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}