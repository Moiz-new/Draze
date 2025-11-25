import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/constants/appColors.dart';
import '../models/VerificationRegionModel.dart';
import '../providers/VerificationProvider.dart';
import 'AssignedTenantsTab.dart';
import 'TenantDocumentsScreen.dart';

class AssignedTenantsListTab extends StatefulWidget {
  const AssignedTenantsListTab({Key? key}) : super(key: key);

  @override
  State<AssignedTenantsListTab> createState() => _AssignedTenantsListTabState();
}

class _AssignedTenantsListTabState extends State<AssignedTenantsListTab> {
  VerificationRegion? _selectedRegion;
  List<AssignedTenant> _assignedTenants = [];
  bool _isLoadingTenants = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerificationProvider>().fetchVerifications();
    });
  }

  Future<void> _fetchAssignedTenants() async {
    if (_selectedRegion == null) {
      setState(() {
        _errorMessage = 'Please select a region first';
      });
      return;
    }

    setState(() {
      _isLoadingTenants = true;
      _errorMessage = null;
      _assignedTenants = [];
    });

    final verificationProvider = context.read<VerificationProvider>();
    final landlordData = verificationProvider.landlordData;

    // First link the landlord to region if not already linked
    if (landlordData == null || landlordData.regionId != _selectedRegion!.id) {
      final linkSuccess = await verificationProvider.linkLandlordToRegion(
        _selectedRegion!.id,
      );

      if (!linkSuccess) {
        setState(() {
          _errorMessage =
              verificationProvider.errorMessage ?? 'Failed to link region';
          _isLoadingTenants = false;
        });
        return;
      }
    }

    // Now fetch assigned tenants
    final linkedLandlord = verificationProvider.landlordData;
    if (linkedLandlord == null) {
      setState(() {
        _errorMessage = 'Failed to get landlord information';
        _isLoadingTenants = false;
      });
      return;
    }

    final result = await verificationProvider.fetchAssignedTenants(
      landlordId: linkedLandlord.id,
      regionId: _selectedRegion!.id,
    );

    setState(() {
      if (result['success'] == true) {
        _assignedTenants =
            (result['data'] as List)
                .map((item) => AssignedTenant.fromJson(item))
                .toList();
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch tenants';
        _assignedTenants = [];
      }
      _isLoadingTenants = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationProvider>(
      builder: (context, verificationProvider, child) {
        if (verificationProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading regions...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (verificationProvider.errorMessage != null &&
            _selectedRegion == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    verificationProvider.errorMessage ?? 'An error occurred',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    verificationProvider.fetchVerifications();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await verificationProvider.fetchVerifications();
            if (_selectedRegion != null) {
              await _fetchAssignedTenants();
            }
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Region Selection
                  Text(
                    'Select Region',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<VerificationRegion>(
                      value: _selectedRegion,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                        hintText: 'Choose a region',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 28.sp,
                      ),
                      dropdownColor: AppColors.surface,
                      items:
                          verificationProvider.regions.map((region) {
                            return DropdownMenuItem<VerificationRegion>(
                              value: region,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      region.code,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      region.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value;
                          _assignedTenants = [];
                          _errorMessage = null;
                        });
                        // Automatically fetch tenants when region is selected
                        if (value != null) {
                          _fetchAssignedTenants();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Loading Indicator
                  if (_isLoadingTenants)
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3.w,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading tenants...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Results Section
                  if (!_isLoadingTenants) ...[
                    if (_errorMessage != null)
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_assignedTenants.isEmpty &&
                        _selectedRegion != null)
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 40.h),
                            Icon(
                              Icons.people_outline,
                              size: 64.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No tenants assigned to this region',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_assignedTenants.isNotEmpty) ...[
                      // Stats Card
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              Icons.people,
                              'Total',
                              _assignedTenants.length.toString(),
                              AppColors.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40.h,
                              color: AppColors.divider,
                            ),
                            _buildStatItem(
                              Icons.check_circle,
                              'Verified',
                              _assignedTenants
                                  .where((t) => t.status == 'verified')
                                  .length
                                  .toString(),
                              AppColors.success,
                            ),
                            Container(
                              width: 1,
                              height: 40.h,
                              color: AppColors.divider,
                            ),
                            _buildStatItem(
                              Icons.pending,
                              'Pending',
                              _assignedTenants
                                  .where((t) => t.status == 'under_review')
                                  .length
                                  .toString(),
                              AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Tenants List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assigned Tenants',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '${_assignedTenants.length} Total',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Tenants List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _assignedTenants.length,
                        itemBuilder: (context, index) {
                          final tenant = _assignedTenants[index];
                          return _buildTenantCard(tenant);
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24.sp, color: color),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTenantCard(AssignedTenant tenant) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (tenant.status) {
      case 'verified':
        statusColor = AppColors.success;
        statusText = 'Verified';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      case 'under_review':
      default:
        statusColor = AppColors.warning;
        statusText = 'Under Review';
        statusIcon = Icons.pending;
    }

    String getInitials() {
      if (tenant.tenant != null && tenant.tenant!.name.isNotEmpty) {
        final names = tenant.tenant!.name.split(' ');
        if (names.length >= 2) {
          return '${names[0][0]}${names[1][0]}'.toUpperCase();
        }
        return tenant.tenant!.name.substring(0, 2).toUpperCase();
      }
      return tenant.tenantId.substring(0, 2).toUpperCase();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            // Navigate to details if needed
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          getInitials(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Tenant Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.tenant?.name ?? 'Unknown Tenant',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            tenant.tenantId,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14.sp, color: statusColor),
                          SizedBox(width: 4.w),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Contact Info
                if (tenant.tenant?.mobile != null &&
                    tenant.tenant!.mobile.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          tenant.tenant!.mobile,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (tenant.tenant?.email != null &&
                    tenant.tenant!.email.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            tenant.tenant!.email,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Document Count and Date
                Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${tenant.documents.length} Documents',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatDate(tenant.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                Divider(color: AppColors.divider, height: 1),
                SizedBox(height: 12.h),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  TenantDocumentsScreen(tenant: tenant),
                        ),
                      );
                    },
                    icon: Icon(Icons.description, size: 20.sp),
                    label: Text(
                      'View Documents',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
