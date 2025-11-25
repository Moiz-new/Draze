import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/user/provider/reel_provider.dart';
import 'package:draze/user/screens/MyVisitsScreen.dart';
import 'package:draze/user/screens/UserReelsScreen.dart';
import 'package:draze/user/screens/profile_screen.dart';
import 'package:draze/user/screens/userScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'MyBookingsScreen.dart';

// ErrorBoundary Widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(Object, StackTrace)? onError;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.onRetry,
  });

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Something went wrong. Please try again.',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.onRetry?.call();
                setState(() {
                  error = null;
                  stackTrace = null;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          error = details.exception;
          stackTrace = details.stack;
          print('ErrorBoundary: Caught error: $error\n$stackTrace');
        });
      }
    };
  }

  @override
  void dispose() {
    FlutterError.onError = null;
    super.dispose();
  }
}

// UserMainScreen Widget
class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Pause all videos when app goes to background
      final videoController = Provider.of<VideoControllersProvider>(
        context,
        listen: false,
      );
      videoController.pauseAll();
      print(
        'UserMainScreen: App lifecycle changed to $state, paused all videos',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReelsProvider>(
      builder: (context, reelsProvider, child) {
        final selectedTab = reelsProvider.selectedTab;

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
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      isSelected: selectedTab == 0,
                    ),
                    _buildNavItem(
                      context,
                      index: 1,
                      icon: Icons.video_library_outlined,
                      activeIcon: Icons.video_library,
                      label: 'Reels',
                      isSelected: selectedTab == 1,
                    ),
                    _buildNavItem(
                      context,
                      index: 2,
                      icon: Icons.message_outlined,
                      activeIcon: Icons.message_outlined,
                      label: 'Visits',
                      isSelected: selectedTab == 2,
                    ),
                    _buildNavItem(
                      context,
                      index: 3,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      isSelected: selectedTab == 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(int selectedTab) {
    switch (selectedTab) {
      case 0:
        return const UserHomeScreen();
      case 1:
        return ErrorBoundary(
          onError: (error, stackTrace) {
            print('Error in ReelsScreen: $error\n$stackTrace');
          },
          onRetry: () {
            print('UserMainScreen: Retrying ReelsScreen initialization');
          },
          child: UserReelsScreen(),
        );
      case 2:
        return ErrorBoundary(
          onError: (error, stackTrace) {
            print('Error in MyVisitsScreen: $error\n$stackTrace');
          },
          child: const MyBookingsScreen(),
        );
      case 3:
        return ErrorBoundary(
          onError: (error, stackTrace) {
            print('Error in ProfileScreen: $error\n$stackTrace');
          },
          child: const UserProfileScreen(),
        );
      default:
        return const UserHomeScreen();
    }
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        print('UserMainScreen: Switching to tab $index');

        final reelsProvider = Provider.of<ReelsProvider>(
          context,
          listen: false,
        );
        final videoController = Provider.of<VideoControllersProvider>(
          context,
          listen: false,
        );
        final previousTab = reelsProvider.selectedTab;

        // Handle video playback based on tab switching
        if (previousTab == 1 && index != 1) {
          // Leaving reels tab - pause all videos
          print('UserMainScreen: Leaving Reels tab, pausing all videos');
          videoController.pauseAll();
          reelsProvider.setReelsTabActive(false);
        } else if (previousTab != 1 && index == 1) {
          // Entering reels tab - mark as active
          print('UserMainScreen: Entering Reels tab');
          reelsProvider.setReelsTabActive(true);
        }

        // Update selected tab
        reelsProvider.setSelectedTab(index);
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
}
