// Phone Authentication Screen with API Integration
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/presentations/widgets/background_bubble.dart'
    show BackgroundBubbles;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/PhoneAuthProvider.dart'; // Add this import

class PhoneAuthScreen extends StatefulWidget {
  final String role;
  const PhoneAuthScreen({super.key, required this.role});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    // Clear any previous state when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhoneAuthProvider>().clearState();
    });
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(' ', '');
    setState(() {
      _isValidPhone =
          phone.length == 10 /*&& RegExp(r'^[6-9]\d{9}$').hasMatch(phone)*/;
    });
  }

  Future<void> _sendOTP() async {
    if (!_isValidPhone) return;

    final phoneAuthProvider = context.read<PhoneAuthProvider>();
    final phone = _phoneController.text.replaceAll(' ', '');

    final success = await phoneAuthProvider.requestOTP(phone, widget.role);

    if (success && mounted) {
      final response = phoneAuthProvider.otpResponse!;
      context.go('/auth/otp', extra: {
        'role': widget.role,
        'phoneNumber': phone,
        'isRegistered': response['isRegistered'],
        'userName': response['userName'],
      });
    } else if (mounted) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneAuthProvider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  Future<void> _sendOTPForAgent() async {
    if (!_isValidPhone) return;

    final phoneAuthProvider = context.read<PhoneAuthProvider>();
    final phone = _phoneController.text.replaceAll(' ', '');

    final success = await phoneAuthProvider.requesagentOTP(phone,widget.role);

    if (success && mounted) {
      final response = phoneAuthProvider.otpResponse!;
      context.go('/auth/otp', extra: {
        'role': widget.role,
        'phoneNumber': phone,
        'isRegistered': response['isRegistered'],
        'userName': response['userName'],
      });
    } else if (mounted) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneAuthProvider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendTanentOTP() async {
    if (!_isValidPhone) return;

    final phoneAuthProvider = context.read<PhoneAuthProvider>();
    final phone = _phoneController.text.replaceAll(' ', '');

    final success = await phoneAuthProvider.requestTanentOTP(phone);

    if (success && mounted) {
      final response = phoneAuthProvider.otpResponse!;
      context.go('/auth/otp', extra: {
        'role': widget.role,
        'phoneNumber': phone,
        'isRegistered': response['isRegistered'],
        'userName': response['userName'],
      });
    } else if (mounted) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneAuthProvider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }



  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const BackgroundBubbles(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: AppSizes.largePadding(context) * 3),

                    // Welcome Text
                    SizedBox(height: AppSizes.largePadding(context) * 3),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Welcome to Draze',
                        style: TextStyle(
                          fontSize: AppSizes.titleText(context) - 5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.largePadding(context)),

                    // Phone Input
                    Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSizes.smallPadding(context)),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _phoneFocusNode.hasFocus
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                              AppSizes.mediumPadding(context),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '🇮🇳',
                                  style: TextStyle(
                                    fontSize: AppSizes.mediumText(context),
                                  ),
                                ),
                                SizedBox(width: AppSizes.smallPadding(context)),
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: AppSizes.mediumText(context),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey[300],
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: TextStyle(
                                fontSize: AppSizes.mediumText(context),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Mobile Number',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppSizes.smallText(context),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(
                                  AppSizes.mediumPadding(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.largePadding(context)),

                    // Continue Button with Provider
                    Consumer<PhoneAuthProvider>(
                      builder: (context, phoneAuthProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: AppSizes.buttonHeight(context),
                          child: ElevatedButton(
                            onPressed: _isValidPhone && !phoneAuthProvider.isLoading && widget.role == 'landlord'
                                ? _sendOTP
                                : _isValidPhone && !phoneAuthProvider.isLoading && widget.role == 'tenant'
                                ? _sendTanentOTP
                                : _isValidPhone && !phoneAuthProvider.isLoading && widget.role == 'seller'
                                ? _sendOTPForAgent
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: phoneAuthProvider.isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: AppSizes.mediumPadding(context)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}