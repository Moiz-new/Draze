import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/user/models/hotel_modal.dart';
import 'package:draze/user/models/rent_property.dart';
import 'package:draze/user/models/sell_modal.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/RentPropertyModel.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (property == null) {
      return const SizedBox.shrink();
    }

    final propertyData = _extractPropertyData();
    if (propertyData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context, propertyData),
            _buildContentSection(context, propertyData),
          ],
        ),
      ),
    );
  }

  PropertyData? _extractPropertyData() {
    try {
      if (property is RentProperty) {
        final rentProp = property as RentProperty;
        return PropertyData(
          title: rentProp.title ?? 'Untitled Property',
          price: '₹${_formatPrice(rentProp.monthlyRent.toDouble() ?? 0)}/mo',
          location:
              '${rentProp.city ?? 'Unknown'}, ${rentProp.state ?? 'Unknown'}',
          images: rentProp.images ?? [],
          type: PropertyType.rent,
          bedrooms: rentProp.bedrooms ?? 0,
          bathrooms: rentProp.bathrooms ?? 0,
          area: rentProp.areaSquareFeet.toInt() ?? 0,
          starRating: null,
          totalRooms: null,
          hasBreakfast: null,
          propertyType: rentProp.propertyType ?? 'Apartment',
          furnishingStatus: null,
          isVerified: rentProp.isVerified ?? false,
        );
      } else if (property is SellProperty) {
        final sellProp = property as SellProperty;
        return PropertyData(
          title: sellProp.title ?? 'Untitled Property',
          price: '₹${_formatPrice(sellProp.price.toDouble() ?? 0)}',
          location:
              '${sellProp.city ?? 'Unknown'}, ${sellProp.state ?? 'Unknown'}',
          images: sellProp.images ?? [],
          type: PropertyType.sell,
          bedrooms: sellProp.bedrooms ?? 0,
          bathrooms: sellProp.bathrooms ?? 0,
          area: sellProp.areaSquareFeet.toInt() ?? 0,
          starRating: null,
          totalRooms: null,
          hasBreakfast: null,
          propertyType: sellProp.propertyType ?? 'House',
          furnishingStatus: null,
          isVerified: sellProp.isVerified ?? false,
        );
      } else if (property is HotelProperty) {
        final hotelProp = property as HotelProperty;
        return PropertyData(
          title: hotelProp.name ?? 'Unnamed Hotel',
          price:
              '₹${_formatPrice(hotelProp.pricePerNight.toDouble() ?? 0)}/night',
          location:
              '${hotelProp.city ?? 'Unknown'}, ${hotelProp.state ?? 'Unknown'}',
          images: hotelProp.images ?? [],
          type: PropertyType.hotel,
          bedrooms: null,
          bathrooms: null,
          area: null,
          starRating: hotelProp.starRating ?? 0,
          totalRooms: hotelProp.totalRooms ?? 0,
          hasBreakfast: hotelProp.hasBreakfast ?? false,
          propertyType: 'Hotel',
          furnishingStatus: null,
          isVerified: hotelProp.isVerified ?? false,
        );
      }
    } catch (e) {
      debugPrint('Error extracting property data: $e');
      return null;
    }
    return null;
  }

  Widget _buildImageSection(BuildContext context, PropertyData data) {
    final imageUrl = data.images.isNotEmpty ? data.images.first : null;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child:
                imageUrl != null
                    ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      memCacheHeight: 300,
                      maxWidthDiskCache: 400,
                      maxHeightDiskCache: 300,
                      placeholder:
                          (context, url) => Container(
                            color: AppColors.divider.withOpacity(0.3),
                            child: Center(
                              child: Lottie.asset(
                                'assets/animations/Loading.json',
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => _buildPlaceholderImage(),
                    )
                    : _buildPlaceholderImage(),
          ),
        ),

        // Property type badge
        Positioned(
          top: 12,
          left: 12,
          child: _buildPropertyTypeBadge(context, data.type),
        ),

        // Verification badge
        if (data.isVerified)
          //Positioned(top: 12, left: 80, child: _buildVerificationBadge()),

        // Favorite button
        //Positioned(top: 12, right: 12, child: _buildFavoriteButton()),

        // Image count indicator
        if (data.images.length > 1)
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildImageCountChip(data.images.length),
          ),

        // Quick info chip
        Positioned(
          bottom: 12,
          right: 12,
          child: _buildQuickInfoChip(context, data),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.divider.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPropertyTypeBadge(BuildContext context, PropertyType type) {
    final typeConfig = _getTypeConfiguration(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeConfig['color'],
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(typeConfig['icon'], size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            typeConfig['text'],
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'VERIFIED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCountChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_library, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

/*
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavoriteToggle,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: isFavorite ?? false ? Colors.red : Colors.grey[600],
        ),
      ),
    );
  }
*/

  Widget _buildQuickInfoChip(BuildContext context, PropertyData data) {
    String quickInfo = '';
    IconData quickIcon = Icons.info_outline;

    switch (data.type) {
      case PropertyType.rent:
      case PropertyType.sell:
        if (data.bedrooms != null && data.bedrooms! > 0) {
          quickInfo = '${data.bedrooms} BHK';
          quickIcon = Icons.home_outlined;
        }
        break;
      case PropertyType.hotel:
        if (data.starRating != null && data.starRating! > 0) {
          quickInfo = '${data.starRating}★';
          quickIcon = Icons.star_outline;
        }
        break;
    }

    if (quickInfo.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(quickIcon, size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            quickInfo,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, PropertyData data) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Property details row
          _buildPropertyDetailsRow(data),
          const SizedBox(height: 8),

          // Price
          Text(
            data.price,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetailsRow(PropertyData data) {
    List<Widget> details = [];

    switch (data.type) {
      case PropertyType.rent:
      case PropertyType.sell:
        if (data.bedrooms != null && data.bedrooms! > 0) {
          details.add(_buildDetailChip(Icons.bed, '${data.bedrooms} BR'));
        }
        if (data.bathrooms != null && data.bathrooms! > 0) {
          details.add(_buildDetailChip(Icons.bathtub, '${data.bathrooms} BA'));
        }
        if (data.area != null && data.area! > 0) {
          details.add(
            _buildDetailChip(Icons.square_foot, '${data.area} sq ft'),
          );
        }
        if (data.propertyType.isNotEmpty) {
          details.add(_buildDetailChip(Icons.home_work, data.propertyType));
        }
        break;
      case PropertyType.hotel:
        if (data.totalRooms != null && data.totalRooms! > 0) {
          details.add(
            _buildDetailChip(Icons.hotel, '${data.totalRooms} Rooms'),
          );
        }
        if (data.hasBreakfast == true) {
          details.add(_buildDetailChip(Icons.free_breakfast, 'Breakfast'));
        }
        if (data.starRating != null && data.starRating! > 0) {
          details.add(_buildDetailChip(Icons.star, '${data.starRating} Star'));
        }
        break;
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children:
          details.take(3).toList(), // Limit to 3 details to avoid overflow
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTypeConfiguration(PropertyType type) {
    switch (type) {
      case PropertyType.rent:
        return {
          'text': 'RENT',
          'color': Colors.green,
          'icon': Icons.key_outlined,
        };
      case PropertyType.sell:
        return {
          'text': 'SALE',
          'color': Colors.blue,
          'icon': Icons.sell_outlined,
        };
      case PropertyType.hotel:
        return {
          'text': 'HOTEL',
          'color': Colors.orange,
          'icon': Icons.hotel_outlined,
        };
    }
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} K';
    }
    return price.toStringAsFixed(0);
  }
}

class PropertyData {
  final String title;
  final String price;
  final String location;
  final List<String> images;
  final PropertyType type;
  final int? bedrooms;
  final int? bathrooms;
  final int? area;
  final int? starRating;
  final int? totalRooms;
  final bool? hasBreakfast;
  final String propertyType;
  final String? furnishingStatus;
  final bool isVerified;

  PropertyData({
    required this.title,
    required this.price,
    required this.location,
    required this.images,
    required this.type,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.starRating,
    this.totalRooms,
    this.hasBreakfast,
    required this.propertyType,
    this.furnishingStatus,
    required this.isVerified,
  });
}

enum PropertyType { rent, sell, hotel }
