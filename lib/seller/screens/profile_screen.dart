// seller_profile_screen.dart
import 'package:draze/seller/screens/EditSellerProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/SellerProfileProvider.dart';
import 'SellerMySubscriptionScreen.dart';
import 'SellerSubscriptionPlansScreen.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Fetch profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerProfileProvider>().fetchSellerProfile();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<SellerProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sellerData == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.error != null && provider.sellerData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.error ?? 'Unknown error',
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchSellerProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: AppColors.surface),
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              const _ProfileAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                      child: Column(
                        children: [
                          const _ProfileHeader(),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          const _StatsCards(),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          // ADD THIS SUBSCRIPTION SECTION HERE
                          _SubscriptionSection(
                            onTap: _navigateToSubscriptionPlans,
                            lable: "Subscription Plans",
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          _SubscriptionSection(
                            onTap: _navigateToMySubscriptionPlans,
                            lable: "My Subscription Plans",
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          const _VerificationSection(),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          const _PersonalInfo(),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          _ActionButtons(
                            onEdit: _showEditProfile,
                            onLogout: _showLogoutDialog,
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
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

  void _handleListTileTap(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title tapped')));
  }

  void _showEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSellerProfileScreen()),
    );
  }

  // ADD THIS METHOD
  void _navigateToSubscriptionPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerSubscriptionPlansScreen(),
      ),
    );
  }void _navigateToMySubscriptionPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SellerMySubscriptionScreen(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final provider = context.read<SellerProfileProvider>();
                await provider.logout();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                  context.go('/auth/role');
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ADD THIS NEW WIDGET CLASS
class _SubscriptionSection extends StatelessWidget {
  final VoidCallback onTap;
  String lable;

  _SubscriptionSection({required this.onTap, required this.lable});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.card_membership,
                    color: AppColors.surface,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lable,
                        style: TextStyle(
                          color: AppColors.surface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock premium features & list more properties',
                        style: TextStyle(
                          color: AppColors.surface.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.surface,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Rest of your existing classes remain the same...
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.14,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: const FlexibleSpaceBar(
        title: Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Text(
            'Profile',
            style: TextStyle(
              color: AppColors.surface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        background: _AppBarBackground(),
      ),
      automaticallyImplyLeading: false,
      actions: [
        GestureDetector(
          onTap: () => context.push('/auth/role'),
          child: Container(
            margin: EdgeInsets.only(right: AppSizes.smallPadding(context) + 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text(
                  'Change Role',
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.person, color: AppColors.surface, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProfileProvider>(
      builder: (context, provider, child) {
        final profileImageUrl = provider.getFullProfileImageUrl();

        return Column(
          children: [
            profileImageUrl != null
                ? CachedNetworkImage(
                  imageUrl: profileImageUrl,
                  imageBuilder:
                      (context, imageProvider) => CircleAvatar(
                        radius: 50,
                        backgroundImage: imageProvider,
                        backgroundColor: AppColors.disabled,
                      ),
                  placeholder:
                      (context, url) => const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.disabled,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.disabled,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                          size: 50,
                        ),
                      ),
                )
                : const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.disabled,
                  child: Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 50,
                  ),
                ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              provider.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) / 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    provider.status == 'ACTIVE'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.status,
                style: TextStyle(
                  color:
                      provider.status == 'ACTIVE'
                          ? AppColors.success
                          : AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (provider.isVerified) ...[
              SizedBox(height: AppSizes.smallPadding(context) / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatsCards extends StatelessWidget {
  const _StatsCards();

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProfileProvider>(
      builder: (context, provider, child) {
        String memberSince = 'N/A';
        if (provider.createdAt != null) {
          try {
            final date = DateTime.parse(provider.createdAt!);
            memberSince = DateFormat('MMM yyyy').format(date);
          } catch (e) {
            memberSince = 'N/A';
          }
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Member Since',
                memberSince,
                Icons.calendar_today,
                AppColors.primary,
              ),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Expanded(
              child: _buildStatCard(
                context,
                'Status',
                provider.status,
                Icons.info,
                provider.status == 'ACTIVE'
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Expanded(
              child: _buildStatCard(
                context,
                'Verified',
                provider.isVerified ? 'Yes' : 'No',
                Icons.verified_user,
                provider.isVerified ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerificationSection extends StatelessWidget {
  const _VerificationSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProfileProvider>(
      builder: (context, provider, child) {
        return _buildSection(context, 'Verification', [
          _buildListTile(
            context,
            Icons.verified_user,
            'Verification Status',
            provider.isVerified ? 'Verified' : 'Not Verified',
            provider.isVerified ? AppColors.success : AppColors.error,
            showArrow: false,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    provider.isVerified
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.isVerified ? 'Verified' : 'Pending',
                style: TextStyle(
                  color:
                      provider.isVerified ? AppColors.success : AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          _buildListTile(
            context,
            Icons.app_registration,
            'Registration',
            provider.isRegistered ? 'Completed' : 'Pending',
            provider.isRegistered ? AppColors.success : AppColors.warning,
            showArrow: false,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    provider.isRegistered
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.isRegistered ? 'Complete' : 'Pending',
                style: TextStyle(
                  color:
                      provider.isRegistered
                          ? AppColors.success
                          : AppColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
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
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.disabled),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    bool showArrow = true,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing:
          trailing ??
          (showArrow
              ? const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              )
              : null),
    );
  }
}

class _PersonalInfo extends StatelessWidget {
  const _PersonalInfo();

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProfileProvider>(
      builder: (context, provider, child) {
        return _VerificationSection()
            ._buildSection(context, 'Personal Information', [
              _VerificationSection()._buildListTile(
                context,
                Icons.email,
                'Email',
                provider.email,
                AppColors.primary,
                showArrow: false,
              ),
              _VerificationSection()._buildListTile(
                context,
                Icons.phone,
                'Phone',
                provider.mobile,
                AppColors.primary,
                showArrow: false,
              ),
              _VerificationSection()._buildListTile(
                context,
                Icons.location_on,
                'Address',
                provider.address,
                AppColors.primary,
                showArrow: false,
              ),
            ]);
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const _ActionButtons({required this.onEdit, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: AppColors.surface, size: 20),
            label: const Text(
              'Edit Profile',
              style: TextStyle(
                color: AppColors.surface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
