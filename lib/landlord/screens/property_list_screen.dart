import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/landlord/screens/property%20details/property_details_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:draze/landlord/screens/property_screen.dart';

import '../providers/AllPropertyListProvider.dart';
import 'EditPropertyScreen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen>
    with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  final int _itemsPerPage = 10;
  List<AllPropertyListModel> _displayedProperties = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final propertyProvider = context.read<AllPropertyListProvider>();
    await propertyProvider.loadProperties();
    _resetPagination();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      _loadMoreProperties();
    }
  }

  void _loadMoreProperties() {
    final propertyProvider = context.read<AllPropertyListProvider>();
    final allFilteredProperties = propertyProvider.filteredProperties;

    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final nextPageStartIndex = (_currentPage + 1) * _itemsPerPage;
      final nextPageEndIndex = nextPageStartIndex + _itemsPerPage;

      if (nextPageStartIndex >= allFilteredProperties.length) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreData = false;
        });
        return;
      }

      final newProperties = allFilteredProperties.sublist(
        nextPageStartIndex,
        nextPageEndIndex.clamp(0, allFilteredProperties.length),
      );

      setState(() {
        _currentPage++;
        _displayedProperties.addAll(newProperties);
        _isLoadingMore = false;
        _hasMoreData = nextPageEndIndex < allFilteredProperties.length;
      });
    });
  }

  void _resetPagination() {
    final propertyProvider = context.read<AllPropertyListProvider>();
    final allFilteredProperties = propertyProvider.filteredProperties;

    setState(() {
      _currentPage = 0;
      _hasMoreData = allFilteredProperties.length > _itemsPerPage;
      _displayedProperties = allFilteredProperties.take(_itemsPerPage).toList();
    });
  }

  void _showDeleteConfirmation(
      BuildContext context,
      AllPropertyListModel property,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete Property',
            style: TextStyle(fontSize: 18.sp),
          ),
          content: Text(
            'Are you sure you want to delete "${property.name}"? This action cannot be undone.',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteProperty(property);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProperty(AllPropertyListModel property) async {
    final propertyProvider = context.read<AllPropertyListProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(strokeWidth: 3.w),
                  SizedBox(height: 16.h),
                  Text(
                    'Deleting property...',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final success = await propertyProvider.deleteProperty(property.id);

    if (mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      _resetPagination();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${property.name} deleted successfully',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              propertyProvider.error ?? 'Failed to delete property',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        propertyProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Properties',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 25.sp,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.sp),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<AllPropertyListProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.filteredProperties.isNotEmpty &&
              _displayedProperties.isEmpty &&
              !propertyProvider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resetPagination();
            });
          }

          if (propertyProvider.isLoading && _displayedProperties.isEmpty) {
            return Center(
              child: CircularProgressIndicator(strokeWidth: 3.w),
            );
          }

          if (propertyProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red[400]),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading properties',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      propertyProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      propertyProvider.clearError();
                      _refreshData();
                    },
                    icon: Icon(Icons.refresh, size: 18.sp),
                    label: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primary,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.all(16.w),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.search, size: 20.sp),
                      suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          propertyProvider.updateSearchQuery('');
                          _resetPagination();
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.blue[700]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                    onChanged: (value) {
                      propertyProvider.updateSearchQuery(value);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _resetPagination();
                      });
                    },
                  ),
                ),

                // Results Info
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${propertyProvider.filteredProperties.length} properties found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                      if (_displayedProperties.isNotEmpty)
                        Text(
                          'Showing ${_displayedProperties.length} of ${propertyProvider.filteredProperties.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                    ],
                  ),
                ),

                // Properties List
                Expanded(
                  child:
                  _displayedProperties.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 64.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No properties found',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                propertyProvider.searchQuery.isNotEmpty
                                    ? 'Try adjusting your search terms'
                                    : 'No properties available at the moment',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    itemCount:
                    _displayedProperties.length +
                        (_hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _displayedProperties.length) {
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          child: Center(
                            child:
                            _isLoadingMore
                                ? CircularProgressIndicator(
                              strokeWidth: 3.w,
                            )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final property = _displayedProperties[index];
                      return PropertyCard(
                        property: property,
                        onDelete:
                            () => _showDeleteConfirmation(
                          context,
                          property,
                        ),
                        onEdit: () {
                          _refreshData();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/properties/add-property');

          if (result == true && mounted) {
            _refreshData();
          }
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final AllPropertyListModel property;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const PropertyCard({
    Key? key,
    required this.property,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PropertyDetailsScreen(
                propertyId: property.id,
                propertyName: property.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Image
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child:
                  property.images.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: property.images.first,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                      ),
                    ),
                    errorWidget:
                        (context, url, error) =>
                        _buildPlaceholderImage(),
                  )
                      : _buildPlaceholderImage(),
                ),
              ),
              SizedBox(width: 16.w),

              // Property Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                            property.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            property.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color:
                              property.isActive
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Property Type
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        property.type,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            '${property.address}, ${property.city}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Property Stats
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.meeting_room_outlined,
                          '${property.totalRooms} Rooms',
                        ),
                        SizedBox(width: 8.w),
                        _buildStatChip(
                          Icons.bed_outlined,
                          '${property.totalBeds} Beds',
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),

              // Edit and Delete Buttons Column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 22.sp,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditPropertyScreen(
                            propertyData: property.toJson(),
                          ),
                        ),
                      );

                      if (result == true && onEdit != null) {
                        onEdit!();
                      }
                    },
                    tooltip: 'Edit Property',
                    padding: EdgeInsets.all(8.w),
                    constraints: BoxConstraints(
                      minWidth: 36.w,
                      minHeight: 36.h,
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22.sp,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete Property',
                    padding: EdgeInsets.all(8.w),
                    constraints: BoxConstraints(
                      minWidth: 36.w,
                      minHeight: 36.h,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.home_outlined,
        size: 40.sp,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}