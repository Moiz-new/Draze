import 'dart:convert';
import 'package:draze/app/api_constants.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/providers/OverviewPropertyProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../screens/property_screen.dart';

class AllPropertyListProvider with ChangeNotifier {
  List<AllPropertyListModel> _properties = [];
  List<AllPropertyListModel> _filteredProperties = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  bool _isDeleting = false;

  List<AllPropertyListModel> get properties => _properties;
  List<AllPropertyListModel> get filteredProperties => _filteredProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isDeleting => _isDeleting;

  Map<String, int> get propertyStats {
    int total = _properties.length;
    int active = _properties
        .where((p) => p.isActive && p.occupiedSpace < p.totalCapacity)
        .length;
    int rented = _properties.where((p) => p.occupiedSpace > 0).length;
    int inactive = _properties.where((p) => !p.isActive).length;

    return {
      'total': total,
      'active': active,
      'rented': rented,
      'inactive': inactive,
    };
  }

  Future<void> loadProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/landlord/properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _properties = (data['properties'] as List)
              .map((json) => AllPropertyListModel.fromJson(json))
              .toList();
          _applySearchFilter();
        } else {
          throw Exception('Failed to load properties');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteProperty(String propertyId) async {
    _isDeleting = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$base_url/api/landlord/properties/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove from local lists
          _properties.removeWhere((p) => p.id == propertyId);
          _filteredProperties.removeWhere((p) => p.id == propertyId);
          _isDeleting = false;
          notifyListeners();
          return true;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete property');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredProperties = List.from(_properties);
    } else {
      _filteredProperties = _properties.where((property) {
        return property.name.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ) ||
            property.address.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            property.city.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            property.type.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}