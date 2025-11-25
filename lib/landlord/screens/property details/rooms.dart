import 'package:draze/landlord/models/FetchRoomModel.dart';
import 'package:draze/landlord/screens/property%20details/AddRoomImagesScreen.dart';
import 'package:draze/landlord/screens/property%20details/RoomDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/providers/room_provider.dart';

class RoomsTab extends StatefulWidget {
  final String propertyId;

  const RoomsTab({super.key, required this.propertyId});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomProvider>(
        context,
        listen: false,
      ).loadRooms(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        // Show content without header if no rooms
        if (!roomProvider.isLoading && roomProvider.rooms.isEmpty) {
          return _buildContent(context);
        }

        // Show header and content for other states
        return Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent(context)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3.2,
            offset: const Offset(0, 1.6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rooms',
            style: TextStyle(
              fontSize: AppSizes.largeText(context) * 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(
            height: AppSizes.buttonHeight(context) * 0.8,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push(
                  '/properties/property-details/${widget.propertyId}/add-room',
                );

                // Refresh room list if room was added successfully
                if (result == true && mounted) {
                  Provider.of<RoomProvider>(
                    context,
                    listen: false,
                  ).loadRooms(widget.propertyId);
                }
              },
              icon: const Icon(Icons.add, size: 12.8, color: Colors.white),
              label: Text(
                'Add Room',
                style: TextStyle(
                  fontSize: AppSizes.smallText(context) * 0.8,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.6,
                  vertical: 4.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        if (roomProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (roomProvider.error != null) {
          return _buildErrorState(context, roomProvider.error!);
        }

        if (roomProvider.rooms.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildRoomsList(context, roomProvider.rooms);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.meeting_room_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
          Text(
            'No rooms added yet',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context) * 0.8,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6.4),
          Text(
            'Start by adding your first room',
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.mediumPadding(context) * 1.5),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push(
                '/properties/property-details/${widget.propertyId}/add-room',
              );

              // Refresh room list if room was added successfully
              if (result == true && mounted) {
                Provider.of<RoomProvider>(
                  context,
                  listen: false,
                ).loadRooms(widget.propertyId);
              }
            },
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              'Add Room',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context) * 0.8,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
          Text(
            'Error loading rooms',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context) * 0.8,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6.4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.smallText(context) * 0.8,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<RoomProvider>(
                context,
                listen: false,
              ).loadRooms(widget.propertyId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(BuildContext context, List<FetchRoomModel> rooms) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 1.2),
      itemCount: rooms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12.8),
      itemBuilder: (context, index) {
        return RoomCard(room: rooms[index], propertyId: widget.propertyId);
      },
    );
  }
}

// RoomCard class remains the same as in your original code
class RoomCard extends StatefulWidget {
  final FetchRoomModel room;
  final String propertyId;

  const RoomCard({super.key, required this.room, required this.propertyId});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _showMore = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  List<String> _roomImages = [];
  bool _isLoadingImages = true;

  @override
  void initState() {
    super.initState();
    _loadRoomImages();
  }

  Future<void> _loadRoomImages() async {
    setState(() {
      _isLoadingImages = true;
    });

    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final images = await roomProvider.getRoomImages(
        widget.propertyId,
        widget.room.roomId,
      );

      setState(() {
        _roomImages = images;
        _isLoadingImages = false;
      });
    } catch (e) {
      setState(() {
        _roomImages = [];
        _isLoadingImages = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RoomDetailsScreen(
                  propertyId: widget.propertyId,
                  roomId: widget.room.roomId,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6.4,
              offset: const Offset(0, 1.6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildRoomInfo(),
            if (_showMore) _buildExpandedDetails(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          if (_isLoadingImages)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.8),
                  topRight: Radius.circular(12.8),
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_roomImages.isEmpty)
            _buildEmptyImageState()
          else
            _buildImageCarousel(),
          Positioned(
            top: 9.6,
            right: 9.6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.4,
                vertical: 3.2,
              ),
              decoration: BoxDecoration(
                color:
                    widget.room.status.toLowerCase() == 'available'
                        ? Colors.green
                        : Colors.orange,
                borderRadius: BorderRadius.circular(9.6),
              ),
              child: Text(
                widget.room.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (_roomImages.length > 1)
            Positioned(
              bottom: 9.6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_roomImages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentImageIndex == index ? 16 : 4.8,
                    height: 4.8,
                    margin: const EdgeInsets.symmetric(horizontal: 1.6),
                    decoration: BoxDecoration(
                      color:
                          _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyImageState() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12.8),
        topRight: Radius.circular(12.8),
      ),
      child: Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddRoomImagesScreen(
                            propertyId: widget.propertyId,
                            roomId: widget.room.roomId,
                          ),
                    ),
                  );
                  if (result == true && mounted) {
                    _loadRoomImages();
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12.8),
        topRight: Radius.circular(12.8),
      ),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentImageIndex = index;
          });
        },
        itemCount: _roomImages.length,
        itemBuilder: (context, index) {
          return Image.network(
            _roomImages[index],
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  size: 38.4,
                  color: Colors.grey[400],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Padding(
      padding: const EdgeInsets.all(12.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.room.name,
                  style: const TextStyle(
                    fontSize: 14.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.4,
                  vertical: 3.2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.4),
                ),
                child: Text(
                  widget.room.type,
                  style: TextStyle(
                    fontSize: 9.6,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.4),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 12.8, color: AppColors.primary),
              Text(
                '${widget.room.price.toStringAsFixed(0)}/month',
                style: TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12.8),
              Icon(Icons.people, size: 12.8, color: Colors.grey[600]),
              const SizedBox(width: 3.2),
              Text(
                'Capacity: ${widget.room.capacity}',
                style: TextStyle(fontSize: 11.2, color: Colors.grey[600]),
              ),
            ],
          ),
          if (widget.room.beds.isNotEmpty) ...[
            const SizedBox(height: 6.4),
            Row(
              children: [
                Icon(Icons.bed, size: 12.8, color: Colors.grey[600]),
                const SizedBox(width: 3.2),
                Text(
                  '${widget.room.beds.length} bed${widget.room.beds.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 11.2, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.8, 0, 12.8, 12.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 0.8),
          const SizedBox(height: 12.8),
          if (widget.room.floorNumber != null)
            _buildDetailRow('Floor', widget.room.floorNumber.toString()),
          if (widget.room.securityDeposit > 0)
            _buildDetailRow(
              'Deposit',
              '₹${widget.room.securityDeposit.toStringAsFixed(0)}',
            ),
          if (widget.room.roomSize != null && widget.room.roomSize!.isNotEmpty)
            _buildDetailRow('Room Size', widget.room.roomSize!),
          if (widget.room.noticePeriod > 0)
            _buildDetailRow(
              'Notice Period',
              '${widget.room.noticePeriod} days',
            ),
          if (widget.room.beds.isNotEmpty) ...[
            const SizedBox(height: 9.6),
            Text(
              'Beds',
              style: TextStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6.4),
            ...widget.room.beds.map((bed) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bed.name!,
                        style: const TextStyle(
                          fontSize: 10.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.4,
                        vertical: 2.4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4.8),
                      ),
                      child: Text(
                        '₹${bed.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 9.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.2, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.2,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.8, vertical: 6.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 28.8,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push(
                  '/properties/property-details/${widget.propertyId}/edit-room/${widget.room.roomId}',
                );
                if (result == true && mounted) {
                  Provider.of<RoomProvider>(
                    context,
                    listen: false,
                  ).loadRooms(widget.propertyId);
                }
              },
              icon: const Icon(Icons.edit, size: 12.8, color: Colors.white),
              label: const Text(
                'Edit',
                style: TextStyle(fontSize: 9.6, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.4,
                  vertical: 3.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6.4),
          SizedBox(
            height: 28.8,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed == true && mounted) {
                  _handleDelete();
                }
              },
              icon: const Icon(Icons.delete, size: 12.8, color: Colors.white),
              label: const Text(
                'Delete',
                style: TextStyle(fontSize: 9.6, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.4,
                  vertical: 3.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete ${widget.room.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  Future<void> _handleDelete() async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final result = await roomProvider.deleteRoom(
      widget.propertyId,
      widget.room.roomId,
    );

    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.6),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.6),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }
}
