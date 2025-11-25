import 'dart:io';
import 'package:draze/landlord/screens/property_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/appColors.dart';
import '../../app/api_constants.dart';
import '../providers/AddSubOwnerProvider.dart';
import '../providers/AllPropertyListProvider.dart';

class AddSubOwnerScreen extends StatefulWidget {
  const AddSubOwnerScreen({Key? key}) : super(key: key);

  @override
  State<AddSubOwnerScreen> createState() => _AddSubOwnerScreenState();
}

class _AddSubOwnerScreenState extends State<AddSubOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  final _aadhaarOtpController = TextEditingController();

  File? _profilePhoto;
  File? _idProofImage;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  // Aadhaar verification states
  bool _aadhaarVerified = false;
  bool _showAadhaarOtpField = false;
  int? _aadhaarTxnId;
  bool _isVerifyingAadhaar = false;

  // PAN verification states
  bool _panVerified = false;
  bool _isVerifyingPan = false;

  // For Aadhaar formatting
  String _previousAadhaarText = '';

  @override
  void initState() {
    super.initState();
    _aadhaarController.addListener(_formatAadhaarNumber);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubOwnerProvider>(context, listen: false).fetchPermissions();
      Provider.of<AllPropertyListProvider>(
        context,
        listen: false,
      ).loadProperties();
    });
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor:
            result['success'] ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the OTP'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    if (_aadhaarTxnId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaction ID missing, please resend OTP'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    final url = "$base_url/api/kyc/aadhaar/submit-otp";

    try {
      setState(() => _isSubmitting = true);

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

          // Update form fields from KYC data
          _fullNameController.text =
              kycData['full_name'] ?? _fullNameController.text;

          // Update Aadhaar field
          _aadhaarController.text =
              _formatAadhaarForDisplay(kycData['aadhaar_number']) ??
              _aadhaarController.text;

          _showAadhaarOtpField = false;
          _aadhaarOtpController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Aadhaar verified successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'OTP verification failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
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

          // Optional: update full name from API
          final panData = data['data'];
          if (panData['full_name'] != null &&
              panData['full_name'].toString().isNotEmpty) {
            _fullNameController.text = panData['full_name'];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'PAN verified successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'PAN verification failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    } finally {
      setState(() => _isVerifyingPan = false);
    }
  }

  String? _formatAadhaarForDisplay(String? aadhaar) {
    if (aadhaar == null || aadhaar.length != 12) return aadhaar;
    return aadhaar.replaceRange(4, 4, '-').replaceRange(9, 9, '-');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'profile') {
            _profilePhoto = File(pickedFile.path);
          } else {
            _idProofImage = File(pickedFile.path);
          }
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${type == 'profile' ? 'Profile photo' : 'ID proof'} selected successfully',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  void _showImageSourceDialog(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'Choose Image Source',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primary),
                  title: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, type);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primary),
                  title: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, type);
                  },
                ),
                if ((type == 'profile' && _profilePhoto != null) ||
                    (type == 'idproof' && _idProofImage != null))
                  ListTile(
                    leading: Icon(Icons.delete, color: AppColors.error),
                    title: Text('Remove Image'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        if (type == 'profile') {
                          _profilePhoto = null;
                        } else {
                          _idProofImage = null;
                        }
                      });
                    },
                  ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check Aadhaar verification if Aadhaar is provided
    if (_aadhaarController.text.trim().isNotEmpty && !_aadhaarVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify Aadhaar before submitting'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    final subOwnerProvider = Provider.of<SubOwnerProvider>(
      context,
      listen: false,
    );

    // Validate permissions
    if (subOwnerProvider.selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one permission'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    // Validate properties
    if (subOwnerProvider.selectedProperties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one property'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await subOwnerProvider.submitSubOwner(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        aadhaarNumber:
            _aadhaarController.text.trim().isNotEmpty
                ? _aadhaarController.text.trim()
                : null,
        panNumber:
            _panController.text.trim().isNotEmpty
                ? _panController.text.trim()
                : null,
        profilePhoto: _profilePhoto,
        idProofImage: _idProofImage,
      );

      if (!mounted) return;

      if (result['success']) {
        // Clear form
        _fullNameController.clear();
        _emailController.clear();
        _mobileController.clear();
        _passwordController.clear();
        _aadhaarController.clear();
        _panController.clear();
        setState(() {
          _profilePhoto = null;
          _idProofImage = null;
          _aadhaarVerified = false;
          _panVerified = false;
          _showAadhaarOtpField = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            duration: Duration(seconds: 3),
          ),
        );

        // Show success dialog with details
        _showSuccessDialog(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 32.sp),
              SizedBox(width: 12.w),
              Text(
                'Success!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result['message'] ?? 'Sub-owner created successfully',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              if (result['subOwner'] != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Name', result['subOwner']['name']),
                      _buildDetailRow('Email', result['subOwner']['email']),
                      _buildDetailRow('Mobile', result['subOwner']['mobile']),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Sub-Owner',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Basic Information Section
                    _buildSectionTitle('Basic Information'),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      hint: 'Enter full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      hint: 'Enter email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email address';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      hint: 'Enter mobile number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter mobile number';
                        }
                        if (value.length != 10) {
                          return 'Mobile number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Consumer<SubOwnerProvider>(
                      builder: (context, provider, child) {
                        return _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          hint: 'Enter password',
                          obscureText: provider.obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              provider.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              provider.togglePasswordVisibility();
                            },
                          ),
                        );
                      },
                    ),

                    // Aadhaar Number Section
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _aadhaarController,
                            label: 'Aadhaar Number',
                            icon: Icons.credit_card,
                            hint: 'XXXX-XXXX-XXXX',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                String digitsOnly = value.replaceAll('-', '');
                                if (digitsOnly.length != 12) {
                                  return 'Aadhaar number must be 12 digits';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _aadhaarVerified
                            ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            )
                            : SizedBox(
                              height: 38.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  final digitsOnly = _aadhaarController.text
                                      .replaceAll('-', '');
                                  if (digitsOnly.length == 12 &&
                                      !_isVerifyingAadhaar) {
                                    _onVerifyAadhaar();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child:
                                    _isVerifyingAadhaar
                                        ? SizedBox(
                                          width: 14.w,
                                          height: 14.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Text('Verify'),
                              ),
                            ),
                      ],
                    ),

                    // OTP field (shown conditionally)
                    if (_showAadhaarOtpField) ...[
                      SizedBox(height: 12.h),
                      _buildTextField(
                        controller: _aadhaarOtpController,
                        label: 'Enter Aadhaar OTP',
                        hint: 'Enter 6-digit OTP',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 38.h,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitAadhaarOtp,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: const Text('Submit OTP'),
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _panController,
                            label: 'PAN Number',
                            icon: Icons.credit_card_outlined,
                            hint: 'ABCDE1234F',
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Z0-9]'),
                              ),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length != 10) {
                                  return 'PAN must be 10 characters';
                                }
                                if (!RegExp(
                                  r'^[A-Z]{5}[0-9]{4}[A-Z]$',
                                ).hasMatch(value)) {
                                  return 'Invalid PAN format';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _panVerified
                            ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            )
                            : SizedBox(
                              height: 38.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  final panText =
                                      _panController.text.trim().toUpperCase();
                                  if (panText.length == 10 &&
                                      RegExp(
                                        r'^[A-Z]{5}[0-9]{4}[A-Z]$',
                                      ).hasMatch(panText) &&
                                      !_isVerifyingPan) {
                                    _onVerifyPan();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child:
                                    _isVerifyingPan
                                        ? SizedBox(
                                          width: 14.w,
                                          height: 14.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Text('Verify'),
                              ),
                            ),
                      ],
                    ),

                    // Permissions Section
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Permissions'),
                    SizedBox(height: 12.h),
                    _buildPermissionsCard(),

                    // Assigned Properties Section
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Assigned Properties'),
                    SizedBox(height: 8.h),
                    Text(
                      'Select properties to assign to sub-owner',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildPropertiesCard(),

                    // Profile Photo Section
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Profile Photo (Optional)'),
                    SizedBox(height: 12.h),
                    _buildUploadCard(
                      'Click to upload profile photo',
                      'profile',
                      _profilePhoto,
                    ),

                    // ID Proof Section
                    SizedBox(height: 24.h),
                    _buildSectionTitle('ID Proof Image (Optional)'),
                    SizedBox(height: 12.h),
                    _buildUploadCard(
                      'Click to upload ID proof',
                      'idproof',
                      _idProofImage,
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            // Bottom Action Button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        validator: validator,
        style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),
          hintStyle: TextStyle(color: AppColors.disabled, fontSize: 14.sp),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22.sp),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.error, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Consumer<SubOwnerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingPermissions) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading permissions...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.permissionErrorMessage != null) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  provider.permissionErrorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.error),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchPermissions(),
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.allPermissions.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    color: AppColors.textSecondary,
                    size: 48.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No permissions available',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => provider.selectAllPermissions(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.success,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Select All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => provider.deselectAllPermissions(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.error, width: 1),
                        ),
                        child: Text(
                          'Deselect All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    provider.displayedPermissions.map((permission) {
                      final isSelected = provider.selectedPermissions.contains(
                        permission.id,
                      );
                      return GestureDetector(
                        onTap: () => provider.togglePermission(permission.id),
                        child: Tooltip(
                          message: permission.description,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.background,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.divider,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              permission.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              if (!provider.showAllPermissions &&
                  provider.allPermissions.length > 6) ...[
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => provider.toggleShowAllPermissions(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Show Less',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Selected: ${provider.selectedPermissions.length} permissions',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertiesCard() {
    return Consumer2<AllPropertyListProvider, SubOwnerProvider>(
      builder: (context, propertyProvider, subOwnerProvider, child) {
        if (propertyProvider.isLoading) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading properties...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (propertyProvider.error != null) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  propertyProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.error),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: () => propertyProvider.loadProperties(),
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (propertyProvider.properties.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: AppColors.textSecondary,
                    size: 48.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No properties available',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Properties:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Show dialog for each property when selecting all
                          for (var property in propertyProvider.properties) {
                            if (!subOwnerProvider.selectedProperties.contains(
                              property.id,
                            )) {
                              subOwnerProvider.addPropertyAssignment(
                                PropertyAssignment(
                                  propertyId: property.id,
                                  years: 1,
                                  agreementEndDate: DateTime.now().add(
                                    Duration(days: 365),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.success,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Select All',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => subOwnerProvider.deselectAllProperties(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.error,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: propertyProvider.properties.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final property = propertyProvider.properties[index];
                  final isSelected = subOwnerProvider.selectedProperties
                      .contains(property.id);
                  final assignment = subOwnerProvider.getPropertyAssignment(
                    property.id,
                  );

                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        subOwnerProvider.removePropertyAssignment(property.id);
                      } else {
                        _showPropertyAssignmentDialog(
                          property.id,
                          property.name,
                          context,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.background,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.success
                                  : AppColors.divider,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.success
                                      : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.home_work_outlined,
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: Text(
                                        '${property.city}, ${property.state}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    _buildPropertyBadge(
                                      Icons.meeting_room_outlined,
                                      '${property.totalRooms} Rooms',
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildPropertyBadge(
                                      Icons.bed_outlined,
                                      '${property.totalBeds} Beds',
                                    ),
                                  ],
                                ),
                                // Show agreement details if selected
                                if (isSelected && assignment != null) ...[
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          size: 12.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${assignment.years} ${assignment.years == 1 ? "Year" : "Years"}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (assignment.agreementEndDate !=
                                            null) ...[
                                          SizedBox(width: 8.w),
                                          Text(
                                            '• Until ${assignment.agreementEndDate!.day}/${assignment.agreementEndDate!.month}/${assignment.agreementEndDate!.year}',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Edit button for selected properties
                          if (isSelected)
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                              onPressed:
                                  () => _showPropertyAssignmentDialog(
                                    property.id,
                                    property.name,
                                    context,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Selected: ${subOwnerProvider.selectedProperties.length} of ${propertyProvider.properties.length} properties',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertyBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: AppColors.primary),
          SizedBox(width: 2.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String text, String type, File? image) {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: image != null ? AppColors.success : AppColors.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showImageSourceDialog(type),
          borderRadius: BorderRadius.circular(12.r),
          child:
              image != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(image, fit: BoxFit.cover),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 12.w,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              'Tap to change',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48.sp,
                        color: AppColors.primary.withOpacity(0.6),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.disabled,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child:
              _isSubmitting
                  ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Sub-Owner',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    int selectionIndex = newValue.selection.end;

    if (formatted.length > newValue.text.length) {
      selectionIndex += (formatted.length - newValue.text.length);
    }

    if (selectionIndex > 0 &&
        selectionIndex <= formatted.length &&
        selectionIndex < formatted.length &&
        formatted[selectionIndex] == '-') {
      selectionIndex++;
    }

    selectionIndex = selectionIndex.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

void _showPropertyAssignmentDialog(
  String propertyId,
  String propertyName,
  BuildContext context,
) {
  final subOwnerProvider = Provider.of<SubOwnerProvider>(
    context,
    listen: false,
  );
  final existingAssignment = subOwnerProvider.getPropertyAssignment(propertyId);

  int selectedYears = existingAssignment?.years ?? 1;
  DateTime? selectedEndDate = existingAssignment?.agreementEndDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            backgroundColor: AppColors.surface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agreement Details',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  propertyName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agreement Duration
                Text(
                  'Agreement Duration',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (selectedYears > 1) {
                              setState(() {
                                selectedYears--;
                              });
                            }
                          },
                          child: Icon(
                            Icons.remove,
                            color:
                                selectedYears > 1
                                    ? AppColors.primary
                                    : AppColors.disabled,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$selectedYears ${selectedYears == 1 ? "Year" : "Years"}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (selectedYears < 99) {
                              setState(() {
                                selectedYears++;
                              });
                            }
                          },
                          child: Icon(
                            Icons.add,
                            color:
                                selectedYears < 99
                                    ? AppColors.primary
                                    : AppColors.disabled,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Agreement End Date
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Text(
                      'Agreement End Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate:
                          selectedEndDate ??
                          DateTime.now().add(
                            Duration(days: 365 * selectedYears),
                          ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365 * 100)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primary,
                              onPrimary: Colors.white,
                              surface: AppColors.surface,
                              onSurface: AppColors.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color:
                            selectedEndDate == null
                                ? AppColors.error.withOpacity(0.5)
                                : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color:
                              selectedEndDate == null
                                  ? AppColors.error
                                  : AppColors.primary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            selectedEndDate != null
                                ? '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}'
                                : 'Select end date (Required)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  selectedEndDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.error,
                              fontWeight:
                                  selectedEndDate != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondary,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ),

                if (selectedEndDate != null) ...[
                  SizedBox(height: 8.h),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedEndDate = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 16.sp,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Clear date',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed:
                    selectedEndDate == null
                        ? null
                        : () {
                          // Save the assignment
                          subOwnerProvider.addPropertyAssignment(
                            PropertyAssignment(
                              propertyId: propertyId,
                              years: selectedYears,
                              agreementEndDate: selectedEndDate,
                            ),
                          );
                          Navigator.pop(context);
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedEndDate == null
                          ? AppColors.disabled
                          : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// Update the _buildPropertiesCard method - Replace the GestureDetector onTap
// Change this line in the property item:
// onTap: () => subOwnerProvider.toggleProperty(property.id),
// To:
// onTap: () {
//   if (subOwnerProvider.selectedProperties.contains(property.id)) {
//     subOwnerProvider.removePropertyAssignment(property.id);
//   } else {
//     _showPropertyAssignmentDialog(property.id, property.name);
//   }
// },

// Also add an edit button for already selected properties
// Add this inside the property container's Row, after the Column:
// if (isSelected)
//   IconButton(
//     icon: Icon(
//       Icons.edit,
//       color: AppColors.primary,
//       size: 20.sp,
//     ),
//     onPressed: () => _showPropertyAssignmentDialog(
//       property.id,
//       property.name,
//     ),
//   ),
