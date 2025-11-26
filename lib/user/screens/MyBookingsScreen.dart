import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/appColors.dart';
import 'MyVisitsScreen.dart';
import 'MyEnquiriesScreen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [_buildTabBar(), Expanded(child: _buildTabBarView())],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Bookings',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6.r,
            spreadRadius: 0,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8.r,
                spreadRadius: 0,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: [
            Tab(
              child: Container(
                alignment: Alignment.center,
                height: 44.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 18.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Property Visits',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Container(
                alignment: Alignment.center,
                height: 44.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hotel_outlined, size: 18.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Hotel Enquiries',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: const [MyVisitsScreen(), MyEnquiriesScreen()],
    );
  }
}
