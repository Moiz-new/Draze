import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../models/SellerVisitorModel.dart';

class SellerVisitorDetailsScreen extends StatelessWidget {
  final SellerVisitorModel visitor;

  const SellerVisitorDetailsScreen({Key? key, required this.visitor})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  SizedBox(height: 20.h),
                  _buildVisitorInfoCard(),
                  SizedBox(height: 20.h),
                  if (visitor.propertyId != null) ...[
                    _buildPropertyInfoCard(),
                    SizedBox(height: 20.h),
                  ],
                  if (visitor.userId != null) ...[
                    _buildUserInfoCard(),
                    SizedBox(height: 20.h),
                  ],
                  _buildVisitDetailsCard(),
                  SizedBox(height: 20.h),
                  _buildTimelineCard(),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, size: 20.w, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_getStatusColor().withOpacity(0.8), _getStatusColor()],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(60.w, 20.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Visit Details',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    visitor.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getStatusColor().withOpacity(0.8), _getStatusColor()],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(), color: Colors.white, size: 36.w),
          ),
          SizedBox(height: 16.h),
          Text(
            visitor.status,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _getStatusDescription(),
              style: TextStyle(
                fontSize: 14.sp,
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorInfoCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: const Color(0xFF6366F1),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Visitor Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow('Name', visitor.name, Icons.account_circle),
          SizedBox(height: 16.h),
          _buildInfoRow('Mobile', visitor.mobile, Icons.phone),
          if (visitor.email != null && visitor.email!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildInfoRow('Email', visitor.email!, Icons.email),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    if (visitor.userId == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_rounded,
                color: const Color(0xFF8B5CF6),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Registered User',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow('User Email', visitor.userId!.email, Icons.email),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoCard() {
    if (visitor.propertyId == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_rounded,
                color: const Color(0xFF6366F1),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Property Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            'Property Name',
            visitor.propertyId!.name,
            Icons.business,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'Address',
            visitor.propertyId!.address,
            Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDetailsCard() {
    final bool isUpcoming = visitor.scheduledDate.isAfter(DateTime.now());
    final bool isPast = visitor.scheduledDate.isBefore(DateTime.now());

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: const Color(0xFF6366F1),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Visit Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            'Scheduled Date & Time',
            DateFormat(
              'EEEE, MMM dd, yyyy • hh:mm a',
            ).format(visitor.scheduledDate),
            Icons.access_time,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'Visit Type',
            isUpcoming ? 'Upcoming Visit' : 'Past Visit',
            isUpcoming ? Icons.schedule : Icons.history,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('Purpose', visitor.purpose, Icons.flag),
          if (visitor.notes.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildInfoRow('Notes', visitor.notes, Icons.note_alt),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: const Color(0xFF6366F1),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildTimelineItem(
            'Visit Scheduled',
            DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.createdAt),
            Icons.add_circle,
            const Color(0xFF6366F1),
            true,
          ),
          _buildTimelineItem(
            'Last Updated',
            DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.updatedAt),
            Icons.update,
            const Color(0xFF8B5CF6),
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    IconData icon,
    Color color,
    bool showLine,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.w, color: color),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showLine) ...[
          SizedBox(height: 12.h),
          Row(
            children: [
              SizedBox(width: 19.w),
              Container(width: 2.w, height: 24.h, color: Colors.grey.shade200),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.w, color: Colors.grey.shade500),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (visitor.status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFEAB308);
      case 'CONFIRMED':
        return const Color(0xFF6366F1);
      case 'COMPLETED':
        return const Color(0xFF10B981);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon() {
    switch (visitor.status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule_rounded;
      case 'CONFIRMED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusDescription() {
    switch (visitor.status.toUpperCase()) {
      case 'PENDING':
        return 'Awaiting confirmation';
      case 'CONFIRMED':
        return 'Visit confirmed';
      case 'CANCELLED':
        return 'Visit was cancelled';
      default:
        return 'Unknown status';
    }
  }
}
