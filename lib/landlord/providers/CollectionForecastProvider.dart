import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draze/app/api_constants.dart';

class CollectionForecastProvider extends ChangeNotifier {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _forecastData;
  String _selectedView = 'Forecast';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get forecastData => _forecastData;
  String get selectedView => _selectedView;

  // Computed getters for easy access
  Map<String, dynamic>? get currentMonth => _forecastData?['currentMonth'];
  Map<String, dynamic>? get nextMonth => _forecastData?['nextMonth'];
  Map<String, dynamic>? get twoMonthsAhead => _forecastData?['twoMonthsAhead'];
  int get projectedEfficiency => _forecastData?['projectedEfficiency'] ?? 0;
  List get pastCollectionEfficiency => _forecastData?['pastCollectionEfficiency'] as List? ?? [];
  List get breakdown => _forecastData?['breakdown'] as List? ?? [];

  // Initialize and load data
  Future<void> initialize() async {
    await loadForecastData();
  }

  // Load forecast data from API
  Future<void> loadForecastData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String? landlordId = prefs.getString('landlord_id');

      final response = await http.get(
        Uri.parse('$base_url/api/landlord/analytics/collections/forecast'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _forecastData = json.decode(response.body);
        _error = null;
      } else {
        _error = 'Failed to load forecast data';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change selected view (Forecast/Breakdown)
  void setSelectedView(String view) {
    if (_selectedView != view) {
      _selectedView = view;
      notifyListeners();
    }
  }

  // Utility method to format amounts
  String formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  // Get efficiency color based on value
  Color getEfficiencyColor(int efficiency) {
    if (efficiency > 70) {
      return const Color(0xFF4CAF50); // Success green
    } else if (efficiency > 40) {
      return const Color(0xFFFFA726); // Warning orange
    } else {
      return const Color(0xFFEF5350); // Error red
    }
  }

  // Check if breakdown data is available
  bool get hasBreakdownData => breakdown.isNotEmpty;

  // Check if past efficiency data is available
  bool get hasPastEfficiencyData => pastCollectionEfficiency.isNotEmpty;

  // Refresh/reload data
  Future<void> refresh() async {
    await loadForecastData();
  }

  // Clear all data (useful for logout)
  void clearData() {
    _isLoading = true;
    _error = null;
    _forecastData = null;
    _selectedView = 'Forecast';
    notifyListeners();
  }
}