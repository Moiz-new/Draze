import 'package:draze/app/api_constants.dart';
import 'package:draze/landlord/models/OverviewPropertyModel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OverviewPropertyProvider with ChangeNotifier {
  final OverviewPropertyService _propertyService;

  OverviewPropertyProvider(this._propertyService);

  OverviewPropertyModel? _currentProperty;
  List<OverviewPropertyModel> _properties = [];
  bool _isLoading = false;
  String? _error;

  OverviewPropertyModel? get currentProperty => _currentProperty;
  List<OverviewPropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPropertyById(String propertyId) async {
    if (propertyId.isEmpty) {
      _error = 'Invalid property ID';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProperty = await _propertyService.fetchPropertyById(propertyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentProperty = null;
      debugPrint('Error fetching property: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await _propertyService.fetchAllProperties();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _properties = [];
      debugPrint('Error fetching properties: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentProperty() {
    _currentProperty = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class OverviewPropertyService {
  final String baseUrl = '$base_url/api/landlord';

  Future<OverviewPropertyModel> fetchPropertyById(String propertyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/properties/$propertyId');
      debugPrint('Fetching property from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null) {
          throw Exception('Invalid response: null data');
        }

        if (data['success'] == true && data['property'] != null) {
          return OverviewPropertyModel.fromJson(data['property']);
        } else {
          throw Exception(data['message'] ?? 'Property not found');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Property not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load property: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching property: $e');
    }
  }

  Future<List<OverviewPropertyModel>> fetchAllProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/properties');
      debugPrint('Fetching properties from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null) {
          throw Exception('Invalid response: null data');
        }

        if (data['success'] == true && data['properties'] != null) {
          final List<dynamic> propertiesJson = data['properties'];
          return propertiesJson
              .map((json) {
            try {
              return OverviewPropertyModel.fromJson(json);
            } catch (e) {
              debugPrint('Error parsing property: $e');
              return null;
            }
          })
              .whereType<OverviewPropertyModel>()
              .toList();
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to load properties: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching properties: $e');
    }
  }
}