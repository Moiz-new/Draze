import 'package:draze/landlord/models/OverviewPropertyModel.dart';
import 'package:draze/landlord/providers/OverviewPropertyProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/core/constants/appColors.dart';

class OverviewTab extends StatefulWidget {
  final String propertyId;

  const OverviewTab({super.key, required this.propertyId});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch property details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OverviewPropertyProvider>(
        context,
        listen: false,
      ).fetchPropertyById(widget.propertyId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.propertyId);
    return Consumer<OverviewPropertyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48.0,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Error loading property',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  provider.error!,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchPropertyById(widget.propertyId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final property = provider.currentProperty;
        if (property == null) {
          return const Center(child: Text('Property not found'));
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildImageCarousel(context, property)),
            SliverPadding(
              padding: const EdgeInsets.all(12.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPropertyHeader(context, property),
                  const SizedBox(height: 16.0),
                  _buildQuickStats(context, property),
                  const SizedBox(height: 16.0),
                  _buildPropertyDetails(context, property),
                  const SizedBox(height: 16.0),
                  if (property.description.isNotEmpty)
                    _buildDescriptionCard(context, property),
                  if (property.description.isNotEmpty)
                    const SizedBox(height: 16.0),
                  if ((property.amenities ?? []).isNotEmpty)
                    _buildAmenitiesCard(context, property),
                  if ((property.amenities ?? []).isNotEmpty)
                    const SizedBox(height: 16.0),
                  _buildContactCard(context, property),
                  const SizedBox(height: 16.0),
                  _buildRatingSummary(context, property),
                  const SizedBox(height: 16.0),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageCarousel(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    final images = property.images ?? [];

    if (images.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.28,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48.0,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.28,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => const Icon(
                      Icons.error,
                      color: AppColors.error,
                      size: 24.0,
                    ),
              );
            },
          ),
          if (images.length > 1) ...[
            Positioned(
              left: 12.0,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12.0,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    if (_currentImageIndex < images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    width: _currentImageIndex == index ? 20.0 : 6.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color:
                          _currentImageIndex == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12.0,
              right: 12.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${_currentImageIndex + 1} / ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyHeader(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16.0,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          '${property.address}, ${property.city}, ${property.state} ${property.pincode}',
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color:
                    property.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color:
                      property.isActive ? AppColors.success : AppColors.error,
                  width: 0.8,
                ),
              ),
              child: Text(
                property.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12.0,
                  color:
                      property.isActive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            Icons.home_outlined,
            'Type',
            property.type,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.door_front_door_outlined,
            'Rooms',
            property.totalRooms.toString(),
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.bed_outlined,
            'Beds',
            property.totalBeds.toString(),
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3.0,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.0, color: color),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20.0,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8.0),
                const Text(
                  'Property Details',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            _buildDetailRow(
              context,
              'Property ID',
              property.propertyId,
              Icons.tag,
            ),
            _buildDetailRow(
              context,
              'Property Type',
              property.type,
              Icons.home,
            ),
            _buildDetailRow(
              context,
              'Total Rooms',
              property.totalRooms.toString(),
              Icons.door_front_door,
            ),
            _buildDetailRow(
              context,
              'Total Beds',
              property.totalBeds.toString(),
              Icons.bed,
            ),
            _buildDetailRow(
              context,
              'Total Capacity',
              property.totalCapacity.toString(),
              Icons.people,
            ),
            _buildDetailRow(
              context,
              'Occupied Space',
              property.occupiedSpace.toString(),
              Icons.person,
            ),
            _buildDetailRow(
              context,
              'Monthly Collection',
              '₹${property.monthlyCollection.toStringAsFixed(0)}',
              Icons.currency_rupee,
            ),
            _buildDetailRow(
              context,
              'Pending Dues',
              '₹${property.pendingDues.toStringAsFixed(0)}',
              Icons.account_balance_wallet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 20.0,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8.0),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                property.description,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesCard(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    final amenities = property.amenities ?? [];
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_outline,
                  size: 20.0,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8.0),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16.0,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            amenity,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    final ratingSummary = property.ratingSummary;
    if (ratingSummary == null) return const SizedBox.shrink();

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 20.0, color: AppColors.warning),
                const SizedBox(width: 8.0),
                const Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Text(
                  ratingSummary.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(Icons.star, color: AppColors.warning, size: 24.0),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              '${ratingSummary.totalRatings} ratings • ${property.commentCount} comments',
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    OverviewPropertyModel property,
  ) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.contact_phone_outlined,
                  size: 20.0,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8.0),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (property.contactNumber != null)
              _buildContactRow(
                context,
                Icons.phone,
                'Phone',
                property.contactNumber!,
                AppColors.success,
              ),
            if (property.email != null)
              _buildContactRow(
                context,
                Icons.email,
                'Email',
                property.email!,
                AppColors.primary,
              ),
            if (property.contactNumber == null && property.email == null)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'No contact information available',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16.0, color: AppColors.primary),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.0, color: color),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Add functionality to call or email
              },
              icon: Icon(Icons.arrow_forward_ios, size: 16.0, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
