import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import '../../../app/api_constants.dart';
import '../../models/TenantModel.dart';
import '../../providers/DuesProvider.dart';
import '../../providers/AddTenantProvider.dart';
import 'DueAssignScreen.dart';

class AddTenantScreen extends StatefulWidget {
  final String propertyId;
  final String roomId;
  final String bedId;

  const AddTenantScreen({
    super.key,
    required this.propertyId,
    required this.roomId,
    required this.bedId,
  });

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Details Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _workController = TextEditingController();
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365 * 25));
  String _maritalStatus = 'Unmarried';

  // Family Details Controllers
  final _fatherNameController = TextEditingController();
  final _fatherMobileController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherMobileController = TextEditingController();

  // Financial Details Controllers
  final _rentAmountController = TextEditingController();
  final _securityDepositController = TextEditingController();
  DateTime _moveInDate = DateTime.now();

  // Agreement Details Controllers
  final _noticePeriodController = TextEditingController(text: '30');
  final _agreementPeriodController = TextEditingController(text: '12');
  String _agreementPeriodType = 'months';
  final _rentOnDateController = TextEditingController(text: '5');
  String _rentDateOption = 'fixed';
  String _rentalFrequency = 'Monthly';
  String _verifiedAadhaarValue = ''; // Store verified Aadhaar value
  String _verifiedPanValue = ''; // Store verified PAN value

  // Additional Details Controllers
  final _referredByController = TextEditingController();
  final _remarksController = TextEditingController();
  final _bookedByController = TextEditingController();

  // Electricity Details Controllers
  final _electricityPerUnitController = TextEditingController(text: '8');
  final _initialReadingController = TextEditingController();
  DateTime _initialReadingDate = DateTime.now();
  final _electricityDueDescriptionController = TextEditingController();

  // Opening Balance Controllers
  DateTime _openingBalanceStartDate = DateTime.now();
  DateTime _openingBalanceEndDate = DateTime.now().add(
    const Duration(days: 30),
  );
  final _openingBalanceAmountController = TextEditingController(text: '0');

  TenantStatus _selectedStatus = TenantStatus.pending;
  bool _isLoading = false;

  // For Aadhaar formatting
  String _previousAadhaarText = '';

  // Verification states
  bool _aadhaarVerified = false;
  bool _panVerified = false;
  bool _showAadhaarOtpField = false;
  final _aadhaarOtpController = TextEditingController();
  int? _aadhaarTxnId;
  bool _isVerifyingAadhaar = false;
  bool _isVerifyingPan = false;

  // PAN Controller
  final _panController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aadhaarController.addListener(_formatAadhaarNumber);
    _aadhaarController.addListener(_onAadhaarTextChanged); // Add this
    _panController.addListener(_onPanTextChanged); // Add this
  }

  // Add these new methods after _formatAadhaarNumber()
  void _onAadhaarTextChanged() {
    setState(() {
      // Check if the current text is different from verified value
      if (_aadhaarVerified &&
          _aadhaarController.text != _verifiedAadhaarValue) {
        _aadhaarVerified = false;
        _showAadhaarOtpField = false;
        _aadhaarOtpController.clear();
        _aadhaarTxnId = null;
      }
    });
  }

  void _onPanTextChanged() {
    setState(() {
      // Check if the current text is different from verified value
      if (_panVerified &&
          _panController.text.toUpperCase() != _verifiedPanValue) {
        _panVerified = false;
      }
    });
  }

  bool _isAadhaarLengthValid() {
    final digitsOnly = _aadhaarController.text.replaceAll('-', '');
    return digitsOnly.length == 12;
  }

  // Helper method to check if PAN has required length and format
  bool _isPanLengthValid() {
    final text = _panController.text.trim().toUpperCase();
    return text.length == 10;
  }

  void _formatAadhaarNumber() {
    final text = _aadhaarController.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (_previousAadhaarText == digitsOnly) return;
    _previousAadhaarText = digitsOnly;

    final limitedDigits = digitsOnly.substring(
      0,
      digitsOnly.length > 12 ? 12 : digitsOnly.length,
    );

    String formatted = '';
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i == 4 || i == 8) {
        formatted += '-';
      }
      formatted += limitedDigits[i];
    }

    if (formatted != text) {
      _aadhaarController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // Aadhaar Verification Methods
  Future<void> _onVerifyAadhaar() async {
    FocusScope.of(context).unfocus();
    setState(() => _isVerifyingAadhaar = true);

    final result = await _generateAadhaarOtp();

    setState(() => _isVerifyingAadhaar = false);

    if (result['success'] == true) {
      setState(() {
        _aadhaarTxnId = result['txnId'];
        _showAadhaarOtpField = true;
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result['message'])));
  }

  Future<Map<String, dynamic>> _generateAadhaarOtp() async {
    final aadhaarNumber = _aadhaarController.text.replaceAll("-", "");
    final url = "$base_url/api/kyc/aadhaar/generate-otp";

    try {
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
    }
  }

  Future<void> _submitAadhaarOtp() async {
    final otp = _aadhaarOtpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    if (_aadhaarTxnId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction ID missing, please resend OTP'),
        ),
      );
      return;
    }

    final url = "$base_url/api/kyc/aadhaar/submit-otp";

    try {
      setState(() => _isLoading = true);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"txnId": _aadhaarTxnId, "otp": otp}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final kycData = data['data'];

        setState(() {
          _aadhaarVerified = true;
          _verifiedAadhaarValue =
              _aadhaarController.text; // STORE VERIFIED VALUE

          // Update form fields from KYC data
          _nameController.text = kycData['full_name'] ?? _nameController.text;
          _dob = _parseDateFromApi(kycData['dob']) ?? _dob;
          _aadhaarController.text =
              _formatAadhaarForDisplay(kycData['aadhaar_number']) ??
              _aadhaarController.text;

          // Update verified value after formatting
          _verifiedAadhaarValue =
              _aadhaarController.text; // UPDATE AFTER FORMAT

          // Map gender
          final gender = _mapGenderFromApi(kycData['gender']);
          if (gender != null) {
            // You might want to add a gender field to your form
          }

          // Compose address from API address object
          if (kycData['address'] != null && kycData['address'] is Map) {
            final addressMap = Map<String, dynamic>.from(kycData['address']);
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

            _permanentAddressController.text = parts.join(", ");
          }

          _showAadhaarOtpField = false;
          _aadhaarOtpController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Aadhaar verified successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP verification failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // PAN Verification
  Future<void> _onVerifyPan() async {
    setState(() => _isVerifyingPan = true);

    final panNumber = _panController.text.trim().toUpperCase();
    final url = "$base_url/api/kyc/pan";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"panNumber": panNumber}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _panVerified = true;
          _verifiedPanValue =
              _panController.text.toUpperCase(); // STORE VERIFIED VALUE

          // Optional: update full name from API
          final panData = data['data'];
          if (panData['full_name'] != null &&
              panData['full_name'].toString().isNotEmpty) {
            _nameController.text = panData['full_name'];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'PAN verified successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'PAN verification failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() => _isVerifyingPan = false);
    }
  }

  DateTime? _parseDateFromApi(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return null;
    try {
      return DateTime.parse(isoDate);
    } catch (_) {
      return null;
    }
  }

  String? _formatAadhaarForDisplay(String? aadhaar) {
    if (aadhaar == null || aadhaar.length != 12) return aadhaar;
    return aadhaar.replaceRange(4, 4, '-').replaceRange(9, 9, '-');
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

  @override
  void dispose() {
    _aadhaarController.removeListener(_formatAadhaarNumber);
    _aadhaarController.removeListener(_onAadhaarTextChanged); // Add this
    _panController.removeListener(_onPanTextChanged); // Add this
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _aadhaarOtpController.dispose();
    _permanentAddressController.dispose();
    _workController.dispose();
    _fatherNameController.dispose();
    _fatherMobileController.dispose();
    _motherNameController.dispose();
    _motherMobileController.dispose();
    _rentAmountController.dispose();
    _securityDepositController.dispose();
    _noticePeriodController.dispose();
    _agreementPeriodController.dispose();
    _rentOnDateController.dispose();
    _referredByController.dispose();
    _remarksController.dispose();
    _bookedByController.dispose();
    _electricityPerUnitController.dispose();
    _initialReadingController.dispose();
    _electricityDueDescriptionController.dispose();
    _openingBalanceAmountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitForm() async {
    if (!_aadhaarVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify Aadhaar before submitting'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final tenant = Tenant(
        propertyId: widget.propertyId,
        roomId: widget.roomId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _mobileController.text.trim(),
        status: _selectedStatus,
        startDate: _moveInDate,
        monthlyRent: double.tryParse(_rentAmountController.text.trim()) ?? 0.0,
        deposit: double.tryParse(_securityDepositController.text.trim()) ?? 0.0,
        notes:
            _remarksController.text.trim().isNotEmpty
                ? _remarksController.text.trim()
                : null,
      );

      try {
        final apiData = {
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "aadhaar":
              _aadhaarController.text.trim().isNotEmpty
                  ? _aadhaarController.text.trim().replaceAll('-', '')
                  : null,
          "pan":
              _panController.text.trim().isNotEmpty
                  ? _panController.text.trim().toUpperCase()
                  : null,
          "mobile": _mobileController.text.trim(),
          "permanentAddress":
              _permanentAddressController.text.trim().isNotEmpty
                  ? _permanentAddressController.text.trim()
                  : null,
          "work":
              _workController.text.trim().isNotEmpty
                  ? _workController.text.trim()
                  : null,
          "dob": _formatDate(_dob),
          "maritalStatus": _maritalStatus,
          "fatherName":
              _fatherNameController.text.trim().isNotEmpty
                  ? _fatherNameController.text.trim()
                  : null,
          "fatherMobile":
              _fatherMobileController.text.trim().isNotEmpty
                  ? _fatherMobileController.text.trim()
                  : null,
          "motherName":
              _motherNameController.text.trim().isNotEmpty
                  ? _motherNameController.text.trim()
                  : null,
          "motherMobile":
              _motherMobileController.text.trim().isNotEmpty
                  ? _motherMobileController.text.trim()
                  : null,
          "photo": null,
          "propertyId": widget.propertyId,
          "roomId": widget.roomId,
          "bedId": widget.bedId.isNotEmpty ? widget.bedId : null,
          "moveInDate": _formatDate(_moveInDate),
          "rentAmount":
              double.tryParse(_rentAmountController.text.trim()) ?? 0.0,
          "securityDeposit":
              double.tryParse(_securityDepositController.text.trim()) ?? 0.0,
          "noticePeriod":
              int.tryParse(_noticePeriodController.text.trim()) ?? 30,
          "agreementPeriod":
              int.tryParse(_agreementPeriodController.text.trim()) ?? 12,
          "agreementPeriodType": _agreementPeriodType,
          "rentOnDate": int.tryParse(_rentOnDateController.text.trim()) ?? 5,
          "rentDateOption": _rentDateOption,
          "rentalFrequency": _rentalFrequency,
          "referredBy":
              _referredByController.text.trim().isNotEmpty
                  ? _referredByController.text.trim()
                  : null,
          "remarks":
              _remarksController.text.trim().isNotEmpty
                  ? _remarksController.text.trim()
                  : null,
          "bookedBy":
              _bookedByController.text.trim().isNotEmpty
                  ? _bookedByController.text.trim()
                  : null,
          "electricityPerUnit":
              double.tryParse(_electricityPerUnitController.text.trim()) ?? 0.0,
          "initialReading":
              _initialReadingController.text.trim().isNotEmpty
                  ? double.tryParse(_initialReadingController.text.trim())
                  : null,
          "finalReading": null,
          "initialReadingDate": _formatDate(_initialReadingDate),
          "finalReadingDate": null,
          "electricityDueDescription":
              _electricityDueDescriptionController.text.trim().isNotEmpty
                  ? _electricityDueDescriptionController.text.trim()
                  : null,
          "openingBalanceStartDate": _formatDate(_openingBalanceStartDate),
          "openingBalanceEndDate": _formatDate(_openingBalanceEndDate),
          "openingBalanceAmount":
              double.tryParse(_openingBalanceAmountController.text.trim()) ??
              0.0,
        };

        print("API Data: $apiData");

        final responseData = await Provider.of<AddTenantProvider>(
          context,
          listen: false,
        ).addTenant(tenant, apiData);

        if (!mounted) return;
        _onTenantAddedAlternative(context, responseData);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${e.toString()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Please fill all required fields correctly'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _onTenantAddedAlternative(
    BuildContext context,
    Map<String, dynamic> responseData,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Tenant added successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    if (responseData['tenant'] == null) {
      print('Error: tenant data is null in response');
      return;
    }

    final tenantId = responseData['tenant']['tenantId'];

    if (responseData['tenant']['accommodations'] == null ||
        (responseData['tenant']['accommodations'] as List).isEmpty) {
      print('Error: accommodations data is null or empty in response');
      return;
    }

    final landlordId =
        responseData['tenant']['accommodations'][0]['landlordId'];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) =>
                DueAssignScreen(tenantId: tenantId, landlordId: landlordId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add New Tenant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSectionCard(
                title: 'Personal Details',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter full name',
                      icon: Icons.person,
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        if (RegExp(r'[0-9]').hasMatch(v!)) {
                          return 'Name should not contain numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v!.trim())) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile',
                      hint: 'Enter mobile',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        if (v!.trim().length != 10) {
                          return 'Must be 10 digits';
                        }
                        if (v.startsWith('0') || v.startsWith('+')) {
                          return 'No 0 or + prefix allowed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Aadhaar with Verify button
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _aadhaarController,
                            label: 'Aadhaar',
                            hint: 'XXXX-XXXX-XXXX',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.trim().isEmpty ?? true) return 'Required';
                              final digitsOnly = v!.replaceAll('-', '');
                              if (digitsOnly.length != 12) {
                                return 'Invalid Aadhaar (12 digits required)';
                              }
                              if (!_aadhaarVerified) {
                                return 'Please verify Aadhaar';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _aadhaarVerified
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : SizedBox(
                              height: 38,
                              child: ElevatedButton(
                                // Enable button only when length is valid and not verifying
                                onPressed:
                                    _isAadhaarLengthValid() &&
                                            !_isVerifyingAadhaar
                                        ? _onVerifyAadhaar
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child:
                                    _isVerifyingAadhaar
                                        ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Text('Verify'),
                              ),
                            ),
                      ],
                    ),
                    // OTP field (shown conditionally)
                    if (_showAadhaarOtpField) ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _aadhaarOtpController,
                        label: 'Enter Aadhaar OTP',
                        hint: 'Enter 6-digit OTP',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitAadhaarOtp,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Submit OTP'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // PAN with Verify button
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _panController,
                            label: 'PAN (Optional)',
                            hint: 'ABCDE1234F',
                            icon: Icons.credit_card,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 10,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              if (v.trim().length != 10) {
                                return 'PAN must be 10 characters';
                              }
                              final panRegex = RegExp(
                                r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
                              );
                              if (!panRegex.hasMatch(v.trim().toUpperCase())) {
                                return 'Invalid PAN format';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _panVerified
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : SizedBox(
                              height: 38,
                              child: ElevatedButton(
                                // Enable button only when length is valid and not verifying
                                onPressed:
                                    _isPanLengthValid() && !_isVerifyingPan
                                        ? _onVerifyPan
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child:
                                    _isVerifyingPan
                                        ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Text('Verify'),
                              ),
                            ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _permanentAddressController,
                      label: 'Permanent Address',
                      hint: 'Enter permanent address',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _workController,
                      label: 'Work/Occupation (Optional)',
                      hint: 'Enter work or occupation',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      label: 'Date of Birth',
                      value: _dob,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dob,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().subtract(
                            const Duration(days: 365 * 18),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _dob = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Marital Status',
                      value: _maritalStatus,
                      items: ['Unmarried', 'Married', 'Divorced', 'Widowed'],
                      onChanged: (v) => setState(() => _maritalStatus = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Family Details (Optional)',
                icon: Icons.family_restroom,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _fatherNameController,
                      label: "Father's Name",
                      hint: "Enter father's name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _fatherMobileController,
                      label: "Father's Mobile",
                      hint: "Enter father's mobile",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _motherNameController,
                      label: "Mother's Name",
                      hint: "Enter mother's name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _motherMobileController,
                      label: "Mother's Mobile",
                      hint: "Enter mother's mobile",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Financial Details',
                icon: Icons.attach_money,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _rentAmountController,
                      label: 'Monthly Rent',
                      hint: 'Enter monthly rent',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        if (double.tryParse(v!.trim()) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _securityDepositController,
                      label: 'Security Deposit',
                      hint: 'Enter security deposit',
                      icon: Icons.shield_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.trim().isEmpty ?? true) return 'Required';
                        if (double.tryParse(v!.trim()) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      label: 'Move-in Date',
                      value: _moveInDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _moveInDate.isBefore(DateTime.now())
                              ? DateTime.now()
                              : _moveInDate,
                          firstDate: DateTime.now(), // Changed: Only allow today and future dates
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _moveInDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Agreement Details',
                icon: Icons.description_outlined,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _noticePeriodController,
                      label: 'Notice Period (days)',
                      hint: 'Enter notice period',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _agreementPeriodController,
                            label: 'Agreement Period',
                            hint: 'Enter period',
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Type',
                            value: _agreementPeriodType,
                            items: ['months', 'years'],
                            onChanged:
                                (v) =>
                                    setState(() => _agreementPeriodType = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _rentOnDateController,
                      label: 'Rent Due Date (day of month)',
                      hint: 'Enter date (1-31)',
                      icon: Icons.event,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Rent Date Option',
                      value: _rentDateOption,
                      items: ['fixed', 'flexible'],
                      onChanged: (v) => setState(() => _rentDateOption = v!),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Rental Frequency',
                      value: _rentalFrequency,
                      items: ['Monthly', 'Quarterly', 'Yearly'],
                      onChanged: (v) => setState(() => _rentalFrequency = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Electricity Details (Optional)',
                icon: Icons.electric_bolt,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _electricityPerUnitController,
                      label: 'Price per Unit (₹)',
                      hint: 'Enter price per unit',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _initialReadingController,
                      label: 'Initial Reading',
                      hint: 'Enter initial reading',
                      icon: Icons.speed,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      label: 'Initial Reading Date',
                      value: _initialReadingDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _initialReadingDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _initialReadingDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _electricityDueDescriptionController,
                      label: 'Description',
                      hint: 'Enter description',
                      icon: Icons.notes,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Opening Balance (Optional)',
                icon: Icons.account_balance_wallet,
                child: Column(
                  children: [
                    _buildDateField(
                      label: 'Start Date',
                      value: _openingBalanceStartDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _openingBalanceStartDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _openingBalanceStartDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDateField(
                      label: 'End Date',
                      value: _openingBalanceEndDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _openingBalanceEndDate,
                          firstDate: _openingBalanceStartDate,
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _openingBalanceEndDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _openingBalanceAmountController,
                      label: 'Amount (₹)',
                      hint: 'Enter amount',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Additional Details (Optional)',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _referredByController,
                      label: 'Referred By',
                      hint: 'Enter referrer name',
                      icon: Icons.person_add,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _bookedByController,
                      label: 'Booked By',
                      hint: 'Enter booking person name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _remarksController,
                      label: 'Remarks',
                      hint: 'Enter any additional remarks',
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Add Tenant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  _formatDate(value),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items:
                  items.map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
