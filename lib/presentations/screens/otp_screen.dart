import 'dart:async';

import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/presentations/widgets/background_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/OTPVerificationProvider.dart';
import '../providers/PhoneAuthProvider.dart'; // Add this import

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.role,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Clear any previous state when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OTPVerificationProvider>().clearState();
    });
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel previous timer if exists
    setState(() {
      _resendTimer = 30; // Reset timer to 30 seconds
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    final otpProvider = context.read<OTPVerificationProvider>();
    final success = await otpProvider.verifyOTP(
      widget.phoneNumber.replaceAll(' ', ''),
      otp,
      widget.role,
    );

    if (success && mounted) {
      final response = otpProvider.verificationResponse!;
      final isRegistered = response['isRegistered'] ?? false;

      if (isRegistered) {
        context.go('/properties');
      } else {
        // User is not registered, navigate to respective registration screen
        _navigateToRegistration();
      }
    } else if (mounted) {
      // Show error
      _showErrorSnackBar(otpProvider.errorMessage ?? 'OTP verification failed');
      // Clear OTP fields on error
      _clearOTPFields();
    }
  }

  Future<void> _verifyTanentOTP() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    final otpProvider = context.read<OTPVerificationProvider>();
    final success = await otpProvider.verifyTanentOTP(
      widget.phoneNumber.replaceAll(' ', ''),
      otp,
    );

    if (success && mounted) {
      final response = otpProvider.verificationResponse!;
      final isRegistered = response['isRegistered'] ?? false;

      if (isRegistered) {
        context.go('/User');
      } else {
        _navigateToRegistration();
      }
    } else if (mounted) {
      // Show error
      _showErrorSnackBar(otpProvider.errorMessage ?? 'OTP verification failed');
      // Clear OTP fields on error
      _clearOTPFields();
    }
  }

  Future<void> _verifyAgentOTP() async {
    print(widget.role);
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    final otpProvider = context.read<OTPVerificationProvider>();
    final success = await otpProvider.verifyAgentOTP(
      widget.phoneNumber.replaceAll(' ', ''),
      otp,
    );

    if (success && mounted) {
      final response = otpProvider.verificationResponse!;
      final isRegistered = response['seller']['isRagistered'] ?? false;

      if (isRegistered) {
        context.go('/seller');
      } else {
        _navigateToRegistration();
      }
    } else if (mounted) {
      // Show error
      _showErrorSnackBar(otpProvider.errorMessage ?? 'OTP verification failed');
      // Clear OTP fields on error
      _clearOTPFields();
    }
  }

  void _navigateToRegistration() {
    switch (widget.role) {
      case 'seller':
        context.push('/seller_registration');
        break;
      case 'landlord':
        context.push('/landlord_registration');
        break;
      case 'tenant':
        context.push('/user_registration');
        break;
      default:
        context.push('/landlord_registration');
    }
  }

  void _clearOTPFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOTP() async {
    final phoneAuthProvider = context.read<PhoneAuthProvider>();
    final phone = widget.phoneNumber.replaceAll(' ', '');
    bool success = false;

    // Call appropriate API based on role
    if (widget.role == 'tenant') {
      success = await phoneAuthProvider.requestTanentOTP(phone);
    } else if (widget.role == 'seller') {
      success = await phoneAuthProvider.requesagentOTP(phone, widget.role);
    } else {
      // For landlord or other roles
      success = await phoneAuthProvider.requestOTP(phone, widget.role);
    }

    if (success && mounted) {
      _startTimer(); // Restart the timer
      _clearOTPFields();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to +91 ${widget.phoneNumber}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showErrorSnackBar(
        phoneAuthProvider.errorMessage ?? 'Failed to resend OTP',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const BackgroundBubbles(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button

                    SizedBox(height: AppSizes.largePadding(context) * 2),

                    // Title
                    Text(
                      'Verify Your Phone Number',
                      style: TextStyle(
                        fontSize: AppSizes.titleText(context) - 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: AppSizes.smallPadding(context)),

                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: AppSizes.mediumText(context),
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'We\'ve sent a 6-digit code to \n',
                          ),
                          TextSpan(
                            text: '+91 ${widget.phoneNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.largePadding(context) * 2),

                    // OTP Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                              _focusNodes[index].hasFocus
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              fontSize: AppSizes.largeText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              // Check if all fields are filled
                              final otp =
                              _otpControllers
                                  .map((controller) => controller.text)
                                  .join();
                              if (otp.length == 6) {
                                widget.role == 'tenant'
                                    ? _verifyTanentOTP()
                                    : widget.role == 'seller'
                                    ? _verifyAgentOTP()
                                    : _verifyOTP();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: AppSizes.largePadding(context)),

                    // Verify Button with Provider
                    Consumer<OTPVerificationProvider>(
                      builder: (context, otpProvider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: AppSizes.buttonHeight(context),
                          child: ElevatedButton(
                            onPressed:
                            otpProvider.isLoading ? null : _verifyOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child:
                            otpProvider.isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                                : Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: AppSizes.mediumPadding(context) + 10),

                    // Resend OTP with Provider
                    Center(
                      child: Consumer<PhoneAuthProvider>(
                        builder: (context, phoneAuthProvider, child) {
                          if (_resendTimer > 0) {
                            return Text(
                              'Resend OTP in ${_resendTimer}s',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context),
                                color: AppColors.textSecondary,
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: phoneAuthProvider.isLoading ? null : _resendOTP,
                            child:
                            phoneAuthProvider.isLoading
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Resending...',
                                  style: TextStyle(
                                    fontSize: AppSizes.smallText(
                                      context,
                                    ),
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}