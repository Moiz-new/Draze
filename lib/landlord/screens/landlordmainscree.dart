// lib/seller/screens/seller_main_screen.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/screens/visitors/VisitorsDashboard.dart';
import 'package:draze/landlord/screens/landlord_reel_screen.dart';
import 'package:draze/landlord/screens/profile_screen.dart';
import 'package:draze/landlord/screens/property_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers for state management
final selectedTabProvider = StateProvider<int>((ref) => 0);
final refreshTriggerProvider = StateProvider<int>((ref) => 0);

class LandlordMainScreen extends ConsumerStatefulWidget {
  const LandlordMainScreen({super.key});

  @override
  ConsumerState<LandlordMainScreen> createState() => _LandlordMainScreenState();
}

class _LandlordMainScreenState extends ConsumerState<LandlordMainScreen>
    with WidgetsBindingObserver {

  // Global key for scaffold to access drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    // Trigger refresh when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      ref.read(refreshTriggerProvider.notifier).state++;
    }
  }

  Widget _buildScreen(int tabIndex, int refreshKey) {
    switch (tabIndex) {
      case 0:
        return KeyedSubtree(
          key: ValueKey('home_$refreshKey'),
          child: LandlordScreen(scaffoldKey: _scaffoldKey),
        );
      case 1:
        return KeyedSubtree(
          key: ValueKey('reels_$refreshKey'),
          child: LandlordReelsScreen(scaffoldKey: _scaffoldKey),
        );
      case 2:
        return KeyedSubtree(
          key: ValueKey('visits_$refreshKey'),
          child: VisitorsDashboard(scaffoldKey: _scaffoldKey),
        );
      case 3:
        return KeyedSubtree(
          key: ValueKey('profile_$refreshKey'),
          child: LandlordProfileScreen(),
        );
      default:
        return LandlordScreen(scaffoldKey: _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final refreshKey = ref.watch(refreshTriggerProvider);

    return Scaffold(
      key: _scaffoldKey,
      // Add drawer here if needed
      drawer: _buildDrawer(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _buildScreen(selectedTab, refreshKey),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // Drawer widget - customize this according to your needs
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Landlord Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 0;
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Reels'),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 1;
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Visits'),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 2;
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              ref.read(selectedTabProvider.notifier).state = 3;
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
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
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.video_library_outlined,
                activeIcon: Icons.video_library,
                label: 'Reels',
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.message_outlined,
                activeIcon: Icons.message,
                label: 'Visits',
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required int index,
        required IconData icon,
        required IconData activeIcon,
        required String label,
      }) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.mediumPadding(context),
          vertical: AppSizes.smallPadding(context),
        ),
        decoration: BoxDecoration(
          color: isSelected
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
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('$index-$isSelected'),
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

  void _onTabTapped(int index) {
    final currentTab = ref.read(selectedTabProvider);

    if (currentTab != index) {
      // Change tab
      ref.read(selectedTabProvider.notifier).state = index;
      // Trigger refresh for the new screen
      ref.read(refreshTriggerProvider.notifier).state++;
    } else {
      // Tap on same tab - could implement scroll to top or refresh
      ref.read(refreshTriggerProvider.notifier).state++;
    }
  }
}

// Extension to help with tab navigation from other screens
extension LandlordMainScreenNavigation on WidgetRef {
  void navigateToTab(int tabIndex) {
    read(selectedTabProvider.notifier).state = tabIndex;
    read(refreshTriggerProvider.notifier).state++;
  }

  void refreshCurrentTab() {
    read(refreshTriggerProvider.notifier).state++;
  }
}

// Provider for scaffold key access (if needed in other parts of the app)
final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});