import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/AllTenantDuesList.dart';

class AllTenantDuesListProvider extends ChangeNotifier {
  DuesResponse? _duesResponse;
  bool _isLoading = false;
  String? _error;

  DuesResponse? get duesResponse => _duesResponse;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<TenantDue> get tenants => _duesResponse?.tenants ?? [];

  double get totalDuesAmount {
    double total = 0;
    if (_duesResponse?.tenants != null) {
      for (var tenant in _duesResponse!.tenants!) {
        total += tenant.totalAmount ?? 0;
      }
    }
    return total;
  }

  int get totalPendingDues {
    int count = 0;
    if (_duesResponse?.tenants != null) {
      for (var tenant in _duesResponse!.tenants!) {
        if (tenant.dues != null) {
          count +=
              tenant.dues!
                  .where((due) => due.status?.toUpperCase() == 'PENDING')
                  .length;
        }
      }
    }
    return count;
  }

  Future<void> fetchDues() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final landlordId = prefs.getString('landlord_id');
      final response = await http.get(
        Uri.parse('$base_url/api/dues/getdue/$landlordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _duesResponse = DuesResponse.fromJson(jsonData);
        _error = null;
      } else {
        _error = 'Failed to load dues: ${response.statusCode}';
        _duesResponse = null;
      }
    } catch (e) {
      _error = 'Error fetching dues: $e';
      _duesResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _duesResponse = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
