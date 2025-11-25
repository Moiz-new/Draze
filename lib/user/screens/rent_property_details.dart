import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/user/models/rent_property.dart';
import 'package:draze/user/provider/property_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class RentPropertyDetailsScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const RentPropertyDetailsScreen({super.key, required this.propertyId});

  @override
  ConsumerState<RentPropertyDetailsScreen> createState() =>
      _RentPropertyDetailsScreenState();
}

class _RentPropertyDetailsScreenState
    extends ConsumerState<RentPropertyDetailsScreen> {
  late PageController _pageController;
  late ScrollController _scrollController;
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precacheImages();
    });
  }

  void _precacheImages() {
    final property = ref
        .read(rentPropertiesProvider)
        .properties
        .firstWhere(
          (p) => p.id == widget.propertyId,
          orElse:
              () => RentProperty(
                id: widget.propertyId,
                title: '',
                description: '',
                location: '',
                city: '',
                state: '',
                latitude: 0.0,
                longitude: 0.0,
                monthlyRent: 0.0,
                securityDeposit: 0.0,
                bedrooms: 0,
                bathrooms: 0,
                areaSquareFeet: 0.0,
                propertyType: '',
                images: const [],
                amenities: const [],
                ownerName: '',
                ownerPhone: '',
                ownerEmail: '',
                isAvailable: false,
                availableFrom: DateTime.now(),
                furnishedType: '',
                floorNumber: 0,
                totalFloors: 0,
                parkingType: '',
                parkingSpaces: 0,
                petsAllowed: false,
                rating: 0.0,
                reviewCount: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                nearbyPlaces: const [],
                electricityType: '',
                waterSupply: '',
                hasBalcony: false,
                hasGarden: false,
                isVerified: false,
                leaseDurationMonths: 0,
              ),
        );
    final images = property.images ?? [];
    if (images.isNotEmpty) {
      for (var url in images.take(2)) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(
      rentPropertiesProvider.select(
        (state) => AsyncValue<RentProperty?>.data(
          state.properties.firstWhere(
            (p) => p.id == widget.propertyId,
            orElse:
                () => RentProperty(
                  id: widget.propertyId,
                  title: '',
                  description: '',
                  location: '',
                  city: '',
                  state: '',
                  latitude: 0.0,
                  longitude: 0.0,
                  monthlyRent: 0.0,
                  securityDeposit: 0.0,
                  bedrooms: 0,
                  bathrooms: 0,
                  areaSquareFeet: 0.0,
                  propertyType: '',
                  images: const [],
                  amenities: const [],
                  ownerName: '',
                  ownerPhone: '',
                  ownerEmail: '',
                  isAvailable: false,
                  availableFrom: DateTime.now(),
                  furnishedType: '',
                  floorNumber: 0,
                  totalFloors: 0,
                  parkingType: '',
                  parkingSpaces: 0,
                  petsAllowed: false,
                  rating: 0.0,
                  reviewCount: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  nearbyPlaces: const [],
                  electricityType: '',
                  waterSupply: '',
                  hasBalcony: false,
                  hasGarden: false,
                  isVerified: false,
                  leaseDurationMonths: 0,
                ),
          ),
        ),
      ),
    );

    return propertyAsync.when(
      data: (property) => _buildContent(property),
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildContent(RentProperty? property) {
    if (property == null || property.id.isEmpty) {
      return _buildError('Property not found');
    }

    final sections = [
      SizedBox(height: AppSizes.smallPadding(context) + 2),
      _buildPropertyHeader(property),
      SizedBox(height: AppSizes.smallPadding(context) + 2),
      _buildPriceSection(property),
      _buildPropertyDetails(property),
      if ((property.amenities ?? []).isNotEmpty) _buildAmenities(property),
      _buildLocationSection(property),
      _buildOwnerSection(property),
      if ((property.nearbyPlaces ?? []).isNotEmpty)
        _buildNearbyPlaces(property),
      if (property.description.isNotEmpty ?? false) _buildDescription(property),
      SizedBox(height: AppSizes.buttonHeight(context) * 1.5),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(property),
          _buildImageCarousel(property),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.smallPadding(context) + 2,
              vertical: AppSizes.smallPadding(context) + 2 / 2,
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
      floatingActionButton: _buildFloatingActionButton(property),
      bottomNavigationBar: _buildBottomBar(property),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildError(dynamic error) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: AppSizes.smallIcon(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.smallIcon(context),
              color: Colors.red,
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Text(
              'Error: $error',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.smallText(context) - 3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(rentPropertiesProvider);
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.mediumPadding(context),
                  vertical: AppSizes.smallPadding(context) + 2,
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: AppSizes.smallText(context) - 3),
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2 / 2),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.mediumPadding(context),
                  vertical: AppSizes.smallPadding(context) + 2,
                ),
              ),
              child: Text(
                'Go Back',
                style: TextStyle(fontSize: AppSizes.smallText(context) - 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(RentProperty property) {
    final images = property.images ?? [];
    return SliverToBoxAdapter(
      child: Card(
        margin: EdgeInsets.all(AppSizes.smallPadding(context) + 4),
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
                onPageChanged:
                    (index) => setState(() => _currentImageIndex = index),
                itemCount: images.isNotEmpty ? images.length : 1,
                itemBuilder: (context, index) {
                  return Hero(
                    tag: 'property_image_${property.id}_$index',
                    child:
                        images.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: images[index],
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
              if (images.length > 1)
                Positioned(
                  bottom: AppSizes.smallPadding(context) + 2,
                  left: 0,
                  right: 0,
                  child: _buildImageIndicators(images.length),
                ),
              Positioned(
                top: AppSizes.smallPadding(context) + 2,
                right: AppSizes.smallPadding(context) + 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.smallPadding(context) + 2,
                    vertical: AppSizes.smallPadding(context) + 2 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${images.isNotEmpty ? images.length : 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.smallText(context) - 3,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppSizes.smallPadding(context) + 2,
                right: AppSizes.smallPadding(context) + 2,
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
                    onPressed: () => _showImageGallery(context, images),
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
    return Image.asset(
      'assets/images/placeholder_logo.png',
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: AppSizes.smallIcon(context),
                color: Colors.grey,
              ),
            ),
          ),
    );
  }

  Widget _buildImageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSizes.smallPadding(context) + 2 / 2,
          ),
          width:
              _currentImageIndex == index
                  ? AppSizes.mediumPadding(context) * 2
                  : AppSizes.smallPadding(context) + 2,
          height: AppSizes.smallPadding(context) + 2,
          decoration: BoxDecoration(
            color: _currentImageIndex == index ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context) / 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAppBar(RentProperty property) {
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        property.title ?? 'Property Details',
        style: TextStyle(
          color: Colors.black87,
          fontSize: AppSizes.mediumText(context) - 2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.black87,
            size: AppSizes.smallIcon(context),
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: Colors.black87,
            size: AppSizes.smallIcon(context),
          ),
          onPressed: () => _shareProperty(property),
        ),
      ],
    );
  }

  Widget _buildPropertyHeader(RentProperty property) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.smallPadding(context) + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  property.title ?? 'Property',
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context) - 2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (property.isVerified == true)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.smallPadding(context) + 2,
                    vertical: AppSizes.smallPadding(context) + 2 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: AppSizes.smallIcon(context),
                      ),
                      SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: AppSizes.smallText(context) - 3,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSizes.smallPadding(context) + 2 / 2),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.textSecondary,
                size: AppSizes.smallIcon(context),
              ),
              SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
              Expanded(
                child: Text(
                  '${property.location ?? ''}, ${property.city ?? ''}, ${property.state ?? ''}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.smallText(context) - 3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          ...[
            SizedBox(height: AppSizes.smallPadding(context) + 2 / 2),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < (property.rating?.floor() ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: AppSizes.smallIcon(context),
                  );
                }),
                SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
                Text(
                  '${property.rating ?? 0} (${property.reviewCount ?? 0} reviews)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.smallText(context) - 3,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(RentProperty property) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.mediumPadding(context),
      ),
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
              'Pricing Details',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Rent',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.smallText(context) - 3,
                      ),
                    ),
                    Text(
                      '₹${property.monthlyRent.toStringAsFixed(0) ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: AppSizes.mediumText(context) - 2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: AppSizes.smallIcon(context),
                ),
              ],
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Row(
              children: [
                Expanded(
                  child: _buildPriceItem(
                    'Security Deposit',
                    '₹${property.securityDeposit.toStringAsFixed(0) ?? 'N/A'}',
                    Icons.security,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: _buildPriceItem(
                    'Lease Duration',
                    '${property.leaseDurationMonths ?? 'N/A'} months',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSizes.smallPadding(context) + 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppSizes.smallIcon(context),
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.smallText(context) - 3,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.smallPadding(context) + 2 / 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.smallText(context) - 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails(RentProperty property) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.mediumPadding(context),
      ),
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
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'Property Type',
                    property.propertyType ?? 'N/A',
                    Icons.home_work_outlined,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: _buildDetailCard(
                    'Furnished',
                    _getFurnishedText(property.furnishedType),
                    Icons.chair_outlined,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'Bedrooms',
                    '${property.bedrooms ?? 'N/A'}',
                    Icons.bed_outlined,
                    Colors.purple,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: _buildDetailCard(
                    'Bathrooms',
                    '${property.bathrooms ?? 'N/A'}',
                    Icons.bathtub_outlined,
                    Colors.cyan,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'Area',
                    '${property.areaSquareFeet ?? 'N/A'} sq ft',
                    Icons.square_foot,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: _buildDetailCard(
                    'Floor',
                    '${property.floorNumber ?? 'N/A'}/${property.totalFloors ?? 'N/A'}',
                    Icons.stairs,
                    Colors.brown,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'Parking',
                    property.parkingType != 'no parking'
                        ? '${property.parkingSpaces ?? 0} ${property.parkingType}'
                        : 'None',
                    Icons.local_parking,
                    Colors.teal,
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: _buildDetailCard(
                    'Pets',
                    property.petsAllowed == true ? 'Allowed' : 'Not Allowed',
                    Icons.pets,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.smallPadding(context) + 2),
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
              SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: AppSizes.smallText(context) - 3,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.smallPadding(context) + 2 / 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.smallText(context) - 3,
            ),
          ),
        ],
      ),
    );
  }

  String _getFurnishedText(String? type) {
    switch (type?.toLowerCase()) {
      case 'fully':
        return 'Fully Furnished';
      case 'semi':
        return 'Semi Furnished';
      case 'unfurnished':
        return 'Unfurnished';
      default:
        return 'Not Specified';
    }
  }

  Widget _buildAmenities(RentProperty property) {
    final amenities = property.amenities ?? [];
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.smallPadding(context) + 2,
      ),
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
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Wrap(
              spacing: AppSizes.smallPadding(context) + 2 / 2,
              runSpacing: AppSizes.smallPadding(context) + 2 / 2,
              children:
                  amenities
                      .map((amenity) => _buildAmenityChip(amenity))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    final icon = _getAmenityIcon(amenity);
    return Tooltip(
      message: amenity,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.smallPadding(context) + 2,
          vertical: AppSizes.smallPadding(context) + 2 / 2,
        ),
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
              icon,
              size: AppSizes.smallIcon(context),
              color: AppColors.primary,
            ),
            SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
            Text(
              amenity,
              style: TextStyle(
                fontSize: AppSizes.smallText(context) - 3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case '24/7 security':
      case 'security':
        return Icons.security;
      case 'swimming pool':
      case 'pool':
        return Icons.pool;
      case 'gym':
        return Icons.fitness_center;
      case 'garden':
        return Icons.local_florist;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildLocationSection(RentProperty property) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.smallPadding(context) + 2,
      ),
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
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Card(
              elevation: AppSizes.cardElevation(context) / 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
              ),
              child: Container(
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
                      fontSize: AppSizes.smallText(context) - 3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: AppSizes.smallIcon(context),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2 / 2),
                Expanded(
                  child: Text(
                    '${property.location ?? ''}, ${property.city ?? ''}, ${property.state ?? ''}',
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context) - 3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openMap(property),
                    icon: Icon(Icons.map, size: AppSizes.smallIcon(context)),
                    label: Text(
                      'View on Map',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context) - 3,
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
                        vertical: AppSizes.smallPadding(context) + 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _getDirections(property),
                    icon: Icon(
                      Icons.directions,
                      size: AppSizes.smallIcon(context),
                    ),
                    label: Text(
                      'Directions',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context) - 3,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius(context),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizes.smallPadding(context) + 2,
                      ),
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

  Widget _buildOwnerSection(RentProperty property) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.smallPadding(context) + 2,
      ),
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
              'Contact Owner',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Row(
              children: [
                CircleAvatar(
                  radius: AppSizes.smallIcon(context) / 2,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Text(
                    property.ownerName.isNotEmpty == true
                        ? property.ownerName.substring(0, 1).toUpperCase()
                        : 'O',
                    style: TextStyle(
                      fontSize: AppSizes.mediumText(context) - 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context) + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.ownerName ?? 'Owner',
                        style: TextStyle(
                          fontSize: AppSizes.mediumText(context) - 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Property Owner',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.smallText(context) - 3,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.phone,
                        color: Colors.green,
                        size: AppSizes.smallIcon(context),
                      ),
                      onPressed: () => _callOwner(property),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.email,
                        color: Colors.blue,
                        size: AppSizes.smallIcon(context),
                      ),
                      onPressed: () => _emailOwner(property),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPlaces(RentProperty property) {
    final nearbyPlaces = property.nearbyPlaces ?? [];
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.smallPadding(context) + 2,
      ),
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
              'Nearby Places',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Wrap(
              spacing: AppSizes.smallPadding(context) + 2 / 2,
              runSpacing: AppSizes.smallPadding(context) + 2 / 2,
              children:
                  nearbyPlaces
                      .map((place) => _buildNearbyPlaceChip(place))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyPlaceChip(String place) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2,
        vertical: AppSizes.smallPadding(context) + 2 / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Text(
        place,
        style: TextStyle(
          fontSize: AppSizes.smallText(context) - 3,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDescription(RentProperty property) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context) + 2 / 4,
        vertical: AppSizes.smallPadding(context) + 2,
      ),
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
                fontSize: AppSizes.mediumText(context) - 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context) + 2),
            Text(
              property.description ?? '',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.smallText(context) - 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(RentProperty property) {
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

  Widget _buildBottomBar(RentProperty property) {
    return Container(
      padding: EdgeInsets.all(AppSizes.smallPadding(context) + 2),
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
            child: ElevatedButton(
              onPressed: () => _callOwner(property),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.smallPadding(context) + 2,
                ),
              ),
              child: Text(
                'Contact Owner',
                style: TextStyle(fontSize: AppSizes.smallText(context)),
              ),
            ),
          ),
          SizedBox(width: AppSizes.smallPadding(context) + 2),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking feature coming soon!')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.smallPadding(context) + 2,
                ),
              ),
              child: Text(
                'Book Now',
                style: TextStyle(fontSize: AppSizes.smallText(context)),
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

  void _toggleFavorite() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        final favorites = ref.read(favoritePropertiesProvider);
        if (_isFavorite) {
          ref.read(favoritePropertiesProvider.notifier).state = {
            ...favorites,
            widget.propertyId,
          };
        } else {
          ref.read(favoritePropertiesProvider.notifier).state =
              favorites.where((id) => id != widget.propertyId).toSet();
        }
      });
    }
  }

  void _shareProperty(RentProperty property) {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final shareText = '''
Check out this amazing rental property!
Title: ${property.title ?? 'Property'}
Location: ${property.location ?? ''}, ${property.city ?? ''}, ${property.state ?? ''}
Rent: ₹${property.monthlyRent.toStringAsFixed(0) ?? 'N/A'}/month
View it on Draze!
''';
    Share.share(shareText);
  }

  void _callOwner(RentProperty property) async {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final phone = property.ownerPhone ?? '';
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

  void _emailOwner(RentProperty property) async {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final email = property.ownerEmail ?? '';
    if (email.isNotEmpty && mounted) {
      final uri = Uri.parse(
        'mailto:$email?subject=Inquiry about ${property.title ?? 'Property'}',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cannot send email')));
      }
    }
  }

  void _openMap(RentProperty property) async {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final lat = property.latitude ?? 0.0;
    final lng = property.longitude ?? 0.0;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot open map')));
    }
  }

  void _getDirections(RentProperty property) async {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds < 500) {
      return;
    }
    _lastTap = now;

    final lat = property.latitude ?? 0.0;
    final lng = property.longitude ?? 0.0;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot get directions')));
    }
  }

  void _scrollToTop() {
    _scrollController.jumpTo(0);
  }
}
