import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../app/api_constants.dart';
import '../models/SellerVisitorModel.dart';

class SellerVisitorsDashboardProvider extends ChangeNotifier {
  // State variables
  List<SellerVisitorModel> _visits = [];
  int _totalVisits = 0;
  Map<String, int> _statusCounts = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SellerVisitorModel> get visits => _visits;

  int get totalVisits => _totalVisits;

  Map<String, int> get statusCounts => _statusCounts;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // Individual status count getters with null safety
  int get pendingCount => _statusCounts['PENDING'] ?? 0;

  int get confirmedCount => _statusCounts['CONFIRMED'] ?? 0;

  int get completedCount => _statusCounts['COMPLETED'] ?? 0;

  int get cancelledCount => _statusCounts['CANCELLED'] ?? 0;

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
        Uri.parse('$base_url/api/seller/getallvisits'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Parse visits array
          final List<dynamic> visitsJson = data['visits'] ?? [];
          _visits =
              visitsJson
                  .map((json) => SellerVisitorModel.fromJson(json))
                  .toList();

          // Calculate total visits
          _totalVisits = _visits.length;

          // Calculate status counts
          _statusCounts = {};
          for (var visit in _visits) {
            final status = visit.status.toUpperCase();
            _statusCounts[status] = (_statusCounts[status] ?? 0) + 1;
          }

          print('Total Visits: $_totalVisits');
          print('Status Counts: $_statusCounts');
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _visits = [];
      _totalVisits = 0;
      _statusCounts = {};
      print('Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to get visits by status
  List<SellerVisitorModel> getVisitsByStatus(String status) {
    return _visits
        .where((visit) => visit.status.toUpperCase() == status.toUpperCase())
        .toList();
  }

  // Method to get visits by property
  List<SellerVisitorModel> getVisitsByProperty(String propertyId) {
    return _visits
        .where((visit) => visit.propertyId?.id == propertyId)
        .toList();
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

  // Method to clear all data
  void clearData() {
    _visits = [];
    _totalVisits = 0;
    _statusCounts = {};
    _error = null;
    notifyListeners();
  }
}
