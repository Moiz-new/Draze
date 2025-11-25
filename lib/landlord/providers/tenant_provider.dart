import 'package:flutter/foundation.dart';
import 'package:draze/landlord/models/tenant_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';
import '../screens/property details/TenantDetailsScreen.dart';

class TenantProvider with ChangeNotifier {
  final TenantService _tenantService;

  TenantProvider(this._tenantService);

  List<Tenant>? _tenants;
  bool _isLoading = false;
  String? _error;

  List<Tenant>? get tenants => _tenants;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadTenants(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tenants = await _tenantService.getTenantsByProperty(propertyId);
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _tenants = null;
      notifyListeners();
    }
  }

  Future<void> addTenant(Tenant tenant, String propertyId) async {
    try {
      await _tenantService.addTenant(tenant);
      await loadTenants(propertyId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTenant(Tenant tenant, String propertyId) async {
    try {
      await _tenantService.updateTenant(tenant);
      await loadTenants(propertyId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTenant(String tenantId, String propertyId) async {
    try {
      await _tenantService.deleteTenant(tenantId);
      await loadTenants(propertyId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class TenantService {
  static final String baseUrl = '$base_url/api/landlord';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      'auth_token',
    ); // Adjust key name as per your implementation
  }

  Future<List<Tenant>> getTenantsByProperty(String propertyId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tenant/property/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Tenant.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load tenants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tenants: $e');
    }
  }

  Future<void> addTenant(Tenant tenant) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tenant'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(tenant.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add tenant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding tenant: $e');
    }
  }


  Future<TenantDetails> getTenantDetails(String tenantId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tenant/$tenantId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(tenantId);
      print("Tokennnn$token");
      print('Tenant Details Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['tenant'] != null) {
          return TenantDetails.fromJson(jsonData['tenant']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception(
          'Failed to load tenant details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching tenant details: $e');
    }
  }

  Future<void> updateTenant(Tenant tenant) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/tenant/${tenant.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(tenant.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update tenant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating tenant: $e');
    }
  }

  Future<void> deleteTenant(String tenantId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/tenant/$tenantId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete tenant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting tenant: $e');
    }
  }
}
