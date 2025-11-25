import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/appColors.dart';

// Model Classes
class MySubscriptionPlan {
  final String id;
  final String planName;
  final double price;
  final int propertyLimit;
  final int durationDays;
  final bool isTrial;
  final String description;

  MySubscriptionPlan({
    required this.id,
    required this.planName,
    required this.price,
    required this.propertyLimit,
    required this.durationDays,
    required this.isTrial,
    required this.description,
  });

  factory MySubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return MySubscriptionPlan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      propertyLimit: json['propertyLimit'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
      isTrial: json['isTrial'] ?? false,
      description: json['description'] ?? '',
    );
  }
}

class MySubscription {
  final String id;
  final String sellerId;
  final MySubscriptionPlan? planId;
  final String planName;
  final int propertyLimit;
  final double price;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String paymentStatus;

  MySubscription({
    required this.id,
    required this.sellerId,
    this.planId,
    required this.planName,
    required this.propertyLimit,
    required this.price,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.paymentStatus,
  });

  factory MySubscription.fromJson(Map<String, dynamic> json) {
    return MySubscription(
      id: json['_id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      planId: json['planId'] != null
          ? MySubscriptionPlan.fromJson(json['planId'])
          : null,
      planName: json['planName'] ?? '',
      propertyLimit: json['propertyLimit'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 0,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
      paymentStatus: json['paymentStatus'] ?? '',
    );
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  double get progressPercentage {
    final totalDays = endDate.difference(startDate).inDays;
    final daysUsed = DateTime.now().difference(startDate).inDays;
    if (totalDays <= 0) return 0;
    final progress = (daysUsed / totalDays).clamp(0.0, 1.0);
    return progress;
  }
}

// Provider
class SellerMySubscriptionProvider with ChangeNotifier {
  MySubscription? _subscription;
  bool _isLoading = false;
  String? _error;

  MySubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveSubscription => _subscription?.isActive ?? false;

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchMySubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('https://api.drazeapp.com/api/seller/subscription/my-subscription'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          _subscription = MySubscription.fromJson(jsonData['data']);
          _error = null;
        } else {
          _subscription = null;
          _error = jsonData['message'] ?? 'No active subscription found';
        }
      } else if (response.statusCode == 404) {
        _subscription = null;
        _error = 'No active subscription found';
      } else {
        throw Exception('Failed to load subscription: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _subscription = null;
      debugPrint('Error fetching subscription: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
