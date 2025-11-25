import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

class LandlordProfileEditProvider extends ChangeNotifier {
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();

  // Bank Details Controllers
  final _bankAccountHolderNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankIfscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();

  // Form State
  String? _selectedGender;
  String? _selectedState;
  String? _profileImagePath;
  String? _existingProfileImageUrl;
  bool _isLoading = false;
  bool _isFetchingProfile = false;
  bool _isEditing = false;
  bool _isBankVerified = false;
  bool _isVerifyingBank = false;
  bool _hasBankDetails = false;

  // Store original values for cancel functionality
  Map<String, dynamic>? _originalValues;

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
  String? _bankAccountHolderNameError;
  String? _bankAccountNumberError;
  String? _bankIfscCodeError;
  String? _bankNameError;
  String? _branchNameError;

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

  static final String _apiUrl = '$base_url/api/landlord/profile';
  static final String _bankVerifyUrl = '$base_url/api/kyc/bank';
  static final String _baseUrl = base_url;

  // Getters
  TextEditingController get nameController => _nameController;

  TextEditingController get emailController => _emailController;

  TextEditingController get phoneController => _phoneController;

  TextEditingController get dobController => _dobController;

  TextEditingController get aadharController => _aadharController;

  TextEditingController get panController => _panController;

  TextEditingController get addressController => _addressController;

  TextEditingController get pinCodeController => _pinCodeController;

  TextEditingController get bankAccountHolderNameController =>
      _bankAccountHolderNameController;

  TextEditingController get bankAccountNumberController =>
      _bankAccountNumberController;

  TextEditingController get bankIfscCodeController => _bankIfscCodeController;

  TextEditingController get bankNameController => _bankNameController;

  TextEditingController get branchNameController => _branchNameController;

  String? get selectedGender => _selectedGender;

  String? get selectedState => _selectedState;

  String? get profileImagePath => _profileImagePath;

  String? get existingProfileImageUrl => _existingProfileImageUrl;

  bool get isLoading => _isLoading;

  bool get isFetchingProfile => _isFetchingProfile;

  bool get isEditing => _isEditing;

  bool get isBankVerified => _isBankVerified;

  bool get isVerifyingBank => _isVerifyingBank;

  bool get hasBankDetails => _hasBankDetails;

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

  String? get bankAccountHolderNameError => _bankAccountHolderNameError;

  String? get bankAccountNumberError => _bankAccountNumberError;

  String? get bankIfscCodeError => _bankIfscCodeError;

  String? get bankNameError => _bankNameError;

  String? get branchNameError => _branchNameError;

  // Setters
  void setEditing(bool value) {
    _isEditing = value;
    if (value) {
      _saveOriginalValues();
    }
    notifyListeners();
  }

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

  void setProfileImage(String? imagePath) {
    _profileImagePath = imagePath;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setFetchingProfile(bool fetching) {
    _isFetchingProfile = fetching;
    notifyListeners();
  }

  void setVerifyingBank(bool verifying) {
    _isVerifyingBank = verifying;
    notifyListeners();
  }

  // NEW METHOD: Reset bank verification when field is edited
  void onBankFieldChanged() {
    if (_isBankVerified) {
      _isBankVerified = false;
      notifyListeners();
    }
  }

  // Save original values before editing
  void _saveOriginalValues() {
    _originalValues = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'dob': _dobController.text,
      'aadhar': _aadharController.text,
      'pan': _panController.text,
      'address': _addressController.text,
      'pinCode': _pinCodeController.text,
      'gender': _selectedGender,
      'state': _selectedState,
      'profileImageUrl': _existingProfileImageUrl,
      'bankAccountHolderName': _bankAccountHolderNameController.text,
      'bankAccountNumber': _bankAccountNumberController.text,
      'bankIfscCode': _bankIfscCodeController.text,
      'bankName': _bankNameController.text,
      'branchName': _branchNameController.text,
      'isBankVerified': _isBankVerified,
      'hasBankDetails': _hasBankDetails,
    };
  }

  // Restore original values
  void _restoreOriginalValues() {
    if (_originalValues != null) {
      _nameController.text = _originalValues!['name'] ?? '';
      _emailController.text = _originalValues!['email'] ?? '';
      _phoneController.text = _originalValues!['phone'] ?? '';
      _dobController.text = _originalValues!['dob'] ?? '';
      _aadharController.text = _originalValues!['aadhar'] ?? '';
      _panController.text = _originalValues!['pan'] ?? '';
      _addressController.text = _originalValues!['address'] ?? '';
      _pinCodeController.text = _originalValues!['pinCode'] ?? '';
      _selectedGender = _originalValues!['gender'];
      _selectedState = _originalValues!['state'];
      _existingProfileImageUrl = _originalValues!['profileImageUrl'];
      _profileImagePath = null;
      _bankAccountHolderNameController.text =
          _originalValues!['bankAccountHolderName'] ?? '';
      _bankAccountNumberController.text =
          _originalValues!['bankAccountNumber'] ?? '';
      _bankIfscCodeController.text = _originalValues!['bankIfscCode'] ?? '';
      _bankNameController.text = _originalValues!['bankName'] ?? '';
      _branchNameController.text = _originalValues!['branchName'] ?? '';
      _isBankVerified = _originalValues!['isBankVerified'] ?? false;
      _hasBankDetails = _originalValues!['hasBankDetails'] ?? false;
    }
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  void resetBankVerification() {
    _isBankVerified = false;
    notifyListeners();
  }

  void setHasBankDetails(bool value) {
    _hasBankDetails = value;
    notifyListeners();
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

  String? validateBankAccountHolderName(String? value) {
    final requiredCheck = _validateRequired(value, 'Account holder name');
    if (requiredCheck != null) return requiredCheck;

    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateBankAccountNumber(String? value) {
    final requiredCheck = _validateRequired(value, 'Account number');
    if (requiredCheck != null) return requiredCheck;

    if (value!.length < 9 || value.length > 18) {
      return 'Account number must be 9-18 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number should only contain digits';
    }
    return null;
  }

  String? validateBankIfscCode(String? value) {
    final requiredCheck = _validateRequired(value, 'IFSC code');
    if (requiredCheck != null) return requiredCheck;

    if (value!.length != 11) return 'IFSC code must be 11 characters';
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.toUpperCase())) {
      return 'Invalid IFSC format (e.g., SBIN0001234)';
    }
    return null;
  }

  String? validateBankName(String? value) {
    final requiredCheck = _validateRequired(value, 'Bank name');
    if (requiredCheck != null) return requiredCheck;

    if (value!.trim().length < 2) {
      return 'Bank name must be at least 2 characters';
    }
    return null;
  }

  String? validateBranchName(String? value) {
    final requiredCheck = _validateRequired(value, 'Branch name');
    if (requiredCheck != null) return requiredCheck;

    if (value!.trim().length < 2) {
      return 'Branch name must be at least 2 characters';
    }
    return null;
  }

  String? validateGender() =>
      _selectedGender == null ? 'Please select gender' : null;

  String? validateState() =>
      _selectedState == null ? 'Please select state' : null;

  // Verify Bank Details
  Future<Map<String, dynamic>> verifyBankDetails() async {
    try {
      setVerifyingBank(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.post(
        Uri.parse(_bankVerifyUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'accountNumber': _bankAccountNumberController.text.trim(),
          'ifsc': _bankIfscCodeController.text.trim().toUpperCase(),
        }),
      );

      print("Bank response: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _isBankVerified = true;

        // Only update account holder name from API if it's empty
        if (data['data'] != null && data['data']['full_name'] != null) {
          if (_bankAccountHolderNameController.text.trim().isEmpty) {
            _bankAccountHolderNameController.text = data['data']['full_name'];
          }
        }

        notifyListeners();
        return {
          'success': true,
          'message': data['message'] ?? 'Bank details verified successfully',
          'data': data['data'],
        };
      }

      _isBankVerified = false;
      notifyListeners();
      return {
        'success': false,
        'message': data['message'] ?? 'Bank verification failed',
      };
    } catch (e) {
      _isBankVerified = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      setVerifyingBank(false);
    }
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

    // Validate bank details only if user is adding them
    if (_hasBankDetails) {
      _bankAccountHolderNameError = validateBankAccountHolderName(
        _bankAccountHolderNameController.text,
      );
      _bankAccountNumberError = validateBankAccountNumber(
        _bankAccountNumberController.text,
      );
      _bankIfscCodeError = validateBankIfscCode(_bankIfscCodeController.text);
      _bankNameError = validateBankName(_bankNameController.text);
      _branchNameError = validateBranchName(_branchNameController.text);
    }

    notifyListeners();

    List<String?> errors = [
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
    ];

    if (_hasBankDetails) {
      errors.addAll([
        _bankAccountHolderNameError,
        _bankAccountNumberError,
        _bankIfscCodeError,
        _bankNameError,
        _branchNameError,
      ]);
    }

    return errors.every((error) => error == null);
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
                                        _stateError =
                                            _bankAccountHolderNameError =
                                                _bankAccountNumberError =
                                                    _bankIfscCodeError =
                                                        _bankNameError =
                                                            _branchNameError =
                                                                null;
    notifyListeners();
  }

  // Fetch profile data
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      setFetchingProfile(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _populateFormFields(data['landlord']);
        return {'success': true, 'message': 'Profile fetched successfully'};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch profile',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      setFetchingProfile(false);
    }
  }

  void _populateFormFields(Map<String, dynamic> landlord) {
    // Populate all fields from API response
    _nameController.text = landlord['name']?.toString() ?? '';
    _emailController.text = landlord['email']?.toString() ?? '';
    _phoneController.text = landlord['mobile']?.toString() ?? '';

    // Format and populate Aadhar number
    final aadharNumber =
        landlord['aadhaarNumber']?.toString() ??
        landlord['aadhaar']?.toString() ??
        landlord['aadhar']?.toString() ??
        '';
    _aadharController.text = _formatAadhar(aadharNumber);

    // Format and populate PAN number
    final panNumber =
        landlord['panNumber']?.toString() ?? landlord['pan']?.toString() ?? '';
    _panController.text = panNumber.toUpperCase();

    _addressController.text = landlord['address']?.toString() ?? '';
    _pinCodeController.text = landlord['pinCode']?.toString() ?? '';
    _selectedState = landlord['state']?.toString();
    _selectedGender = landlord['gender']?.toString();

    // Populate bank details from nested bankAccount object
    if (landlord['bankAccount'] != null) {
      final bankAccount = landlord['bankAccount'] as Map<String, dynamic>;
      final accountNumber = bankAccount['accountNumber']?.toString() ?? '';
      final ifscCode = bankAccount['ifscCode']?.toString() ?? '';

      _hasBankDetails = accountNumber.isNotEmpty && ifscCode.isNotEmpty;

      if (_hasBankDetails) {
        _bankAccountHolderNameController.text =
            bankAccount['accountHolderName']?.toString() ?? '';
        _bankAccountNumberController.text = accountNumber;
        _bankIfscCodeController.text = ifscCode.toUpperCase();
        _bankNameController.text = bankAccount['bankName']?.toString() ?? '';
        _branchNameController.text =
            bankAccount['branchName']?.toString() ?? '';
        _isBankVerified = true; // Assume existing bank details are verified
      }
    } else {
      // Fallback to old structure (if API returns flat structure)
      final bankAccountNumber = landlord['bankAccountNumber']?.toString() ?? '';
      final bankIfscCode = landlord['bankIfscCode']?.toString() ?? '';

      _hasBankDetails = bankAccountNumber.isNotEmpty && bankIfscCode.isNotEmpty;

      if (_hasBankDetails) {
        _bankAccountHolderNameController.text =
            landlord['bankAccountHolderName']?.toString() ?? '';
        _bankAccountNumberController.text = bankAccountNumber;
        _bankIfscCodeController.text = bankIfscCode.toUpperCase();
        _bankNameController.text = landlord['bankName']?.toString() ?? '';
        _branchNameController.text = landlord['branchName']?.toString() ?? '';
        _isBankVerified = true;
      }
    }

    // Handle profile photo URL
    final photoUrl = landlord['profilePhoto']?.toString() ?? '';
    if (photoUrl.isNotEmpty) {
      if (!photoUrl.startsWith('http')) {
        _existingProfileImageUrl = '$base_url$photoUrl';
      } else {
        _existingProfileImageUrl = photoUrl;
      }
    } else {
      _existingProfileImageUrl = null;
    }

    // Convert ISO date to DD/MM/YYYY format
    if (landlord['dob'] != null && landlord['dob'].toString().isNotEmpty) {
      try {
        DateTime date = DateTime.parse(landlord['dob'].toString());
        _dobController.text =
            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        _dobController.text = '';
      }
    } else {
      _dobController.text = '';
    }

    notifyListeners();
  }

  String _formatAadhar(String aadhar) {
    String digitsOnly = aadhar.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length == 12) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 8)}-${digitsOnly.substring(8, 12)}';
    }
    return aadhar;
  }

  Future<Map<String, dynamic>> updateProfile() async {
    try {
      setLoading(true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      // Convert DD/MM/YYYY to ISO format for API
      final dobParts = _dobController.text.split('/');
      final dobISO =
          '${dobParts[2]}-${dobParts[1].padLeft(2, '0')}-${dobParts[0].padLeft(2, '0')}';

      final request = http.MultipartRequest('PUT', Uri.parse(_apiUrl));

      request.headers['Authorization'] = 'Bearer $token';

      // Add ALL form fields
      request.fields.addAll({
        'name': _nameController.text.trim(),
        'mobile': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'aadhaarNumber': _aadharController.text.replaceAll('-', '').trim(),
        'panNumber': _panController.text.trim().toUpperCase(),
        'address': _addressController.text.trim(),
        'pinCode': _pinCodeController.text.trim(),
        'state': _selectedState ?? '',
        'dob': dobISO,
        'gender': _selectedGender ?? '',
      });

      // Add bank details if present and verified
      if (_hasBankDetails && _isBankVerified) {
        request.fields.addAll({
          'bankAccountHolderName': _bankAccountHolderNameController.text.trim(),
          'bankAccountNumber': _bankAccountNumberController.text.trim(),
          'bankIfscCode': _bankIfscCodeController.text.trim().toUpperCase(),
          'bankName': _bankNameController.text.trim(),
          'branchName': _branchNameController.text.trim(),
        });
      }

      // Add profile photo only if a new one is selected
      if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        final file = File(_profileImagePath!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profilePhoto',
              _profileImagePath!,
            ),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Update Profile Response: $responseBody");

      final data = json.decode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update existing profile image URL if new one was uploaded
        if (_profileImagePath != null &&
            data['landlord']?['profilePhoto'] != null) {
          final photoUrl = data['landlord']['profilePhoto'].toString();
          if (!photoUrl.startsWith('http')) {
            _existingProfileImageUrl = '$base_url$photoUrl';
          } else {
            _existingProfileImageUrl = photoUrl;
          }
        }
        _profileImagePath = null;
        setEditing(false);
        _originalValues = null;

        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'shouldNavigateBack': true,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update profile',
      };
    } catch (e) {
      print("Update Profile Error: $e");
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    } finally {
      setLoading(false);
    }
  }

  void cancelEditing() {
    _restoreOriginalValues();
    setEditing(false);
    clearAllErrors();
    notifyListeners();
  }

  @override
  void dispose() {
    [
      _nameController,
      _emailController,
      _phoneController,
      _dobController,
      _aadharController,
      _panController,
      _addressController,
      _pinCodeController,
      _bankAccountHolderNameController,
      _bankAccountNumberController,
      _bankIfscCodeController,
      _bankNameController,
      _branchNameController,
    ].forEach((controller) => controller.dispose());
    super.dispose();
  }
}
