import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/constants/appColors.dart';
import '../models/VerificationRegionModel.dart';
import '../providers/VerificationProvider.dart';
import '../providers/AllTenantListProvider.dart';

class AssignRegionTab extends StatefulWidget {
  const AssignRegionTab({Key? key}) : super(key: key);

  @override
  State<AssignRegionTab> createState() => _AssignRegionTabState();
}

class _AssignRegionTabState extends State<AssignRegionTab>
    with AutomaticKeepAliveClientMixin {
  final Map<String, VerificationRegion?> _selectedRegionsPerTenant = {};
  final Set<String> _selectedTenantIds = {};
  VerificationRegion? _bulkSelectedRegion;
  bool _isSelectAllMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerificationProvider>().fetchVerifications();
      context.read<AllTenantListProvider>().fetchTenants();
    });
  }

  void _toggleSelectAll(List<AllTenantListModel> tenants) {
    setState(() {
      if (_selectedTenantIds.length == tenants.length) {
        _selectedTenantIds.clear();
      } else {
        // Changed: Use tenantId instead of id
        _selectedTenantIds.addAll(tenants.map((t) => t.tenantId));
      }
    });
  }

  void _toggleTenantSelection(String tenantId) {
    setState(() {
      if (_selectedTenantIds.contains(tenantId)) {
        _selectedTenantIds.remove(tenantId);
      } else {
        _selectedTenantIds.add(tenantId);
      }
    });
  }

  Future<void> _handleAssignRegion(AllTenantListModel tenant) async {
    // Changed: Use tenantId as key instead of id
    final selectedRegion = _selectedRegionsPerTenant[tenant.tenantId];

    if (selectedRegion == null) {
      _showSnackBar('Please select a region first', AppColors.error);
      return;
    }

    await _linkAndAssignRegion(
      [tenant.tenantId],
      selectedRegion,
      'Assigning region to ${tenant.name}...',
    );
  }

  Future<void> _handleBulkAssign() async {
    if (_selectedTenantIds.isEmpty) {
      _showSnackBar('Please select at least one tenant', AppColors.error);
      return;
    }

    if (_bulkSelectedRegion == null) {
      _showSnackBar(
        'Please select a region for bulk assignment',
        AppColors.error,
      );
      return;
    }

    await _linkAndAssignRegion(
      _selectedTenantIds.toList(),
      _bulkSelectedRegion!,
      'Assigning region to ${_selectedTenantIds.length} tenant(s)...',
    );
  }

  Future<void> _linkAndAssignRegion(
      List<String> tenantIds,
      VerificationRegion region,
      String loadingMessage,
      ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3.w,
              ),
              SizedBox(height: 16.h),
              Text(
                'Linking landlord to region...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Step 1: Link landlord to region
    final verificationProvider = context.read<VerificationProvider>();
    final linkSuccess =
    await verificationProvider.linkLandlordToRegion(region.id);

    if (!linkSuccess) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        _showSnackBar(
          verificationProvider.errorMessage ?? 'Failed to link region',
          AppColors.error,
        );
      }
      return;
    }

    // Get the linked landlord data
    final landlordData = verificationProvider.landlordData;

    if (landlordData == null) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        _showSnackBar(
          'Failed to retrieve landlord data',
          AppColors.error,
        );
      }
      return;
    }

    // Update loading message
    if (mounted) {
      Navigator.pop(context); // Close first dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  loadingMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Step 2: Assign region to tenants using the landlord ID from the linked data
    final result = await verificationProvider.assignRegionToTenants(
      landlordId: landlordData.id,
      regionId: region.id,
      tenantIds: tenantIds,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    // Show result message
    if (mounted) {
      if (result['success'] == true) {
        _showSnackBar(
          result['message'] ?? 'Region assigned successfully!',
          AppColors.success,
        );

        // Clear selections after successful assignment
        if (tenantIds.length > 1) {
          setState(() {
            _selectedTenantIds.clear();
            _bulkSelectedRegion = null;
          });
        } else {
          // Clear individual selection
          setState(() {
            _selectedRegionsPerTenant.remove(tenantIds.first);
          });
        }
      } else {
        _showSnackBar(
          result['message'] ?? 'Failed to assign region',
          AppColors.error,
        );
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<VerificationProvider, AllTenantListProvider>(
      builder: (context, verificationProvider, tenantProvider, child) {
        if (verificationProvider.isLoading || tenantProvider.isLoading) {
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
                  'Loading data...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (verificationProvider.errorMessage != null ||
            tenantProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: AppColors.error,
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    verificationProvider.errorMessage ??
                        tenantProvider.error ??
                        'An error occurred',
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
                    tenantProvider.fetchTenants();
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

        final tenants = tenantProvider.activeTenants;

        return Column(
          children: [
            // Bulk Assignment Section
            if (_isSelectAllMode && tenants.isNotEmpty)
              Container(
                color: AppColors.primary.withOpacity(0.1),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _selectedTenantIds.length == tenants.length,
                          onChanged: (_) => _toggleSelectAll(tenants),
                          activeColor: AppColors.primary,
                        ),
                        Text(
                          'Select All (${_selectedTenantIds.length}/${tenants.length})',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          color: AppColors.error,
                          onPressed: () {
                            setState(() {
                              _isSelectAllMode = false;
                              _selectedTenantIds.clear();
                              _bulkSelectedRegion = null;
                            });
                          },
                          tooltip: 'Cancel Selection',
                        ),
                      ],
                    ),
                    if (_selectedTenantIds.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonFormField<VerificationRegion>(
                          value: _bulkSelectedRegion,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            hintText: 'Select region for all',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          dropdownColor: AppColors.surface,
                          items: verificationProvider.regions.map((region) {
                            return DropdownMenuItem<VerificationRegion>(
                              value: region,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      region.code,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      region.name,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _bulkSelectedRegion = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 44.h,
                        child: ElevatedButton.icon(
                          onPressed: _bulkSelectedRegion != null
                              ? _handleBulkAssign
                              : null,
                          icon: Icon(Icons.done_all, size: 20.sp),
                          label: Text(
                            'Assign to ${_selectedTenantIds.length} Tenant(s)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.disabled,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await verificationProvider.fetchVerifications();
                  await tenantProvider.fetchTenants();
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 48.sp,
                                color: Colors.white,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Assign Regions',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Assign verification regions to tenants',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Action Button
                        if (!_isSelectAllMode)
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isSelectAllMode = true;
                                });
                              },
                              icon: Icon(Icons.checklist, size: 24.sp),
                              label: Text(
                                'Select Multiple Tenants',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 24.h),

                        // Stats Card
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Tenants',
                                tenants.length.toString(),
                                Icons.people,
                                AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildStatCard(
                                'Regions Available',
                                verificationProvider.regions.length.toString(),
                                Icons.location_city,
                                AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Tenants List
                        Text(
                          'Active Tenants',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        if (tenants.isEmpty)
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
                                  'No active tenants found',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tenants.length,
                            itemBuilder: (context, index) {
                              final tenant = tenants[index];
                              return _buildTenantCard(
                                tenant,
                                verificationProvider.regions,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32.sp, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantCard(
      AllTenantListModel tenant,
      List<VerificationRegion> regions,
      ) {
    final accommodation = tenant.activeAccommodation;
    // Changed: Use tenantId instead of id for selection check
    final isSelected = _selectedTenantIds.contains(tenant.tenantId);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: _isSelectAllMode && isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
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
        children: [
          // Tenant Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _isSelectAllMode && isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                if (_isSelectAllMode)
                  Checkbox(
                    value: isSelected,
                    // Changed: Pass tenantId instead of id
                    onChanged: (_) => _toggleTenantSelection(tenant.tenantId),
                    activeColor: AppColors.primary,
                  ),
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : 'T',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ${tenant.tenantId}',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tenant Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.phone, 'Mobile', tenant.mobile),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.email, 'Email', tenant.email),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.work, 'Work', tenant.work),
                if (accommodation != null) ...[
                  SizedBox(height: 8.h),
                  _buildDetailRow(
                    Icons.home,
                    'Property',
                    accommodation.propertyName,
                  ),
                  SizedBox(height: 8.h),
                  _buildDetailRow(
                    Icons.meeting_room,
                    'Room',
                    accommodation.roomId,
                  ),
                ],

                // Show individual assignment only when not in select all mode
                if (!_isSelectAllMode) ...[
                  SizedBox(height: 16.h),
                  Divider(color: AppColors.divider, height: 1),
                  SizedBox(height: 16.h),

                  // Region Selection
                  Text(
                    'Assign Region',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: DropdownButtonFormField<VerificationRegion>(
                      // Changed: Use tenantId as key instead of id
                      value: _selectedRegionsPerTenant[tenant.tenantId],
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        hintText: 'Select region',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                      dropdownColor: AppColors.surface,
                      items: regions.map((region) {
                        return DropdownMenuItem<VerificationRegion>(
                          value: region,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  region.code,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  region.name,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          // Changed: Use tenantId as key instead of id
                          _selectedRegionsPerTenant[tenant.tenantId] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Assign Button
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton.icon(
                      // Changed: Use tenantId to check for selected region
                      onPressed: _selectedRegionsPerTenant[tenant.tenantId] != null
                          ? () => _handleAssignRegion(tenant)
                          : null,
                      icon: Icon(Icons.check_circle, size: 20.sp),
                      label: Text(
                        'Assign Region',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.disabled,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
