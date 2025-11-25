import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/user/provider/property_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  RangeValues _priceRange = const RangeValues(0, 1000000);
  int _minBedrooms = 1;
  int _maxBedrooms = 5;
  String _furnishedType = 'Any';
  bool _hasParking = false;
  bool _isVerified = false;
  String _city = '';
  final List<String> _propertyTypes = [];
  final List<String> _amenities = [];
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    // Initialize with current filter state
    _initializeFilters();
  }

  void _initializeFilters() {
    final currentFilters = ref.read(filterOptionsProvider);
    setState(() {
      _priceRange = RangeValues(
        currentFilters.minPrice ?? 0,
        currentFilters.maxPrice ?? 1000000,
      );
      _minBedrooms = currentFilters.minBedrooms ?? 1;
      _maxBedrooms = currentFilters.maxBedrooms ?? 5;
      _furnishedType =
          currentFilters.furnishedType?.toLowerCase() == 'fully'
              ? 'Fully'
              : currentFilters.furnishedType?.toLowerCase() == 'semi'
              ? 'Semi'
              : currentFilters.furnishedType?.toLowerCase() == 'unfurnished'
              ? 'Unfurnished'
              : 'Any';
      _hasParking = currentFilters.hasParking ?? false;
      _isVerified = currentFilters.isVerified ?? false;
      _city = currentFilters.city ?? '';
      _cityController.text = _city;
      _propertyTypes.clear();
      _propertyTypes.addAll(currentFilters.propertyTypes);
      _amenities.clear();
      _amenities.addAll(currentFilters.amenities);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85; // Leave 15% space from top

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 50),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPriceSection(selectedTab),
                          const SizedBox(height: 24),
                          if (selectedTab != 2) _buildBedroomSection(),
                          if (selectedTab != 2) const SizedBox(height: 24),
                          if (selectedTab == 0) _buildFurnishedSection(),
                          if (selectedTab == 0) const SizedBox(height: 24),
                          _buildToggleSection(),
                          // const SizedBox(height: 24),
                          // _buildCitySection(),
                          const SizedBox(height: 24),
                          _buildPropertyTypesSection(selectedTab),
                          const SizedBox(height: 24),
                          _buildAmenitiesSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Properties',
                    style: TextStyle(
                      fontSize: AppSizes.largeText(context),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(int selectedTab) {
    final maxPrice = selectedTab == 2 ? 20000.0 : 10000000.0;

    return _buildSection(
      title: 'Price Range',
      icon: Icons.currency_rupee_rounded,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Min Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${_formatPrice(_priceRange.start)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 2, height: 30, color: AppColors.divider),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Max Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${_formatPrice(_priceRange.end)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              overlayColor: AppColors.primary.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: maxPrice,
              divisions: 100,
              onChanged: (RangeValues values) {
                setState(() => _priceRange = values);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedroomSection() {
    return _buildSection(
      title: 'Bedrooms',
      icon: Icons.bed_rounded,
      child: Row(
        children: [
          Expanded(
            child: _buildCounterCard(
              'Min Bedrooms',
              _minBedrooms,
              onDecrement:
                  _minBedrooms > 1
                      ? () => setState(() => _minBedrooms--)
                      : null,
              onIncrement: () => setState(() => _minBedrooms++),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCounterCard(
              'Max Bedrooms',
              _maxBedrooms,
              onDecrement:
                  _maxBedrooms > _minBedrooms
                      ? () => setState(() => _maxBedrooms--)
                      : null,
              onIncrement: () => setState(() => _maxBedrooms++),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(
    String title,
    int value, {
    VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCounterButton(Icons.remove, onPressed: onDecrement),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildCounterButton(Icons.add, onPressed: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: onPressed != null ? Colors.white : AppColors.textSecondary,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildFurnishedSection() {
    return _buildSection(
      title: 'Furnished Type',
      icon: Icons.chair_rounded,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _furnishedType,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            items:
                ['Any', 'Fully', 'Semi', 'Unfurnished']
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _furnishedType = value!),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.settings_rounded,
      child: Column(
        children: [
          _buildToggleCard(
            'Has Parking',
            'Properties with parking space',
            Icons.local_parking_rounded,
            _hasParking,
            (value) => setState(() => _hasParking = value),
          ),
          const SizedBox(height: 12),
          _buildToggleCard(
            'Verified Properties',
            'Only show verified listings',
            Icons.verified_rounded,
            _isVerified,
            (value) => setState(() => _isVerified = value),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  value
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.divider.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitySection() {
    return _buildSection(
      title: 'Location',
      icon: Icons.location_on_rounded,
      child: TextField(
        controller: _cityController,
        onChanged: (value) => setState(() => _city = value),
        decoration: InputDecoration(
          hintText: 'Enter city name',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTypesSection(int selectedTab) {
    final types =
        selectedTab == 2
            ? ['Luxury', 'Budget', 'Business', 'Resort']
            : ['Apartment', 'House', 'Villa', 'Plot'];

    return _buildSection(
      title: 'Property Types',
      icon: Icons.home_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            types
                .map(
                  (type) => _buildChip(type, _propertyTypes.contains(type), (
                    selected,
                  ) {
                    setState(() {
                      if (selected) {
                        _propertyTypes.add(type);
                      } else {
                        _propertyTypes.remove(type);
                      }
                    });
                  }),
                )
                .toList(),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = ['WiFi', 'Parking', 'Gym', 'Pool', 'Security'];

    return _buildSection(
      title: 'Amenities',
      icon: Icons.star_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            amenities
                .map(
                  (amenity) => _buildChip(
                    amenity,
                    _amenities.contains(amenity),
                    (selected) {
                      setState(() {
                        if (selected) {
                          _amenities.add(amenity);
                        } else {
                          _amenities.remove(amenity);
                        }
                      });
                    },
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
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
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildChip(
    String label,
    bool selected,
    ValueChanged<bool> onSelected,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              selected ? AppColors.primary : AppColors.divider.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _resetFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear All',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 1000000);
      _minBedrooms = 1;
      _maxBedrooms = 5;
      _furnishedType = 'Any';
      _hasParking = false;
      _isVerified = false;
      _city = '';
      _cityController.clear();
      _propertyTypes.clear();
      _amenities.clear();
    });
  }

  void _applyFilters() {
    ref.read(filterOptionsProvider.notifier).state = FilterOptions(
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      minBedrooms: _minBedrooms,
      maxBedrooms: _maxBedrooms,
      propertyTypes: _propertyTypes.toSet(),
      amenities: _amenities.toSet(),
      furnishedType:
          _furnishedType == 'Any' ? null : _furnishedType.toLowerCase(),
      hasParking: _hasParking,
      isVerified: _isVerified,
      city: _city.isEmpty ? null : _city,
    );

    Navigator.pop(context);
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}
