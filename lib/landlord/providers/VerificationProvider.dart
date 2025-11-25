import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/VerificationRegionModel.dart';

class VerificationProvider extends ChangeNotifier {
  List<VerificationRegion> _regions = [];
  VerificationRegion? _selectedRegion;
  LandlordData? _landlordData;
  bool _isLoading = false;
  bool _isLinking = false;
  bool _isAssigning = false;
  String? _errorMessage;

  List<VerificationRegion> get regions => _regions;
  VerificationRegion? get selectedRegion => _selectedRegion;
  LandlordData? get landlordData => _landlordData;
  bool get isLoading => _isLoading;
  bool get isLinking => _isLinking;
  bool get isAssigning => _isAssigning;
  String? get errorMessage => _errorMessage;

  void setSelectedRegion(VerificationRegion? region) {
    // Ensure the selected region exists in the regions list
    if (region != null && _regions.any((r) => r.id == region.id)) {
      _selectedRegion = region;
    } else {
      _selectedRegion = null;
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedRegion = null;
    notifyListeners();
  }

  Future<void> fetchVerifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      print(token);
      final response = await http.get(
        Uri.parse('$base_url/api/verification/public/all'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
      );
      print("object1");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          _regions = (jsonData['data'] as List)
              .map((item) => VerificationRegion.fromJson(item))
              .where((region) => region.isActive)
              .toList();

          // Clear selection if current selection is not in the new list
          if (_selectedRegion != null &&
              !_regions.any((r) => r.id == _selectedRegion!.id)) {
            _selectedRegion = null;
          }

          _errorMessage = null;
        } else {
          _errorMessage = 'Failed to load regions';
          _regions = [];
          _selectedRegion = null;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _regions = [];
        _selectedRegion = null;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _regions = [];
      _selectedRegion = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> linkLandlordToRegion(String regionId) async {
    _isLinking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$base_url/api/verification/linkedLandlords'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'regionId': regionId,
        }),
      );
      print("object2");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          _landlordData = LandlordData.fromJson(jsonData['data']);
          _landlordData = LandlordData(
            id: _landlordData!.id,
            name: _landlordData!.name,
            mobile: _landlordData!.mobile,
            email: _landlordData!.email,
            regionId: regionId,
            regionName: _selectedRegion?.name,
          );
          _errorMessage = null;
          _isLinking = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = jsonData['message'] ?? 'Failed to link region';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLinking = false;
    notifyListeners();
    return false;
  }

  /// Assign region to tenant(s)
  /// [landlordId] - The landlord ID
  /// [regionId] - The region ID to assign
  /// [tenantIds] - List of tenant IDs to assign the region to
  Future<Map<String, dynamic>> assignRegionToTenants({
    required String landlordId,
    required String regionId,
    required List<String> tenantIds,
  }) async {
    _isAssigning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$base_url/api/verification/assign/$landlordId/$regionId'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tenantIds': tenantIds,
        }),
      );

      print("object3");
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          _errorMessage = null;
          _isAssigning = false;
          notifyListeners();
          return {
            'success': true,
            'message': jsonData['message'] ?? 'Region assigned successfully',
            'assignedCount': jsonData['assignedCount'] ?? tenantIds.length,
            'data': jsonData['data'],
          };
        } else {
          _errorMessage = jsonData['message'] ?? 'Failed to assign region';
          _isAssigning = false;
          notifyListeners();
          return {
            'success': false,
            'message': _errorMessage,
          };
        }
      } else {
        final jsonData = json.decode(response.body);
        _errorMessage = jsonData['message'] ?? 'Server error: ${response.statusCode}';
        _isAssigning = false;
        notifyListeners();
        return {
          'success': false,
          'message': _errorMessage,
        };
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isAssigning = false;
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Fetch assigned tenants for a specific landlord and region
  /// [landlordId] - The landlord ID
  /// [regionId] - The region ID
  Future<Map<String, dynamic>> fetchAssignedTenants({
    required String landlordId,
    required String regionId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$base_url/api/verification/assignments/$landlordId/$regionId'),
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
      );

      print("Fetch Assigned Tenants Response:");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return {
            'success': true,
            'message': jsonData['message'] ?? 'Tenants fetched successfully',
            'count': jsonData['count'] ?? 0,
            'data': jsonData['data'] ?? [],
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Failed to fetch tenants',
            'data': [],
          };
        }
      } else {
        final jsonData = json.decode(response.body);
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Server error: ${response.statusCode}',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
      };
    }
  }
}