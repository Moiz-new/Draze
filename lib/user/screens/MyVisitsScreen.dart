import 'package:draze/user/models/MyVisitModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/appColors.dart';
import '../provider/MyVisitsProvider.dart';

class MyVisitsScreen extends StatefulWidget {
  const MyVisitsScreen({Key? key}) : super(key: key);

  @override
  State<MyVisitsScreen> createState() => _MyVisitsScreenState();
}

class _MyVisitsScreenState extends State<MyVisitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitsProvider>().fetchAllVisits();
    });
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
      body: Consumer<VisitsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingWidget();
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider);
          }

          return Column(
            children: [
              _buildTabBar(),
              Expanded(child: _buildTabBarView(provider)),
            ],
          );
        },
      ),
    );
  }


  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 1),
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
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
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
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          tabs: [
            Tab(
              child: Container(
                alignment: Alignment.center,
                height: 40.h,
                child: const Text('All'),
              ),
            ),
            Tab(
              child: Container(
                alignment: Alignment.center,
                height: 40.h,
                child: const Text('Upcoming'),
              ),
            ),
            Tab(
              child: Container(
                alignment: Alignment.center,
                height: 40.h,
                child: const Text('Past'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView(VisitsProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildVisitsList(provider.visits),
        _buildVisitsList(provider.upcomingVisits),
        _buildVisitsList(provider.pastVisits),
      ],
    );
  }

  Widget _buildVisitsList(List<MyVisitModel> visits) {
    if (visits.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<VisitsProvider>().refreshVisits(),
      color: AppColors.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Check if we've scrolled to the bottom
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.extentAfter == 0) {
            // Load more data when reaching the bottom
            context.read<VisitsProvider>().loadMoreVisits();
          }
          return false;
        },
        child: Consumer<VisitsProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: visits.length + (provider.hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == visits.length) {
                  return provider.isLoadingMore
                      ? _buildLoadMoreIndicator()
                      : const SizedBox.shrink();
                }

                return _buildVisitCard(visits[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildVisitCard(MyVisitModel visit) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  visit.displayTitle, // Using displayTitle getter from model
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStatusChip(visit.status),
            ],
          ),
          SizedBox(height: 8.h),
          // Property info (if you have property details in your API response)
          if (visit.propertyId.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.textSecondary,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Property ID: ${visit.propertyId}',
                    // You can modify this based on actual property data
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],

          // Visit date info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.primary, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      visit.displayDate, // Using displayDate getter from model
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (visit.notes.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    visit.notes,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Visitor info
          if (visit.hasVisitorInfo) ...[
            Row(
              children: [
                Icon(Icons.person, color: AppColors.textSecondary, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (visit.mobile != null)
                        Text(
                          visit.mobile!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (visit.isUpcoming && visit.mobile != null)
                  ElevatedButton.icon(
                    onPressed: () => _callNumber(visit.mobile!),
                    icon: Icon(Icons.call, size: 16.sp),
                    label: Text('Call', style: TextStyle(fontSize: 12.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(80.w, 32.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
          ],

          // Landlord info (if available)
          if (visit.landlordId != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Landlord ID: ${visit.landlordId}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Additional info row
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (visit.purpose != null)
                Chip(
                  label: Text(
                    visit.purpose!,
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                ),
              Text(
                'Updated: ${_formatDateTime(visit.updatedAt)}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = AppColors.warning;
        displayText = 'Pending';
        break;
      case 'confirmed':
        chipColor = AppColors.success;
        displayText = 'Confirmed';
        break;
      case 'scheduled':
        chipColor = AppColors.primary;
        displayText = 'Scheduled';
        break;
      case 'cancelled':
        chipColor = AppColors.error;
        displayText = 'Cancelled';
        break;
      case 'completed':
        chipColor = AppColors.success.withOpacity(0.7);
        displayText = 'Completed';
        break;
      default:
        chipColor = AppColors.disabled;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading visits...',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(VisitsProvider provider) {
    print(provider.error);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Oops! No Visits',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: provider.refreshVisits,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80.sp,
              color: AppColors.disabled,
            ),
            SizedBox(height: 16.h),
            Text(
              'No visits found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your visit history will appear here',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle error - maybe show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone app'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
