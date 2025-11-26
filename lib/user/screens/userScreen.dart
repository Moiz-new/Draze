import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/user/screens/SellerPropertyListScreen.dart';
import 'package:draze/user/screens/HotelBanquetScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'RentPropertyScreen.dart';
import '../provider/RentPropertyProvider.dart';
import '../provider/SellerListProvider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  String _currentLocation = 'Getting location...';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  Timer? _debounce;
  Timer? _locationTimer;
  bool _isDisposed = false;
  bool _isLocationLoading = false;
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String _errorMessage = '';
  List<dynamic> _properties = [];
  String _currentSearchQuery = '';

  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _getCurrentLocationOptimized();
        _loadInitialData();
      }
    });
  }

  void _onTabChanged() {
    if (_isDisposed || !mounted) return;
    if (!_tabController.indexIsChanging) {
      final newIndex = _tabController.index;
      if (newIndex >= 0 && newIndex < 3) {
        setState(() {
          _selectedTabIndex = newIndex;
          _properties.clear();
        });
        _loadInitialData();
        // Clear search when tab changes
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
        }
      }
    }
  }

  void _onSearchChanged() {
    if (_isDisposed || !mounted) return;

    final query = _searchController.text.trim();

    // Cancel previous debounce
    _debounce?.cancel();

    // Debounce search for smooth performance
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_isDisposed || !mounted) return;

      setState(() {
        _currentSearchQuery = query;
      });

      // Perform search for Rent, Sell, and Hotels tabs
      if (query.isNotEmpty) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    if (_selectedTabIndex == 0) {
      // Search in rent properties
      final rentProvider = context.read<RentPropertyProvider>();
      rentProvider.searchProperties(query);
    } else if (_selectedTabIndex == 1) {
      // Search in seller properties
      final sellerProvider = context.read<SellerListProvider>();
      sellerProvider.searchProperties(query);
    }
    // Hotel search is handled internally in HotelBanquetScreen
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearchQuery = '';
    });

    // Reset the appropriate provider search based on current tab
    if (_selectedTabIndex == 0) {
      final rentProvider = context.read<RentPropertyProvider>();
      rentProvider.clearSearch();
    } else if (_selectedTabIndex == 1) {
      final sellerProvider = context.read<SellerListProvider>();
      sellerProvider.clearSearch();
    }
  }

  void _onScroll() {
    if (_isDisposed || !mounted) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (_isDisposed || !mounted) return;

      final offset = _scrollController.offset;
      final shouldShow = offset >= 200;

      if (_showScrollToTop != shouldShow) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }

      if (offset >= _scrollController.position.maxScrollExtent - 200) {
        _handleLoadMore();
      }
    });
  }

  void _handleLoadMore() {
    if (_hasMore && !_isLoading) {
      _loadMoreProperties();
    }
  }

  void _scrollToTop() {
    if (_isDisposed || !mounted || !_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _getCurrentLocationOptimized() async {
    if (_isLocationLoading || _isDisposed || !mounted) return;

    setState(() {
      _isLocationLoading = true;
    });

    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        _updateLocationSafely('Location access denied');
        return;
      }

      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null && mounted && !_isDisposed) {
        _processLocation(lastKnownPosition);
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      if (mounted && !_isDisposed) {
        _processLocation(position);
      }
    } catch (e) {
      _updateLocationSafely('Location unavailable');
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  Future<bool> _checkLocationPermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  void _processLocation(Position position) async {
    if (_isDisposed || !mounted) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty && mounted && !_isDisposed) {
        final placemark = placemarks.first;
        final location = _formatLocationString(placemark);
        _updateLocationSafely(location);
      }
    } catch (e) {
      _updateLocationSafely('Location found');
    }
  }

  String _formatLocationString(Placemark placemark) {
    final locality = placemark.locality?.trim();
    final area = placemark.administrativeArea?.trim();

    if (locality?.isNotEmpty == true && area?.isNotEmpty == true) {
      return '$locality, $area';
    } else if (locality?.isNotEmpty == true) {
      return locality!;
    } else if (area?.isNotEmpty == true) {
      return area!;
    }
    return 'Current Location';
  }

  void _updateLocationSafely(String location) {
    if (mounted && !_isDisposed) {
      setState(() {
        _currentLocation = location;
      });
    }
  }

  void _loadInitialData() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = true;
        });
      }
    });
  }

  void _loadMoreProperties() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = _properties.length < 50;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    _locationTimer?.cancel();

    if (_tabController.hasListeners) {
      _tabController.removeListener(_onTabChanged);
    }
    if (_scrollController.hasListeners) {
      _scrollController.removeListener(_onScroll);
    }
    _searchController.removeListener(_onSearchChanged);

    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              _buildOptimizedAppBar(context, innerBoxIsScrolled),
              _buildTabSection(context),
            ],
        body: _buildTabContent(),
      ),
      floatingActionButton:
          _showScrollToTop
              ? FloatingActionButton(
                onPressed: _scrollToTop,
                mini: true,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 20.sp,
                ),
              )
              : null,
    );
  }

  Widget _buildOptimizedAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 220.h,
      toolbarHeight: 8.h,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      actions: [],
      flexibleSpace: FlexibleSpaceBar(background: _buildGradientBackground()),
    );
  }

  Widget _buildGradientBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF7c6eff), Color(0xFF4338ca)],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildHeaderText(),
                  SizedBox(height: 10.h),
                  _buildLocationRow(),
                  SizedBox(height: 12.h),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -100.h,
          right: -30.w,
          child: Container(
            width: 150.w,
            height: 150.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
        Positioned(
          top: 50.h,
          right: 100.w,
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Draze',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          onPressed: () {
            // Navigate to notifications
          },
        ),
      ],
    );
  }

  Widget _buildHeaderText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Welcome User! ,',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child:
              _isLocationLoading
                  ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: Lottie.asset(
                      'assets/animations/Loading.json',
                      width: 18.w,
                      height: 18.h,
                    ),
                  )
                  : Icon(Icons.location_on, color: Colors.white, size: 18.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            _currentLocation,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    String getSearchHint() {
      switch (_selectedTabIndex) {
        case 0:
          return 'Search rent properties...';
        case 1:
          return 'Search properties for sale...';
        case 2:
          return 'Search hotels...';
        default:
          return 'Search by location...';
      }
    }

    // Enable search for all tabs (Rent, Sell, and Hotels)
    bool isSearchEnabled = true;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isSearchEnabled ? AppColors.textSecondary : Colors.grey[400],
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              enabled: isSearchEnabled,
              style: TextStyle(
                color:
                    isSearchEnabled ? AppColors.textPrimary : Colors.grey[500],
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: getSearchHint(),
                hintStyle: TextStyle(
                  color:
                      isSearchEnabled
                          ? AppColors.textSecondary
                          : Colors.grey[400],
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty && isSearchEnabled)
            GestureDetector(
              onTap: _clearSearch,
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _OptimizedTabBarDelegate(context, _tabController),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        RentPropertyScreen(searchQuery: _currentSearchQuery),
        SellerPropertyListScreen(searchQuery: _currentSearchQuery),
        HotelBanquetScreen(searchQuery: _currentSearchQuery),
      ],
    );
  }
}

class _OptimizedTabBarDelegate extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  final TabController tabController;

  _OptimizedTabBarDelegate(this.context, this.tabController);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            TabBar(
              controller: tabController,
              indicator: _SimpleTabIndicator(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.all(2.w),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Rent'),
                Tab(text: 'Sell'),
                Tab(text: 'Hotels'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60.h;

  @override
  double get minExtent => 60.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _SimpleTabIndicator extends Decoration {
  final Color color;
  final BorderRadius borderRadius;

  const _SimpleTabIndicator({required this.color, required this.borderRadius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _SimpleTabIndicatorPainter(color: color, borderRadius: borderRadius);
  }
}

class _SimpleTabIndicatorPainter extends BoxPainter {
  final Color color;
  final BorderRadius borderRadius;

  _SimpleTabIndicatorPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      configuration.size!.width,
      configuration.size!.height,
    );

    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()..color = color;

    canvas.drawRRect(rrect, paint);
  }
}
