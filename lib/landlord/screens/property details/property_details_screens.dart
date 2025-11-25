import 'package:draze/landlord/providers/property_details_provider.dart';
import 'package:draze/landlord/screens/property%20details/PropertyReviewScreen.dart';
import 'package:draze/landlord/screens/property%20details/ComplaintAgainstPropertyScreen.dart';
import 'package:draze/landlord/screens/property%20details/TenantDuesAgainstPropertyScreen.dart';
import 'package:draze/landlord/screens/property%20details/ExpenseAgainstPropertyScreen.dart';
import 'package:draze/landlord/screens/property%20details/overview.dart';
import 'package:draze/landlord/screens/property%20details/rooms.dart';
import 'package:draze/landlord/screens/property%20details/tenant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';

import 'PropertyDashboardScreen.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String propertyName;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  @override
  ConsumerState<PropertyDetailsScreen> createState() =>
      _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = [
    'Dashboard',
    'Overview',
    'Rooms',
    'Tenants',
    'Dues',
    'Complaints',
    'Expenses',
    'Review',
  ];

  final List<IconData> _tabIcons = [
    Icons.dashboard,
    Icons.info_outline,
    Icons.meeting_room_outlined,
    Icons.people_outline,
    Icons.monetization_on_outlined,
    Icons.receipt_long_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.star,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailsState = ref.watch(
      propertyDetailsProvider((
        propertyId: widget.propertyId,
        tabController: _tabController,
      )),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailsState.property.when(
        data: (property) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    centerTitle: false,
                    title: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Text(
                        widget.propertyName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.largeText(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    actions: [
                      Container(
                        margin: EdgeInsets.all(AppSizes.mediumPadding(context)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius(context),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSizes.cardCornerRadius(context),
                            ),
                            onTap: () {
                              context.pop();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.mediumPadding(context),
                                vertical: AppSizes.smallPadding(context),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swap_horiz,
                                    color: Colors.white,
                                    size: AppSizes.smallIcon(context) - 4,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Change Property',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppSizes.smallText(context) - 2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    tabController: _tabController,
                    tabTitles: _tabTitles,
                    tabIcons: _tabIcons,
                    context: context,
                  ),
                ),
              ];
            },
            body: Builder(
              builder: (BuildContext context) {
                return CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PropertyDashboardScreen(
                            propertyId: widget.propertyId,
                            tabController: _tabController,
                          ),
                          OverviewTab(propertyId: widget.propertyId),
                          RoomsTab(propertyId: widget.propertyId),
                          TenantsTab(propertyId: widget.propertyId),
                          TenantDuesAgainstPropertyScreen(
                            propertyId: widget.propertyId,
                          ),
                          ComplaintAgainstPropertyScreen(
                            propertyId: widget.propertyId,
                          ),
                          ExpenseAgainstPropertyScreen(
                            propertyId: widget.propertyId,
                          ),
                          PropertyReviewScreen(propertyId: widget.propertyId),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
        loading:
            () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading property details...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.smallText(context),
                    ),
                  ),
                ],
              ),
            ),
        error:
            (error, stack) => Center(
              child: Container(
                margin: EdgeInsets.all(AppSizes.mediumPadding(context)),
                padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: AppSizes.largeIcon(context),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading property',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: AppSizes.mediumText(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$error',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.smallText(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        // Retry loading
                        ref.invalidate(
                          propertyDetailsProvider((
                            propertyId: widget.propertyId,
                            tabController: _tabController,
                          )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.smallText(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
      bottomNavigationBar: detailsState.property.when(
        data:
            (property) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 90.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        label: 'Overview',
                        isActive: detailsState.selectedBottomNavIndex == 0,
                        onTap:
                            () => ref
                                .read(
                                  propertyDetailsProvider((
                                    propertyId: widget.propertyId,
                                    tabController: _tabController,
                                  )).notifier,
                                )
                                .onBottomNavTap(0),
                      ),
                      _buildBottomNavItem(
                        context,
                        icon: Icons.monetization_on_outlined,
                        activeIcon: Icons.monetization_on,
                        label: 'Finance',
                        isActive: detailsState.selectedBottomNavIndex == 1,
                        onTap:
                            () => ref
                                .read(
                                  propertyDetailsProvider((
                                    propertyId: widget.propertyId,
                                    tabController: _tabController,
                                  )).notifier,
                                )
                                .onBottomNavTap(1),
                      ),
                      _buildBottomNavItem(
                        context,
                        icon: Icons.people_outline,
                        activeIcon: Icons.people,
                        label: 'Tenants',
                        isActive: detailsState.selectedBottomNavIndex == 2,
                        onTap:
                            () => ref
                                .read(
                                  propertyDetailsProvider((
                                    propertyId: widget.propertyId,
                                    tabController: _tabController,
                                  )).notifier,
                                )
                                .onBottomNavTap(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        loading: () => SizedBox.shrink(),
        error: (_, __) => SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
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

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabTitles;
  final List<IconData> tabIcons;
  final BuildContext context;

  _StickyTabBarDelegate({
    required this.tabController,
    required this.tabTitles,
    required this.tabIcons,
    required this.context,
  });

  @override
  double get minExtent => 64.0;

  @override
  double get maxExtent => 64.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      height: 64.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.smallPadding(context),
          vertical: AppSizes.smallPadding(context),
        ),
        child: Row(
          children:
              tabTitles.asMap().entries.map((entry) {
                final index = entry.key;
                final title = entry.value;
                final isSelected = tabController.index == index;

                return Padding(
                  padding: EdgeInsets.only(
                    right: AppSizes.smallPadding(context),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius(context),
                      ),
                      onTap: () {
                        tabController.animateTo(index);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.smallPadding(context) + 5,
                          vertical: AppSizes.smallPadding(context) + 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius(context),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: isSelected ? 12 : 8,
                              offset: Offset(0, isSelected ? 4 : 2),
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tabIcons[index],
                              size: AppSizes.smallIcon(context),
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                            ),
                            SizedBox(width: AppSizes.smallPadding(context)),
                            Text(
                              title,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                fontSize: AppSizes.smallText(context) - 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
