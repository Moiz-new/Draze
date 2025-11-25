import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../app/api_constants.dart';

class OTPVerificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  Map<String, dynamic>? _verificationResponse;

  bool get isLoading => _isLoading;

  bool get isResending => _isResending;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get verificationResponse => _verificationResponse;

  Future<bool> verifyOTP(String mobile, String otp, String userType) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$base_url/api/auth/otp/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'otp': otp, 'userType': userType}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _verificationResponse = responseData;

        // Save user data to SharedPreferences
        await _saveUserData(responseData);

        _setLoading(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'OTP verification failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyTanentOTP(String mobile, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$base_url/api/users/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'otp': otp}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _verificationResponse = responseData;

        // Save user data to SharedPreferences
        await _saveTanentUserData(responseData);

        _setLoading(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'OTP verification failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }
  Future<bool> verifyAgentOTP(String mobile, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$base_url/api/seller/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'otp': otp}),
      );

      final responseData = json.decode(response.body);
      print("Bodyyyyyyyyyyyyyyyyy$responseData");

      if (response.statusCode == 200 && responseData['success'] == true) {
        _verificationResponse = responseData;

        // Save user data to SharedPreferences
        await _saveAgentUserData(responseData);

        _setLoading(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'OTP verification failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOTP(String mobile, String userType) async {
    _setResending(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$base_url/api/auth/otp/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mobile': mobile, 'userType': userType}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _setResending(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'Failed to resend OTP');
        _setResending(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setResending(false);
      return false;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    if (responseData['token'] != null) {
      await prefs.setString('auth_token', responseData['token']);
    }

    // Save user ID (from user object)
    if (responseData['user'] != null && responseData['user']['id'] != null) {
      await prefs.setString('landlord_id', responseData['user']['id']);
    }

    // Save user role for reference
    if (responseData['user'] != null && responseData['user']['role'] != null) {
      await prefs.setString('user_role', responseData['user']['role']);
    }

    // Save login status
    await prefs.setBool('is_logged_in', true);

    // Optional: Save other user details
    if (responseData['user'] != null) {
      final user = responseData['user'];
      if (user['name'] != null) {
        await prefs.setString('user_name', user['name']);
      }
      if (user['mobile'] != null) {
        await prefs.setString('user_mobile', user['mobile']);
      }
      if (user['email'] != null) {
        await prefs.setString('user_email', user['email']);
      }
    }
  }

  Future<void> _saveTanentUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    if (responseData['token'] != null) {
      await prefs.setString('auth_token', responseData['token']);
    }

    // Save user ID (from user object)
    if (responseData['user'] != null && responseData['user']['id'] != null) {
      await prefs.setString('user_id', responseData['user']['id']);
    }

    // Save user role for reference
    if (responseData['user'] != null && responseData['user']['role'] != null) {
      await prefs.setString('user_role', responseData['user']['role']);
    }

    // Save login status
    await prefs.setBool('is_logged_in', true);

    // Optional: Save other user details
    if (responseData['user'] != null) {
      final user = responseData['user'];
      if (user['name'] != null) {
        await prefs.setString('user_name', user['name']);
      }
      if (user['mobile'] != null) {
        await prefs.setString('user_mobile', user['mobile']);
      }
      if (user['email'] != null) {
        await prefs.setString('user_email', user['email']);
      }
    }
  }
  Future<void> _saveAgentUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save token
    if (responseData['token'] != null) {
      await prefs.setString('auth_token', responseData['token']);
    }

    // Save user ID (from user object)
    if (responseData['seller'] != null && responseData['seller']['id'] != null) {
      await prefs.setString('seller_id', responseData['seller']['id']);
      await prefs.setString('user_role', "seller");

    }

    // Save user role for reference
    if (responseData['user'] != null && responseData['user']['role'] != null) {
    }

    // Save login status
    await prefs.setBool('is_logged_in', true);

    // Optional: Save other user details
    if (responseData['seller'] != null) {
      final user = responseData['seller'];
      if (user['name'] != null) {
        await prefs.setString('user_name', user['name']);
      }
      if (user['mobile'] != null) {
        await prefs.setString('user_mobile', user['mobile']);
      }
      if (user['email'] != null) {
        await prefs.setString('user_email', user['email']);
      }
    }
  }

  // Method to retrieve saved user data
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'auth_token': prefs.getString('auth_token'),
      'user_id': prefs.getString('user_id'),
      'user_role': prefs.getString('user_role'),
      'user_name': prefs.getString('user_name'),
      'user_mobile': prefs.getString('user_mobile'),
      'user_email': prefs.getString('user_email'),
    };
  }

  // Method to check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Method to logout (clear stored data)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_mobile');
    await prefs.remove('user_email');
    await prefs.setBool('is_logged_in', false);

    // Clear the current state
    clearState();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setResending(bool resending) {
    _isResending = resending;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearState() {
    _isLoading = false;
    _isResending = false;
    _errorMessage = null;
    _verificationResponse = null;
    notifyListeners();
  }
}
