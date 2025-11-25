import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../landlord/widgets/aadhar_pan_verify.dart';
import '../../presentations/widgets/AadharPanSection.dart';
import '../providers/LandlordProfileEditProvider.dart';

class LandlordProfileEditScreen extends StatefulWidget {
  const LandlordProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<LandlordProfileEditScreen> createState() =>
      _LandlordProfileEditScreenState();
}

class _LandlordProfileEditScreenState extends State<LandlordProfileEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  Future<void> _loadProfile() async {
    final provider = Provider.of<LandlordProfileEditProvider>(
      context,
      listen: false,
    );
    final result = await provider.fetchProfile();
    if (!result['success'] && mounted) {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectDate(
    BuildContext context,
    LandlordProfileEditProvider provider,
  ) async {
    if (!provider.isEditing) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      provider.dobController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  void _selectProfileImage(LandlordProfileEditProvider provider) async {
    if (!provider.isEditing) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.cardCornerRadius(context) * 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: AppSizes.mediumPadding(context)),
                Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.mediumPadding(context)),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceButton(
                        'Camera',
                        Icons.camera_alt,
                        () async {
                          Navigator.pop(context);
                          await _pickImage(ImageSource.camera, provider);
                        },
                      ),
                    ),
                    SizedBox(width: AppSizes.mediumPadding(context)),
                    Expanded(
                      child: _buildImageSourceButton(
                        'Gallery',
                        Icons.photo_library,
                        () async {
                          Navigator.pop(context);
                          await _pickImage(ImageSource.gallery, provider);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.mediumPadding(context)),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceButton(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source,
    LandlordProfileEditProvider provider,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        provider.setProfileImage(image.path);
        if (mounted) {
          _showSnackBar(
            "Profile image selected successfully!",
            AppColors.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error selecting image: ${e.toString()}", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _verifyBankDetails(LandlordProfileEditProvider provider) async {
    // Validate all bank fields first
    final accountHolderError = provider.validateBankAccountHolderName(
      provider.bankAccountHolderNameController.text,
    );
    final accountError = provider.validateBankAccountNumber(
      provider.bankAccountNumberController.text,
    );
    final ifscError = provider.validateBankIfscCode(
      provider.bankIfscCodeController.text,
    );
    final bankNameError = provider.validateBankName(
      provider.bankNameController.text,
    );
    final branchNameError = provider.validateBranchName(
      provider.branchNameController.text,
    );

    if (accountHolderError != null ||
        accountError != null ||
        ifscError != null ||
        bankNameError != null ||
        branchNameError != null) {
      _showSnackBar("Please fill all bank details correctly", Colors.red);
      return;
    }

    final result = await provider.verifyBankDetails();

    if (result['success']) {
      _showSnackBar(result['message'], AppColors.success);
    } else {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  Future<void> _saveProfile(LandlordProfileEditProvider provider) async {
    // Check if bank details are being added but not verified
    if (provider.hasBankDetails && !provider.isBankVerified) {
      _showSnackBar("Please verify bank details before saving", Colors.red);
      return;
    }

    if (!provider.validateAllFields()) {
      _showSnackBar("Please fill all fields correctly", Colors.red);
      return;
    }

    final result = await provider.updateProfile();

    if (result['success']) {
      _showSnackBar(result['message'], AppColors.success);

      if (result['shouldNavigateBack'] == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } else {
      _showSnackBar(result['message'], Colors.red);
    }
  }

  void _toggleEditMode(LandlordProfileEditProvider provider) {
    if (provider.isEditing) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Discard Changes?',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: Text(
                'Are you sure you want to discard your changes?',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: AppColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.cancelEditing();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Discard',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );
    } else {
      provider.setEditing(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<LandlordProfileEditProvider>(
        builder: (context, provider, child) {
          if (provider.isFetchingProfile) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    'Loading Profile...',
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(provider),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileSection(provider),
                          SizedBox(height: AppSizes.largePadding(context)),
                          _buildSectionHeader(
                            'Personal Information',
                            Icons.person,
                          ),
                          _buildPersonalInfoSection(provider),
                          SizedBox(height: AppSizes.largePadding(context)),
                          _buildSectionHeader(
                            'Identity Documents',
                            Icons.description,
                          ),
                          _buildDocumentSection(provider),
                          SizedBox(height: AppSizes.largePadding(context)),
                          _buildSectionHeader(
                            'Bank Details',
                            Icons.account_balance,
                          ),
                          _buildBankDetailsSection(provider),
                          SizedBox(height: AppSizes.largePadding(context)),
                          if (provider.isEditing) ...[
                            _buildActionButtons(provider),
                            SizedBox(height: AppSizes.largePadding(context)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(LandlordProfileEditProvider provider) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          provider.isEditing ? 'Edit Profile' : 'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.mediumText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            provider.isEditing ? Icons.close : Icons.edit,
            color: Colors.white,
          ),
          onPressed: () => _toggleEditMode(provider),
        ),
      ],
    );
  }

  Widget _buildProfileSection(LandlordProfileEditProvider provider) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap:
                provider.isEditing ? () => _selectProfileImage(provider) : null,
            child: Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(child: _buildProfileImage(provider)),
                  ),
                ),
                if (provider.isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider.nameController.text.isEmpty
                ? 'Landlord'
                : provider.nameController.text,
            style: TextStyle(
              fontSize: AppSizes.mediumText(context) * 1.2,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.emailController.text,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: AppColors.textSecondary,
            ),
          ),
          if (provider.isEditing) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tap photo to change',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context) * 0.9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileImage(LandlordProfileEditProvider provider) {
    if (provider.profileImagePath != null) {
      return Image.file(
        File(provider.profileImagePath!),
        width: 132,
        height: 132,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: 60, color: AppColors.primary);
        },
      );
    }

    if (provider.existingProfileImageUrl != null &&
        provider.existingProfileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: provider.existingProfileImageUrl!,
        width: 132,
        height: 132,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
        errorWidget:
            (context, url, error) =>
                Icon(Icons.person, size: 60, color: AppColors.primary),
      );
    }

    return Icon(Icons.person, size: 60, color: AppColors.primary);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(LandlordProfileEditProvider provider) {
    return Column(
      children: [
        _buildEnhancedTextField(
          controller: provider.nameController,
          label: 'Full Name',
          hint: 'Enter your complete name',
          icon: Icons.person_outline,
          errorText: provider.nameError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildEnhancedTextField(
          controller: provider.emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: provider.emailError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildEnhancedTextField(
          controller: provider.phoneController,
          label: 'Phone Number',
          hint: 'Enter 10-digit mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          errorText: provider.phoneError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        GestureDetector(
          onTap:
              provider.isEditing ? () => _selectDate(context, provider) : null,
          child: AbsorbPointer(
            child: _buildEnhancedTextField(
              controller: provider.dobController,
              label: 'Date of Birth',
              hint: 'Select your date of birth',
              icon: Icons.calendar_today_outlined,
              errorText: provider.dobError,
              enabled: provider.isEditing,
              onChanged: (_) => provider.clearAllErrors(),
            ),
          ),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildDropdownField(
          label: 'Gender',
          value: provider.selectedGender,
          items: provider.genderOptions,
          icon: Icons.wc_outlined,
          errorText: provider.genderError,
          enabled: provider.isEditing,
          onChanged: (value) => provider.setSelectedGender(value),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildEnhancedTextField(
          controller: provider.addressController,
          label: 'Current Address',
          hint: 'Enter your complete current address',
          icon: Icons.location_on_outlined,
          maxLines: 3,
          errorText: provider.addressError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildEnhancedTextField(
          controller: provider.pinCodeController,
          label: 'PIN Code',
          hint: 'Enter 6-digit PIN code',
          icon: Icons.location_city_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          errorText: provider.pinCodeError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildDropdownField(
          label: 'State',
          value: provider.selectedState,
          items: provider.stateOptions,
          icon: Icons.map_outlined,
          errorText: provider.stateError,
          enabled: provider.isEditing,
          onChanged: (value) => provider.setSelectedState(value),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(LandlordProfileEditProvider provider) {
    return Column(
      children: [
        _buildEnhancedTextField(
          controller: provider.aadharController,
          label: 'Aadhar Card Number',
          hint: 'Enter 12-digit Aadhar number (xxxx-xxxx-xxxx)',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [AadharNumberFormatter()],
          errorText: provider.aadharError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildEnhancedTextField(
          controller: provider.panController,
          label: 'PAN Card Number',
          hint: 'Enter PAN number (e.g., ABCDE1234F)',
          icon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            PanNumberFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          errorText: provider.panError,
          enabled: provider.isEditing,
          onChanged: (_) => provider.clearAllErrors(),
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection(LandlordProfileEditProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!provider.hasBankDetails && !provider.isEditing)
          Container(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: Text(
                    'No bank details added. Add your bank details to receive payments.',
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (!provider.hasBankDetails && provider.isEditing) ...[
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight(context),
            child: ElevatedButton.icon(
              onPressed: () {
                provider.setHasBankDetails(true);
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Bank Details',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (provider.hasBankDetails) ...[
          _buildEnhancedTextField(
            controller: provider.bankAccountHolderNameController,
            label: 'Account Holder Name',
            hint: 'Enter account holder name',
            icon: Icons.person_outline,
            errorText: provider.bankAccountHolderNameError,
            enabled: provider.isEditing,
            onChanged: (value) {
              provider.clearAllErrors();
              provider.onBankFieldChanged();
            },
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildEnhancedTextField(
            controller: provider.bankAccountNumberController,
            label: 'Account Number',
            hint: 'Enter bank account number',
            icon: Icons.account_balance_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(18),
            ],
            errorText: provider.bankAccountNumberError,
            enabled: provider.isEditing,
            onChanged: (value) {
              provider.clearAllErrors();
              provider.onBankFieldChanged();
            },
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildEnhancedTextField(
            controller: provider.bankIfscCodeController,
            label: 'IFSC Code',
            hint: 'Enter IFSC code (e.g., SBIN0001234)',
            icon: Icons.code_outlined,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              LengthLimitingTextInputFormatter(11),
            ],
            errorText: provider.bankIfscCodeError,
            enabled: provider.isEditing,
            onChanged: (value) {
              provider.clearAllErrors();
              provider.onBankFieldChanged();
            },
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildEnhancedTextField(
            controller: provider.bankNameController,
            label: 'Bank Name',
            hint: 'Enter bank name',
            icon: Icons.account_balance,
            errorText: provider.bankNameError,
            enabled: provider.isEditing,
            onChanged: (value) {
              provider.clearAllErrors();
              provider.onBankFieldChanged();
            },
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildEnhancedTextField(
            controller: provider.branchNameController,
            label: 'Branch Name',
            hint: 'Enter branch name',
            icon: Icons.location_on_outlined,
            errorText: provider.branchNameError,
            enabled: provider.isEditing,
            onChanged: (value) {
              provider.clearAllErrors();
              provider.onBankFieldChanged();
            },
          ),
          if (provider.isEditing) ...[
            SizedBox(height: AppSizes.mediumPadding(context)),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight(context),
              child: ElevatedButton.icon(
                onPressed:
                    provider.isVerifyingBank
                        ? null
                        : () => _verifyBankDetails(provider),
                icon:
                    provider.isVerifyingBank
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(
                          provider.isBankVerified
                              ? Icons.refresh
                              : Icons.verified_user,
                          color: Colors.white,
                        ),
                label: Text(
                  provider.isVerifyingBank
                      ? 'Verifying...'
                      : provider.isBankVerified
                      ? 'Re-verify Bank Details'
                      : 'Verify Bank Details',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (provider.isBankVerified) ...[
            SizedBox(height: AppSizes.mediumPadding(context)),
            Container(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: AppSizes.smallPadding(context)),
                  Expanded(
                    child: Text(
                      'Bank details verified successfully',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context),
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildActionButtons(LandlordProfileEditProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppSizes.buttonHeight(context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ElevatedButton(
              onPressed:
                  provider.isLoading ? null : () => _toggleEditMode(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.mediumPadding(context)),
        Expanded(
          flex: 2,
          child: Container(
            height: AppSizes.buttonHeight(context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed:
                  provider.isLoading ? null : () => _saveProfile(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
              ),
              child:
                  provider.isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
    int maxLines = 1,
    String? errorText,
    Function(String)? onChanged,
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
            boxShadow:
                enabled
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
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
                  color: AppColors.primary.withOpacity(enabled ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary.withOpacity(enabled ? 1 : 0.5),
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : AppColors.secondary,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(
                  color: AppColors.divider.withOpacity(0.5),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required bool enabled,
    required void Function(String?) onChanged,
    String? errorText,
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
            boxShadow:
                enabled
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: enabled ? onChanged : null,
            items:
                items
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(enabled ? 0.1 : 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary.withOpacity(enabled ? 1 : 0.5),
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : AppColors.secondary,
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(
                  color: AppColors.divider.withOpacity(0.5),
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
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: enabled ? AppColors.primary : AppColors.textSecondary,
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
