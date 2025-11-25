import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../app/api_constants.dart';

class VisitorsDashboardProvider extends ChangeNotifier {
  // State variables
  int? _totalVisits;
  Map<String, int>? _statusCounts;
  bool _isLoading = false;
  String? _error;

  // Getters
  int? get totalVisits => _totalVisits;
  Map<String, int>? get statusCounts => _statusCounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Individual status count getters with null safety
  int get pendingCount => _statusCounts?['pending'] ?? 0;
  int get confirmedCount => _statusCounts?['confirmed'] ?? 0;
  int get completedCount => _statusCounts?['completed'] ?? 0;
  int get cancelledCount => _statusCounts?['cancelled'] ?? 0;

  // API call method
  Future<void> fetchVisitorsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get auth token from shared preferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      // Make API call
      final response = await http.get(
        Uri.parse('$base_url/api/visits/landlord'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          _totalVisits = data['totalVisits'];
          _statusCounts = Map<String, int>.from(data['statusCounts'] ?? {});
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _totalVisits = null;
      _statusCounts = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await fetchVisitorsData();
  }
}