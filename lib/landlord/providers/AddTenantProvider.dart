import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/TenantModel.dart';

class AddTenantProvider extends ChangeNotifier {
  List<Tenant> _tenants = [];
  bool _isLoading = false;
  String? _error;
  String? _lastAddedTenantId;
  String? _lastAddedLandlordId;

  String? get lastAddedTenantId => _lastAddedTenantId;
  String? get lastAddedLandlordId => _lastAddedLandlordId;

  static final String baseUrl = '$base_url/api/landlord';

  List<Tenant> get tenants => _tenants;

  bool get isLoading => _isLoading;

  bool get hasError => _error != null;

  String? get error => _error;

  // Add a new tenant with API call
  Future<Map<String, dynamic>> addTenant(
      Tenant tenant,
      Map<String, dynamic> additionalData,
      ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('$baseUrl/tenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(additionalData),
      );

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['tenant'] != null) {
          final tenantData = responseData['tenant'];

          final newTenant = Tenant(
            id: tenantData['tenantId'],
            propertyId: tenant.propertyId,
            roomId: tenant.roomId,
            name: tenantData['name'],
            email: tenantData['email'],
            phone: tenantData['mobile'],
            status: tenant.status,
            startDate: tenant.startDate,
            monthlyRent: tenant.monthlyRent,
            deposit: tenant.deposit,
            notes: tenant.notes,
            dueAmounts: tenant.dueAmounts,
          );

          _tenants.add(newTenant);
          _lastAddedTenantId = tenantData['tenantId'];
          _lastAddedLandlordId = tenantData['accommodations'][0]['landlordId'];
        }

        _isLoading = false;
        notifyListeners();

        // Return the response data
        return responseData;
      } else {
        throw Exception(
          'Tenant already has an active accommodation in this bed',
        );
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  // Load all tenants
  Future<void> loadTenants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch tenants
      await Future.delayed(const Duration(seconds: 1));
      _tenants = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load tenants for a specific property
  Future<void> loadTenantsByProperty(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _tenants = _tenants.where((t) => t.propertyId == propertyId).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing tenant
  Future<void> updateTenant(Tenant tenant) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _tenants.indexWhere((t) => t.id == tenant.id);
      if (index != -1) {
        _tenants[index] = tenant;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete a tenant
  Future<void> deleteTenant(String tenantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _tenants.removeWhere((t) => t.id == tenantId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get tenant by ID
  Tenant? getTenantById(String tenantId) {
    try {
      return _tenants.firstWhere((t) => t.id == tenantId);
    } catch (e) {
      return null;
    }
  }

  // Get tenants by status
  List<Tenant> getTenantsByStatus(TenantStatus status) {
    return _tenants.where((t) => t.status == status).toList();
  }

  // Get active tenants count
  int get activeTenantCount {
    return _tenants.where((t) => t.status == TenantStatus.active).length;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all data
  void clear() {
    _tenants = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
