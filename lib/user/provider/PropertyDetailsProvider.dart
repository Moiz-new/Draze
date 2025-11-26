import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/PropertyDetailsModel.dart';

class PropertyDetailsProvider extends ChangeNotifier {
  PropertyModel? _property;
  bool _isLoading = false;
  String? _error;
  bool _isSchedulingVisit = false;
  String? _visitScheduleError;
  String? _visitScheduleSuccess;

  PropertyModel? get property => _property;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSchedulingVisit => _isSchedulingVisit;
  String? get visitScheduleError => _visitScheduleError;
  String? get visitScheduleSuccess => _visitScheduleSuccess;

  Future<void> fetchProperty(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/public/property/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(propertyId);
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['property'] != null) {
          _property = PropertyModel.fromJson(data['property']);
        } else {
          throw Exception('Property not found');
        }
      } else {
        throw Exception('Failed to fetch property: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scheduleVisit({
    required String propertyId,
    required DateTime visitDate,
    required String notes,
    required String contactNumber,
  }) async {
    _isSchedulingVisit = true;
    _visitScheduleError = null;
    _visitScheduleSuccess = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> bodyData = {
        'propertyId': propertyId,
        'visitDate': visitDate.toIso8601String(),
        'notes': notes,
        'contactNumber': contactNumber,
      };

      // 🔥 Print the body before sending to API
      print("📌 API Body → ${json.encode(bodyData)}");

      final response = await http.post(
        Uri.parse('$base_url/api/visits'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(bodyData),
      );

      print("🔵 API Response Status: ${response.statusCode}");
      print("🔵 API Response Body: ${response.body}"); // Optional print response too

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _visitScheduleSuccess = data['message'] ?? 'Visit scheduled successfully';
        } else {
          throw Exception('Failed to schedule visit');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to schedule visit: ${response.statusCode}');
      }
    } catch (e) {
      _visitScheduleError = e.toString();
    } finally {
      _isSchedulingVisit = false;
      notifyListeners();
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearVisitMessages() {
    _visitScheduleError = null;
    _visitScheduleSuccess = null;
    notifyListeners();
  }
}