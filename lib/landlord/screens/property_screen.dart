import 'dart:convert';
import 'package:draze/app/api_constants.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/providers/OverviewPropertyProvider.dart';
import 'package:draze/landlord/screens/property%20details/property_details_screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../providers/AllPropertyListProvider.dart';
import '../widgets/DrawerWidget.dart';

class AllPropertyListModel {
  final String id;
  final String propertyId;
  final String landlordId;
  final String name;
  final String type;
  final String address;
  final String pinCode;
  final String city;
  final String state;
  final String description;
  final List<String> images;
  final int totalRooms;
  final int totalBeds;
  final double monthlyCollection;
  final double pendingDues;
  final int totalCapacity;
  final int occupiedSpace;
  final bool isActive;
  final String? landmark;
  final String? contactNumber;

  AllPropertyListModel({
    required this.id,
    required this.propertyId,
    required this.landlordId,
    required this.name,
    required this.type,
    required this.address,
    required this.pinCode,
    required this.city,
    required this.state,
    required this.description,
    required this.images,
    required this.totalRooms,
    required this.totalBeds,
    required this.monthlyCollection,
    required this.pendingDues,
    required this.totalCapacity,
    required this.occupiedSpace,
    required this.isActive,
    this.landmark,
    this.contactNumber,
  });

  factory AllPropertyListModel.fromJson(Map<String, dynamic> json) {
    return AllPropertyListModel(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      pinCode: json['pinCode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds'] ?? 0,
      monthlyCollection: (json['monthlyCollection'] ?? 0).toDouble(),
      pendingDues: (json['pendingDues'] ?? 0).toDouble(),
      totalCapacity: json['totalCapacity'] ?? 0,
      occupiedSpace: json['occupiedSpace'] ?? 0,
      isActive: json['isActive'] ?? true,
      landmark: json['landmark'],
      contactNumber: json['contactNumber'],
    );
  }

  // Add this toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'propertyId': propertyId,
      'landlordId': landlordId,
      'name': name,
      'type': type,
      'address': address,
      'pinCode': pinCode,
      'city': city,
      'state': state,
      'description': description,
      'images': images,
      'totalRooms': totalRooms,
      'totalBeds': totalBeds,
      'monthlyCollection': monthlyCollection,
      'pendingDues': pendingDues,
      'totalCapacity': totalCapacity,
      'capacity': totalCapacity, // Also add this for compatibility
      'occupiedSpace': occupiedSpace,
      'isActive': isActive,
      'landmark': landmark,
      'contactNumber': contactNumber,
      'ownerName': contactNumber, // Add ownerName field if needed
    };
  }

  // Optional: Add a copyWith method for easier property updates
  AllPropertyListModel copyWith({
    String? id,
    String? propertyId,
    String? landlordId,
    String? name,
    String? type,
    String? address,
    String? pinCode,
    String? city,
    String? state,
    String? description,
    List<String>? images,
    int? totalRooms,
    int? totalBeds,
    double? monthlyCollection,
    double? pendingDues,
    int? totalCapacity,
    int? occupiedSpace,
    bool? isActive,
    String? landmark,
    String? contactNumber,
  }) {
    return AllPropertyListModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      city: city ?? this.city,
      state: state ?? this.state,
      description: description ?? this.description,
      images: images ?? this.images,
      totalRooms: totalRooms ?? this.totalRooms,
      totalBeds: totalBeds ?? this.totalBeds,
      monthlyCollection: monthlyCollection ?? this.monthlyCollection,
      pendingDues: pendingDues ?? this.pendingDues,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      occupiedSpace: occupiedSpace ?? this.occupiedSpace,
      isActive: isActive ?? this.isActive,
      landmark: landmark ?? this.landmark,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }
}
// Property Provider

class LandlordScreen extends StatefulWidget {
  const LandlordScreen({super.key, required GlobalKey<ScaffoldState> scaffoldKey});

  @override
  State<LandlordScreen> createState() => _LandlordScreenState();
}

class _LandlordScreenState extends State<LandlordScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;
  String? userName;

  Future<void> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'Guest';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllPropertyListProvider>().loadProperties();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawerwidget(Name: userName!),
      body: Consumer<AllPropertyListProvider>(
        builder: (context, propertyProvider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar with Hero Section
              SliverAppBar(
                expandedHeight: AppSizes.buttonHeight(context) * 4.5,
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
                                height: AppSizes.smallPadding(context) * 6,
                              ),
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizes.titleText(context) - 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: AppSizes.smallPadding(context) / 2,
                              ),
                              Text(
                                '$userName!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizes.titleText(context) - 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: AppSizes.smallPadding(context) / 2.5,
                              ),
                              Text(
                                'Manage Your Properties',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizes.smallText(context),
                                ),
                              ),
                              SizedBox(height: AppSizes.mediumPadding(context)),
                              // Search Bar
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: AppSizes.mediumPadding(context),
                                ),
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
                                    propertyProvider.updateSearchQuery(value);
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
                                      vertical: AppSizes.mediumPadding(context),
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
                    fontSize: AppSizes.titleText(context) - 5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconTheme: IconThemeData(color: Colors.white),
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
                          GestureDetector(

                            child: _buildEnhancedStatCard(
                              context,
                              'Total Properties',
                              propertyProvider.propertyStats['total']
                                  .toString(),
                              Icons.home_work_outlined,
                              AppColors.primary,
                              '+12%',
                            ),
                            onTap: () {
                              context.push(
                                '/property_all_list',
                              );
                            },
                          ),
                          _buildEnhancedStatCard(
                            context,
                            'Active',
                            propertyProvider.propertyStats['active'].toString(),
                            Icons.check_circle_outline,
                            AppColors.success,
                            '+5%',
                          ),
                          _buildEnhancedStatCard(
                            context,
                            'Rented',
                            propertyProvider.propertyStats['rented'].toString(),
                            Icons.key_outlined,
                            const Color.fromARGB(255, 17, 111, 193),
                            '+8%',
                          ),
                          _buildEnhancedStatCard(
                            context,
                            'Maintenance',
                            propertyProvider.propertyStats['inactive']
                                .toString(),
                            Icons.build_outlined,
                            AppColors.warning,
                            '-2%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Properties Section Header
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
                            'Properties',
                            style: TextStyle(
                              fontSize: AppSizes.mediumText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            '/property_all_list',
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.mediumPadding(context),
                            vertical: AppSizes.smallPadding(context),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.cardCornerRadius(context),
                            ),
                          ),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: AppSizes.smallText(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Properties List
              if (propertyProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                if (propertyProvider.error != null)
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
                          Text(
                            propertyProvider.error!,
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context),
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSizes.mediumPadding(context)),
                          ElevatedButton(
                            onPressed: () {
                              propertyProvider.loadProperties();
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
                else
                  if (propertyProvider.filteredProperties.isEmpty)
                    SliverFillRemaining(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: AppSizes.largePadding(context) + 30),
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
                                  size: AppSizes.largeIcon(context) * 1.2,
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
                                propertyProvider.searchQuery.isEmpty
                                    ? 'Add your first property to get started'
                                    : 'No properties match your search',
                                style: TextStyle(
                                  fontSize: AppSizes.smallText(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >=
                              propertyProvider.filteredProperties.length)
                            return null;

                          final property = propertyProvider
                              .filteredProperties[index];

                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppSizes.mediumPadding(context),
                              AppSizes.smallPadding(context),
                              AppSizes.mediumPadding(context),
                              index ==
                                  (propertyProvider.filteredProperties.length >
                                      3
                                      ? 2
                                      : propertyProvider.filteredProperties
                                      .length - 1)
                                  ? AppSizes.largePadding(context) * 2
                                  : 0,
                            ),
                            child: PropertyCard(
                              property: property,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      PropertyDetailsScreen(
                                        propertyId: property.id,
                                        propertyName: property.name,),));
                              },
                            ),
                          );
                        },
                        childCount: propertyProvider.filteredProperties.length >
                            3
                            ? 3
                            : propertyProvider.filteredProperties.length,
                      ),
                    )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          context.push('/properties/add-property');
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

  Widget _buildEnhancedStatCard(BuildContext context,
      String title,
      String count,
      IconData icon,
      Color color,
      String trend,) {
    bool isPositive = trend.startsWith('+');

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
          // Background decoration
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
                Row(
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
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smallPadding(context),
                        vertical: AppSizes.smallPadding(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                        isPositive
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trend,
                        style: TextStyle(
                          fontSize: AppSizes.smallText(context) * 0.8,
                          color:
                          isPositive ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
}

class PropertyCard extends StatelessWidget {
  final AllPropertyListModel property;
  final VoidCallback onTap;

  const PropertyCard({Key? key, required this.property, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 1.5,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 1.5,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context) * 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context) * 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Image Section with Hero Effect
                  Container(
                    height: 150,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Property Image with Modern Styling
                        if (property.images.isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.network(
                              property.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildModernPlaceholder(context);
                              },
                              loadingBuilder: (context,
                                  child,
                                  loadingProgress,) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade100,
                                        Colors.grey.shade50,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: CircularProgressIndicator(
                                        value:
                                        loadingProgress
                                            .expectedTotalBytes !=
                                            null
                                            ? loadingProgress
                                            .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 3,
                                        color: AppColors.primary,
                                        backgroundColor: AppColors.primary
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          _buildModernPlaceholder(context),

                        // Modern Glass Morphism Overlay
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.15),
                              ],
                              stops: [0.0, 0.7, 1.0],
                            ),
                          ),
                        ),

                        // Modern Status Badge with Glass Effect
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                              property.isActive
                                  ? AppColors.success.withOpacity(0.9)
                                  : AppColors.error.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  property.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: AppSizes.smallText(context) * 0.8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Modern Image Counter
                        if (property.images.length > 1)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 4),
                                  Text(
                                    '${property.images.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Property ID Badge (Bottom Left)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              property.propertyId,
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context) * 0.75,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Modern Content Section
                  Padding(
                    padding: EdgeInsets.all(
                      AppSizes.mediumPadding(context) * 1.2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Property Name and Type
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.name,
                                    style: TextStyle(
                                      fontSize:
                                      AppSizes.mediumText(context) * 1.15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.2,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(
                                        property.type,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getTypeColor(
                                          property.type,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      property.type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize:
                                        AppSizes.smallText(context) * 0.8,
                                        color: _getTypeColor(property.type),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Contact Info
                            if (property.contactNumber != null)
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  size: AppSizes.smallIcon(context),
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: AppSizes.mediumPadding(context)),

                        // Modern Location Card
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade100,
                                Colors.blue.shade50,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: AppSizes.smallIcon(context) * 0.9,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${property.address}',
                                      style: TextStyle(
                                        fontSize:
                                        AppSizes.smallText(context) * 0.9,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${property.city}, ${property
                                          .state} - ${property.pinCode}',
                                      style: TextStyle(
                                        fontSize:
                                        AppSizes.smallText(context) * 0.8,
                                        color: AppColors.textSecondary,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppSizes.mediumPadding(context)),

                        // Modern Statistics Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernStatChip(
                                context,
                                icon: Icons.meeting_room_outlined,
                                value: '${property.totalRooms}',
                                label: 'Rooms',
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildModernStatChip(
                                context,
                                icon: Icons.bed_outlined,
                                value: '${property.totalBeds}',
                                label: 'Beds',
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildModernStatChip(
                                context,
                                icon: Icons.group_outlined,
                                value: '${property.totalCapacity}',
                                label: 'Capacity',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppSizes.smallPadding(context) * 1.5),

                        // Modern Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (property.landmark != null &&
                                property.landmark!.isNotEmpty)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.place_outlined,
                                      size: AppSizes.smallIcon(context) * 0.8,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property.landmark!,
                                        style: TextStyle(
                                          fontSize:
                                          AppSizes.smallText(context) * 0.8,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize:
                                      AppSizes.smallText(context) * 0.8,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildModernPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
            Colors.purple.withOpacity(0.03),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(child: CustomPaint(painter: DottedPatternPainter())),
          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.apartment_rounded,
                    size: AppSizes.largeIcon(context) * 1.2,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'No Image Available',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context) * 0.9,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatChip(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppSizes.smallIcon(context) * 0.9, color: color),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.95,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.75,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pg':
        return Colors.blue.shade600;
      case 'hostel':
        return Colors.green.shade600;
      case 'flat':
        return Colors.orange.shade600;
      default:
        return AppColors.primary;
    }
  }
}

// Custom Painter for Background Pattern
class DottedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const double dotSize = 2.0;
    const double spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
