import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/MySubscriptionPlansModel.dart';
import '../models/ReelMySubcriptionModel.dart';

class MySubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];
  List<ReelSubscription> _reelSubscriptions = [];
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  List<ReelSubscription> get reelSubscriptions => _reelSubscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Check if there are any subscriptions (bed or reel)
  bool get hasAnySubscriptions => _subscriptions.isNotEmpty || _reelSubscriptions.isNotEmpty;

  // Fetch all subscriptions (bed + reel)
  Future<void> fetchAllSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch both subscriptions in parallel
      await Future.wait([
        _fetchBedSubscriptions(),
        _fetchReelSubscriptions(),
      ]);

      // Only set error if both are empty and there was actually an error
      if (!hasAnySubscriptions && _error == null) {
        _error = null; // No error, just no subscriptions
      }
    } catch (e) {
      _error = 'Error loading subscriptions: ${e.toString()}';
      print('Error in fetchAllSubscriptions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReelSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchReelSubscriptions();
      _error = null;
    } catch (e) {
      _error = 'Error loading reel subscriptions: ${e.toString()}';
      print('Error in fetchReelSubscriptions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch bed subscriptions (original API)
  Future<void> _fetchBedSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final landlordId = prefs.getString('landlord_id');

      if (landlordId == null || landlordId.isEmpty) {
        print('Landlord ID not found for bed subscriptions');
        _subscriptions = [];
        return;
      }

      final response = await http.get(
        Uri.parse(
          '$base_url/api/landlord/subscriptions/my-subscriptions/$landlordId',
        ),
      );

      print(landlordId);
      print('Bed Subscriptions Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          _subscriptions = (jsonData['data'] as List)
              .map((item) => Subscription.fromJson(item))
              .toList();
          print('Bed subscriptions loaded: ${_subscriptions.length}');
        } else {
          _subscriptions = [];
          print('No bed subscription data found');
        }
      } else {
        _subscriptions = [];
        print('Bed subscriptions API error: ${response.statusCode}');
      }
    } catch (e) {
      _subscriptions = [];
      print('Error fetching bed subscriptions: $e');
    }
  }

  // Fetch reel subscriptions (new API)
  Future<void> _fetchReelSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final landlordId = prefs.getString('landlord_id');

      if (landlordId == null || landlordId.isEmpty) {
        print('Landlord ID not found for reel subscriptions');
        _reelSubscriptions = [];
        return;
      }

      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('No auth token found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/landlord/reel-subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );


      print('Reel Subscriptions Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          _reelSubscriptions = (jsonData['data'] as List)
              .map((item) => ReelSubscription.fromJson(item))
              .toList();
          print('Reel subscriptions loaded: ${_reelSubscriptions.length}');
        } else {
          _reelSubscriptions = [];
          print('No reel subscription data found');
        }
      } else {
        _reelSubscriptions = [];
        print('Reel subscriptions API error: ${response.statusCode}');
      }
    } catch (e) {
      _reelSubscriptions = [];
      print('Error fetching reel subscriptions: $e');
    }
  }

  // Keep the original method for backward compatibility
  Future<void> fetchSubscriptions() async {
    await fetchAllSubscriptions();
  }

  // Refresh all subscriptions
  Future<void> refreshSubscriptions() async {
    await fetchAllSubscriptions();
  }
}