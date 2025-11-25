// lib/landlord/providers/dues_provider.dart

import 'dart:convert';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Due.dart';

// Property model for dropdown
class PropertyItem {
  final String id;
  final String propertyId;
  final String name;
  final String type;
  final List<RoomItem> rooms;

  PropertyItem({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.type,
    required this.rooms,
  });

  factory PropertyItem.fromJson(Map<String, dynamic> json) {
    return PropertyItem(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      rooms:
          (json['rooms'] as List?)
              ?.map((room) => RoomItem.fromJson(room))
              .toList() ??
          [],
    );
  }
}

class RoomItem {
  final String roomId;
  final String name;
  final List<BedItem> beds;
  final List<TenantItem> tenants;

  RoomItem({
    required this.roomId,
    required this.name,
    required this.beds,
    required this.tenants,
  });

  factory RoomItem.fromJson(Map<String, dynamic> json) {
    return RoomItem(
      roomId: json['roomId'] ?? '',
      name: json['name'] ?? '',
      beds:
          (json['beds'] as List?)
              ?.map((bed) => BedItem.fromJson(bed))
              .toList() ??
          [],
      tenants:
          (json['tenants'] as List?)
              ?.map((tenant) => TenantItem.fromJson(tenant))
              .toList() ??
          [],
    );
  }
}

class BedItem {
  final String bedId;
  final String name;
  final List<TenantItem> tenants;

  BedItem({required this.bedId, required this.name, required this.tenants});

  factory BedItem.fromJson(Map<String, dynamic> json) {
    return BedItem(
      bedId: json['bedId'] ?? '',
      name: json['name'] ?? '',
      tenants:
          (json['tenants'] as List?)
              ?.map((tenant) => TenantItem.fromJson(tenant))
              .toList() ??
          [],
    );
  }
}

class TenantItem {
  final String tenantId;
  final String name;
  final String email;
  final String roomId;
  final String? bedId;

  TenantItem({
    required this.tenantId,
    required this.name,
    required this.email,
    required this.roomId,
    this.bedId,
  });

  factory TenantItem.fromJson(Map<String, dynamic> json) {
    return TenantItem(
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roomId: json['roomId'] ?? '',
      bedId: json['bedId'],
    );
  }
}

// Service class for API calls
class DuesService {
  // Get all dues for a landlord
  Future<List<Due>> getAllDues(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/api/dues/alldues/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response has the expected structure
        if (responseData['success'] == true && responseData['dues'] != null) {
          final List<dynamic> duesData = responseData['dues'];
          return duesData.map((json) => Due.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load dues: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllDues: $e');
      throw Exception('Error fetching dues: $e');
    }
  }

  // Get all properties for landlord
  Future<List<PropertyItem>> getAllProperties(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/api/landlord/properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Properties Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['properties'] as List)
              .map((json) => PropertyItem.fromJson(json))
              .toList();
        } else {
          throw Exception('Failed to load properties');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching properties: $e');
    }
  }

  Future<Due> createDue({
    required String landlordId,
    required String name,
    required String type,
    double? amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/dues/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'landlordId': landlordId,
          'name': name,
          'type': type,
          if (amount != null) 'amount': amount,
          'status': 'ACTIVE',
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Due.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create due: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating due: $e');
      throw Exception('Error creating due: $e');
    }
  }

  Future<Due> updateDue(String dueId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/api/dues/update/$dueId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      print('Update Response Status: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return Due.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update due: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating due: $e');
    }
  }

  // NEW: Edit due API - specifically for status changes using the /edit endpoint
  Future<Due> editDue(String dueId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$base_url/api/dues/edit/$dueId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      print('Edit Response Status: ${response.statusCode}');
      print('Edit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return Due.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to edit due status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error editing due: $e');
      throw Exception('Error editing due: $e');
    }
  }

  // Delete due
  Future<Map<String, dynamic>> deleteDue(String dueId) async {
    try {
      final response = await http.delete(
        Uri.parse('$base_url/api/dues/delete/$dueId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete Response Status: ${response.statusCode}');
      print('Delete Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception(
          'Failed to delete due: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error deleting due: $e');
      throw Exception('Error deleting due: $e');
    }
  }

  // Toggle due status (DEPRECATED - use editDue instead)
  @Deprecated('Use editDue method instead')
  Future<Due> toggleDueStatus(String dueId, String currentStatus) async {
    final newStatus = currentStatus == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    return editDue(dueId, newStatus);
  }

  // Assign due to tenants
  Future<void> assignDueToTenants({
    required String dueId,
    required List<String> tenantIds,
    double? amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/dues/assign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'dueId': dueId,
          'tenantIds': tenantIds,
          if (amount != null) 'amount': amount,
        }),
      );

      print(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to assign due: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assigning due: $e');
    }
  }
}

// Provider class for state management
class DuesProvider with ChangeNotifier {
  final DuesService _duesService = DuesService();

  List<Due> _dues = [];
  List<PropertyItem> _properties = [];
  bool _isLoading = false;
  bool _isLoadingProperties = false;
  String? _error;

  List<Due> get dues => _dues;

  List<PropertyItem> get properties => _properties;

  bool get isLoading => _isLoading;

  bool get isLoadingProperties => _isLoadingProperties;

  String? get error => _error;

  bool get hasError => _error != null;

  // Load all dues for a user
  Future<void> loadDues() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('landlord_id');
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('UserId: $userId');
    print('Token: $token');

    try {
      _dues = await _duesService.getAllDues(userId!, token!);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _dues = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all properties
  Future<void> loadProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    _isLoadingProperties = true;
    notifyListeners();

    try {
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      _properties = await _duesService.getAllProperties(token);
    } catch (e) {
      print('Error loading properties: $e');
      _properties = [];
    } finally {
      _isLoadingProperties = false;
      notifyListeners();
    }
  }

  // Get all tenants from properties
  List<TenantItem> getAllTenants() {
    List<TenantItem> allTenants = [];

    for (var property in _properties) {
      for (var room in property.rooms) {
        // Add room-level tenants
        allTenants.addAll(room.tenants);

        // Add bed-level tenants
        for (var bed in room.beds) {
          allTenants.addAll(bed.tenants);
        }
      }
    }

    // Remove duplicates based on tenantId
    final uniqueTenants = <String, TenantItem>{};
    for (var tenant in allTenants) {
      uniqueTenants[tenant.tenantId] = tenant;
    }

    return uniqueTenants.values.toList();
  }

  // Create a new due
  Future<void> createDue({
    required String landlordId,
    required String name,
    required String type,
    double? amount,
  }) async {
    try {
      final newDue = await _duesService.createDue(
        landlordId: landlordId,
        name: name,
        type: type,
        amount: amount,
      );
      _dues.add(newDue);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update a due (for name, type, amount changes)
  Future<void> updateDue(String dueId, Map<String, dynamic> updates) async {
    try {
      final updatedDue = await _duesService.updateDue(dueId, updates);
      final index = _dues.indexWhere((due) => due.id == dueId);
      if (index != -1) {
        _dues[index] = updatedDue;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // NEW: Edit due - specifically for status changes using /api/dues/edit endpoint
  Future<void> editDue(String dueId, String status) async {
    try {
      final updatedDue = await _duesService.editDue(dueId, status);
      final index = _dues.indexWhere((due) => due.id == dueId);
      if (index != -1) {
        _dues[index] = updatedDue;
        notifyListeners();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete a due
  Future<void> deleteDue(String dueId) async {
    try {
      // Call the service to delete the due
      final response = await _duesService.deleteDue(dueId);

      // Remove from local list
      _dues.removeWhere((due) => due.id == dueId);

      // Clear any previous errors
      _error = null;

      // Notify listeners to update UI
      notifyListeners();

      print('Due deleted successfully: ${response['message']}');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Error in provider deleteDue: $e');
      rethrow;
    }
  }

  // Toggle due status (DEPRECATED - use editDue instead)
  @Deprecated('Use editDue method instead for status changes')
  Future<void> toggleDueStatus(String dueId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
      await editDue(dueId, newStatus);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Assign due to tenants
  Future<void> assignDue({
    required String dueId,
    required List<String> tenantIds,
    double? amount,
  }) async {
    try {
      await _duesService.assignDueToTenants(
        dueId: dueId,
        tenantIds: tenantIds,
        amount: amount,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
