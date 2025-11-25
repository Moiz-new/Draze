// File: lib/seller/widgets/property_card.dart

import 'package:flutter/material.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';

import '../models/SellerPropertyModel.dart';

class SellerPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;

  const SellerPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  AppSizes.cardCornerRadius(context) * 1.5,
                ),
                topRight: Radius.circular(
                  AppSizes.cardCornerRadius(context) * 1.5,
                ),
              ),
              child: _buildPropertyImage(context),
            ),

            // Property Details
            Padding(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      SizedBox(width: AppSizes.smallPadding(context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.smallPadding(context),
                          vertical: AppSizes.smallPadding(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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

                  // Property ID
                  Row(
                    children: [
                      Icon(
                        Icons.tag,
                        size: AppSizes.smallIcon(context) * 0.8,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSizes.smallPadding(context) / 2),
                      Text(
                        property.propertyId,
                        style: TextStyle(
                          fontSize: AppSizes.smallText(context) * 0.9,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.smallPadding(context)),

                  // Address
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
                          '${property.address}, ${property.city}, ${property.state}',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (property.landmark.isNotEmpty) ...[
                    SizedBox(height: AppSizes.smallPadding(context) / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: AppSizes.smallIcon(context) * 0.8,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppSizes.smallPadding(context) / 2),
                        Expanded(
                          child: Text(
                            property.landmark,
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context) * 0.9,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: AppSizes.mediumPadding(context)),

                  // Property Stats
                  Row(
                    children: [
                      _buildStatChip(
                        context,
                        Icons.bed_outlined,
                        '${property.totalBeds} Beds',
                      ),
                      SizedBox(width: AppSizes.smallPadding(context)),
                      _buildStatChip(
                        context,
                        Icons.meeting_room_outlined,
                        '${property.totalRooms} Rooms',
                      ),
                      SizedBox(width: AppSizes.smallPadding(context)),
                      _buildStatChip(
                        context,
                        Icons.people_outline,
                        '${property.totalCapacity} Cap',
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),

                  // Occupancy Info
                  if (property.totalCapacity > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Occupancy',
                                    style: TextStyle(
                                      fontSize: AppSizes.smallText(context) * 0.9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${property.occupiedSpace}/${property.totalCapacity}',
                                    style: TextStyle(
                                      fontSize: AppSizes.smallText(context) * 0.9,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSizes.smallPadding(context) / 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: property.totalCapacity > 0
                                      ? property.occupiedSpace / property.totalCapacity
                                      : 0,
                                  backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getOccupancyColor(
                                      property.occupiedSpace / property.totalCapacity,
                                    ),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.mediumPadding(context)),
                  ],

                  // Financial Info
                  Container(
                    padding: EdgeInsets.all(AppSizes.smallPadding(context)),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius(context),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFinancialInfo(
                          context,
                          'Monthly',
                          '₹${_formatAmount(property.monthlyCollection)}',
                          AppColors.success,
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.textSecondary.withOpacity(0.2),
                        ),
                        _buildFinancialInfo(
                          context,
                          'Pending',
                          '₹${_formatAmount(property.pendingDues)}',
                          property.pendingDues > 0
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizes.mediumPadding(context)),

                  // Status and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.smallPadding(context),
                          vertical: AppSizes.smallPadding(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: property.isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              property.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: AppSizes.smallIcon(context) * 0.8,
                              color: property.isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            SizedBox(width: AppSizes.smallPadding(context) / 2),
                            Text(
                              property.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context) * 0.9,
                                color: property.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (property.ratingSummary.averageRating > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.smallPadding(context),
                            vertical: AppSizes.smallPadding(context) / 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: AppSizes.smallIcon(context) * 0.9,
                                color: Colors.amber,
                              ),
                              SizedBox(width: AppSizes.smallPadding(context) / 2),
                              Text(
                                property.ratingSummary.averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: AppSizes.smallText(context),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                ' (${property.ratingSummary.totalRatings})',
                                style: TextStyle(
                                  fontSize: AppSizes.smallText(context) * 0.85,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Amenities (if available)
                  if (property.amenities.isNotEmpty) ...[
                    SizedBox(height: AppSizes.mediumPadding(context)),
                    Wrap(
                      spacing: AppSizes.smallPadding(context) / 2,
                      runSpacing: AppSizes.smallPadding(context) / 2,
                      children: property.amenities
                          .take(4)
                          .map(
                            (amenity) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.smallPadding(context),
                            vertical: AppSizes.smallPadding(context) / 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getAmenityIcon(amenity),
                                size: AppSizes.smallIcon(context) * 0.7,
                                color: AppColors.secondary,
                              ),
                              SizedBox(width: AppSizes.smallPadding(context) / 3),
                              Text(
                                amenity,
                                style: TextStyle(
                                  fontSize: AppSizes.smallText(context) * 0.85,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .toList(),
                    ),
                    if (property.amenities.length > 4)
                      Padding(
                        padding: EdgeInsets.only(top: AppSizes.smallPadding(context) / 2),
                        child: Text(
                          '+${property.amenities.length - 4} more',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context) * 0.85,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],

                  // Contact Info
                  if (property.contactNumber.isNotEmpty) ...[
                    SizedBox(height: AppSizes.mediumPadding(context)),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: AppSizes.smallIcon(context) * 0.8,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppSizes.smallPadding(context) / 2),
                        Text(
                          property.contactNumber,
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context) * 0.9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (property.ownerName.isNotEmpty) ...[
                          SizedBox(width: AppSizes.smallPadding(context)),
                          Text(
                            '• ${property.ownerName}',
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context) * 0.9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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

  Widget _buildPropertyImage(BuildContext context) {
    final imageUrl = property.images.isNotEmpty ? property.images.first : null;

    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.1),
      child: Stack(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(context);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.primary,
                  ),
                );
              },
            )
          else
            _buildPlaceholder(context),

          // Image count badge
          if (property.images.length > 1)
            Positioned(
              top: AppSizes.smallPadding(context),
              right: AppSizes.smallPadding(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.smallPadding(context),
                  vertical: AppSizes.smallPadding(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: AppSizes.smallIcon(context) * 0.7,
                      color: Colors.white,
                    ),
                    SizedBox(width: AppSizes.smallPadding(context) / 3),
                    Text(
                      '${property.images.length}',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context) * 0.85,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.05),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: AppSizes.largeIcon(context),
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              'No Image Available',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context),
        vertical: AppSizes.smallPadding(context) / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSizes.smallIcon(context) * 0.9,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: AppSizes.smallPadding(context) / 2),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInfo(
      BuildContext context,
      String label,
      String amount,
      Color color,
      ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.85,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.smallPadding(context) / 3),
          Text(
            amount,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    }
    return amount.toString();
  }

  Color _getOccupancyColor(double percentage) {
    if (percentage >= 0.9) {
      return AppColors.error;
    } else if (percentage >= 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();
    if (amenityLower.contains('wifi') || amenityLower.contains('internet')) {
      return Icons.wifi;
    } else if (amenityLower.contains('parking')) {
      return Icons.local_parking;
    } else if (amenityLower.contains('cctv') || amenityLower.contains('security')) {
      return Icons.security;
    } else if (amenityLower.contains('water')) {
      return Icons.water_drop;
    } else if (amenityLower.contains('ac') || amenityLower.contains('air')) {
      return Icons.ac_unit;
    } else if (amenityLower.contains('laundry')) {
      return Icons.local_laundry_service;
    } else if (amenityLower.contains('gym')) {
      return Icons.fitness_center;
    } else if (amenityLower.contains('power') || amenityLower.contains('backup')) {
      return Icons.power;
    } else {
      return Icons.check_circle_outline;
    }
  }
}