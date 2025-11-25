import 'package:flutter/material.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HotelBanquetScreen.dart';
import '../widgets/EnquiryBottomSheet.dart'; // Add this import

class HotelBanquetDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelBanquetDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelBanquetDetailsScreen> createState() =>
      _HotelBanquetDetailsScreenState();
}

class _HotelBanquetDetailsScreenState extends State<HotelBanquetDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackbar('Could not launch phone dialer');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackbar('Could not launch email app');
    }
  }

  Future<void> _openWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri launchUri = Uri.parse(url);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar('Could not open website');
    }
  }

  Future<void> _openMaps() async {
    final lat = widget.hotel.latitude;
    final lng = widget.hotel.longitude;
    final Uri launchUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar('Could not open maps');
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Add this method to show enquiry bottom sheet
  void _showEnquiryBottomSheet() {
    // TODO: Get userId from your auth provider/shared preferences
    // Example:
    // final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    // OR
    // final prefs = await SharedPreferences.getInstance();
    // final userId = prefs.getString('userId') ?? '';

    final String userId = "YOUR_USER_ID"; // Replace with actual userId

    // Null check for hotel ID
    if (widget.hotel.hotelId.isEmpty) {
      _showSnackbar('Hotel information is incomplete', isError: true);
      return;
    }

    if (userId.isEmpty) {
      _showSnackbar('Please login to submit enquiry', isError: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: EnquiryBottomSheet(
              hotelId: widget.hotel.id,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                _buildDescriptionSection(),
                _buildAmenitiesSection(),
                _buildContactSection(),
                _buildLocationSection(),
                _buildAdditionalInfoSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      title:
          _showAppBarTitle
              ? Text(
                widget.hotel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
              : null,
      flexibleSpace: FlexibleSpaceBar(background: _buildHeaderImage()),
    );
  }

  Widget _buildHeaderImage() {
    return widget.hotel.images.isNotEmpty
        ? Stack(
          children: [
            PageView.builder(
              itemCount: widget.hotel.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.hotel.images[index],
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholderImage(),
                );
              },
            ),
            if (widget.hotel.images.length > 1)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.hotel.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, const Color(0xFF7c6eff)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel, size: 80, color: Colors.white.withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              'No Image Available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.hotel.name,
                  style: TextStyle(
                    fontSize: AppSizes.largeText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${widget.hotel.address}, ${widget.hotel.city}, ${widget.hotel.state}',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_city,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Pincode: ${widget.hotel.pincode}',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context) - 1,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    switch (widget.hotel.status.toLowerCase()) {
      case 'approved':
        badgeColor = AppColors.success;
        break;
      case 'pending':
        badgeColor = AppColors.warning;
        break;
      default:
        badgeColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Text(
        widget.hotel.status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: EdgeInsets.all(AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.hotel.description,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    if (widget.hotel.amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding(context),
      ).copyWith(bottom: AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Amenities',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                widget.hotel.amenities.map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAmenityIcon(amenity),
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          amenity,
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding(context),
      ).copyWith(bottom: AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.phone,
            'Primary Phone',
            widget.hotel.contactNumber,
            () => _makePhoneCall(widget.hotel.contactNumber),
          ),
          if (widget.hotel.alternateContact.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.phone_android,
              'Alternate Phone',
              widget.hotel.alternateContact,
              () => _makePhoneCall(widget.hotel.alternateContact),
            ),
          ],
          if (widget.hotel.email.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.email,
              'Email',
              widget.hotel.email,
              () => _sendEmail(widget.hotel.email),
            ),
          ],
          if (widget.hotel.website.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.language,
              'Website',
              widget.hotel.website,
              () => _openWebsite(widget.hotel.website),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context) - 1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding(context),
      ).copyWith(bottom: AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.address,
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.hotel.city}, ${widget.hotel.state} - ${widget.hotel.pincode}',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding(context),
      ).copyWith(bottom: AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Hotel ID', widget.hotel.hotelId),
          _buildInfoRow('Registration Number', widget.hotel.registrationNumber),
          _buildInfoRow(
            'Verification Status',
            widget.hotel.verificationStatus.toUpperCase(),
          ),
          _buildInfoRow(
            'Availability',
            widget.hotel.isAvailable ? 'Available' : 'Not Available',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showEnquiryBottomSheet,
                // Updated to show enquiry form
                icon: const Icon(Icons.info),
                label: const Text('Submit Inquiry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final lowerAmenity = amenity.toLowerCase();
    if (lowerAmenity.contains('ac') || lowerAmenity.contains('air')) {
      return Icons.ac_unit;
    } else if (lowerAmenity.contains('swim')) {
      return Icons.pool;
    } else if (lowerAmenity.contains('gym')) {
      return Icons.fitness_center;
    } else if (lowerAmenity.contains('wifi')) {
      return Icons.wifi;
    } else if (lowerAmenity.contains('parking')) {
      return Icons.local_parking;
    } else if (lowerAmenity.contains('restaurant')) {
      return Icons.restaurant;
    } else if (lowerAmenity.contains('spa')) {
      return Icons.spa;
    } else if (lowerAmenity.contains('bar')) {
      return Icons.local_bar;
    }
    return Icons.check_circle;
  }
}
