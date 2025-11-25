// File: lib/providers/property_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';
import '../models/SellerPropertyModel.dart';

class SellerPropertyProvider extends ChangeNotifier {
  List<PropertyModel> _properties = [];
  List<PropertyModel> _filteredProperties = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<PropertyModel> get properties => _properties;

  List<PropertyModel> get filteredProperties => _filteredProperties;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Property stats
  Map<String, int> get propertyStats {
    return {
      'total': _properties.length,
      'active': _properties.where((p) => p.isActive).length,
      'sold': 0, // Add logic if you have sold status
      'inactive': _properties.where((p) => !p.isActive).length,
    };
  }

  // Search functionality
  void searchProperties(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredProperties = List.from(_properties);
    } else {
      _filteredProperties =
          _properties.where((property) {
            return property.name.toLowerCase().contains(_searchQuery) ||
                property.address.toLowerCase().contains(_searchQuery) ||
                property.city.toLowerCase().contains(_searchQuery) ||
                property.type.toLowerCase().contains(_searchQuery);
          }).toList();
    }
    notifyListeners();
  }

  // Fetch properties from API
  Future<void> fetchProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get auth token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Make API call
      final response = await http
          .get(
            Uri.parse('$base_url/api/seller/getproperties'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> propertiesJson = jsonData['properties'] ?? [];
          _properties =
              propertiesJson
                  .map((json) => PropertyModel.fromJson(json))
                  .toList();
          _filteredProperties = List.from(_properties);
          _error = null;
        } else {
          throw Exception(
            'Failed to load properties: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Properties endpoint not found.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _properties = [];
      _filteredProperties = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh properties
  Future<void> refreshProperties() async {
    await fetchProperties();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get property by ID
  PropertyModel? getPropertyById(String id) {
    try {
      return _properties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }
}
