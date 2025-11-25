import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/seller/screens/EditPropertyScreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/SellerPropertyModel.dart';

class SellerPropertyDetailsScreen extends StatefulWidget {
  final PropertyModel property;

  const SellerPropertyDetailsScreen({super.key, required this.property});

  @override
  State<SellerPropertyDetailsScreen> createState() =>
      _SellerPropertyDetailsScreenState();
}

class _SellerPropertyDetailsScreenState
    extends State<SellerPropertyDetailsScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentImageIndex = 0;
  bool _isExpanded = false;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precacheImages();
    });
  }

  void _precacheImages() {
    if (widget.property.images.isNotEmpty) {
      for (var url in widget.property.images.take(2)) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      SizedBox(height: AppSizes.largePadding(context)),
      _buildPropertyHeader(context),
      SizedBox(height: AppSizes.largePadding(context) + 4),
      _buildPropertyStats(context),
      SizedBox(height: AppSizes.largePadding(context) + 8),
      _buildPropertyDescription(context),
      SizedBox(height: AppSizes.largePadding(context)),
      _buildLocationSection(context),
      SizedBox(height: AppSizes.largePadding(context)),
      _buildAmenitiesSection(context),
      SizedBox(height: AppSizes.largePadding(context)),
      _buildContactSection(context),
      SizedBox(height: AppSizes.largePadding(context)),
      _buildRatingSection(context),
      SizedBox(height: AppSizes.buttonHeight(context) * 1.5),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(context),
            _buildImageCarousel(context),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.smallPadding(context),
                vertical: AppSizes.smallPadding(context) / 2,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => sections[index],
                  childCount: sections.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black87,
          size: AppSizes.smallIcon(context),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        widget.property.name,
        style: TextStyle(
          color: Colors.black87,
          fontSize: AppSizes.mediumText(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: Colors.black87,
            size: AppSizes.smallIcon(context),
          ),
          onPressed: _shareProperty,
        ),
      ],
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        margin: EdgeInsets.all(AppSizes.mediumPadding(context)),
        elevation: AppSizes.cardElevation(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount:
                    widget.property.images.isNotEmpty
                        ? widget.property.images.length
                        : 1,
                itemBuilder: (context, index) {
                  return Hero(
                    tag: 'property_image_${widget.property.id}_$index',
                    child:
                        widget.property.images.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: widget.property.images[index],
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => _buildPlaceholderImage(),
                              errorWidget:
                                  (context, url, error) =>
                                      _buildPlaceholderImage(),
                            )
                            : _buildPlaceholderImage(),
                  );
                },
              ),
              if (widget.property.images.length > 1)
                Positioned(
                  bottom: AppSizes.smallPadding(context),
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.property.images.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: AppSizes.smallPadding(context) / 2,
                        ),
                        width: _currentImageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
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
                        widget.property.isActive
                            ? AppColors.success
                            : AppColors.error,
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                  ),
                  child: Text(
                    widget.property.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.smallText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSizes.smallPadding(context),
                right: AppSizes.smallPadding(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context) * 2,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: AppSizes.smallIcon(context),
                    ),
                    onPressed:
                        () =>
                            _showImageGallery(context, widget.property.images),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: AppSizes.smallIcon(context),
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPropertyHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.property.name,
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPropertyIcon(widget.property.type),
                      color: AppColors.primary,
                      size: AppSizes.mediumIcon(context),
                    ),
                    SizedBox(width: AppSizes.smallPadding(context) / 2),
                    Text(
                      widget.property.type,
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Row(
            children: [
              Text(
                '₹${_formatPrice(widget.property.monthlyCollection.toDouble())}/month',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: AppSizes.smallIcon(context),
              ),
              SizedBox(width: AppSizes.smallPadding(context)),
              Expanded(
                child: Text(
                  '${widget.property.address}, ${widget.property.city}, ${widget.property.state} - ${widget.property.pinCode}',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (widget.property.landmark.isNotEmpty) ...[
            SizedBox(height: AppSizes.smallPadding(context) / 2),
            Row(
              children: [
                Icon(
                  Icons.near_me_outlined,
                  color: AppColors.textSecondary,
                  size: AppSizes.smallIcon(context),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Text(
                  'Near ${widget.property.landmark}',
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
    );
  }

  Widget _buildPropertyStats(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.smallPadding(context)),
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Rooms',
                    widget.property.totalRooms.toString(),
                    Icons.bed_outlined,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Beds',
                    widget.property.totalBeds.toString(),
                    Icons.hotel_outlined,
                    Colors.cyan,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Capacity',
                    widget.property.totalCapacity.toString(),
                    Icons.people_outline,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Occupied',
                    widget.property.occupiedSpace.toString(),
                    Icons.business_center_outlined,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pending Dues',
                    '₹${_formatPrice(widget.property.pendingDues.toDouble())}',
                    Icons.currency_rupee,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.smallPadding(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.smallIcon(context), color: color),
              SizedBox(width: AppSizes.smallPadding(context) / 2),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: AppSizes.smallText(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.smallPadding(context) / 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.smallText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDescription(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.smallPadding(context)),
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.property.description,
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: _isExpanded ? null : 3,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (widget.property.description.length > 100)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Show Less' : 'Read More',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.smallPadding(context)),
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Container(
              height: AppSizes.buttonHeight(context) * 2,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
              ),
              child: Center(
                child: Text(
                  'Map Preview (Integration Pending)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.smallText(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: AppSizes.smallIcon(context),
                ),
                SizedBox(width: AppSizes.smallPadding(context) / 2),
                Expanded(
                  child: Text(
                    '${widget.property.address}, ${widget.property.city}, ${widget.property.state} - ${widget.property.pinCode}',
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection(BuildContext context) {
    if (widget.property.amenities.isEmpty) return const SizedBox.shrink();

    // Clean and parse amenities
    List<String> cleanAmenities = _parseAmenities(widget.property.amenities);

    if (cleanAmenities.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.smallPadding(context)),
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Wrap(
              spacing: AppSizes.smallPadding(context) / 2,
              runSpacing: AppSizes.smallPadding(context) / 2,
              children:
                  cleanAmenities
                      .map((amenity) => _buildAmenityChip(amenity))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Add this helper method to parse and clean amenities
  List<String> _parseAmenities(dynamic amenities) {
    List<String> result = [];

    if (amenities is List) {
      // If it's already a proper list
      for (var amenity in amenities) {
        String cleaned = amenity.toString().trim();
        if (cleaned.isNotEmpty) {
          result.add(cleaned);
        }
      }
    } else if (amenities is String) {
      // If it's a string representation of JSON array
      String cleaned = amenities
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", '');

      List<String> items = cleaned.split(',');
      for (var item in items) {
        String trimmed = item.trim();
        if (trimmed.isNotEmpty) {
          result.add(trimmed);
        }
      }
    }

    return result;
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context),
        vertical: AppSizes.smallPadding(context) / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAmenityIcon(amenity),
            size: AppSizes.smallIcon(context),
            color: AppColors.primary,
          ),
          SizedBox(width: AppSizes.smallPadding(context) / 2),
          Text(
            amenity,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.smallPadding(context)),
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Row(
              children: [
                CircleAvatar(
                  radius: AppSizes.smallIcon(context) / 2,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: AppSizes.smallIcon(context) / 1.5,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owner Name',
                        style: TextStyle(
                          fontSize: AppSizes.smallText(context),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        widget.property.ownerName,
                        style: TextStyle(
                          fontSize: AppSizes.smallText(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.property.contactNumber.isNotEmpty) ...[
              SizedBox(height: AppSizes.smallPadding(context)),
              Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.smallIcon(context) / 2,
                    backgroundColor: AppColors.success.withOpacity(0.2),
                    child: Icon(
                      Icons.phone,
                      color: AppColors.success,
                      size: AppSizes.smallIcon(context) / 1.5,
                    ),
                  ),
                  SizedBox(width: AppSizes.smallPadding(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          widget.property.contactNumber,
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _callOwner,
                    icon: Icon(Icons.call, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final rating = widget.property.ratingSummary;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.smallPadding(context)),
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      rating.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: AppSizes.mediumText(context) * 2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: AppSizes.smallIcon(context),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.smallPadding(context) / 2),
                    Text(
                      '${rating.totalRatings} ratings',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppSizes.mediumPadding(context) * 2),
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 5; i >= 1; i--)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.smallPadding(context) / 4,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$i',
                                style: TextStyle(
                                  fontSize: AppSizes.smallText(context),
                                ),
                              ),
                              SizedBox(
                                width: AppSizes.smallPadding(context) / 2,
                              ),
                              Icon(
                                Icons.star,
                                size: AppSizes.smallIcon(context) / 1.5,
                                color: Colors.amber,
                              ),
                              SizedBox(
                                width: AppSizes.smallPadding(context) / 2,
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value:
                                      rating.totalRatings > 0
                                          ? (rating.ratingDistribution['$i'] ??
                                                  0) /
                                              rating.totalRatings
                                          : 0,
                                  backgroundColor: Colors.grey[200],
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(
                                width: AppSizes.smallPadding(context) / 2,
                              ),
                              Text(
                                '${rating.ratingDistribution['$i'] ?? 0}',
                                style: TextStyle(
                                  fontSize: AppSizes.smallText(context),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.property.commentCount > 0) ...[
              SizedBox(height: AppSizes.mediumPadding(context)),
              Divider(),
              SizedBox(height: AppSizes.smallPadding(context)),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: AppSizes.smallIcon(context),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSizes.smallPadding(context) / 2),
                  Text(
                    '${widget.property.commentCount} Comments',
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _scrollToTop,
      backgroundColor: AppColors.primary,
      mini: true,
      child: Icon(
        Icons.arrow_upward,
        color: Colors.white,
        size: AppSizes.smallIcon(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.smallPadding(context) + 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppSizes.cardElevation(context),
            offset: Offset(0, -AppSizes.cardElevation(context) / 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditPropertyScreen(propertyId: widget.property.id),
                  ),
                );
              },
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: AppSizes.smallIcon(context),
              ),
              label: Text(
                'Edit Property',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.smallPadding(context) + 8,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.mediumPadding(context)),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: AppSizes.smallIcon(context),
              ),
              label: Text(
                'Delete',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.smallPadding(context) + 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<String> images) {
    if (images.isEmpty) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            child: PageView.builder(
              controller: PageController(initialPage: _currentImageIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.contain,
                    placeholder:
                        (context, url) =>
                            Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => _buildPlaceholderImage(),
                  ),
                );
              },
            ),
          ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Property'),
            content: const Text(
              'Are you sure you want to delete this property? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle delete functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _shareProperty() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final shareText = '''
Check out this amazing property!
Title: ${widget.property.name}
Location: ${widget.property.address}, ${widget.property.city}, ${widget.property.state}
Monthly Collection: ₹${_formatPrice(widget.property.monthlyCollection.toDouble())}
Total Rooms: ${widget.property.totalRooms}
View it on Draze!
''';
    Share.share(shareText);
  }

  void _callOwner() async {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final phone = widget.property.contactNumber;
    if (phone.isNotEmpty && mounted) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cannot make call')));
      }
    }
  }

  void _scrollToTop() {
    _scrollController.jumpTo(0);
  }

  IconData _getPropertyIcon(String type) {
    switch (type.toLowerCase()) {
      case 'apartment':
        return Icons.apartment;
      case 'house':
        return Icons.house;
      case 'villa':
        return Icons.villa;
      case 'plot':
        return Icons.terrain;
      case 'commercial':
        return Icons.business;
      case 'office':
        return Icons.corporate_fare;
      case 'pg':
      case 'hostel':
        return Icons.home_work;
      default:
        return Icons.home;
    }
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'parking':
        return Icons.local_parking;
      case 'gym':
        return Icons.fitness_center;
      case 'swimming pool':
      case 'pool':
        return Icons.pool;
      case 'garden':
        return Icons.yard;
      case 'security':
        return Icons.security;
      case 'elevator':
      case 'lift':
        return Icons.elevator;
      case 'balcony':
        return Icons.balcony;
      case 'wifi':
        return Icons.wifi;
      case 'power backup':
        return Icons.power;
      case 'water supply':
        return Icons.water_drop;
      case 'cctv':
        return Icons.videocam;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'kitchen':
        return Icons.kitchen;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)} K';
    } else {
      return price.toStringAsFixed(0);
    }
  }
}
