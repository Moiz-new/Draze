// lib/landlord/widgets/enhanced_property_filter_sheet.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:draze/landlord/models/property_model.dart';
import 'package:draze/landlord/providers/property_provider.dart';

class EnhancedPropertyFilterSheet extends ConsumerStatefulWidget {
  const EnhancedPropertyFilterSheet({super.key});

  @override
  ConsumerState<EnhancedPropertyFilterSheet> createState() =>
      _EnhancedPropertyFilterSheetState();
}

class _EnhancedPropertyFilterSheetState
    extends ConsumerState<EnhancedPropertyFilterSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(propertyFilterProvider);
    final selectedStatus = ref.watch(propertyStatusFilterProvider);
    final selectedPriceRange = ref.watch(propertyPriceRangeProvider);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3 * _fadeAnimation.value),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(
                0,
                MediaQuery.of(context).size.height *
                    0.7 *
                    _slideAnimation.value,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      AppSizes.cardCornerRadius(context) * 2,
                    ),
                    topRight: Radius.circular(
                      AppSizes.cardCornerRadius(context) * 2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, -4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(
                        top: AppSizes.smallPadding(context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Properties',
                            style: TextStyle(
                              fontSize: AppSizes.largeText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.mediumPadding(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Property Type Section
                            _buildFilterSection(
                              'Property Type',
                              Icons.home_work_outlined,
                              Column(
                                children: [],
                              ),
                            ),

                            SizedBox(height: AppSizes.largePadding(context)),

                            // Status Section
                            _buildFilterSection(
                              'Status',
                              Icons.check_circle_outline,
                              Column(
                                children: [
                                  _buildStatusGrid(selectedStatus as String?),
                                ],
                              ),
                            ),

                            SizedBox(height: AppSizes.largePadding(context)),

                            // Price Range Section
                            _buildFilterSection(
                              'Price Range',
                              Icons.attach_money_outlined,
                              Column(
                                children: [
                                  _buildPriceRangeSlider(selectedPriceRange),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: AppSizes.largePadding(context) * 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Actions
                    Container(
                      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, -2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Clear all filters
                                ref
                                    .read(propertyFilterProvider.notifier)
                                    .state = null;
                                ref
                                    .read(propertyStatusFilterProvider.notifier)
                                    .state = null;
                                ref
                                    .read(propertyPriceRangeProvider.notifier)
                                    .state = const RangeValues(0, 100000);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.textSecondary,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSizes.mediumPadding(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.cardCornerRadius(context),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppSizes.mediumText(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.mediumPadding(context)),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSizes.mediumPadding(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.cardCornerRadius(context),
                                  ),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  fontSize: AppSizes.mediumText(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
        );
      },
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.smallPadding(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSizes.smallIcon(context),
              ),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        content,
      ],
    );
  }

/*
  Widget _buildTypeGrid(PropertyType? selectedFilter) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.smallPadding(context),
      mainAxisSpacing: AppSizes.smallPadding(context),
      childAspectRatio: 3,
      children: [
        _buildFilterOption(
          'All',
          Icons.select_all,
          selectedFilter == null,
          () => ref.read(propertyFilterProvider.notifier).state = null,
        ),
        ...PropertyType.values.map((type) {
          IconData icon;
          switch (type) {
            case PropertyType.apartment:
              icon = Icons.apartment;
              break;
            case PropertyType.house:
              icon = Icons.house;
              break;
            case PropertyType.office:
              icon = Icons.business;
              break;
            case PropertyType.shops:
              icon = Icons.store;
              break;
            default:
              icon = Icons.home;
          }

          return _buildFilterOption(
            type.displayName,
            icon,
            selectedFilter == type,
            () => ref.read(propertyFilterProvider.notifier).state = type,
          );
        }),
      ],
    );
  }
*/

  Widget _buildStatusGrid(String? selectedStatus) {
    final statuses = [
      {'name': 'All', 'icon': Icons.select_all, 'value': null},
      {'name': 'Active', 'icon': Icons.check_circle, 'value': 'active'},
      {'name': 'Rented', 'icon': Icons.key, 'value': 'rented'},
      {'name': 'Maintenance', 'icon': Icons.build, 'value': 'maintenance'},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.smallPadding(context),
      mainAxisSpacing: AppSizes.smallPadding(context),
      childAspectRatio: 3,
      children:
          statuses.map((status) {
            return _buildFilterOption(
              status['name'] as String,
              status['icon'] as IconData,
              selectedStatus == status['value'],
              () =>
                  ref.read(propertyStatusFilterProvider.notifier).state =
                      status['value'] as PropertyStatus?,
            );
          }).toList(),
    );
  }

  Widget _buildFilterOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: AppSizes.smallIcon(context),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSlider(RangeValues selectedPriceRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.mediumPadding(context),
                vertical: AppSizes.smallPadding(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
              ),
              child: Text(
                '₹${selectedPriceRange.start.toInt()}',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              'to',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.mediumPadding(context),
                vertical: AppSizes.smallPadding(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
              ),
              child: Text(
                '₹${selectedPriceRange.end.toInt()}',
                style: TextStyle(
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: RangeSlider(
            values: selectedPriceRange,
            min: 0,
            max: 100000,
            divisions: 100,
            onChanged: (RangeValues values) {
              ref.read(propertyPriceRangeProvider.notifier).state = values;
            },
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹0',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '₹1,00,000+',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Updated PropertyFilterChips for horizontal scrolling
class PropertyFilterChips extends ConsumerWidget {
  const PropertyFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(propertyFilterProvider);

    return /*SizedBox(
      height: AppSizes.buttonHeight(context),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.mediumPadding(context),
        ),
        children: [
          // All properties chip
          _buildFilterChip(
            context,
            ref,
            'All Properties',
            null,
            selectedFilter == null,
          ),
          SizedBox(width: AppSizes.smallPadding(context)),

          // Property type chips
          ...PropertyType.values.map((type) {
            IconData icon;
            switch (type) {
              case PropertyType.apartment:
                icon = Icons.apartment;
                break;
              case PropertyType.house:
                icon = Icons.house;
                break;
              case PropertyType.office:
                icon = Icons.business;
                break;
              case PropertyType.shops:
                icon = Icons.store;
                break;
              default:
                icon = Icons.home;
            }

            return Padding(
              padding: EdgeInsets.only(right: AppSizes.smallPadding(context)),
              child: _buildEnhancedFilterChip(
                context,
                ref,
                type.displayName,
                icon,
                type,
                selectedFilter == type,
              ),
            );
          }),
        ],
      ),
    );*/
    SizedBox();
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    PropertyType? type,
    bool isSelected,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: AppSizes.smallText(context),
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(propertyFilterProvider.notifier).state =
            selected ? type : null;
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 1.5,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
      ),
    );
  }

  Widget _buildEnhancedFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    PropertyType? type,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(propertyFilterProvider.notifier).state =
            isSelected ? null : type;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.mediumPadding(context),
          vertical: AppSizes.smallPadding(context),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 1.5,
          ),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: AppSizes.smallIcon(context),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
