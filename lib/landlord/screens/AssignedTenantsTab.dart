import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/constants/appColors.dart';
import '../models/VerificationRegionModel.dart';
import '../providers/VerificationProvider.dart';

class AssignedTenantsTab extends StatefulWidget {
  const AssignedTenantsTab({Key? key}) : super(key: key);

  @override
  State<AssignedTenantsTab> createState() => _AssignedTenantsTabState();
}

class _AssignedTenantsTabState extends State<AssignedTenantsTab> {
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

        if (verificationProvider.errorMessage != null) {
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                Icons.people,
                                'Total Tenants',
                                _assignedTenants.length.toString(),
                                AppColors.primary,
                              ),
                              Container(
                                width: 1,
                                height: 40.h,
                                color: AppColors.divider,
                              ),
                              _buildStatItem(
                                Icons.pending_actions,
                                'Under Review',
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

                        // Tenants List
                        Text(
                          'Assigned Tenants',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _assignedTenants.length,
                          itemBuilder: (context, index) {
                            final tenant = _assignedTenants[index];
                            return _buildAssignedTenantCard(tenant);
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
    );
  }

  Widget _buildAssignedTenantCard(AssignedTenant tenant) {
    Color statusColor;
    String statusText;

    switch (tenant.status) {
      case 'verified':
        statusColor = AppColors.success;
        statusText = 'Verified';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusText = 'Rejected';
        break;
      case 'under_review':
      default:
        statusColor = AppColors.warning;
        statusText = 'Under Review';
    }

    // Get tenant name initials
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
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    getInitials(),
                    style: TextStyle(
                      fontSize: 16.sp,
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
                        tenant.tenant?.name ?? 'Unknown Tenant',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tenant.tenant?.email != null && tenant.tenant!.email.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.email,
                    'Email',
                    tenant.tenant!.email,
                  ),
                  SizedBox(height: 8.h),
                ],
                if (tenant.tenant?.mobile != null && tenant.tenant!.mobile.isNotEmpty) ...[
                  _buildDetailRow(
                    Icons.phone,
                    'Mobile',
                    tenant.tenant!.mobile,
                  ),
                  SizedBox(height: 8.h),
                ],
                _buildDetailRow(
                  Icons.calendar_today,
                  'Created',
                  _formatDate(tenant.createdAt),
                ),
                if (tenant.documents.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Divider(color: AppColors.divider),
                  SizedBox(height: 12.h),
                  Text(
                    'Documents (${tenant.documents.length})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...tenant.documents.map(
                        (doc) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              doc.name,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class AssignedTenant {
  final String id;
  final String tenantId;
  final String regionId;
  final String landlordId;
  final String status;
  final String assignedRole;
  final List<DocumentInfo> documents;
  final String policeReportUrl;
  final String remarks;
  final String? verifiedAt;
  final List<dynamic> tenantdocuments;
  final String createdAt;
  final String updatedAt;
  final TenantInfo? tenant;

  AssignedTenant({
    required this.id,
    required this.tenantId,
    required this.regionId,
    required this.landlordId,
    required this.status,
    required this.assignedRole,
    required this.documents,
    required this.policeReportUrl,
    required this.remarks,
    this.verifiedAt,
    required this.tenantdocuments,
    required this.createdAt,
    required this.updatedAt,
    this.tenant,
  });

  factory AssignedTenant.fromJson(Map<String, dynamic> json) {
    // Debug print
    print('Parsing AssignedTenant: ${json['tenantId']}');
    print('Tenant data: ${json['tenant']}');

    TenantInfo? tenantInfo;
    if (json['tenant'] != null) {
      try {
        if (json['tenant'] is Map<String, dynamic>) {
          tenantInfo = TenantInfo.fromJson(json['tenant'] as Map<String, dynamic>);
        }
      } catch (e) {
        print('Error parsing tenant info: $e');
      }
    }

    return AssignedTenant(
      id: json['_id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      regionId: json['regionId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      status: json['status'] ?? 'unknown',
      assignedRole: json['assignedRole'] ?? 'Unknown',
      documents: (json['documents'] as List?)
          ?.map((doc) => DocumentInfo.fromJson(doc))
          .toList() ??
          [],
      policeReportUrl: json['policeReportUrl'] ?? '',
      remarks: json['remarks'] ?? '',
      verifiedAt: json['verifiedAt'],
      tenantdocuments: json['tenantdocuments'] ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      tenant: tenantInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tenantId': tenantId,
      'regionId': regionId,
      'landlordId': landlordId,
      'status': status,
      'assignedRole': assignedRole,
      'documents': documents.map((doc) => doc.toJson()).toList(),
      'policeReportUrl': policeReportUrl,
      'remarks': remarks,
      'verifiedAt': verifiedAt,
      'tenantdocuments': tenantdocuments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tenant': tenant?.toJson(),
    };
  }
}

class TenantInfo {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String tenantId;

  TenantInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.tenantId,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      tenantId: json['tenantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'tenantId': tenantId,
    };
  }
}

class DocumentInfo {
  final String name;
  final String fileUrl;
  final String uploadedBy;
  final String uploadedByModel;
  final String uploadedAt;
  final String id;

  DocumentInfo({
    required this.name,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedByModel,
    required this.uploadedAt,
    required this.id,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      name: json['name'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      uploadedBy: json['uploadedBy'] ?? '',
      uploadedByModel: json['uploadedByModel'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploadedByModel': uploadedByModel,
      'uploadedAt': uploadedAt,
      '_id': id,
    };
  }
}