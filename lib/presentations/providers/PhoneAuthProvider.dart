// providers/phone_auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../app/api_constants.dart';

class PhoneAuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _otpResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get otpResponse => _otpResponse;

  Future<bool> requestOTP(String mobile, String userType) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$base_url/api/auth/otp/request-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': mobile,
          'userType': userType,
        }),
      );

      final responseData = json.decode(response.body);

      print(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        _otpResponse = responseData;
        _setLoading(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }
  Future<bool> requesagentOTP(String mobile, String userType) async {
    print("Agents");
    _setLoading(true);
    _clearError();
    print("Agents1");

    try {

      print("Agents2");


      final response = await http.post(
        Uri.parse('$base_url/api/seller/request-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': mobile,
          'userType': userType,
        }),
      );
      print("Agents3");

      final responseData = json.decode(response.body);
      print("Agents4");

      print(mobile);
      print(userType);
      print(responseData);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _otpResponse = responseData;
        _setLoading(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }
  Future<bool> requestTanentOTP(String mobile,) async {
    _setLoading(true);
    _clearError();


    try {
      final response = await http.post(
        Uri.parse('$base_url/api/users/auth/request-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mobile': mobile,
        }),
      );

      final responseData = json.decode(response.body);

      print("responsseeeeeeeeee$responseData");
      if (response.statusCode == 200 && responseData['success'] == true) {
        _otpResponse = responseData;
        _setLoading(false);
        return true;
      } else {
        _setError(responseData['message'] ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
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
    _errorMessage = null;
    _otpResponse = null;
    notifyListeners();
  }
}