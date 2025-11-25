// models/SellerSubscriptionModel.dart

import 'package:draze/app/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Subscription Plan Model
class SellerSubscriptionPlan {
  final String id;
  final String planName;
  final double price;
  final int propertyLimit;
  final int durationDays;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SellerSubscriptionPlan({
    required this.id,
    required this.planName,
    required this.price,
    required this.propertyLimit,
    required this.durationDays,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SellerSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SellerSubscriptionPlan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      propertyLimit: json['propertyLimit'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'price': price,
      'propertyLimit': propertyLimit,
      'durationDays': durationDays,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for creating modified copies
  SellerSubscriptionPlan copyWith({
    String? id,
    String? planName,
    double? price,
    int? propertyLimit,
    int? durationDays,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerSubscriptionPlan(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      propertyLimit: propertyLimit ?? this.propertyLimit,
      durationDays: durationDays ?? this.durationDays,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SellerSubscriptionPlan(id: $id, planName: $planName, price: $price, propertyLimit: $propertyLimit, durationDays: $durationDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SellerSubscriptionPlan &&
        other.id == id &&
        other.planName == planName &&
        other.price == price &&
        other.propertyLimit == propertyLimit &&
        other.durationDays == durationDays &&
        other.description == description &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planName.hashCode ^
        price.hashCode ^
        propertyLimit.hashCode ^
        durationDays.hashCode ^
        description.hashCode ^
        isActive.hashCode;
  }
}

// Provider Class
class SellerSubscriptionProvider with ChangeNotifier {
  List<SellerSubscriptionPlan> _plans = [];
  bool _isLoading = false;
  String? _error;
  SellerSubscriptionPlan? _selectedPlan;

  List<SellerSubscriptionPlan> get plans => _plans;

  bool get isLoading => _isLoading;

  String? get error => _error;

  SellerSubscriptionPlan? get selectedPlan => _selectedPlan;

  // Get auth token from SharedPreferences
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  // Fetch subscription plans from API
  Future<void> fetchSubscriptionPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/seller/subscription/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Fetch Plans Response Status: ${response.statusCode}');
      debugPrint('Fetch Plans Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> plansData = jsonData['data'];
          _plans =
              plansData
                  .map((plan) => SellerSubscriptionPlan.fromJson(plan))
                  .toList();

          // Sort plans by price
          _plans.sort((a, b) => a.price.compareTo(b.price));

          debugPrint('Successfully fetched ${_plans.length} plans');
        } else {
          throw Exception('Failed to load subscription plans');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching subscription plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Capture payment and activate subscription
  Future<bool> capturePayment({
    required String paymentId,
    required String planId,
    required double amount,
    String? note,
  }) async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      debugPrint('=== Capturing Payment ===');
      debugPrint('Payment ID: $paymentId');
      debugPrint('Plan ID: $planId');
      debugPrint('Amount: $amount');
      debugPrint('Note: ${note ?? "No note"}');

      final requestBody = {
        'razorpay_payment_id': paymentId,
        'planId': planId,
        'amount': amount,
        'note': note ?? 'Subscription plan purchase',
      };

      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$base_url/api/seller/payment/capture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Check for success status codes (200 or 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        // Check if the API response indicates success
        if (jsonData['success'] == true || jsonData['status'] == 'success') {
          debugPrint('✅ Payment captured successfully');

          // Clear the selected plan after successful payment
          clearSelectedPlan();

          // Optionally refresh subscription plans
          await fetchSubscriptionPlans();

          return true;
        } else {
          // API returned 200/201 but success is false
          final errorMessage =
              jsonData['message'] ?? 'Failed to capture payment';
          debugPrint('❌ Payment capture failed: $errorMessage');
          throw Exception(errorMessage);
        }
      } else if (response.statusCode == 400) {
        // Bad request - validation error
        final jsonData = json.decode(response.body);
        final errorMessage = jsonData['message'] ?? 'Invalid payment details';
        debugPrint('❌ Payment validation error: $errorMessage');
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        // Unauthorized
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        // Not found
        throw Exception('Payment capture endpoint not found');
      } else if (response.statusCode == 500) {
        // Server error
        throw Exception('Server error. Please try again later.');
      } else {
        // Other errors
        throw Exception(
          'Payment capture failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error capturing payment: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Select a plan
  void selectPlan(SellerSubscriptionPlan plan) {
    _selectedPlan = plan;
    debugPrint('Selected plan: ${plan.planName} (${plan.id})');
    notifyListeners();
  }

  // Clear selected plan
  void clearSelectedPlan() {
    _selectedPlan = null;
    debugPrint('Cleared selected plan');
    notifyListeners();
  }

  // Get plan by ID
  SellerSubscriptionPlan? getPlanById(String id) {
    try {
      return _plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      debugPrint('Plan not found with id: $id');
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _plans = [];
    _isLoading = false;
    _error = null;
    _selectedPlan = null;
    notifyListeners();
  }
}
