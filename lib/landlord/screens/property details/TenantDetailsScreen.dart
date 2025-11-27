import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/providers/tenant_provider.dart';

class TenantDetailsScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailsScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailsScreen> createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends State<TenantDetailsScreen> {
  TenantDetails? _tenantDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print(widget.tenantId);
    _loadTenantDetails();
  }

  Future<void> _loadTenantDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tenantService = TenantService();
      final details = await tenantService.getTenantDetails(widget.tenantId);
      setState(() {
        _tenantDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(strokeWidth: 1.6.w))
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'Error loading details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              _error ?? 'Unknown error',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _loadTenantDetails,
            icon: Icon(Icons.refresh, size: 20.sp),
            label: Text('Retry', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_tenantDetails == null) return const SizedBox();

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildProfileSection(),
              _buildPersonalInfoSection(),
              _buildFamilyInfoSection(),
              _buildAccommodationSection(),
              _buildElectricitySection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: _tenantDetails!.photo != null
                      ? ClipOval(
                    child: Image.network(
                      _tenantDetails!.photo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 50.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 50.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  _tenantDetails!.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _tenantDetails!.tenantId,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', _tenantDetails!.email),
          Divider(height: 24.h),
          _buildInfoRow(Icons.phone_outlined, 'Mobile', _tenantDetails!.mobile),
          Divider(height: 24.h),
          _buildInfoRow(Icons.work_outline, 'Occupation', _tenantDetails!.work),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.cake_outlined,
            'Date of Birth',
            _formatDate(_tenantDetails!.dob),
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.favorite_border,
            'Marital Status',
            _tenantDetails!.maritalStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.credit_card_outlined,
            'Aadhaar',
            _tenantDetails!.aadhaar,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.home_outlined,
            'Permanent Address',
            _tenantDetails!.permanentAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Family Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.person_outline,
            'Father\'s Name',
            _tenantDetails!.fatherName,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.phone_outlined,
            'Father\'s Mobile',
            _tenantDetails!.fatherMobile,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.person_outline,
            'Mother\'s Name',
            _tenantDetails!.motherName,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.phone_outlined,
            'Mother\'s Mobile',
            _tenantDetails!.motherMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationSection() {
    if (_tenantDetails!.accommodations.isEmpty) return const SizedBox();

    final acc = _tenantDetails!.accommodations.first;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Accommodation Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: acc.isActive ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  acc.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.apartment_outlined, 'Property', acc.propertyName),
          Divider(height: 24.h),
          _buildInfoRow(Icons.meeting_room_outlined, 'Room ID', acc.roomId),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Move In Date',
            _formatDate(acc.moveInDate),
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.currency_rupee,
            'Monthly Rent',
            '₹${acc.rentAmount.toStringAsFixed(0)}',
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.account_balance_wallet_outlined,
            'Security Deposit',
            '₹${acc.securityDeposit.toStringAsFixed(0)}',
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.pending_actions_outlined,
            'Pending Dues',
            '₹${acc.pendingDues.toStringAsFixed(0)}',
            valueColor:
            acc.pendingDues > 0 ? AppColors.error : AppColors.success,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.event_repeat,
            'Rental Frequency',
            acc.rentalFrequency,
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.calendar_month,
            'Rent Date',
            'Day ${acc.rentOnDate}',
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.schedule_outlined,
            'Notice Period',
            '${acc.noticePeriod} days',
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.description_outlined,
            'Agreement Period',
            '${acc.agreementPeriod} ${acc.agreementPeriodType}',
          ),
          if (acc.remarks.isNotEmpty) ...[
            Divider(height: 24.h),
            _buildInfoRow(Icons.notes_outlined, 'Remarks', acc.remarks),
          ],
        ],
      ),
    );
  }

  Widget _buildElectricitySection() {
    if (_tenantDetails!.accommodations.isEmpty) return const SizedBox();

    final electricity = _tenantDetails!.accommodations.first.electricity;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.bolt,
                  color: AppColors.warning,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Electricity Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            Icons.attach_money,
            'Rate per Unit',
            '₹${electricity.perUnit.toStringAsFixed(0)}',
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.speed,
            'Initial Reading',
            '${electricity.initialReading} units',
          ),
          Divider(height: 24.h),
          _buildInfoRow(
            Icons.calendar_today,
            'Reading Date',
            _formatDate(electricity.initialReadingDate),
          ),
          if (electricity.finalReading != null) ...[
            Divider(height: 24.h),
            _buildInfoRow(
              Icons.speed,
              'Final Reading',
              '${electricity.finalReading} units',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

// Model classes for the API response
class TenantDetails {
  final String id;
  final String name;
  final String email;
  final String aadhaar;
  final String mobile;
  final String permanentAddress;
  final String work;
  final String dob;
  final String maritalStatus;
  final String fatherName;
  final String fatherMobile;
  final String motherName;
  final String motherMobile;
  final String? photo;
  final String tenantId;
  final List<Accommodation> accommodations;

  TenantDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.aadhaar,
    required this.mobile,
    required this.permanentAddress,
    required this.work,
    required this.dob,
    required this.maritalStatus,
    required this.fatherName,
    required this.fatherMobile,
    required this.motherName,
    required this.motherMobile,
    this.photo,
    required this.tenantId,
    required this.accommodations,
  });

  factory TenantDetails.fromJson(Map<String, dynamic> json) {
    return TenantDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      aadhaar: json['aadhaar'] ?? 'N/A',
      mobile: json['mobile'] ?? 'N/A',
      permanentAddress: json['permanentAddress'] ?? 'N/A',
      work: json['work'] ?? 'N/A',
      dob: json['dob'] ?? '',
      maritalStatus: json['maritalStatus'] ?? 'N/A',
      fatherName: json['fatherName'] ?? 'N/A',
      fatherMobile: json['fatherMobile'] ?? 'N/A',
      motherName: json['motherName'] ?? 'N/A',
      motherMobile: json['motherMobile'] ?? 'N/A',
      photo: json['photo'],
      tenantId: json['tenantId'] ?? '',
      accommodations: (json['accommodations'] as List?)
          ?.map((acc) => Accommodation.fromJson(acc))
          .toList() ??
          [],
    );
  }
}

class Accommodation {
  final String propertyName;
  final String roomId;
  final String bedId;
  final String moveInDate;
  final String? moveOutDate;
  final double rentAmount;
  final double securityDeposit;
  final double pendingDues;
  final bool isActive;
  final int noticePeriod;
  final int agreementPeriod;
  final String agreementPeriodType;
  final int rentOnDate;
  final String rentalFrequency;
  final String remarks;
  final Electricity electricity;

  Accommodation({
    required this.propertyName,
    required this.roomId,
    required this.bedId,
    required this.moveInDate,
    this.moveOutDate,
    required this.rentAmount,
    required this.securityDeposit,
    required this.pendingDues,
    required this.isActive,
    required this.noticePeriod,
    required this.agreementPeriod,
    required this.agreementPeriodType,
    required this.rentOnDate,
    required this.rentalFrequency,
    required this.remarks,
    required this.electricity,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      propertyName: json['propertyName'] ?? 'N/A',
      roomId: json['roomId'] ?? 'N/A',
      bedId: json['bedId'] ?? '',
      moveInDate: json['moveInDate'] ?? '',
      moveOutDate: json['moveOutDate'],
      rentAmount: (json['rentAmount'] ?? 0).toDouble(),
      securityDeposit: (json['securityDeposit'] ?? 0).toDouble(),
      pendingDues: (json['pendingDues'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      noticePeriod: json['noticePeriod'] ?? 0,
      agreementPeriod: json['agreementPeriod'] ?? 0,
      agreementPeriodType: json['agreementPeriodType'] ?? '',
      rentOnDate: json['rentOnDate'] ?? 0,
      rentalFrequency: json['rentalFrequency'] ?? 'N/A',
      remarks: json['remarks'] ?? '',
      electricity: Electricity.fromJson(json['electricity'] ?? {}),
    );
  }
}

class Electricity {
  final double perUnit;
  final int initialReading;
  final int? finalReading;
  final String initialReadingDate;
  final String? finalReadingDate;

  Electricity({
    required this.perUnit,
    required this.initialReading,
    this.finalReading,
    required this.initialReadingDate,
    this.finalReadingDate,
  });

  factory Electricity.fromJson(Map<String, dynamic> json) {
    return Electricity(
      perUnit: (json['perUnit'] ?? 0).toDouble(),
      initialReading: json['initialReading'] ?? 0,
      finalReading: json['finalReading'],
      initialReadingDate: json['initialReadingDate'] ?? '',
      finalReadingDate: json['finalReadingDate'],
    );
  }
}