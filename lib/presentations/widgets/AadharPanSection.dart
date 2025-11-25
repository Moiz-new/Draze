import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../landlord/providers/landlord_registration_provider.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';

import '../../landlord/widgets/aadhar_pan_verify.dart';

class AadhaarPanSection extends StatefulWidget {
  final LandlordRegistrationProvider provider;

  const AadhaarPanSection({Key? key, required this.provider}) : super(key: key);

  @override
  _AadhaarPanSectionState createState() => _AadhaarPanSectionState();
}

class _AadhaarPanSectionState extends State<AadhaarPanSection> {
  bool _showAadhaarOtpField = false;
  final TextEditingController _aadhaarOtpController = TextEditingController();
  bool _isVerifyingAadhaar = false;
  bool _isVerifyingPan = false;
  bool _isSubmittingOtp = false;

  @override
  void initState() {
    super.initState();
    widget.provider.setupAadhaarPanListeners();
    widget.provider.aadharController.addListener(_onAadhaarTextChanged);
  }

  void _onAadhaarTextChanged() {
    if (_showAadhaarOtpField) {
      setState(() {
        _showAadhaarOtpField = false;
        _aadhaarOtpController.clear();
        _aadhaarTxnId = null;
      });
    }
  }

  @override
  void dispose() {
    widget.provider.aadharController.removeListener(_onAadhaarTextChanged);
    _aadhaarOtpController.dispose();
    super.dispose();
  }

  int? _aadhaarTxnId;

  void _onVerifyAadhaar() async {
    FocusScope.of(context).unfocus();
    setState(() => _isVerifyingAadhaar = true);
    final result = await widget.provider.generateAadhaarOtp();
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

  void _onVerifyPan() async {
    setState(() => _isVerifyingPan = true);
    final result = await widget.provider.verifyPan();
    setState(() => _isVerifyingPan = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Aadhaar field + verify button row
        Padding(
          padding: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
          child: Row(
            children: [
              Expanded(
                child: _buildEnhancedTextField(
                  context: context,
                  controller: widget.provider.aadharController,
                  label: 'Aadhaar Card Number',
                  hint: 'Enter 12-digit Aadhaar number (xxxx-xxxx-xxxx)',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [AadharNumberFormatter()],
                  errorText: widget.provider.aadharError,
                  onChanged: (_) => widget.provider.clearAllErrors(),
                ),
              ),
              const SizedBox(width: 8),
              widget.provider.aadhaarVerified
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed:
                          widget.provider.aadharController.text.length == 14 &&
                                  widget.provider.validateAadhar(
                                        widget.provider.aadharController.text,
                                      ) ==
                                      null &&
                                  !_isVerifyingAadhaar &&
                                  !widget
                                      .provider
                                      .aadhaarVerified // This ensures button is disabled when verified
                              ? _onVerifyAadhaar
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
        ),

        if (_showAadhaarOtpField) ...[
          _buildOtpInputField(context),
          SizedBox(height: AppSizes.mediumPadding(context)),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed:
                  _isSubmittingOtp
                      ? null
                      : () async {
                        final otp = _aadhaarOtpController.text.trim();
                        if (otp.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter the OTP'),
                            ),
                          );
                          return;
                        }
                        if (_aadhaarTxnId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Transaction ID missing, please resend OTP',
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() => _isSubmittingOtp = true);

                        final result = await widget.provider.submitAadhaarOtp(
                          txnId: _aadhaarTxnId!,
                          otp: otp,
                        );

                        setState(() => _isSubmittingOtp = false);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])),
                        );

                        if (result['success'] == true) {
                          setState(() {
                            _showAadhaarOtpField = false;
                            _aadhaarOtpController.clear();
                          });
                        }
                      },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child:
                  _isSubmittingOtp
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Submit OTP'),
            ),
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
        ],

        Padding(
          padding: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
          child: Row(
            children: [
              Expanded(
                child: _buildEnhancedTextField(
                  context: context,
                  controller: widget.provider.panController,
                  label: 'PAN Card Number',
                  hint: 'Enter PAN number (e.g., ABCDE1234F)',
                  icon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    PanNumberFormatter(),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  ],
                  errorText: widget.provider.panError,
                  onChanged: (_) => widget.provider.clearAllErrors(),
                ),
              ),
              const SizedBox(width: 8),
              widget.provider.panVerified
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed:
                          widget.provider.panController.text.length == 10 &&
                                  !_isVerifyingPan &&
                                  !widget
                                      .provider
                                      .panVerified // This ensures button is disabled when verified
                              ? _onVerifyPan
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
        ),
      ],
    );
  }

  Widget _buildOtpInputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Aadhaar OTP',
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _aadhaarOtpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter 6-digit OTP',
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.mediumPadding(context),
                vertical: AppSizes.mediumPadding(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    String? errorText,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.smallText(context),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : AppColors.divider,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : AppColors.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.red : AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSizes.mediumPadding(context),
                vertical: AppSizes.mediumPadding(context),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: AppSizes.smallText(context) * 0.9,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
