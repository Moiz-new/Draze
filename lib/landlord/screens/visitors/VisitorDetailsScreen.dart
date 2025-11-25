import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../models/VisitorModel.dart';

class VisitorDetailsScreen extends StatelessWidget {
  final VisitorModel visitor;

  const VisitorDetailsScreen({Key? key, required this.visitor})
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
                  _buildPropertyInfoCard(),
                  SizedBox(height: 20.h),
                  _buildVisitDetailsCard(),
                  SizedBox(height: 20.h),
                  if (visitor.feedback != null) ...[
                    _buildFeedbackCard(),
                    SizedBox(height: 20.h),
                  ],
                  if (visitor.status.toLowerCase() == 'cancelled') ...[
                    _buildCancellationCard(),
                    SizedBox(height: 20.h),
                  ],
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
                    visitor.landlordId!.name,
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
            visitor.statusText,
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
          _buildInfoRow('Name', visitor.landlordId!.name, Icons.account_circle),
          SizedBox(height: 16.h),
          _buildInfoRow('Mobile', visitor.landlordId!.mobile, Icons.phone),
          SizedBox(height: 16.h),
          _buildInfoRow('Email', visitor.landlordId!.email, Icons.email),
        ],
      ),
    );
  }

  Widget _buildPropertyInfoCard() {
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
            'Visit Date & Time',
            DateFormat(
              'EEEE, MMM dd, yyyy • hh:mm a',
            ).format(visitor.visitDate),
            Icons.access_time,
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            'Visit Type',
            visitor.isUpcoming ? 'Upcoming Visit' : 'Past Visit',
            visitor.isUpcoming ? Icons.schedule : Icons.history,
          ),
          if (visitor.notes.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildInfoRow('Notes', visitor.notes, Icons.note_alt),
          ],
          if (visitor.completionNotes != null &&
              visitor.completionNotes!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildInfoRow(
              'Completion Notes',
              visitor.completionNotes!,
              Icons.check_circle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
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
                Icons.rate_review_rounded,
                color: const Color(0xFF10B981),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.feedback!.comment,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14.w,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Given on ${DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.feedback!.givenAt)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationCard() {
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
                Icons.cancel_rounded,
                color: const Color(0xFFEF4444),
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Cancellation Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (visitor.cancellationReason != null) ...[
            _buildInfoRow('Reason', visitor.cancellationReason!, Icons.info),
            SizedBox(height: 16.h),
          ],
          if (visitor.cancelledAt != null) ...[
            _buildInfoRow(
              'Cancelled On',
              DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.cancelledAt!),
              Icons.schedule,
            ),
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
            'Visit Requested',
            DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.createdAt),
            Icons.add_circle,
            const Color(0xFF6366F1),
            true,
          ),
          if (visitor.confirmedAt != null)
            _buildTimelineItem(
              'Visit Confirmed',
              DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.confirmedAt!),
              Icons.check_circle,
              const Color(0xFF10B981),
              visitor.completedAt != null || visitor.cancelledAt != null,
            ),
          if (visitor.completedAt != null)
            _buildTimelineItem(
              'Visit Completed',
              DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.completedAt!),
              Icons.task_alt,
              const Color(0xFF10B981),
              false,
            ),
          if (visitor.cancelledAt != null)
            _buildTimelineItem(
              'Visit Cancelled',
              DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.cancelledAt!),
              Icons.cancel,
              const Color(0xFFEF4444),
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
    switch (visitor.status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFEAB308);
      case 'confirmed':
        return const Color(0xFF6366F1);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon() {
    switch (visitor.status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusDescription() {
    switch (visitor.status.toLowerCase()) {
      case 'pending':
        return 'Awaiting confirmation';
      case 'confirmed':
        return 'Visit confirmed';
      case 'completed':
        return 'Visit completed successfully';
      case 'cancelled':
        return 'Visit was cancelled';
      default:
        return 'Unknown status';
    }
  }
}
