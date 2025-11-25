import 'package:draze/user/models/SllerListPropertyModel.dart';
import 'package:draze/user/screens/SellPropertyDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../core/constants/appColors.dart';
import '../../landlord/screens/property details/property_details_screens.dart';
import '../provider/SellerListProvider.dart';

class SellerPropertyListScreen extends StatefulWidget {
  final String searchQuery;

  const SellerPropertyListScreen({Key? key, this.searchQuery = ''})
    : super(key: key);

  @override
  State<SellerPropertyListScreen> createState() =>
      _SellerPropertyListScreenState();
}

class _SellerPropertyListScreenState extends State<SellerPropertyListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<SellerListModel> _filteredProperties = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'SellerPropertyListScreen initState - searchQuery: "${widget.searchQuery}"',
    );
    _initializeAnimations();
    _initializeProvider();
    _setupSearchListener();

    // Handle initial search query
    if (widget.searchQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSearchQueryChange();
      });
    }
  }

  @override
  void didUpdateWidget(SellerPropertyListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      'SellerPropertyListScreen didUpdateWidget - old: "${oldWidget.searchQuery}", new: "${widget.searchQuery}"',
    );
    // Handle search query changes from parent
    if (widget.searchQuery != oldWidget.searchQuery) {
      _handleSearchQueryChange();
    }
  }

  void _handleSearchQueryChange() {
    debugPrint(
      'SellerPropertyListScreen _handleSearchQueryChange - query: "${widget.searchQuery}"',
    );

    if (widget.searchQuery.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredProperties.clear();
      });
      debugPrint('SellerPropertyListScreen - cleared search');
    } else {
      final provider = context.read<SellerListProvider>();
      final results = provider.searchPropertiesAndReturn(widget.searchQuery);

      setState(() {
        _isSearching = true;
        _filteredProperties = results;
      });

      debugPrint(
        'SellerPropertyListScreen - search results count: ${results.length}',
      );
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _initializeProvider() {
    // Load properties when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerListProvider>();
      debugPrint(
        'SellerPropertyListScreen - Initializing provider, current state: ${provider.loadingState}',
      );
      debugPrint(
        'SellerPropertyListScreen - Current properties count: ${provider.properties.length}',
      );

      // Always try to load properties to ensure we have the latest data
      provider
          .loadProperties()
          .then((_) {
            debugPrint(
              'SellerPropertyListScreen - Properties loaded, final count: ${provider.properties.length}',
            );
            debugPrint(
              'SellerPropertyListScreen - Loading state: ${provider.loadingState}',
            );

            if (provider.loadingState == PropertyLoadingState.loaded) {
              _animationController.forward();

              // Re-apply search if there's a query
              if (widget.searchQuery.isNotEmpty) {
                _handleSearchQueryChange();
              }
            }
          })
          .catchError((error) {
            debugPrint(
              'SellerPropertyListScreen - Error loading properties: $error',
            );
          });
    });
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final provider = context.read<SellerListProvider>();
      provider.searchProperties(_searchController.text);
    });
  }

  List<SellerListModel> _getCurrentProperties() {
    final provider = context.read<SellerListProvider>();

    debugPrint(
      'SellerPropertyListScreen _getCurrentProperties - _isSearching: $_isSearching, filteredCount: ${_filteredProperties.length}',
    );
    debugPrint(
      'SellerPropertyListScreen _getCurrentProperties - provider properties: ${provider.properties.length}, filtered: ${provider.filteredProperties.length}',
    );

    if (_isSearching) {
      debugPrint(
        'SellerPropertyListScreen - returning search results: ${_filteredProperties.length}',
      );
      return _filteredProperties;
    }

    final currentProperties =
        provider.filteredProperties.isNotEmpty
            ? provider.filteredProperties
            : provider.properties;

    debugPrint(
      'SellerPropertyListScreen - returning provider properties: ${currentProperties.length}',
    );
    return currentProperties;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              SizedBox(height: 8.h),
              if (widget.searchQuery.isNotEmpty) _buildSearchIndicator(),
              Expanded(
                child: Consumer<SellerListProvider>(
                  builder: (context, provider, child) {
                    debugPrint(
                      'SellerPropertyListScreen Consumer rebuild - provider state: ${provider.loadingState}',
                    );
                    debugPrint(
                      'SellerPropertyListScreen Consumer rebuild - properties: ${provider.properties.length}, filtered: ${provider.filteredProperties.length}',
                    );

                    if (provider.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Loading all properties...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (provider.hasError) {
                      return _buildErrorWidget(provider);
                    } else if (provider.properties.isEmpty) {
                      return _buildEmptyWidget();
                    }

                    final currentProperties = _getCurrentProperties();
                    debugPrint(
                      'SellerPropertyListScreen - current properties to display: ${currentProperties.length}',
                    );

                    if (currentProperties.isEmpty &&
                        widget.searchQuery.isNotEmpty) {
                      return _buildNoResultsWidget();
                    }

                    if (currentProperties.isEmpty) {
                      return _buildEmptyWidget();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        debugPrint(
                          'SellerPropertyListScreen - Pull to refresh triggered',
                        );
                        await provider.refreshProperties();
                        if (widget.searchQuery.isNotEmpty) {
                          _handleSearchQueryChange();
                        }
                      },
                      color: AppColors.primary,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: currentProperties.length + 1,
                          // +1 for bottom padding
                          itemBuilder: (context, index) {
                            // Add bottom padding after last item
                            if (index == currentProperties.length) {
                              return SizedBox(height: 20.h);
                            }

                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      (index * 0.1).clamp(0.0, 1.0),
                                      1.0,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                ),
                                child: _buildPropertyCard(
                                  currentProperties[index],
                                  index,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Optional: Add floating action button to manually refresh
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final provider = context.read<SellerListProvider>();
              await provider.refreshProperties();
              if (widget.searchQuery.isNotEmpty) {
                _handleSearchQueryChange();
              }
              _showSnackBar('Properties refreshed!');
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.refresh, color: Colors.white),
            mini: true,
          ),
        );
      },
    );
  }

  Widget _buildSearchIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Searching for: "${widget.searchQuery}"',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${_filteredProperties.length} found',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    String message = 'No Results Found';
    String description =
        'Try adjusting your search to find what you\'re looking for.';

    if (widget.searchQuery.isNotEmpty) {
      description =
          'No properties match your search "${widget.searchQuery}". Try a different search term.';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.filter_list_off,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () {
                final provider = context.read<SellerListProvider>();
                provider.clearSearch();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPropertyCard(SellerListModel property, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellPropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(property.images),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPropertyHeader(property),
                  SizedBox(height: 8.h),
                  _buildPropertyDetails(property),
                  SizedBox(height: 12.h),
                  _buildAmenities(property.amenities),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    debugPrint('Building image slider with ${images.length} images');

    // Filter valid images - they should now already be full URLs from the model
    final validImages = images
        .where((img) =>
    img.isNotEmpty &&
        !img.contains('undefined') &&
        (img.startsWith('http://') || img.startsWith('https://'))
    )
        .toList();

    debugPrint('Valid images after filtering: ${validImages.length}');
    if (validImages.isNotEmpty) {
      debugPrint('First image URL: ${validImages.first}');
    }

    if (validImages.isEmpty) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.divider.withOpacity(0.3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 48.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8.h),
              Text(
                'No images available',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200.h,
      child: PageView.builder(
        itemCount: validImages.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  validImages[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.divider.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading image ${validImages[index]}: $error');
                    return Container(
                      color: AppColors.divider.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Image counter overlay
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${index + 1}/${validImages.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyHeader(SellerListModel property) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  property.type,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (property.totalRatings > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14.sp, color: AppColors.success),
                SizedBox(width: 2.w),
                Text(
                  property.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyDetails(SellerListModel property) {
    return Column(
      children: [
        _buildDetailRow(Icons.location_on, property.address),
        SizedBox(height: 6.h),
        _buildDetailRow(Icons.place, '${property.city}, ${property.state}'),
        if (property.landmark.isNotEmpty) ...[
          SizedBox(height: 6.h),
          _buildDetailRow(Icons.near_me, property.landmark),
        ],
        if (property.description.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            property.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities(List<String> amenities) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              amenities.take(6).map((amenity) {
                // Limit to first 6 amenities for better UI
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    amenity,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
        ),
        if (amenities.length > 6)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              '+${amenities.length - 6} more amenities',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildErrorWidget(SellerListProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Properties',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              provider.errorMessage,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () async {
                await provider.refreshProperties();
                if (provider.loadingState == PropertyLoadingState.loaded) {
                  _animationController.reset();
                  _animationController.forward();
                  if (widget.searchQuery.isNotEmpty) {
                    _handleSearchQueryChange();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Properties Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Properties will appear here once they are added',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () async {
                await context.read<SellerListProvider>().refreshProperties();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
