// lib/landlord/widgets/property_card.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';

import 'package:draze/landlord/models/property_model.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.property.status) {
      case PropertyStatus.active:
        return AppColors.success;
      case PropertyStatus.inactive:
        return AppColors.error;
      case PropertyStatus.rented:
        return AppColors.primary;
      case PropertyStatus.maintenance:
        return Colors.orange;
      case PropertyStatus.pending:
        return Colors.amber;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.property.status) {
      case PropertyStatus.active:
        return Icons.check_circle;
      case PropertyStatus.inactive:
        return Icons.cancel;
      case PropertyStatus.rented:
        return Icons.home;
      case PropertyStatus.maintenance:
        return Icons.build;
      case PropertyStatus.pending:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context) * 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: AppColors.divider.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: (_) => _animationController.forward(),
                  onTapUp: (_) => _animationController.reverse(),
                  onTapCancel: () => _animationController.reverse(),
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius(context) * 1.5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius(context) * 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20,
                          left: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: 100,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.all(
                            AppSizes.mediumPadding(context) * 1.2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with enhanced status
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.property.name,
                                          style: TextStyle(
                                            fontSize: AppSizes.mediumText(
                                              context,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              AppSizes.smallPadding(context) *
                                              0.5,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppSizes.smallPadding(
                                              context,
                                            ),
                                            vertical:
                                                AppSizes.smallPadding(context) *
                                                0.3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.cardCornerRadius(
                                                    context,
                                                  ) *
                                                  0.8,
                                            ),
                                          ),
                                          child: Text(
                                            widget.property.type.displayName,
                                            style: TextStyle(
                                              fontSize: AppSizes.smallText(
                                                context,
                                              ),
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Enhanced status badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppSizes.smallPadding(context) * 1.2,
                                      vertical:
                                          AppSizes.smallPadding(context) * 0.7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.cardCornerRadius(context),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getStatusColor().withOpacity(
                                            0.3,
                                          ),
                                          offset: const Offset(0, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(),
                                          color: Colors.white,
                                          size: AppSizes.smallIcon(context),
                                        ),
                                        SizedBox(
                                          width:
                                              AppSizes.smallPadding(context) *
                                              0.5,
                                        ),
                                        Text(
                                          widget.property.status.displayName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: AppSizes.smallText(
                                              context,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: AppSizes.mediumPadding(context)),

                              // Enhanced address with icon
                              Container(
                                padding: EdgeInsets.all(
                                  AppSizes.smallPadding(context) * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.cardCornerRadius(context) * 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(
                                        AppSizes.smallPadding(context) * 0.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.cardCornerRadius(context) *
                                              0.6,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: AppColors.primary,
                                        size: AppSizes.smallIcon(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: AppSizes.smallPadding(context),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.property.address,
                                            style: TextStyle(
                                              fontSize: AppSizes.smallText(
                                                context,
                                              ),
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${widget.property.city}, ${widget.property.state} ${widget.property.pincode}',
                                            style: TextStyle(
                                              fontSize: AppSizes.smallText(
                                                context,
                                              ),
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: AppSizes.mediumPadding(context)),

                              // Enhanced property details with better spacing
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildEnhancedDetailChip(
                                      context,
                                      Icons.meeting_room,
                                      '${widget.property.totalRooms}',
                                      'Rooms',
                                      AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSizes.smallPadding(context),
                                  ),
                                  Expanded(
                                    child: _buildEnhancedDetailChip(
                                      context,
                                      Icons.square_foot,
                                      '${widget.property.totalArea.toInt()}',
                                      'sq ft',
                                      AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),

                              if (widget.property.description.isNotEmpty) ...[
                                SizedBox(
                                  height: AppSizes.mediumPadding(context),
                                ),
                                Container(
                                  padding: EdgeInsets.all(
                                    AppSizes.smallPadding(context),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background.withOpacity(
                                      0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.cardCornerRadius(context) * 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    widget.property.description,
                                    style: TextStyle(
                                      fontSize: AppSizes.smallText(context),
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],

                              SizedBox(height: AppSizes.mediumPadding(context)),

                              // Enhanced amenities section
                              if (widget.property.amenities.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: AppColors.primary,
                                      size: AppSizes.smallIcon(context),
                                    ),
                                    SizedBox(
                                      width:
                                          AppSizes.smallPadding(context) * 0.5,
                                    ),
                                    Text(
                                      'Amenities',
                                      style: TextStyle(
                                        fontSize:
                                            AppSizes.smallText(context) * 1.1,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: AppSizes.smallPadding(context) * 0.7,
                                ),
                                Wrap(
                                  spacing: AppSizes.smallPadding(context) * 0.7,
                                  runSpacing:
                                      AppSizes.smallPadding(context) * 0.5,
                                  children:
                                      widget.property.amenities.take(4).map((
                                        amenity,
                                      ) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                AppSizes.smallPadding(context) *
                                                0.8,
                                            vertical:
                                                AppSizes.smallPadding(context) *
                                                0.4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary.withOpacity(
                                                  0.1,
                                                ),
                                                AppColors.primary.withOpacity(
                                                  0.05,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.cardCornerRadius(
                                                    context,
                                                  ) *
                                                  0.8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            amenity,
                                            style: TextStyle(
                                              fontSize:
                                                  AppSizes.smallText(context) *
                                                  0.9,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                                if (widget.property.amenities.length > 4) ...[
                                  SizedBox(
                                    height:
                                        AppSizes.smallPadding(context) * 0.5,
                                  ),
                                  Text(
                                    '+${widget.property.amenities.length - 4} more',
                                    style: TextStyle(
                                      fontSize:
                                          AppSizes.smallText(context) * 0.9,
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                SizedBox(
                                  height: AppSizes.mediumPadding(context),
                                ),
                              ],

                              // Enhanced footer with better visual hierarchy
                              Container(
                                padding: EdgeInsets.all(
                                  AppSizes.smallPadding(context) * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.cardCornerRadius(context) * 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          color: AppColors.textSecondary,
                                          size: AppSizes.smallIcon(context),
                                        ),
                                        SizedBox(
                                          width:
                                              AppSizes.smallPadding(context) *
                                              0.5,
                                        ),
                                        Text(
                                          'Added ${_formatDate(widget.property.createdAt)}',
                                          style: TextStyle(
                                            fontSize: AppSizes.smallText(
                                              context,
                                            ),
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(
                                        AppSizes.smallPadding(context) * 0.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.cardCornerRadius(context) *
                                              0.6,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: AppColors.primary,
                                        size: AppSizes.smallIcon(context),
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedDetailChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.smallPadding(context) * 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 0.8,
        ),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppSizes.smallIcon(context) * 1.2),
          SizedBox(width: AppSizes.smallPadding(context) * 0.6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.smallText(context) * 0.9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return '1 day ago';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
