import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/screens/DuesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentations/screens/select_role.dart';
import '../providers/LandlordProfileNotifier.dart';
import 'LandlordProfileEditScreen.dart';
import 'SignatureUploadScreen.dart';
import 'TenantAllDuesListScreen.dart';

class LandlordProfileScreen extends ConsumerStatefulWidget {
  const LandlordProfileScreen({super.key});

  @override
  _LandlordProfileScreenState createState() => _LandlordProfileScreenState();
}

class _LandlordProfileScreenState extends ConsumerState<LandlordProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await Future.delayed(Duration.zero);
    ref.read(landlordProfileProvider.notifier).fetchProfile();
  }

  void _refreshProfile() {
    ref.read(landlordProfileProvider.notifier).refreshProfile();
  }

  Future<void> _showEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LandlordProfileEditScreen(),
      ),
    );

    // If result is true, refresh the profile
    if (result == true && mounted) {
      _refreshProfile();
    }
  }

  void _handleNavigation(String route) {
    switch (route) {
      case 'properties':
        context.push('/property_all_list');
        break;
      case 'all_dues':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AllTenantDuesListScreen()),
        );
        break;
      case 'due_packages':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DuesScreen()),
        );
        break;
      case 'signature':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignatureUploadScreen()),
        );
        break;
      default:
        _showSnackBar('Feature coming soon', AppColors.textSecondary);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not provided';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
      return 'Not provided';
    } catch (e) {
      return 'Not provided';
    }
  }

  String _formatAadhar(dynamic aadhar) {
    if (aadhar == null) return 'Not provided';
    final aadharStr = aadhar.toString();
    if (aadharStr.length == 12) {
      return '${aadharStr.substring(0, 4)} ${aadharStr.substring(4, 8)} ${aadharStr.substring(8, 12)}';
    }
    return aadharStr;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(landlordProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshProfile();
          await Future.delayed(const Duration(seconds: 1));
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return _buildErrorContent('Profile not found');
                  }
                  // Convert LandlordProfile to Map for _buildContent
                  final profileMap = {
                    'id': profile.id,
                    'name': profile.name,
                    'email': profile.email,
                    'mobile': profile.mobile,
                    'aadhaarNumber': profile.aadhaarNumber,
                    'panNumber': profile.panNumber,
                    'address': profile.address,
                    'pinCode': profile.pinCode,
                    'state': profile.state,
                    'gender': profile.gender,
                    'dob': profile.dob,
                    'properties': profile.properties,
                    'profilePhoto': profile.fullProfileImageUrl,
                    'createdAt': profile.createdAt,
                  };
                  return _buildContent(profileMap);
                },
                loading: () => _buildLoadingContent(),
                error: (error, stack) => _buildErrorContent(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
      automaticallyImplyLeading: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: TextButton.icon(
            onPressed: () => context.push('/auth/role'),
            icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
            label: const Text(
              'Switch Role',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile) {
    final profileImageUrl = profile['profilePhoto'] as String?;
    final name = profile['name'] as String? ?? 'Landlord';
    final email = profile['email'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: ClipOval(child: _buildProfileImage(profileImageUrl)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_work, color: AppColors.primary, size: 16),
                SizedBox(width: 6),
                Text(
                  'Property Owner',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 116,
        height: 116,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
        errorWidget:
            (context, url, error) =>
                const Icon(Icons.person, size: 60, color: AppColors.primary),
      );
    }
    return const Icon(Icons.person, size: 60, color: AppColors.primary);
  }

  Widget _buildStatsSection(Map<String, dynamic> ownerData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Properties',
            '${ownerData['totalProperties']}',
            Icons.apartment,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Tenants',
            '${ownerData['totalTenants']}',
            Icons.people,
            AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Revenue',
            '₹${NumberFormat('#,##0').format(ownerData['monthlyRevenue'])}',
            Icons.currency_rupee,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // Add this method in _LandlordProfileScreenState class after _buildInfoSection

  Widget _buildBankDetailsSection(LandlordProfile profile) {
    final bankAccount = profile.bankAccount;
    final hasBankDetails = bankAccount != null && !bankAccount.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bank Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (hasBankDetails)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Added',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (hasBankDetails) ...[
            _buildInfoCard(
              Icons.account_balance,
              'Bank Name',
              bankAccount.bankName,
            ),
            _buildInfoCard(
              Icons.person_outline,
              'Account Holder Name',
              bankAccount.accountHolderName,
            ),
            _buildInfoCard(
              Icons.account_balance_wallet_outlined,
              'Account Number',
              _maskAccountNumber(bankAccount.accountNumber),
            ),
            _buildInfoCard(Icons.code, 'IFSC Code', bankAccount.ifscCode),
            _buildInfoCard(
              Icons.location_city_outlined,
              'Branch Name',
              bankAccount.branchName,
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: AppColors.warning,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Bank Details Added',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add your bank details to receive payments',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showEditProfile,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Add Bank Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.isEmpty) return 'Not provided';
    if (accountNumber.length <= 4) return accountNumber;

    final visibleDigits = accountNumber.substring(accountNumber.length - 4);
    final maskedPart = 'X' * (accountNumber.length - 4);
    return '$maskedPart$visibleDigits';
  }

  Widget _buildContent(Map<String, dynamic> profile) {
    final ownerData = ref.watch(ownerDataProvider);
    final profileAsync = ref.watch(landlordProfileProvider);

    return Padding(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      child: Column(
        children: [
          _buildProfileHeader(profile),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildStatsSection(ownerData),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildInfoSection('Personal Information', [
            _buildInfoCard(
              Icons.email_outlined,
              'Email',
              profile['email'] ?? 'Not provided',
            ),
            _buildInfoCard(
              Icons.phone_outlined,
              'Phone',
              profile['mobile'] ?? 'Not provided',
            ),
            _buildInfoCard(
              Icons.cake_outlined,
              'Date of Birth',
              _formatDate(profile['dob']),
            ),
            _buildInfoCard(
              Icons.wc_outlined,
              'Gender',
              profile['gender'] ?? 'Not specified',
            ),
          ]),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildInfoSection('Address Details', [
            _buildInfoCard(
              Icons.location_on_outlined,
              'Address',
              profile['address'] ?? 'Not provided',
            ),
            _buildInfoCard(
              Icons.location_city_outlined,
              'PIN Code',
              profile['pinCode'] ?? 'Not provided',
            ),
            _buildInfoCard(
              Icons.map_outlined,
              'State',
              profile['state'] ?? 'Not provided',
            ),
          ]),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildInfoSection('Identity Documents', [
            _buildInfoCard(
              Icons.credit_card_outlined,
              'Aadhar Number',
              _formatAadhar(profile['aadhaarNumber']),
            ),
            _buildInfoCard(
              Icons.badge_outlined,
              'PAN Number',
              profile['panNumber'] ?? 'Not provided',
            ),
          ]),
          SizedBox(height: AppSizes.largePadding(context)),
          // Add Bank Details Section here
          profileAsync.when(
            data: (landlordProfile) {
              if (landlordProfile != null) {
                return _buildBankDetailsSection(landlordProfile);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildKYCSection(ownerData),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildQuickActions(ownerData),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildEditButton(),
          SizedBox(height: AppSizes.mediumPadding(context)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKYCSection(Map<String, dynamic> ownerData) {
    final kycStatus = ownerData['kycStatus'] as String;
    final isVerified = kycStatus == 'Verified';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isVerified ? AppColors.success : AppColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isVerified ? Icons.verified_user : Icons.pending,
              color: isVerified ? AppColors.success : AppColors.warning,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KYC Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kycStatus,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isVerified ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isVerified ? AppColors.success : AppColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isVerified ? 'Active' : 'Pending',
              style: TextStyle(
                color: isVerified ? AppColors.success : AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Map<String, dynamic> ownerData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            'My Properties',
            'Manage all your properties',
            Icons.apartment,
            AppColors.primary,
            () => _handleNavigation('properties'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Tenant Dues',
            'View all tenant payment dues',
            Icons.payment,
            AppColors.warning,
            () => _handleNavigation('all_dues'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Due Packages',
            'Manage due payment packages',
            Icons.list_alt,
            AppColors.success,
            () => _handleNavigation('due_packages'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Agreement',
            'Upload Agreement Signature',
            Icons.auto_fix_high_outlined,
            AppColors.error,
            () => _handleNavigation('signature'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _showEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      child: Column(
        children: [
          SizedBox(height: AppSizes.largePadding(context)),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load profile',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshProfile,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
