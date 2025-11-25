import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

class LandlordRegistrationProvider extends ChangeNotifier {

  LandlordRegistrationProvider() {
    setupAadhaarPanListeners();
  }
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _stateController = TextEditingController();

  String? _verifiedAadhaarNumber;
  String? _verifiedPanNumber;

  // Add these getters
  String? get verifiedAadhaarNumber => _verifiedAadhaarNumber;

  String? get verifiedPanNumber => _verifiedPanNumber;

  bool _aadhaarVerified = false;
  bool _panVerified = false;

  bool get aadhaarVerified => _aadhaarVerified;

  bool get panVerified => _panVerified;

  // Form State
  String? _selectedGender;
  String? _selectedState;
  String? _profileImagePath;
  bool _isAgreedToTerms = false;
  bool _isLoading = false;

  // Validation errors
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _dobError;
  String? _aadharError;
  String? _panError;
  String? _addressError;
  String? _pinCodeError;
  String? _stateError;
  String? _genderError;
  String? _profileImageError;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _stateOptions = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Puducherry',
  ];

  static final String _apiUrl = '$base_url/api/landlord/register';

  // Getters
  TextEditingController get nameController => _nameController;

  TextEditingController get emailController => _emailController;

  TextEditingController get phoneController => _phoneController;

  TextEditingController get dobController => _dobController;

  TextEditingController get aadharController => _aadharController;

  TextEditingController get panController => _panController;

  TextEditingController get addressController => _addressController;

  TextEditingController get pinCodeController => _pinCodeController;

  TextEditingController get stateController => _stateController;

  String? get selectedGender => _selectedGender;

  String? get selectedState => _selectedState;

  String? get profileImagePath => _profileImagePath;

  bool get isAgreedToTerms => _isAgreedToTerms;

  bool get isLoading => _isLoading;

  List<String> get genderOptions => _genderOptions;

  List<String> get stateOptions => _stateOptions;

  // Error getters
  String? get nameError => _nameError;

  String? get emailError => _emailError;

  String? get phoneError => _phoneError;

  String? get dobError => _dobError;

  String? get aadharError => _aadharError;

  String? get panError => _panError;

  String? get addressError => _addressError;

  String? get pinCodeError => _pinCodeError;

  String? get stateError => _stateError;

  String? get genderError => _genderError;

  String? get profileImageError => _profileImageError;

  void setupAadhaarPanListeners() {
    _aadharController.addListener(_onAadhaarChanged);
    _panController.addListener(_onPanChanged);
  }

  // Add these listener methods
  void _onAadhaarChanged() {
    final currentAadhaar = _aadharController.text.replaceAll('-', '').trim();
    if (_aadhaarVerified && currentAadhaar != _verifiedAadhaarNumber) {
      _aadhaarVerified = false;
      _verifiedAadhaarNumber = null;
      _aadharError = 'Aadhaar number changed. Please verify again.';
      notifyListeners();
    }
  }


  void _onPanChanged() {
    final currentPan = _panController.text.trim().toUpperCase();
    if (_panVerified && currentPan != _verifiedPanNumber) {
      _panVerified = false;
      _verifiedPanNumber = null;
      _panError = 'PAN number changed. Please verify again.';
      notifyListeners();
    }
  }

  // Update the existing setAadhaarVerified method
  void setAadhaarVerified(bool value) {
    _aadhaarVerified = value;
    if (value) {
      _verifiedAadhaarNumber =
          _aadharController.text.replaceAll('-', '').trim();
    }
    notifyListeners();
  }

  // Update the existing setPanVerified method
  void setPanVerified(bool value) {
    _panVerified = value;
    if (value) {
      _verifiedPanNumber = _panController.text.trim().toUpperCase();
    }
    notifyListeners();
  }

  // Setters
  void setSelectedGender(String? gender) {
    _selectedGender = gender;
    _genderError = null;
    notifyListeners();
  }

  void setSelectedState(String? state) {
    _selectedState = state;
    _stateError = null;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _isAgreedToTerms = value;
    notifyListeners();
  }

  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    _profileImageError = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateName(String? value) {
    final requiredCheck = _validateRequired(value, 'Name');
    if (requiredCheck != null) return requiredCheck;

    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name should only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final requiredCheck = _validateRequired(value, 'Email');
    if (requiredCheck != null) return requiredCheck;

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    final requiredCheck = _validateRequired(value, 'Phone number');
    if (requiredCheck != null) return requiredCheck;

    if (value!.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  Future<Map<String, dynamic>> generateAadhaarOtp() async {
    final aadhaarNumber = _aadharController.text.replaceAll("-", "");
    final url = "$base_url/api/kyc/aadhaar/generate-otp";
    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"aadhaarNumber": aadhaarNumber}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          "success": true,
          "txnId": data['txnId'],
          "message": data['message'] ?? "OTP sent successfully",
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "OTP generation failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: ${e.toString()}"};
    } finally {
      setLoading(false);
    }
  }

  String? validateDOB(String? value) {
    final requiredCheck = _validateRequired(value, 'Date of birth');
    if (requiredCheck != null) return requiredCheck;

    try {
      List<String> parts = value!.split('/');
      if (parts.length != 3) return 'Invalid date format';

      DateTime dob = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      DateTime now = DateTime.now();

      if (dob.isAfter(now)) return 'Date of birth cannot be in the future';

      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day))
        age--;

      if (age < 18) return 'You must be at least 18 years old';
      if (age > 120) return 'Please enter a valid date of birth';
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }

  String? validateAadhar(String? value) {
    final requiredCheck = _validateRequired(value, 'Aadhar number');
    if (requiredCheck != null) return requiredCheck;

    String digitsOnly = value!.replaceAll('-', '');
    if (digitsOnly.length != 12) return 'Aadhar number must be 12 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(digitsOnly))
      return 'Aadhar number should only contain digits';
    if (RegExp(r'^(\d)\1{11}$').hasMatch(digitsOnly))
      return 'Invalid Aadhar number';
    return null;
  }

  String? validatePAN(String? value) {
    final requiredCheck = _validateRequired(value, 'PAN number');
    if (requiredCheck != null) return requiredCheck;

    if (value!.length != 10) return 'PAN number must be 10 characters';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
      return 'Invalid PAN format (e.g., ABCDE1234F)';
    }
    return null;
  }

  String? validateAddress(String? value) {
    final requiredCheck = _validateRequired(value, 'Address');
    if (requiredCheck != null) return requiredCheck;

    if (value!.trim().length < 10) {
      return 'Please enter complete address (at least 10 characters)';
    }
    return null;
  }

  String? validatePinCode(String? value) {
    final requiredCheck = _validateRequired(value, 'PIN Code');
    if (requiredCheck != null) return requiredCheck;

    if (value!.length != 6) return 'PIN Code must be 6 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(value))
      return 'PIN Code should only contain digits';
    return null;
  }

  String? validateGender() =>
      _selectedGender == null ? 'Please select gender' : null;

  String? validateState() =>
      _selectedState == null ? 'Please select state' : null;

  String? validateProfileImage() {
    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      return 'Please select profile image';
    }
    try {
      if (!File(_profileImagePath!).existsSync()) {
        return 'Selected image file not found';
      }
    } catch (e) {
      return 'Invalid image file';
    }
    return null;
  }

  // Validate all fields
  bool validateAllFields() {
    _nameError = validateName(_nameController.text);
    _emailError = validateEmail(_emailController.text);
    _phoneError = validatePhone(_phoneController.text);
    _dobError = validateDOB(_dobController.text);
    _aadharError = validateAadhar(_aadharController.text);
    _panError = validatePAN(_panController.text);
    _addressError = validateAddress(_addressController.text);
    _pinCodeError = validatePinCode(_pinCodeController.text);
    _genderError = validateGender();
    _stateError = validateState();
    _profileImageError = validateProfileImage();

    // Custom validation: check Aadhaar verification
    if (!_aadhaarVerified) {
      _aadharError = 'Please verify your Aadhaar number';
    }

    // Custom validation: check PAN verification
    if (!_panVerified) {
      _panError = 'Please verify your PAN number';
    }

    notifyListeners();

    return [
          _nameError,
          _emailError,
          _phoneError,
          _dobError,
          _aadharError,
          _panError,
          _addressError,
          _pinCodeError,
          _genderError,
          _stateError,
          _profileImageError,
        ].every((error) => error == null) &&
        _isAgreedToTerms;
  }

  // Clear all errors
  void clearAllErrors() {
    _nameError =
        _emailError =
            _phoneError =
                _dobError =
                    _aadharError =
                        _panError =
                            _addressError =
                                _pinCodeError =
                                    _genderError =
                                        _stateError = _profileImageError = null;
    notifyListeners();
  }

  // API Integration
  Future<Map<String, dynamic>> registerLandlord() async {
    if (!_aadhaarVerified || !_panVerified) {
      return {
        'success': false,
        'message': 'Please verify your Aadhaar and PAN before registering',
      };
    }
    try {
      setLoading(true);

      // Convert DD/MM/YYYY to ISO format for API
      final dobParts = _dobController.text.split('/');
      final dobISO =
          '${dobParts[2]}-${dobParts[1].padLeft(2, '0')}-${dobParts[0].padLeft(2, '0')}';

      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // Add form fields
      request.fields.addAll({
        'name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'aadhaar': _aadharController.text.replaceAll('-', ''),
        'pan': _panController.text.trim().toUpperCase(),
        'address': _addressController.text.trim(),
        'pinCode': _pinCodeController.text.trim(),
        'state': _selectedState!,
        'dob': dobISO,
        'gender': _selectedGender!,
      });

      // Add profile photo if selected
      if (_profileImagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profilePhoto', _profileImagePath!),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          // Save token and landlord ID
          await _saveUserData(data['token'], data['landlord']['id']);
          return {'success': true, 'message': data['message']};
        }
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      setLoading(false);
    }
  }

  Future<void> _saveUserData(String token, String landlordId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('landlord_id', landlordId);
    await prefs.setBool('is_logged_in', true);
  }

  Future<Map<String, dynamic>> submitAadhaarOtp({
    required int txnId,
    required String otp,
  }) async {
    final url = "$base_url/api/kyc/aadhaar/submit-otp";
    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"txnId": txnId, "otp": otp}),
      );

      final data = json.decode(response.body);

      print(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final kycData = data['data'];
        _aadhaarVerified = true;
        _verifiedAadhaarNumber = _aadharController.text.replaceAll('-', '').trim();


        // Update form fields from KYC data
        _nameController.text = kycData['full_name'] ?? _nameController.text;
        _dobController.text =
            _formatDateForDisplay(kycData['dob']) ?? _dobController.text;
        _aadharController.text =
            _formatAadhaarForDisplay(kycData['aadhaar_number']) ??
            _aadharController.text;
        _selectedGender =
            _mapGenderFromApi(kycData['gender']) ?? _selectedGender;

        // Compose address from api address object
        if (kycData['address'] != null && kycData['address'] is Map) {
          final addressMap = Map<String, dynamic>.from(kycData['address']);
          String fullAddress = '';
          // Combine components for address string:
          List<String> parts = [];
          if (addressMap['house'] != null &&
              (addressMap['house'] as String).isNotEmpty)
            parts.add(addressMap['house']);
          if (addressMap['street'] != null &&
              (addressMap['street'] as String).isNotEmpty)
            parts.add(addressMap['street']);
          if (addressMap['landmark'] != null &&
              (addressMap['landmark'] as String).isNotEmpty)
            parts.add(addressMap['landmark']);
          if (addressMap['loc'] != null &&
              (addressMap['loc'] as String).isNotEmpty)
            parts.add(addressMap['loc']);
          if (addressMap['vtc'] != null &&
              (addressMap['vtc'] as String).isNotEmpty)
            parts.add(addressMap['vtc']);
          if (addressMap['subdist'] != null &&
              (addressMap['subdist'] as String).isNotEmpty)
            parts.add(addressMap['subdist']);
          if (addressMap['dist'] != null &&
              (addressMap['dist'] as String).isNotEmpty)
            parts.add(addressMap['dist']);
          if (addressMap['state'] != null &&
              (addressMap['state'] as String).isNotEmpty)
            parts.add(addressMap['state']);
          if (addressMap['country'] != null &&
              (addressMap['country'] as String).isNotEmpty)
            parts.add(addressMap['country']);
          fullAddress = parts.join(", ");
          _addressController.text = fullAddress;
          _selectedState = addressMap['state'] ?? _selectedState;
          _pinCodeController.text = (kycData['zip'] ?? '').toString();
        }

        notifyListeners();

        return {
          'success': true,
          'message': data['message'] ?? 'Aadhaar verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      setLoading(false);
    }
  }

  String _formatDateForDisplay(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(isoDate);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return '';
    }
  }

  String _formatAadhaarForDisplay(String? aadhaar) {
    if (aadhaar == null || aadhaar.length != 12) return aadhaar ?? '';
    return aadhaar
        .replaceRange(4, 4, '-') // Insert dash after 4 digits
        .replaceRange(9, 9, '-'); // Insert dash after next 4 digits
  }

  String? _mapGenderFromApi(String? apiGender) {
    if (apiGender == null) return null;
    switch (apiGender.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'O':
        return 'Other';
      default:
        return null;
    }
  }

  Future<Map<String, dynamic>> verifyPan() async {
    final panNumber = _panController.text.trim().toUpperCase();
    final url = "$base_url/api/kyc/pan";
    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"panNumber": panNumber}),
      );

      print(response.body);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _panVerified = true;
        _verifiedPanNumber = _panController.text.trim().toUpperCase();

        // Optional: update full name from API if you want to override
        final panData = data['data'];
        if (panData['full_name'] != null &&
            panData['full_name'].toString().isNotEmpty) {
          _nameController.text = panData['full_name'];
          notifyListeners();
        }

        notifyListeners();
        return {
          'success': true,
          'message': data['message'] ?? 'PAN verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'PAN verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      setLoading(false);
    }
  }

  // Get registration data
  Map<String, dynamic> getRegistrationData() {
    return {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _phoneController.text.trim(),
      'dob': _dobController.text.trim(),
      'aadhaar': _aadharController.text.replaceAll('-', ''),
      'pan': _panController.text.trim().toUpperCase(),
      'address': _addressController.text.trim(),
      'pinCode': _pinCodeController.text.trim(),
      'state': _selectedState,
      'gender': _selectedGender,
      'profilePhoto': _profileImagePath,
      'agreedToTerms': _isAgreedToTerms,
    };
  }

  @override
  void dispose() {
    _aadharController.removeListener(_onAadhaarChanged);
    _panController.removeListener(_onPanChanged);
    [
      _nameController,
      _emailController,
      _phoneController,
      _dobController,
      _aadharController,
      _panController,
      _addressController,
      _pinCodeController,
      _stateController,
    ].forEach((controller) => controller.dispose());
    super.dispose();
  }
}
