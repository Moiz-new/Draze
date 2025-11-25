import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../providers/SellerVisitorsDashboardProvider.dart';

class SellerVisitorsDashboard extends StatefulWidget {
  const SellerVisitorsDashboard({Key? key}) : super(key: key);

  @override
  State<SellerVisitorsDashboard> createState() =>
      _SellerVisitorsDashboardState();
}

class _SellerVisitorsDashboardState extends State<SellerVisitorsDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerVisitorsDashboardProvider>().fetchVisitorsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: Text(
              'Visitors Dashboard',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: Consumer<SellerVisitorsDashboardProvider>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: provider.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error handling
                      if (provider.error != null) ...[
                        _buildErrorCard(provider),
                        SizedBox(height: 20.h),
                      ],

                      // Total visitors card
                      _buildTotalCard(provider),
                      SizedBox(height: 20.h),

                      // Status section
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Status grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 1.2,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push('/all_visitors', extra: "Pending");
                            },
                            child: _buildStatusCard(
                              'Pending',
                              provider.pendingCount.toString(),
                              AppColors.warning,
                              Icons.hourglass_empty,
                              provider.isLoading,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push('/all_visitors', extra: "Confirmed");
                            },
                            child: _buildStatusCard(
                              'Confirmed',
                              provider.confirmedCount.toString(),
                              AppColors.primary,
                              Icons.check_circle_outline,
                              provider.isLoading,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push('/all_visitors', extra: "Completed");
                            },
                            child: _buildStatusCard(
                              'Completed',
                              provider.completedCount.toString(),
                              AppColors.success,
                              Icons.done_all,
                              provider.isLoading,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push('/all_visitors', extra: "Cancelled");
                            },
                            child: _buildStatusCard(
                              'Cancelled',
                              provider.cancelledCount.toString(),
                              AppColors.error,
                              Icons.cancel_outlined,
                              provider.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(SellerVisitorsDashboardProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            provider.error!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.error),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () {
              provider.clearError();
              provider.fetchVisitorsData();
            },
            child: Text(
              'Retry',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(SellerVisitorsDashboardProvider provider) {
    return GestureDetector(
      onTap: () {
        context.push('/all_visitors', extra: "All");
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.people_outline,
                color: AppColors.primary,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Visitors',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  provider.isLoading
                      ? _buildShimmerText(32.sp)
                      : Text(
                        provider.totalVisits?.toString() ?? '0',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String count,
    Color color,
    IconData icon,
    bool isLoading,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.w),
              ),
              isLoading
                  ? _buildShimmerText(24.sp)
                  : Text(
                    count,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerText(double fontSize) {
    return Container(
      width: 40.w,
      height: fontSize,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
