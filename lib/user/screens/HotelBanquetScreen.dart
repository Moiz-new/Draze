import 'package:flutter/material.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'dart:async';

import 'HotelBanquetDetailsScreen.dart';

class HotelBanquetScreen extends StatefulWidget {
  final String searchQuery;

  const HotelBanquetScreen({super.key, this.searchQuery = ''});

  @override
  State<HotelBanquetScreen> createState() => _HotelBanquetScreenState();
}

class _HotelBanquetScreenState extends State<HotelBanquetScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Hotel> _allHotels = [];
  List<Hotel> _filteredHotels = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  @override
  void didUpdateWidget(HotelBanquetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterHotels(widget.searchQuery);
    }
  }

  Future<void> _fetchHotels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.drazeapp.com/api/hotelbanquet/api/hotels/all'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> hotelsData = jsonData['data'];

          setState(() {
            _allHotels = hotelsData.map((json) => Hotel.fromJson(json)).toList();
            _filteredHotels = _allHotels;
            _isLoading = false;
          });

          // Apply search if there's an initial search query
          if (widget.searchQuery.isNotEmpty) {
            _filterHotels(widget.searchQuery);
          }
        } else {
          setState(() {
            _errorMessage = 'Failed to load hotels';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterHotels(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        setState(() {
          _filteredHotels = _allHotels;
        });
      } else {
        final lowerQuery = query.toLowerCase();
        setState(() {
          _filteredHotels = _allHotels.where((hotel) {
            return hotel.name.toLowerCase().contains(lowerQuery) ||
                hotel.city.toLowerCase().contains(lowerQuery) ||
                hotel.address.toLowerCase().contains(lowerQuery) ||
                hotel.state.toLowerCase().contains(lowerQuery);
          }).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_filteredHotels.isEmpty && widget.searchQuery.isNotEmpty) {
      return _buildEmptySearchState();
    }

    if (_filteredHotels.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchHotels,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        itemCount: _filteredHotels.length,
        itemBuilder: (context, index) {
          return _buildHotelCard(_filteredHotels[index]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Loading.json',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Hotels...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.smallText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchHotels,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hotels found',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Hotels Available',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hotels will appear here once they are added',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelBanquetDetailsScreen(hotel: hotel),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(hotel),
            // Content Section
            Padding(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: TextStyle(
                            fontSize: AppSizes.mediumText(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(hotel.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildLocationRow(hotel),
                  const SizedBox(height: 12),
                  Text(
                    hotel.description,
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _buildAmenitiesRow(hotel),
                  const SizedBox(height: 12),
                  _buildContactRow(hotel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Hotel hotel) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.7),
            const Color(0xFF7c6eff).withOpacity(0.7),
          ],
        ),
      ),
      child: hotel.images.isNotEmpty
          ? ClipRRect(
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          hotel.images.first,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholderImage(),
        ),
      )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image Available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildLocationRow(Hotel hotel) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${hotel.city}, ${hotel.state}',
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesRow(Hotel hotel) {
    final amenities = hotel.amenities.take(3).toList();

    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getAmenityIcon(amenity),
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                amenity,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactRow(Hotel hotel) {
    return Row(
      children: [
        Icon(
          Icons.phone,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 4),
        Text(
          hotel.contactNumber,
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 10,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
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
    }
    return Icons.check_circle;
  }
}

// Hotel Model
class Hotel {
  final String id;
  final String hotelId;
  final String name;
  final String description;
  final String status;
  final String verificationStatus;
  final String userId;
  final String registrationNumber;
  final List<String> amenities;
  final String contactNumber;
  final String alternateContact;
  final String email;
  final String website;
  final String address;
  final String city;
  final String state;
  final String districtId;
  final String pincode;
  final List<String> images;
  final List<String> videos;
  final bool isAvailable;
  final double latitude;
  final double longitude;

  Hotel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.description,
    required this.status,
    required this.verificationStatus,
    required this.userId,
    required this.registrationNumber,
    required this.amenities,
    required this.contactNumber,
    required this.alternateContact,
    required this.email,
    required this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.districtId,
    required this.pincode,
    required this.images,
    required this.videos,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    List<String> parseAmenities(List<dynamic>? amenitiesData) {
      if (amenitiesData == null || amenitiesData.isEmpty) return [];

      List<String> result = [];
      for (var item in amenitiesData) {
        if (item is String) {
          // Parse the string format: ["AC","Swimming","Gym",]
          String cleaned = item.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
          List<String> parsed = cleaned.split(',').where((s) => s.trim().isNotEmpty).toList();
          result.addAll(parsed);
        }
      }
      return result;
    }

    final coordinates = json['location']?['coordinates'] ?? [0.0, 0.0];

    return Hotel(
      id: json['_id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      name: json['name'] ?? 'Unnamed Hotel',
      description: json['description'] ?? 'No description available',
      status: json['status'] ?? 'pending',
      verificationStatus: json['verificationStatus'] ?? 'pending',
      userId: json['userId'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      amenities: parseAmenities(json['amenities']),
      contactNumber: json['contactNumber'] ?? '',
      alternateContact: json['alternateContact'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      districtId: json['districtId'] ?? '',
      pincode: json['pincode'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos']) : [],
      isAvailable: json['isAvailable'] ?? true,
      latitude: coordinates[1]?.toDouble() ?? 0.0,
      longitude: coordinates[0]?.toDouble() ?? 0.0,
    );
  }
}