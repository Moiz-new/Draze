import 'dart:io';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Permission Model
class Permission {
  final String id;
  final String name;
  final String description;
  final String createdAt;

  Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

// Property Assignment Model
class PropertyAssignment {
  final String propertyId;
  final int years;
  final DateTime? agreementEndDate;

  PropertyAssignment({
    required this.propertyId,
    required this.years,
    this.agreementEndDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'agreementDuration': {'years': years},
      if (agreementEndDate != null)
        'agreementEndDate': agreementEndDate!.toIso8601String(),
    };
  }
}

class SubOwnerProvider with ChangeNotifier {
  // Permissions
  List<Permission> _allPermissions = [];
  bool _isLoadingPermissions = true;
  String? _permissionErrorMessage;
  Set<String> _selectedPermissions = {};
  bool _showAllPermissions = false;

  // Selected Properties - now stores PropertyAssignment objects
  Map<String, PropertyAssignment> _selectedPropertiesMap = {};

  // Form Controllers
  bool _obscurePassword = true;

  // Getters
  List<Permission> get allPermissions => _allPermissions;

  bool get isLoadingPermissions => _isLoadingPermissions;

  String? get permissionErrorMessage => _permissionErrorMessage;

  Set<String> get selectedPermissions => _selectedPermissions;

  Set<String> get selectedProperties => _selectedPropertiesMap.keys.toSet();

  bool get showAllPermissions => _showAllPermissions;

  bool get obscurePassword => _obscurePassword;

  List<Permission> get displayedPermissions {
    if (_showAllPermissions) {
      return _allPermissions;
    }
    return _allPermissions.length > 6
        ? _allPermissions.take(6).toList()
        : _allPermissions;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Toggle show all permissions
  void toggleShowAllPermissions() {
    _showAllPermissions = !_showAllPermissions;
    notifyListeners();
  }

  // Fetch permissions from API
  Future<void> fetchPermissions() async {
    try {
      _isLoadingPermissions = true;
      _permissionErrorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        _permissionErrorMessage =
        'Authentication token not found. Please login again.';
        _isLoadingPermissions = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$base_url/api/permissions'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['permissions'] != null) {
          final List<dynamic> permissionsJson = data['permissions'];

          _allPermissions =
              permissionsJson.map((json) => Permission.fromJson(json)).toList();
          _isLoadingPermissions = false;
          _permissionErrorMessage = null;
        } else {
          _permissionErrorMessage =
              data['message'] ?? 'Failed to load permissions';
          _isLoadingPermissions = false;
        }
      } else if (response.statusCode == 401) {
        _permissionErrorMessage = 'Session expired. Please login again.';
        _isLoadingPermissions = false;
      } else {
        _permissionErrorMessage =
        'Failed to load permissions. Status: ${response.statusCode}';
        _isLoadingPermissions = false;
      }
    } catch (e) {
      _permissionErrorMessage = 'Error: ${e.toString()}';
      _isLoadingPermissions = false;
    }
    notifyListeners();
  }

  // Permission selection methods
  void togglePermission(String permissionId) {
    if (_selectedPermissions.contains(permissionId)) {
      _selectedPermissions.remove(permissionId);
    } else {
      _selectedPermissions.add(permissionId);
    }
    notifyListeners();
  }

  void selectAllPermissions() {
    _selectedPermissions = _allPermissions.map((p) => p.id).toSet();
    notifyListeners();
  }

  void deselectAllPermissions() {
    _selectedPermissions.clear();
    notifyListeners();
  }

  // Property selection methods - updated to work with PropertyAssignment
  void addPropertyAssignment(PropertyAssignment assignment) {
    _selectedPropertiesMap[assignment.propertyId] = assignment;
    notifyListeners();
  }

  void removePropertyAssignment(String propertyId) {
    _selectedPropertiesMap.remove(propertyId);
    notifyListeners();
  }

  void toggleProperty(
      String propertyId, {
        int defaultYears = 1,
        DateTime? endDate,
      }) {
    if (_selectedPropertiesMap.containsKey(propertyId)) {
      _selectedPropertiesMap.remove(propertyId);
    } else {
      _selectedPropertiesMap[propertyId] = PropertyAssignment(
        propertyId: propertyId,
        years: defaultYears,
        agreementEndDate: endDate,
      );
    }
    notifyListeners();
  }

  void updatePropertyAssignment(
      String propertyId,
      int years,
      DateTime? endDate,
      ) {
    if (_selectedPropertiesMap.containsKey(propertyId)) {
      _selectedPropertiesMap[propertyId] = PropertyAssignment(
        propertyId: propertyId,
        years: years,
        agreementEndDate: endDate,
      );
      notifyListeners();
    }
  }

  PropertyAssignment? getPropertyAssignment(String propertyId) {
    return _selectedPropertiesMap[propertyId];
  }

  void selectAllProperties(List<String> propertyIds, {int defaultYears = 1}) {
    for (var propertyId in propertyIds) {
      if (!_selectedPropertiesMap.containsKey(propertyId)) {
        _selectedPropertiesMap[propertyId] = PropertyAssignment(
          propertyId: propertyId,
          years: defaultYears,
        );
      }
    }
    notifyListeners();
  }

  void deselectAllProperties() {
    _selectedPropertiesMap.clear();
    notifyListeners();
  }

  // Submit form with multipart/form-data for images
  Future<Map<String, dynamic>> submitSubOwner({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? aadhaarNumber,
    String? panNumber,
    File? profilePhoto,
    File? idProofImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      // Validate that properties have required data
      if (_selectedPropertiesMap.isEmpty) {
        return {
          'success': false,
          'message': 'Please select at least one property',
        };
      }

      // Remove hyphens from Aadhaar before sending
      String? cleanAadhaar = aadhaarNumber?.replaceAll('-', '');

      // Create multipart request
      var uri = Uri.parse('$base_url/api/sub-owner/auth/create');
      var request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $authToken';

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['mobile'] = mobile;
      request.fields['password'] = password;

      // Add permissions as JSON array
      request.fields['permissions'] = json.encode(
        _selectedPermissions.toList(),
      );

      List<Map<String, dynamic>> propertiesJson =
      _selectedPropertiesMap.values
          .map((assignment) => assignment.toJson())
          .toList();

      request.fields['assignedProperties'] = json.encode(propertiesJson);

      print('Sending assignedProperties: ${json.encode(propertiesJson)}');
      print(
        'Sending permissions: ${json.encode(_selectedPermissions.toList())}',
      );

      // Add optional Aadhaar number
      if (cleanAadhaar != null && cleanAadhaar.isNotEmpty) {
        request.fields['aadhaarNumber'] = cleanAadhaar;
      }

      // Add optional PAN number
      if (panNumber != null && panNumber.isNotEmpty) {
        request.fields['panNumber'] = panNumber.toUpperCase();
      }

      // Add profile photo if selected
      if (profilePhoto != null) {
        var profilePhotoFile = await http.MultipartFile.fromPath(
          'profilePhoto',
          profilePhoto.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(profilePhotoFile);
      }

      // Add ID proof image if selected
      if (idProofImage != null) {
        var idProofFile = await http.MultipartFile.fromPath(
          'idProofImage',
          idProofImage.path,
          filename: 'idproof_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        request.files.add(idProofFile);
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Reset form after successful submission
        _selectedPermissions.clear();
        _selectedPropertiesMap.clear();
        notifyListeners();

        return {
          'success': true,
          'message': data['message'] ?? 'Sub-owner created successfully',
          'data': data,
          'token': data['token'],
          'subOwner': data['subOwner'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create sub-owner',
          'error': data['error'],
        };
      }
    } catch (e) {
      print('Exception: ${e.toString()}');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Reset provider
  void reset() {
    _selectedPermissions.clear();
    _selectedPropertiesMap.clear();
    _showAllPermissions = false;
    _obscurePassword = true;
    notifyListeners();
  }
}