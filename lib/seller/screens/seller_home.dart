import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/seller/screens/property_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/SellerPropertyModel.dart';
import '../providers/SellerPropertyProvider.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerPropertyProvider>().fetchProperties();
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && !_isSearchVisible) {
      setState(() {
        _isSearchVisible = true;
      });
    } else if (_scrollController.offset <= 100 && _isSearchVisible) {
      setState(() {
        _isSearchVisible = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate statistics from property list
  Map<String, int> _calculateStats(List<PropertyModel> properties) {
    int active = properties.where((p) => p.isActive).length;
    int inactive = properties.where((p) => !p.isActive).length;

    return {
      'total': properties.length,
      'active': active,
      'inactive': inactive,
      'totalBeds': properties.fold(0, (sum, p) => sum + p.totalBeds),
      'totalRooms': properties.fold(0, (sum, p) => sum + p.totalRooms),
      'occupancy': properties.fold(0, (sum, p) => sum + p.occupiedSpace),
      'capacity': properties.fold(0, (sum, p) => sum + p.totalCapacity),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<SellerPropertyProvider>(
        builder: (context, propertyProvider, child) {
          final properties = propertyProvider.properties;
          final filteredProperties = propertyProvider.filteredProperties;
          final isLoading = propertyProvider.isLoading;
          final error = propertyProvider.error;
          final propertyStats = _calculateStats(properties);

          return RefreshIndicator(
            onRefresh: () => propertyProvider.refreshProperties(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Custom App Bar with Hero Section
                SliverAppBar(
                  expandedHeight: AppSizes.buttonHeight(context) * 4.8,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                            AppColors.secondary.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -50,
                            right: -30,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            right: 100,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSizes.mediumPadding(context),
                              kToolbarHeight + AppSizes.mediumPadding(context),
                              AppSizes.mediumPadding(context),
                              AppSizes.mediumPadding(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: AppSizes.smallPadding(context) * 5,
                                ),
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSizes.largeText(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSizes.smallPadding(context) / 2,
                                ),
                                Text(
                                  'Seller!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSizes.largeText(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSizes.smallPadding(context) / 2,
                                ),
                                Text(
                                  'Manage Your Properties',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSizes.smallText(context),
                                  ),
                                ),
                                SizedBox(
                                  height: AppSizes.mediumPadding(context) + 10,
                                ),
                                // Search Bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.cardCornerRadius(context) * 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      propertyProvider.searchProperties(value);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Search properties...',
                                      hintStyle: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppSizes.smallText(context),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.textSecondary,
                                        size: AppSizes.smallIcon(context),
                                      ),
                                      suffixIcon:
                                          _searchController.text.isNotEmpty
                                              ? IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: AppSizes.smallIcon(
                                                    context,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  propertyProvider
                                                      .searchProperties('');
                                                },
                                              )
                                              : null,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.cardCornerRadius(context) *
                                              1.5,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.mediumPadding(
                                          context,
                                        ),
                                        vertical: AppSizes.mediumPadding(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    'Draze',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.titleText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(
                          AppSizes.smallPadding(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: AppSizes.mediumIcon(context),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to notifications
                      },
                    ),
                    SizedBox(width: AppSizes.smallPadding(context)),
                  ],
                ),

                // Overview Statistics
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: AppColors.primary,
                              size: AppSizes.smallIcon(context),
                            ),
                            SizedBox(width: AppSizes.smallPadding(context)),
                            Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: AppSizes.mediumText(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppSizes.mediumPadding(context),
                          mainAxisSpacing: AppSizes.mediumPadding(context),
                          childAspectRatio: 1.6,
                          children: [
                            _buildEnhancedStatCard(
                              context,
                              'Total Properties',
                              propertyStats['total']?.toString() ?? '0',
                              Icons.home_work_outlined,
                              AppColors.primary,
                            ),
                            _buildEnhancedStatCard(
                              context,
                              'Active',
                              propertyStats['active']?.toString() ?? '0',
                              Icons.check_circle_outline,
                              AppColors.success,
                            ),
                            _buildEnhancedStatCard(
                              context,
                              'Total Beds',
                              propertyStats['totalBeds']?.toString() ?? '0',
                              Icons.bed_outlined,
                              const Color(0xFF2196F3),
                            ),
                            _buildEnhancedStatCard(
                              context,
                              'Occupancy',
                              '${propertyStats['occupancy']}/${propertyStats['capacity']}',
                              Icons.people_outline,
                              AppColors.warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // My Properties Section Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.mediumPadding(context),
                      AppSizes.largePadding(context),
                      AppSizes.mediumPadding(context),
                      AppSizes.smallPadding(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.apartment_outlined,
                              color: AppColors.primary,
                              size: AppSizes.smallIcon(context),
                            ),
                            SizedBox(width: AppSizes.smallPadding(context)),
                            Text(
                              'My Properties',
                              style: TextStyle(
                                fontSize: AppSizes.mediumText(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Properties List
                if (isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              AppSizes.largePadding(context),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: AppSizes.largeIcon(context) * 2,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          Text(
                            'Error loading properties',
                            style: TextStyle(
                              fontSize: AppSizes.largeText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                          SizedBox(height: AppSizes.smallPadding(context)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.largePadding(context),
                            ),
                            child: Text(
                              error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          ElevatedButton(
                            onPressed: () {
                              propertyProvider.fetchProperties();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.largePadding(context),
                                vertical: AppSizes.mediumPadding(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.cardCornerRadius(context),
                                ),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredProperties.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              AppSizes.largePadding(context),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.home_outlined,
                              size: AppSizes.largeIcon(context) * 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          Text(
                            'No properties found',
                            style: TextStyle(
                              fontSize: AppSizes.mediumText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSizes.smallPadding(context)),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Try adjusting your search'
                                : 'Add your first property to get started',
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= filteredProperties.length) return null;
                      final property = filteredProperties[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSizes.mediumPadding(context),
                          AppSizes.smallPadding(context),
                          AppSizes.mediumPadding(context),
                          index == filteredProperties.length - 1
                              ? AppSizes.largePadding(context) * 3
                              : 0,
                        ),
                        child: _buildPropertyCard(context, property),
                      );
                    }, childCount: filteredProperties.length),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push('/seller/add-property');
        },
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: AppSizes.smallIcon(context),
        ),
        label: Text(
          'Add Property',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.smallText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    final occupancyPercent =
        property.totalCapacity > 0
            ? ((property.occupiedSpace / property.totalCapacity) * 100).toInt()
            : 0;

    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SellerPropertyDetailsScreen(property: property),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.cardCornerRadius(context)),
              ),
              child: Stack(
                children: [
                  property.images.isNotEmpty
                      ? Image.network(
                        property.images.first,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              size: AppSizes.largeIcon(context),
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: AppSizes.largeIcon(context),
                          color: Colors.grey,
                        ),
                      ),
                  Positioned(
                    top: AppSizes.smallPadding(context),
                    right: AppSizes.smallPadding(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smallPadding(context),
                        vertical: AppSizes.smallPadding(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            property.isActive
                                ? AppColors.success
                                : AppColors.error,
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius(context),
                        ),
                      ),
                      child: Text(
                        property.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.smallText(context) * 0.9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (property.images.length > 1)
                    Positioned(
                      top: AppSizes.smallPadding(context),
                      left: AppSizes.smallPadding(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.smallPadding(context),
                          vertical: AppSizes.smallPadding(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.white,
                              size: AppSizes.smallIcon(context) * 0.8,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${property.images.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSizes.smallText(context) * 0.9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Property Details
            Padding(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          style: TextStyle(
                            fontSize: AppSizes.mediumText(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.smallPadding(context),
                          vertical: AppSizes.smallPadding(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius(context),
                          ),
                        ),
                        child: Text(
                          property.type,
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context) * 0.9,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.smallPadding(context)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: AppSizes.smallIcon(context) * 0.9,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSizes.smallPadding(context) / 2),
                      Expanded(
                        child: Text(
                          '${property.city}, ${property.state}',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),
                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        context,
                        Icons.meeting_room_outlined,
                        '${property.totalRooms} Rooms',
                      ),
                      SizedBox(width: AppSizes.mediumPadding(context)),
                      _buildStatItem(
                        context,
                        Icons.bed_outlined,
                        '${property.totalBeds} Beds',
                      ),
                      SizedBox(width: AppSizes.mediumPadding(context)),
                      _buildStatItem(
                        context,
                        Icons.people_outline,
                        '$occupancyPercent%',
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),
                  // Financial Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Collection',
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context) * 0.9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '₹${_formatNumber(property.monthlyCollection)}',
                            style: TextStyle(
                              fontSize: AppSizes.mediumText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      if (property.pendingDues > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pending Dues',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context) * 0.9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${_formatNumber(property.pendingDues)}',
                              style: TextStyle(
                                fontSize: AppSizes.mediumText(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (property.ratingSummary.totalRatings > 0) ...[
                    SizedBox(height: AppSizes.mediumPadding(context)),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: AppSizes.smallIcon(context),
                          color: Colors.amber,
                        ),
                        SizedBox(width: AppSizes.smallPadding(context) / 2),
                        Text(
                          property.ratingSummary.averageRating.toStringAsFixed(
                            1,
                          ),
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppSizes.smallPadding(context) / 2),
                        Text(
                          '(${property.ratingSummary.totalRatings} reviews)',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSizes.smallIcon(context) * 0.9,
          color: AppColors.primary,
        ),
        SizedBox(width: AppSizes.smallPadding(context) / 2),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.smallPadding(context)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: AppSizes.smallIcon(context),
                  ),
                ),
                SizedBox(height: AppSizes.smallPadding(context)),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
