// lib/providers/due_assignment_provider.dart

import 'package:draze/app/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DueAssignmentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasError => _error != null;

  static final String _baseUrl = '$base_url/api';

  /// Assigns a single due to a tenant
  Future<bool> assignDue({
    required String tenantId,
    required String landlordId,
    required String dueId,
    required double amount,
    required String dueDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (tenantId.isEmpty || landlordId.isEmpty || dueId.isEmpty) {
        throw Exception('Required fields cannot be empty');
      }

      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      // Prepare request body
      final body = {
        'tenantId': tenantId,
        'landlordId': landlordId,
        'dueId': dueId,
        'amount': amount,
        'dueDate': dueDate,
        'isActive': true,
      };

      print('Making API call to: $_baseUrl/dues/assign');
      print('Request body: ${jsonEncode(body)}');

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl/dues/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        // Try to parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          _error = errorData['message'] ?? 'Failed to assign due';
        } catch (e) {
          _error = 'Failed to assign due. Status: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error assigning due: $e');
      return false;
    }
  }

  /// Assigns multiple dues to a tenant
  Future<Map<String, dynamic>> assignMultipleDues({
    required String tenantId,
    required String landlordId,
    required List<Map<String, dynamic>> duesData,
    required String dueDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    int successCount = 0;
    int failureCount = 0;
    List<String> errors = [];

    try {
      // Validate inputs
      if (tenantId.isEmpty || landlordId.isEmpty) {
        throw Exception('Tenant ID and Landlord ID are required');
      }

      if (duesData.isEmpty) {
        throw Exception('No dues to assign');
      }

      // Assign each due sequentially
      for (var dueData in duesData) {
        try {
          final dueId = dueData['dueId'] as String?;
          final amountStr = dueData['amount'] as String?;

          if (dueId == null || dueId.isEmpty) {
            failureCount++;
            errors.add('Invalid due ID');
            continue;
          }

          if (amountStr == null || amountStr.isEmpty) {
            failureCount++;
            errors.add('Invalid amount for ${dueData['name'] ?? 'due'}');
            continue;
          }

          final amount = double.tryParse(amountStr);
          if (amount == null || amount <= 0) {
            failureCount++;
            errors.add('Invalid amount value for ${dueData['name'] ?? 'due'}');
            continue;
          }

          final success = await assignDue(
            tenantId: tenantId,
            landlordId: landlordId,
            dueId: dueId,
            amount: amount,
            dueDate: dueDate,
          );

          if (success) {
            successCount++;
          } else {
            failureCount++;
            errors.add(
              _error ?? 'Failed to assign ${dueData['name'] ?? 'due'}',
            );
          }
        } catch (e) {
          failureCount++;
          errors.add('Error with ${dueData['name'] ?? 'due'}: ${e.toString()}');
        }
      }

      _isLoading = false;
      notifyListeners();

      return {
        'success': successCount,
        'failure': failureCount,
        'errors': errors,
      };
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {
        'success': 0,
        'failure': duesData.length,
        'errors': [e.toString()],
      };
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
