import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:draze/landlord/providers/OverviewPropertyProvider.dart';
import 'package:draze/landlord/providers/tenant_provider.dart';

import '../../../core/constants/appColors.dart';

class PropertyDashboardScreen extends StatefulWidget {
  final String propertyId;
  final TabController? tabController;

  const PropertyDashboardScreen({
    Key? key,
    required this.propertyId,
    this.tabController,
  }) : super(key: key);

  @override
  State<PropertyDashboardScreen> createState() =>
      _PropertyDashboardScreenState();
}

class _PropertyDashboardScreenState extends State<PropertyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add null check for context and mounted state
      if (!mounted) return;

      try {
        // Fetch property details
        context.read<OverviewPropertyProvider>().fetchPropertyById(
          widget.propertyId,
        );
        // Fetch tenants
        context.read<TenantProvider>().loadTenants(widget.propertyId);
      } catch (e) {
        debugPrint('Error initializing data: $e');
      }
    });
  }

  // Helper method to safely get property value
  dynamic _getPropertyValue(
      dynamic property,
      String key, [
        dynamic defaultValue,
      ]) {
    try {
      if (property == null) return defaultValue;

      if (property is Map) {
        return property[key] ?? defaultValue;
      }

      final jsonData = (property as dynamic).toJson();
      return jsonData?[key] ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting property value for $key: $e');
      return defaultValue;
    }
  }

  // Helper method to get full address
  String _getFullAddress(dynamic property) {
    if (property == null) return 'N/A';

    List<String> addressParts = [];

    final address = _getPropertyValue(property, 'address', '');
    if (address != null && address.toString().isNotEmpty) {
      addressParts.add(address.toString());
    }

    final city = _getPropertyValue(property, 'city', '');
    if (city != null && city.toString().isNotEmpty) {
      addressParts.add(city.toString());
    }

    final pinCode = _getPropertyValue(property, 'pinCode', '');
    if (pinCode != null && pinCode.toString().isNotEmpty) {
      addressParts.add(pinCode.toString());
    }

    return addressParts.isEmpty ? 'N/A' : addressParts.join(', ');
  }

  // Navigate to specific tab
  void _navigateToTab(int tabIndex) {
    if (widget.tabController != null && mounted) {
      try {
        widget.tabController!.animateTo(tabIndex);
      } catch (e) {
        debugPrint('Error navigating to tab: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<OverviewPropertyProvider, TenantProvider>(
        builder: (context, propertyProvider, tenantProvider, child) {
          // Show loading if either provider is loading
          if (propertyProvider.isLoading || tenantProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Show error if property provider has error
          if (propertyProvider.error != null) {
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
                  Text(
                    'Error loading property',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      propertyProvider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        propertyProvider.fetchPropertyById(widget.propertyId);
                        tenantProvider.loadTenants(widget.propertyId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
            );
          }

          if (propertyProvider.currentProperty == null) {
            return Center(
              child: Text(
                'No property data available',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final property = propertyProvider.currentProperty!;
          // Get tenant count from TenantProvider with null safety
          final tenantCount = tenantProvider.tenants?.length ?? 0;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              if (mounted) {
                await propertyProvider.fetchPropertyById(widget.propertyId);
                await tenantProvider.loadTenants(widget.propertyId);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Statistics Cards
                  _buildStatisticsCards(property, tenantCount),

                  SizedBox(height: 24.h),
                  // Occupancy Details (if needed)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(dynamic property, int tenantCount) {
    // Use safe getters with null checks
    final totalRooms = _getPropertyValue(property, 'totalRooms', 0) ?? 0;
    final totalBeds = _getPropertyValue(property, 'totalBeds', 0) ?? 0;
    final totalCapacity = _getPropertyValue(property, 'totalCapacity', 0) ?? 0;
    final occupiedSpace = _getPropertyValue(property, 'occupiedSpace', 0) ?? 0;

    // Calculate available beds safely
    int availableBeds = 0;
    try {
      availableBeds = (totalBeds as int) - (occupiedSpace as int);
      if (availableBeds < 0) availableBeds = 0;
    } catch (e) {
      debugPrint('Error calculating available beds: $e');
      availableBeds = 0;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.meeting_room,
                  title: 'Total Rooms',
                  value: '$totalRooms',
                  subtitle: 'Available spaces',
                  color: AppColors.primary,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  onTap: () => _navigateToTab(2),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.bed,
                  title: 'Total Beds',
                  value: '$totalBeds',
                  subtitle: 'Bed capacity',
                  color: AppColors.success,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.7),
                    ],
                  ),
                  onTap: () => _navigateToTab(2),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: 'Total Capacity',
                  value: '$totalCapacity',
                  subtitle: 'Maximum tenants',
                  color: const Color(0xFF9C27B0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  ),
                  onTap: () => _navigateToTab(3),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.person,
                  title: 'Occupied',
                  value: '$occupiedSpace',
                  subtitle: 'Current tenants',
                  color: const Color(0xFFFF9800),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  ),
                  onTap: () => _navigateToTab(3),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Third Row - Active Tenants
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_alt,
                  title: 'Active Tenants',
                  value: '$tenantCount',
                  subtitle: 'Registered tenants',
                  color: const Color(0xFF00BCD4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
                  ),
                  onTap: () => _navigateToTab(3),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available,
                  title: 'Available Beds',
                  value: '$availableBeds',
                  subtitle: 'Ready to rent',
                  color: const Color(0xFF4CAF50),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                  onTap: () => _navigateToTab(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.sp),
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
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