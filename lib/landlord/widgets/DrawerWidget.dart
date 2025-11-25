import 'package:draze/landlord/screens/AddExpenseScreen.dart';
import 'package:draze/landlord/screens/AddSubOwnerScreen.dart';
import 'package:draze/landlord/screens/AllTenantListScreen.dart';
import 'package:draze/landlord/screens/AnnouncementsScreen.dart';
import 'package:draze/landlord/screens/ExpensesAnalyticsScreen.dart';
import 'package:draze/landlord/screens/ExpensesListScreen.dart';
import 'package:draze/landlord/screens/MySubscriptionsScreen.dart';
import 'package:draze/landlord/screens/TenantAllDuesListScreen.dart';
import 'package:draze/presentations/screens/mobile_screen.dart';
import 'package:draze/presentations/screens/select_role.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/appColors.dart';
import '../screens/CollectionForecastScreen.dart';
import '../screens/DuesScreen.dart';
import '../screens/PoliceVerificationScreen.dart';
import '../screens/RoomSwitchRequestsScreen.dart';
import '../screens/SubOwnersScreen.dart';
import '../screens/SubscriptionPlansScreen.dart';
import '../screens/TenantDocumentListScreen.dart';

class Drawerwidget extends StatefulWidget {
  final String Name;

  const Drawerwidget({super.key, required this.Name});

  @override
  State<Drawerwidget> createState() => _DrawerwidgetState();
}

class _DrawerwidgetState extends State<Drawerwidget> {
  @override
  Widget build(BuildContext context) {
    // Get screen height for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;
    final headerFlex = screenHeight < 600 ? 2 : 3;
    final menuFlex = screenHeight < 600 ? 5 : 7;

    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25.r),
          bottomRight: Radius.circular(25.r),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header
          Flexible(
            flex: headerFlex,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25.r),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 2.h),
                              blurRadius: 4.r,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.Name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Drawer Menu Items
          Flexible(
            flex: menuFlex,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDrawerItem(
                      icon: Icons.speaker,
                      title: 'Announcements',
                      onTap: _navigateToAnnouncements,
                    ),
                    _buildDrawerItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Police Verification',
                      onTap: _navigateToPoliceVerificationScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.data_exploration_outlined,
                      title: 'Expenses',
                      onTap: _navigateToAddExpenses,
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics,
                      title: 'Exp. Analytics',
                      onTap: _navigateToExpensesAnalytics,
                    ),
                    _buildDrawerItem(
                      icon: Icons.tour_rounded,
                      title: 'My Subscription',
                      onTap: _navigateToMySubscriptionScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.next_plan,
                      title: 'Subscription Plans',
                      onTap: _navigateToSubscriptionPlansScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.list,
                      title: 'Collections',
                      onTap: _navigateToCollection,
                    ),
                    _buildDrawerItem(
                      icon: Icons.featured_play_list_outlined,
                      title: 'Room Switch Requests',
                      onTap: _navigateToRoomSwitchRequest,
                    ),
                    _buildDrawerItem(
                      icon: Icons.people_outline,
                      title: 'All Tenant List',
                      onTap: _navigateAllTenantListScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.checklist,
                      title: 'All Tenant Dues',
                      onTap: _navigateAllTenantDuesListScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.dock,
                      title: 'Tenant Documents',
                      onTap: _navigateTenantDocumentScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.check_box_outlined,
                      title: 'Due Packages',
                      onTap: _navigateDuesScreen,
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_add_sharp,
                      title: 'Add Sub-Owner',
                      onTap: _navigateAddSubOwner,
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Container(
        constraints: BoxConstraints(minHeight: 48.h, maxHeight: 56.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color:
                          title == "Logout"
                              ? AppColors.error
                              : AppColors.primary,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            title == "Logout"
                                ? AppColors.error
                                : AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color:
                        title == "Logout" ? AppColors.error : AppColors.divider,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAnnouncements() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnnouncementsScreen()),
    );
  }

  void _navigateToPoliceVerificationScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoliceVerificationScreen()),
    );
  }

  void _navigateToAddExpenses() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpensesListScreen()),
    );
  }

  void _navigateToCollection() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CollectionForecastScreen()),
    );
  }

  void _navigateToExpensesAnalytics() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExpensesAnalyticsScreen()),
    );
  }

  void _navigateToSubscriptionPlansScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubscriptionPlansScreen()),
    );
  }

  void _navigateToMySubscriptionScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MySubscriptionsScreen()),
    );
  }

  void _navigateToRoomSwitchRequest() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomSwitchRequestsScreen()),
    );
  }

  void _navigateAllTenantListScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllTenantListScreen()),
    );
  }

  void _navigateAllTenantDuesListScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllTenantDuesListScreen()),
    );
  }

  void _navigateTenantDocumentScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TenantDocumentListScreen()),
    );
  }

  void _navigateDuesScreen() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DuesScreen()),
    );
  }

  void _navigateAddSubOwner() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubOwnersScreen()),
    );
  }

  void _navigateToLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
