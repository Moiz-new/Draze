import 'dart:convert';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserRegistrationProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get userData => _userData;

  static final String _baseUrl = '$base_url/api/auth/user/register';

  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required int age,
    required String gender,
    required String street,
    required String city,
    required String state,
    required String postalCode,
    String? country,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Prepare request body matching the backend schema exactly
      final requestBody = {
        "fullName": fullName.trim(), // Ensure no extra whitespace
        "email": email.trim().toLowerCase(), // Match backend lowercase requirement
        "phone": phone.trim(), // Remove any whitespace
        "age": age,
        "gender": gender, // Make sure this matches enum values: "Male", "Female", "Other"
        "address": {
          "street": street.trim(),
          "city": city.trim(),
          "state": state.trim(),
          "postalCode": postalCode.trim(),
          "country": country?.trim() ?? "India", // Provide default country
        },
      };

      print("Request Body: ${json.encode(requestBody)}");

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData != null) {
          _userData = responseData;
          await _saveUserData(responseData);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Invalid response from server';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Better error handling
        try {
          final errorData = json.decode(response.body);
          _errorMessage = errorData['message'] ?? 'Registration failed. Please try again.';
        } catch (e) {
          _errorMessage = 'Registration failed. Status: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Save token if present in response
      if (responseData['token'] != null) {
        await prefs.setString('auth_token', responseData['token']);
      }

      // Save user ID (direct from response as it's at root level)
      if (responseData['_id'] != null) {
        await prefs.setString('user_id', responseData['_id']);
      }

      // Save user role for reference
      if (responseData['role'] != null) {
        await prefs.setString('user_role', responseData['role']);
      }

      // Save login status
      await prefs.setBool('is_logged_in', true);

      // Save other user details
      if (responseData['fullName'] != null) {
        await prefs.setString('user_name', responseData['fullName']);
      }
      if (responseData['userName'] != null) {
        await prefs.setString('user_username', responseData['userName']);
      }
      if (responseData['phone'] != null) {
        await prefs.setString('user_mobile', responseData['phone']);
      }
      if (responseData['email'] != null) {
        await prefs.setString('user_email', responseData['email']);
      }
      if (responseData['age'] != null) {
        await prefs.setInt('user_age', responseData['age']);
      }
      if (responseData['gender'] != null) {
        await prefs.setString('user_gender', responseData['gender']);
      }

      // Save address details if present
      if (responseData['address'] != null) {
        final address = responseData['address'];
        if (address['street'] != null) {
          await prefs.setString('user_street', address['street']);
        }
        if (address['city'] != null) {
          await prefs.setString('user_city', address['city']);
        }
        if (address['state'] != null) {
          await prefs.setString('user_state', address['state']);
        }
        if (address['postalCode'] != null) {
          await prefs.setString('user_postal_code', address['postalCode']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearUserData() {
    _userData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
