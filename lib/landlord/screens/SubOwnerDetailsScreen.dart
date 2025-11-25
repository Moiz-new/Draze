import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/api_constants.dart';
import '../../core/constants/appColors.dart';

// Sub-Owner Details Screen
class SubOwnerDetailsScreen extends StatelessWidget {
  final dynamic subOwner;

  const SubOwnerDetailsScreen({Key? key, required this.subOwner})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assignedProperties = subOwner['assignedProperties'] as List? ?? [];
    final permissions = subOwner['permissions'] as List? ?? [];
    final createdDate = subOwner['createdAt'] != null
        ? DateTime.tryParse(subOwner['createdAt']) ?? DateTime.now()
        : DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    // Profile Photo
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: subOwner['profilePhoto'] != null
                            ? Image.network(
                          '$base_url+${subOwner['profilePhoto']}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      subOwner['name']?.toString() ?? 'N/A',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        assignedProperties.isNotEmpty ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Information Card
                  _buildSectionCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: subOwner['email']?.toString() ?? 'N/A',
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Mobile',
                          value: subOwner['mobile']?.toString() ?? 'N/A',
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Created Date',
                          value:
                          '${createdDate.day}/${createdDate.month}/${createdDate.year}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Assigned Properties Card
                  if (assignedProperties.isNotEmpty)
                    _buildSectionCard(
                      title: 'Assigned Properties (${assignedProperties.length})',
                      icon: Icons.home_work,
                      child: Column(
                        children: assignedProperties.map((property) {
                          // Null checks for property data
                          if (property == null) return SizedBox.shrink();

                          final prop = property['property'];
                          if (prop == null) return SizedBox.shrink();

                          final status = property['status']?.toString() ?? 'N/A';

                          final agreementStart = property['agreementStartDate'] != null
                              ? DateTime.tryParse(property['agreementStartDate']) ?? DateTime.now()
                              : DateTime.now();

                          final agreementEnd = property['agreementEndDate'] != null
                              ? DateTime.tryParse(property['agreementEndDate']) ?? DateTime.now()
                              : DateTime.now();

                          final duration = property['agreementDuration'] as Map<String, dynamic>? ?? {};

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Icon(
                                        prop['type']?.toString() == 'Hostel'
                                            ? Icons.apartment
                                            : Icons.home,
                                        size: 24.sp,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prop['name']?.toString() ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            prop['type']?.toString() ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == 'Active'
                                            ? AppColors.success.withOpacity(0.1)
                                            : AppColors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: status == 'Active'
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Divider(
                                    color: AppColors.divider.withOpacity(0.5),
                                    height: 1),
                                SizedBox(height: 12.h),
                                _buildPropertyDetail(
                                  icon: Icons.location_on_outlined,
                                  text:
                                  '${prop['address']?.toString() ?? 'N/A'}, ${prop['city']?.toString() ?? 'N/A'} - ${prop['pinCode']?.toString() ?? 'N/A'}',
                                ),
                                SizedBox(height: 8.h),
                                _buildPropertyDetail(
                                  icon: Icons.access_time,
                                  text:
                                  'Agreement: ${duration['years']?.toString() ?? '0'}Y ${duration['months']?.toString() ?? '0'}M',
                                ),
                                SizedBox(height: 8.h),
                                _buildPropertyDetail(
                                  icon: Icons.calendar_month,
                                  text:
                                  'Start: ${agreementStart.day}/${agreementStart.month}/${agreementStart.year}',
                                ),
                                SizedBox(height: 8.h),
                                _buildPropertyDetail(
                                  icon: Icons.event,
                                  text:
                                  'End: ${agreementEnd.day}/${agreementEnd.month}/${agreementEnd.year}',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  if (assignedProperties.isEmpty)
                    _buildSectionCard(
                      title: 'Assigned Properties',
                      icon: Icons.home_work,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 48.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'No properties assigned yet',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // Permissions Card
                  _buildSectionCard(
                    title: 'Permissions (${permissions.length})',
                    icon: Icons.verified_user,
                    child: permissions.isEmpty
                        ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Text(
                          'No permissions assigned',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                        : Column(
                      children: permissions.map<Widget>((permission) {
                        if (permission == null) return SizedBox.shrink();

                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20.sp,
                                color: AppColors.success,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      permission['name']?.toString() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (permission['description'] != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        permission['description'].toString(),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final name = subOwner['name']?.toString() ?? '';
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetail({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'Delete Sub-Owner',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this sub-owner? This action cannot be undone.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Delete functionality
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}