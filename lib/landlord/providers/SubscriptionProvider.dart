import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/SubcriptionsBedReelModel.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<BedPlan> _bedPlans = [];
  List<ReelPlan> _reelPlans = [];
  bool _isLoading = false;
  String? _error;

  List<BedPlan> get bedPlans => _bedPlans;

  List<ReelPlan> get reelPlans => _reelPlans;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchBedPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$base_url/api/landlord/subscriptions/plans'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _bedPlans =
            (data['data'] as List)
                .map((plan) => BedPlan.fromJson(plan))
                .toList();
      } else {
        _error = 'Failed to load bed plans';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReelPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$base_url/api/reel/reel-subscription-plans/active'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _reelPlans =
            (data['data'] as List)
                .map((plan) => ReelPlan.fromJson(plan))
                .toList();
      } else {
        _error = 'Failed to load reel plans';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllPlans() async {
    await Future.wait([fetchBedPlans(), fetchReelPlans()]);
  }

  // Capture Bed Subscription Payment
  Future<Map<String, dynamic>> captureBedSubscriptionPayment({
    required String razorpayPaymentId,
    required String landlordId,
    required String planId,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/api/subscription/capture'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpay_payment_id': razorpayPaymentId,
          'landlordId': landlordId,
          'planId': planId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to capture payment: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Capture Reel Subscription Payment
  Future<Map<String, dynamic>> captureReelSubscriptionPayment({
    required String razorpayPaymentId,
    required String landlordId,
    required String planId,
    required int amount,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$base_url/api/reels/subscription/capture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'razorpay_payment_id': razorpayPaymentId,
          'landlordId': landlordId,
          'planId': planId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Failed to capture payment: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
