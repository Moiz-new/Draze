// lib/seller/screens/seller_main_screen.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/seller/providers/reels_provider.dart';
import 'package:draze/seller/screens/profile_screen.dart';
import 'package:draze/seller/screens/seller_home.dart';
import 'package:draze/seller/screens/sellerreelsscreen.dart';
import 'package:draze/seller/screens/seller_visitor_screen.dart';
import 'package:draze/seller/screens/visitors/SellerAllVisitorsScreen.dart';
import 'package:draze/seller/screens/visitors/SellerVisitorsDashboard.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../landlord/screens/visitors/VisitorsDashboard.dart';

// Provider for managing selected tab
final selectedTabProvider = StateProvider<int>((ref) => 0);

class SellerMainScreen extends ConsumerWidget {
  const SellerMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    // Listen to tab changes and pause videos when leaving ReelsScreen
    ref.listen(selectedTabProvider, (previous, next) {
      if (previous == 1 && next != 1) {
        // Pause all videos when leaving ReelsScreen (index 1)
        final controllers = ref.read(videoControllersProvider);
        for (var controller in controllers.values) {
          controller.pause();
        }
      }
    });

    return Scaffold(
      body: _buildCurrentScreen(selectedTab),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.mediumPadding(context),
              vertical: AppSizes.smallPadding(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  ref,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  context,
                  ref,
                  index: 1,
                  icon: Icons.video_library_outlined,
                  activeIcon: Icons.video_library,
                  label: 'Reels',
                ),
                _buildNavItem(
                  context,
                  ref,
                  index: 2,
                  icon: Icons.message_outlined,
                  activeIcon: Icons.message_outlined,
                  label: 'Visits',
                ),
                _buildNavItem(
                  context,
                  ref,
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the current screen based on selected tab
  // This ensures the widget is rebuilt every time the tab changes
  Widget _buildCurrentScreen(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return const SellerHomeScreen(key: ValueKey('home'));
      case 1:
        return const SellerReelsScreen(key: ValueKey('reels'));
      case 2:
        return const SellerAllVisitorsScreen(key: ValueKey('visits'));
      case 3:
        return ErrorBoundary(
          key: const ValueKey('profile'),
          onError: (error, stackTrace) {
            print('Error in ProfileScreen: $error\n$stackTrace');
          },
          child: const SellerProfileScreen(),
        );
      default:
        return const SellerHomeScreen(key: ValueKey('home'));
    }
  }

  Widget _buildNavItem(
      BuildContext context,
      WidgetRef ref, {
        required int index,
        required IconData icon,
        required IconData activeIcon,
        required String label,
      }) {
    final isSelected = ref.watch(selectedTabProvider) == index;

    return GestureDetector(
      onTap: () {
        ref.read(selectedTabProvider.notifier).state = index;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.mediumPadding(context),
          vertical: AppSizes.smallPadding(context),
        ),
        decoration: BoxDecoration(
          color:
          isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: AppSizes.mediumIcon(context) * 0.9,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) / 3),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.smallText(context) * 0.8,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelsScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Property Reels',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.titleText(context) - 5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.largePadding(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: AppSizes.largeIcon(context) * 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Text(
              'Property Reels',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              'Create and share video tours of your properties',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.titleText(context) - 5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.largePadding(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: AppSizes.largeIcon(context) * 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Text(
              'Profile Settings',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              'Manage your account settings and preferences',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(Object, StackTrace)? onError;

  const ErrorBoundary({super.key, required this.child, this.onError});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? error;
  StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      widget.onError?.call(error!, stackTrace!);
      return const Center(
        child: Text(
          'Something went wrong. Please try again.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      setState(() {
        error = details.exception;
        stackTrace = details.stack;
      });
    };
  }
}