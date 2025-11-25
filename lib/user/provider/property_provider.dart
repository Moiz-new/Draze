import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:draze/user/models/hotel_modal.dart';
import 'package:draze/user/models/rent_property.dart';
import 'package:draze/user/models/sell_modal.dart';

// Enum for loading states
enum PropertyLoadingState { idle, loading, loaded, error }

// Optimized Filter Options with better memory management
class FilterOptions {
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? maxBedrooms;
  final Set<String> propertyTypes;
  final Set<String> amenities;
  final String? furnishedType;
  final bool? hasParking;
  final bool? isVerified;
  final String? city;
  final String? state;
  final double? minArea;
  final double? maxArea;
  final double? minRating;
  final String? facing;
  final String? constructionStatus;
  final int? minStarRating;
  final int? maxStarRating;
  final bool? isPetFriendly;
  final bool? hasWifi;
  final bool? hasPool;
  final bool? hasGym;

  const FilterOptions({
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.maxBedrooms,
    this.propertyTypes = const {},
    this.amenities = const {},
    this.furnishedType,
    this.hasParking,
    this.isVerified,
    this.city,
    this.state,
    this.minArea,
    this.maxArea,
    this.minRating,
    this.facing,
    this.constructionStatus,
    this.minStarRating,
    this.maxStarRating,
    this.isPetFriendly,
    this.hasWifi,
    this.hasPool,
    this.hasGym,
  });

  FilterOptions copyWith({
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    Set<String>? propertyTypes,
    Set<String>? amenities,
    String? furnishedType,
    bool? hasParking,
    bool? isVerified,
    String? city,
    String? state,
    double? minArea,
    double? maxArea,
    double? minRating,
    String? facing,
    String? constructionStatus,
    int? minStarRating,
    int? maxStarRating,
    bool? isPetFriendly,
    bool? hasWifi,
    bool? hasPool,
    bool? hasGym,
  }) {
    return FilterOptions(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      amenities: amenities ?? this.amenities,
      furnishedType: furnishedType ?? this.furnishedType,
      hasParking: hasParking ?? this.hasParking,
      isVerified: isVerified ?? this.isVerified,
      city: city ?? this.city,
      state: state ?? this.state,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      minRating: minRating ?? this.minRating,
      facing: facing ?? this.facing,
      constructionStatus: constructionStatus ?? this.constructionStatus,
      minStarRating: minStarRating ?? this.minStarRating,
      maxStarRating: maxStarRating ?? this.maxStarRating,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      hasWifi: hasWifi ?? this.hasWifi,
      hasPool: hasPool ?? this.hasPool,
      hasGym: hasGym ?? this.hasGym,
    );
  }

  FilterOptions reset() => const FilterOptions();

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        minBedrooms != null ||
        maxBedrooms != null ||
        propertyTypes.isNotEmpty ||
        amenities.isNotEmpty ||
        furnishedType != null ||
        hasParking != null ||
        isVerified != null ||
        city != null ||
        state != null ||
        minArea != null ||
        maxArea != null ||
        minRating != null ||
        facing != null ||
        constructionStatus != null ||
        minStarRating != null ||
        maxStarRating != null ||
        isPetFriendly != null ||
        hasWifi != null ||
        hasPool != null ||
        hasGym != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterOptions &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.minBedrooms == minBedrooms &&
        other.maxBedrooms == maxBedrooms &&
        setEquals(other.propertyTypes, propertyTypes) &&
        setEquals(other.amenities, amenities) &&
        other.furnishedType == furnishedType &&
        other.hasParking == hasParking &&
        other.isVerified == isVerified &&
        other.city == city &&
        other.state == state &&
        other.minArea == minArea &&
        other.maxArea == maxArea &&
        other.minRating == minRating &&
        other.facing == facing &&
        other.constructionStatus == constructionStatus &&
        other.minStarRating == minStarRating &&
        other.maxStarRating == maxStarRating &&
        other.isPetFriendly == isPetFriendly &&
        other.hasWifi == hasWifi &&
        other.hasPool == hasPool &&
        other.hasGym == hasGym;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      minPrice,
      maxPrice,
      minBedrooms,
      maxBedrooms,
      propertyTypes,
      amenities,
      furnishedType,
      hasParking,
      isVerified,
      city,
      state,
      minArea,
      maxArea,
      minRating,
      facing,
      constructionStatus,
      minStarRating,
      maxStarRating,
      isPetFriendly,
      hasWifi,
      hasPool,
      hasGym,
    ]);
  }
}

enum SortOption {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
  rating,
  area,
  name,
  distance,
}

// Optimized PropertyState with better memory management
class PropertyState<T> {
  final List<T> properties;
  final PropertyLoadingState loadingState;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;
  final int totalCount;

  const PropertyState({
    this.properties = const [],
    this.loadingState = PropertyLoadingState.idle,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 0,
    this.totalCount = 0,
  });

  PropertyState<T> copyWith({
    List<T>? properties,
    PropertyLoadingState? loadingState,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
  }) {
    return PropertyState<T>(
      properties: properties ?? this.properties,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PropertyState<T> &&
        listEquals(other.properties, properties) &&
        other.loadingState == loadingState &&
        other.errorMessage == errorMessage &&
        other.hasMore == hasMore &&
        other.currentPage == currentPage &&
        other.totalCount == totalCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      properties,
      loadingState,
      errorMessage,
      hasMore,
      currentPage,
      totalCount,
    );
  }
}

// State Providers with better optimization
final selectedTabProvider = StateProvider<int>((ref) => 0);
final searchQueryProvider = StateProvider<String>((ref) => '');
final filterOptionsProvider = StateProvider<FilterOptions>(
  (ref) => const FilterOptions(),
);
final sortOptionProvider = StateProvider<SortOption>(
  (ref) => SortOption.newest,
);
final favoritePropertiesProvider = StateProvider<Set<String>>((ref) => {});

// Property Data Providers with pagination
final rentPropertiesProvider =
    StateNotifierProvider<RentPropertiesNotifier, PropertyState<RentProperty>>((
      ref,
    ) {
      return RentPropertiesNotifier();
    });

final sellPropertiesProvider =
    StateNotifierProvider<SellPropertiesNotifier, PropertyState<SellProperty>>((
      ref,
    ) {
      return SellPropertiesNotifier();
    });

final hotelPropertiesProvider = StateNotifierProvider<
  HotelPropertiesNotifier,
  PropertyState<HotelProperty>
>((ref) {
  return HotelPropertiesNotifier();
});

// Optimized Filtered Properties Providers with debouncing
final filteredRentPropertiesProvider = Provider<AsyncValue<List<RentProperty>>>(
  (ref) {
    final state = ref.watch(rentPropertiesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filterOptions = ref.watch(filterOptionsProvider);
    final sortOption = ref.watch(sortOptionProvider);

    if (state.loadingState == PropertyLoadingState.loading &&
        state.properties.isEmpty) {
      return const AsyncValue.loading();
    }

    if (state.loadingState == PropertyLoadingState.error) {
      return AsyncValue.error(
        state.errorMessage ?? 'Unknown error',
        StackTrace.current,
      );
    }

    try {
      final filteredProperties = _filterAndSortRentProperties(
        state.properties,
        searchQuery,
        filterOptions,
        sortOption,
      );
      return AsyncValue.data(filteredProperties);
    } catch (e, stack) {
      return AsyncValue.error(e, stack);
    }
  },
);

final filteredSellPropertiesProvider = Provider<AsyncValue<List<SellProperty>>>(
  (ref) {
    final state = ref.watch(sellPropertiesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final filterOptions = ref.watch(filterOptionsProvider);
    final sortOption = ref.watch(sortOptionProvider);

    if (state.loadingState == PropertyLoadingState.loading &&
        state.properties.isEmpty) {
      return const AsyncValue.loading();
    }

    if (state.loadingState == PropertyLoadingState.error) {
      return AsyncValue.error(
        state.errorMessage ?? 'Unknown error',
        StackTrace.current,
      );
    }

    try {
      final filteredProperties = _filterAndSortSellProperties(
        state.properties,
        searchQuery,
        filterOptions,
        sortOption,
      );
      return AsyncValue.data(filteredProperties);
    } catch (e, stack) {
      return AsyncValue.error(e, stack);
    }
  },
);

final filteredHotelPropertiesProvider =
    Provider<AsyncValue<List<HotelProperty>>>((ref) {
      final state = ref.watch(hotelPropertiesProvider);
      final searchQuery = ref.watch(searchQueryProvider);
      final filterOptions = ref.watch(filterOptionsProvider);
      final sortOption = ref.watch(sortOptionProvider);

      if (state.loadingState == PropertyLoadingState.loading &&
          state.properties.isEmpty) {
        return const AsyncValue.loading();
      }

      if (state.loadingState == PropertyLoadingState.error) {
        return AsyncValue.error(
          state.errorMessage ?? 'Unknown error',
          StackTrace.current,
        );
      }

      try {
        final filteredProperties = _filterAndSortHotelProperties(
          state.properties,
          searchQuery,
          filterOptions,
          sortOption,
        );
        return AsyncValue.data(filteredProperties);
      } catch (e, stack) {
        return AsyncValue.error(e, stack);
      }
    });

// Optimized Property State Notifiers with better error handling
class RentPropertiesNotifier
    extends StateNotifier<PropertyState<RentProperty>> {
  static const int _pageSize =
      2; // Reduced to 2 per request for better performance
  final uuid = const Uuid();
  static final List<RentProperty> _cachedProperties = [];

  RentPropertiesNotifier() : super(const PropertyState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!mounted) return;

      state = state.copyWith(loadingState: PropertyLoadingState.loading);

      await Future.delayed(const Duration(milliseconds: 200));

      if (_cachedProperties.isEmpty) {
        _cachedProperties.addAll(_generateStaticRentProperties());
      }

      final properties = _cachedProperties.take(_pageSize).toList();

      if (mounted) {
        state = state.copyWith(
          properties: properties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: 1,
          totalCount: _cachedProperties.length,
          hasMore: properties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading rent properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to load properties',
        );
      }
    }
  }

  Future<void> refreshProperties() async {
    try {
      if (!mounted) return;

      state = state.copyWith(
        loadingState: PropertyLoadingState.loading,
        currentPage: 0,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final properties = _cachedProperties.take(_pageSize).toList();

      if (mounted) {
        state = state.copyWith(
          properties: properties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: 1,
          totalCount: _cachedProperties.length,
          hasMore: properties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error refreshing rent properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to refresh properties',
        );
      }
    }
  }

  Future<void> loadMoreProperties() async {
    try {
      if (!state.hasMore ||
          state.loadingState == PropertyLoadingState.loading ||
          !mounted) {
        return;
      }

      final startIndex = state.currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(
        0,
        _cachedProperties.length,
      );

      if (startIndex >= _cachedProperties.length) return;

      final newProperties = _cachedProperties.sublist(startIndex, endIndex);

      if (mounted && newProperties.isNotEmpty) {
        final allProperties = [...state.properties, ...newProperties];
        state = state.copyWith(
          properties: allProperties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: state.currentPage + 1,
          hasMore: allProperties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading more rent properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to load more properties',
        );
      }
    }
  }

  List<RentProperty> _generateStaticRentProperties() {
    return [
      RentProperty(
        id: 'rent_1',
        title: '2BHK Modern Apartment Bandra',
        description: 'Beautiful apartment with modern amenities',
        location: 'Bandra West',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0607,
        longitude: 72.8362,
        monthlyRent: 45000,
        securityDeposit: 90000,
        bedrooms: 2,
        bathrooms: 2,
        areaSquareFeet: 950,
        propertyType: 'Apartment',
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1664425989384-b35690a9217d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1639751787355-bbc3ed1fd639?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
        ],
        amenities: ['WiFi', 'Parking', '24/7 Security', 'Swimming Pool'],
        ownerName: 'Rajesh Kumar',
        ownerPhone: '+91-9876543210',
        ownerEmail: 'rajesh@example.com',
        isAvailable: true,
        availableFrom: DateTime.now().add(const Duration(days: 15)),
        furnishedType: 'fully',
        floorNumber: 5,
        totalFloors: 12,
        parkingType: 'covered',
        parkingSpaces: 1,
        petsAllowed: true,
        rating: 4.5,
        reviewCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Bandra Station', 'Linking Road'],
        electricityType: 'included',
        waterSupply: '24/7',
        hasBalcony: true,
        hasGarden: false,
        isVerified: true,
        leaseDurationMonths: 12,
      ),
      RentProperty(
        id: 'rent_2',
        title: '3BHK Luxury Villa Koregaon',
        description: 'Spacious villa with garden and parking',
        location: 'Koregaon Park',
        city: 'Pune',
        state: 'Maharashtra',
        latitude: 18.5314,
        longitude: 73.8853,
        monthlyRent: 65000,
        securityDeposit: 130000,
        bedrooms: 3,
        bathrooms: 3,
        areaSquareFeet: 1400,
        propertyType: 'Villa',
        images: [
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1664425989440-91c9eb455a70?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&h=600&fit=crop',
        ],
        amenities: ['WiFi', 'Parking', 'Garden', 'Swimming Pool', 'Gym'],
        ownerName: 'Priya Sharma',
        ownerPhone: '+91-9876543211',
        ownerEmail: 'priya@example.com',
        isAvailable: true,
        availableFrom: DateTime.now().add(const Duration(days: 30)),
        furnishedType: 'semi',
        floorNumber: 1,
        totalFloors: 2,
        parkingType: 'covered',
        parkingSpaces: 2,
        petsAllowed: true,
        rating: 4.8,
        reviewCount: 40,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['MG Road', 'Pune Airport'],
        electricityType: 'separate',
        waterSupply: '24/7',
        hasBalcony: true,
        hasGarden: true,
        isVerified: true,
        leaseDurationMonths: 24,
      ),
      RentProperty(
        id: 'rent_3',
        title: '2BHK Cozy Apartment Bandra',
        description: 'Beautiful apartment with modern amenities',
        location: 'Bandra West',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0607,
        longitude: 72.8362,
        monthlyRent: 45000,
        securityDeposit: 90000,
        bedrooms: 2,
        bathrooms: 2,
        areaSquareFeet: 950,
        propertyType: 'Apartment',
        images: [
          'https://images.unsplash.com/photo-1648840887119-a9d33c964054?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1634830996534-989755ecf678?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
        ],
        amenities: ['WiFi', 'Parking', '24/7 Security', 'Swimming Pool'],
        ownerName: 'Rajesh Kumar',
        ownerPhone: '+91-9876543210',
        ownerEmail: 'rajesh@example.com',
        isAvailable: true,
        availableFrom: DateTime.now().add(const Duration(days: 15)),
        furnishedType: 'fully',
        floorNumber: 5,
        totalFloors: 12,
        parkingType: 'covered',
        parkingSpaces: 1,
        petsAllowed: true,
        rating: 4.5,
        reviewCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Bandra Station', 'Linking Road'],
        electricityType: 'included',
        waterSupply: '24/7',
        hasBalcony: true,
        hasGarden: false,
        isVerified: true,
        leaseDurationMonths: 12,
      ),
      RentProperty(
        id: 'rent_4',
        title: '2BHK Premium Apartment Bandra',
        description: 'Beautiful apartment with modern amenities',
        location: 'Bandra West',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0607,
        longitude: 72.8362,
        monthlyRent: 45000,
        securityDeposit: 90000,
        bedrooms: 2,
        bathrooms: 2,
        areaSquareFeet: 950,
        propertyType: 'Apartment',
        images: [
          'https://images.unsplash.com/photo-1743351482246-7a06419e8b6c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzB8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1634207519283-401a5830e174?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzZ8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
        ],
        amenities: ['WiFi', 'Parking', '24/7 Security', 'Swimming Pool'],
        ownerName: 'Rajesh Kumar',
        ownerPhone: '+91-9876543210',
        ownerEmail: 'rajesh@example.com',
        isAvailable: true,
        availableFrom: DateTime.now().add(const Duration(days: 15)),
        furnishedType: 'fully',
        floorNumber: 5,
        totalFloors: 12,
        parkingType: 'covered',
        parkingSpaces: 1,
        petsAllowed: true,
        rating: 4.5,
        reviewCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Bandra Station', 'Linking Road'],
        electricityType: 'included',
        waterSupply: '24/7',
        hasBalcony: true,
        hasGarden: false,
        isVerified: true,
        leaseDurationMonths: 12,
      ),
      RentProperty(
        id: 'rent_5',
        title: '2BHK Deluxe Apartment Bandra',
        description: 'Beautiful apartment with modern amenities',
        location: 'Bandra West',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0607,
        longitude: 72.8362,
        monthlyRent: 45000,
        securityDeposit: 90000,
        bedrooms: 2,
        bathrooms: 2,
        areaSquareFeet: 950,
        propertyType: 'Apartment',
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1664425989384-b35690a9217d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1639751787355-bbc3ed1fd639?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGhvdXNlJTIwcHJvcGVydGliex1lbnwwfHwwfHx8MA%3D%3D',
        ],
        amenities: ['WiFi', 'Parking', '24/7 Security', 'Swimming Pool'],
        ownerName: 'Rajesh Kumar',
        ownerPhone: '+91-9876543210',
        ownerEmail: 'rajesh@example.com',
        isAvailable: true,
        availableFrom: DateTime.now().add(const Duration(days: 15)),
        furnishedType: 'fully',
        floorNumber: 5,
        totalFloors: 12,
        parkingType: 'covered',
        parkingSpaces: 1,
        petsAllowed: true,
        rating: 4.5,
        reviewCount: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 16)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Bandra Station', 'Linking Road'],
        electricityType: 'included',
        waterSupply: '24/7',
        hasBalcony: true,
        hasGarden: false,
        isVerified: true,
        leaseDurationMonths: 12,
      ),
    ];
  }
}

class SellPropertiesNotifier
    extends StateNotifier<PropertyState<SellProperty>> {
  static const int _pageSize = 2;
  final uuid = const Uuid();
  static final List<SellProperty> _cachedProperties = [];

  SellPropertiesNotifier() : super(const PropertyState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!mounted) return;

      state = state.copyWith(loadingState: PropertyLoadingState.loading);

      await Future.delayed(const Duration(milliseconds: 200));

      if (_cachedProperties.isEmpty) {
        _cachedProperties.addAll(_generateStaticSellProperties());
      }

      final properties = _cachedProperties.take(_pageSize).toList();

      if (mounted) {
        state = state.copyWith(
          properties: properties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: 1,
          totalCount: _cachedProperties.length,
          hasMore: properties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading sell properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to load properties',
        );
      }
    }
  }

  Future<void> refreshProperties() async {
    try {
      if (!mounted) return;

      state = state.copyWith(
        loadingState: PropertyLoadingState.loading,
        currentPage: 0,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final properties = _cachedProperties.take(_pageSize).toList();

      if (mounted) {
        state = state.copyWith(
          properties: properties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: 1,
          totalCount: _cachedProperties.length,
          hasMore: properties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error refreshing sell properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to refresh properties',
        );
      }
    }
  }

  Future<void> loadMoreProperties() async {
    try {
      if (!state.hasMore ||
          state.loadingState == PropertyLoadingState.loading ||
          !mounted) {
        return;
      }

      final startIndex = state.currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(
        0,
        _cachedProperties.length,
      );

      if (startIndex >= _cachedProperties.length) return;

      final newProperties = _cachedProperties.sublist(startIndex, endIndex);

      if (mounted && newProperties.isNotEmpty) {
        final allProperties = [...state.properties, ...newProperties];
        state = state.copyWith(
          properties: allProperties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: state.currentPage + 1,
          hasMore: allProperties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading more sell properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to load more properties',
        );
      }
    }
  }

  List<SellProperty> _generateStaticSellProperties() {
    return [
      SellProperty(
        id: 'sell_1',
        title: '3BHK Premium Apartment Juhu',
        description: 'Premium apartment with excellent amenities',
        location: 'Juhu',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0989,
        longitude: 72.8277,
        price: 15000000,
        pricePerSquareFeet: 12000,
        bedrooms: 3,
        bathrooms: 3,
        areaSquareFeet: 1250,
        propertyType: 'Apartment',
        images: [
          'https://images.unsplash.com/photo-1668911495278-487418f8f72d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDh8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1507086182422-97bd7ca2413b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTR8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop',
        ],
        amenities: ['Swimming Pool', 'Gym', 'Security', 'Parking'],
        ownerName: 'Amit Patel',
        ownerPhone: '+91-9876543250',
        ownerEmail: 'amit@example.com',
        isAvailable: true,
        furnishedType: 'fully',
        floorNumber: 8,
        totalFloors: 15,
        parkingType: 'covered',
        parkingSpaces: 2,
        rating: 4.6,
        reviewCount: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Juhu Beach', 'Airport'],
        hasGarden: false,
        hasBalcony: true,
        isVerified: true,
        constructionStatus: 'ready',
        propertyAge: 3,
        facing: 'west',
        isPremium: true,
        ownershipType: 'freehold',
        maintenanceCharge: 3500,
        legalDocuments: ['Title Deed', 'NOC', 'Approval Certificate'],
        brokerName: '',
        brokerPhone: '',
        brokerCommission: 0.0,
        hasLoan: false,
        bankName: '',
        loanAmount: 0,
      ),
      SellProperty(
        id: 'sell_2',
        title: '4BHK Luxury Villa Whitefield',
        description: 'Independent villa with private garden and pool',
        location: 'Whitefield',
        city: 'Bangalore',
        state: 'Karnataka',
        latitude: 12.9698,
        longitude: 77.7499,
        price: 25000000,
        pricePerSquareFeet: 10000,
        bedrooms: 4,
        bathrooms: 4,
        areaSquareFeet: 2500,
        propertyType: 'Villa',
        images: [
          'https://images.unsplash.com/photo-1668911492786-766a300d744b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NjB8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1668911491756-efb778ca35a6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NjN8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&h=600&fit=crop',
        ],
        amenities: ['Swimming Pool', 'Garden', 'Security', 'Parking', 'Gym'],
        ownerName: 'Sunita Reddy',
        ownerPhone: '+91-9876543251',
        ownerEmail: 'sunita@example.com',
        isAvailable: true,
        furnishedType: 'semi',
        floorNumber: 1,
        totalFloors: 2,
        parkingType: 'covered',
        parkingSpaces: 3,
        rating: 4.9,
        reviewCount: 28,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Tech Parks', 'International Airport'],
        hasGarden: true,
        hasBalcony: true,
        isVerified: true,
        constructionStatus: 'ready',
        propertyAge: 2,
        facing: 'east',
        isPremium: true,
        ownershipType: 'freehold',
        maintenanceCharge: 5000,
        legalDocuments: ['Title Deed', 'NOC', 'Khata Certificate'],
        brokerName: '',
        brokerPhone: '',
        brokerCommission: 0.0,
        hasLoan: false,
        bankName: '',
        loanAmount: 0,
      ),
      SellProperty(
        id: 'sell_3',
        title: '3BHK Coastal Apartment Juhu',
        description: 'Premium apartment with excellent amenities',
        location: 'Juhu',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0989,
        longitude: 72.8277,
        price: 15000000,
        pricePerSquareFeet: 12000,
        bedrooms: 3,
        bathrooms: 3,
        areaSquareFeet: 1250,
        propertyType: 'Apartment',
        images: [
          'https://plus.unsplash.com/premium_photo-1734543932105-1382eaa5e459?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Njl8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://plus.unsplash.com/premium_photo-1734543932105-1382eaa5e459?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Njl8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop',
        ],
        amenities: ['Swimming Pool', 'Gym', 'Security', 'Parking'],
        ownerName: 'Amit Patel',
        ownerPhone: '+91-9876543250',
        ownerEmail: 'amit@example.com',
        isAvailable: true,
        furnishedType: 'fully',
        floorNumber: 8,
        totalFloors: 15,
        parkingType: 'covered',
        parkingSpaces: 2,
        rating: 4.6,
        reviewCount: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Juhu Beach', 'Airport'],
        hasGarden: false,
        hasBalcony: true,
        isVerified: true,
        constructionStatus: 'ready',
        propertyAge: 3,
        facing: 'west',
        isPremium: true,
        ownershipType: 'freehold',
        maintenanceCharge: 3500,
        legalDocuments: ['Title Deed', 'NOC', 'Approval Certificate'],
        brokerName: '',
        brokerPhone: '',
        brokerCommission: 0.0,
        hasLoan: false,
        bankName: '',
        loanAmount: 0,
      ),
      SellProperty(
        id: 'sell_4',
        title: '3BHK Deluxe Apartment Juhu',
        description: 'Premium apartment with excellent amenities',
        location: 'Juhu',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0989,
        longitude: 72.8277,
        price: 15000000,
        pricePerSquareFeet: 12000,
        bedrooms: 3,
        bathrooms: 3,
        areaSquareFeet: 1250,
        propertyType: 'Apartment',
        images: [
          'https://images.unsplash.com/photo-1612302035035-be4cb07db5f3?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NzV8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1744311971549-9c529b60b98a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8ODd8fGhvdXNlJTIwcHJvcGVydGllc3xlbnwwfHwwfHx8MA%3D%3D',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800&h=600&fit=crop',
        ],
        amenities: ['Swimming Pool', 'Gym', 'Security', 'Parking'],
        ownerName: 'Amit Patel',
        ownerPhone: '+91-9876543250',
        ownerEmail: 'amit@example.com',
        isAvailable: true,
        furnishedType: 'fully',
        floorNumber: 8,
        totalFloors: 15,
        parkingType: 'covered',
        parkingSpaces: 2,
        rating: 4.6,
        reviewCount: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        updatedAt: DateTime.now(),
        nearbyPlaces: ['Juhu Beach', 'Airport'],
        hasGarden: false,
        hasBalcony: true,
        isVerified: true,
        constructionStatus: 'ready',
        propertyAge: 3,
        facing: 'west',
        isPremium: true,
        ownershipType: 'freehold',
        maintenanceCharge: 3500,
        legalDocuments: ['Title Deed', 'NOC', 'Approval Certificate'],
        brokerName: '',
        brokerPhone: '',
        brokerCommission: 0.0,
        hasLoan: false,
        bankName: '',
        loanAmount: 0,
      ),
    ];
  }
}

class HotelPropertiesNotifier
    extends StateNotifier<PropertyState<HotelProperty>> {
  static const int _pageSize = 2;
  final uuid = const Uuid();
  static final List<HotelProperty> _cachedProperties = [];

  HotelPropertiesNotifier() : super(const PropertyState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!mounted) return;

      state = state.copyWith(loadingState: PropertyLoadingState.loading);

      await Future.delayed(const Duration(milliseconds: 200));

      if (_cachedProperties.isEmpty) {
        _cachedProperties.addAll(_generateStaticHotelProperties());
      }

      final properties = _cachedProperties.take(_pageSize).toList();

      if (mounted) {
        state = state.copyWith(
          properties: properties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: 1,
          totalCount: _cachedProperties.length,
          hasMore: properties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading hotel properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to load properties',
        );
      }
    }
  }

  Future<void> refreshProperties() async {
    try {
      if (!mounted) return;

      state = state.copyWith(
        loadingState: PropertyLoadingState.loading,
        currentPage: 0,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final properties = _cachedProperties.take(_pageSize).toList();

      if (mounted) {
        state = state.copyWith(
          properties: properties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: 1,
          totalCount: _cachedProperties.length,
          hasMore: properties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error refreshing hotel properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to refresh properties',
        );
      }
    }
  }

  Future<void> loadMoreProperties() async {
    try {
      if (!state.hasMore ||
          state.loadingState == PropertyLoadingState.loading ||
          !mounted) {
        return;
      }

      final startIndex = state.currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(
        0,
        _cachedProperties.length,
      );

      if (startIndex >= _cachedProperties.length) return;

      final newProperties = _cachedProperties.sublist(startIndex, endIndex);

      if (mounted && newProperties.isNotEmpty) {
        final allProperties = [...state.properties, ...newProperties];
        state = state.copyWith(
          properties: allProperties,
          loadingState: PropertyLoadingState.loaded,
          currentPage: state.currentPage + 1,
          hasMore: allProperties.length < _cachedProperties.length,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading more hotel properties: $e\n$stackTrace');
      if (mounted) {
        state = state.copyWith(
          loadingState: PropertyLoadingState.error,
          errorMessage: 'Failed to load more properties',
        );
      }
    }
  }

  List<HotelProperty> _generateStaticHotelProperties() {
    return [
      HotelProperty(
        id: 'hotel_1',
        name: 'Luxury Beach Resort Marine',
        description: 'Premium beachfront resort with world-class amenities',
        location: 'Marine Drive',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 18.9267,
        longitude: 72.8233,
        pricePerNight: 8500,
        originalPrice: 12000,
        starRating: 5,
        images: [
          'https://media.istockphoto.com/id/106393587/photo/luxury-hotel.jpg?s=612x612&w=0&k=20&c=vbt66vTRaL4Dn-ZDHo_28jAg6rFon8Ezv5Ad9CtHppE=',
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
        ],
        amenities: [
          'Free WiFi',
          'Swimming Pool',
          'Spa',
          'Restaurant',
          'Room Service',
        ],
        contactPhone: '+91-22-66661000',
        contactEmail: 'hotel1@example.com',
        website: 'www.luxurybeachresort.com',
        isAvailable: true,
        hotelType: 'Luxury',
        roomTypes: [
          RoomType(
            id: 'room_1_deluxe_marine',
            name: 'Deluxe Ocean View Marine',
            description: 'Spacious room with stunning ocean views',
            pricePerNight: 8500,
            maxOccupancy: 3,
            roomSize: 400,
            amenities: ['AC', 'TV', 'WiFi', 'Mini Bar', 'Ocean View'],
            images: [
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&h=600&fit=crop',
            ],
            isAvailable: true,
            availableRooms: 8,
          ),
        ],
        rating: 4.8,
        reviewCount: 125,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        nearbyAttractions: ['Gateway of India', 'Chhatrapati Shivaji Terminus'],
        hasParking: true,
        hasFreeWifi: true,
        hasBreakfast: true,
        hasPool: true,
        hasGym: true,
        hasSpa: true,
        hasRestaurant: true,
        hasRoomService: true,
        isVerified: true,
        checkInTime: '15:00',
        checkOutTime: '11:00',
        cancellationPolicy: 'Free cancellation up to 24 hours before check-in',
        languages: ['English', 'Hindi', 'Marathi'],
        isPetFriendly: false,
        hasAirConditioning: true,
        distanceFromCenter: 0.5,
        transportAccess: 'Near Churchgate Station',
        certificates: ['ISO Certified', '5-Star Rating'],
        managerName: 'Mr. Anil Kapoor',
        managerPhone: '+91-9876543200',
        hasConferenceRooms: true,
        totalRooms: 120,
        discountPercentage: 15,
      ),
      HotelProperty(
        id: 'hotel_2',
        name: 'Business Executive Hotel MG',
        description: 'Modern business hotel with conference facilities',
        location: 'MG Road',
        city: 'Bangalore',
        state: 'Karnataka',
        latitude: 12.9716,
        longitude: 77.5946,
        pricePerNight: 4500,
        originalPrice: 6000,
        starRating: 4,
        images: [
          'https://media.istockphoto.com/id/514102692/photo/udaipur-city-palace-in-rajasthan-state-of-india.jpg?s=612x612&w=0&k=20&c=bYRDPOuf6nFgghl6VAnCn__22SFyu_atC_fiSCzVNtY=',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=600&fit=crop',
        ],
        amenities: [
          'Free WiFi',
          'Business Center',
          'Gym',
          'Restaurant',
          'Conference Rooms',
        ],
        contactPhone: '+91-80-66661001',
        contactEmail: 'hotel2@example.com',
        website: 'www.businessexecutive.com',
        isAvailable: true,
        hotelType: 'Business',
        roomTypes: [
          RoomType(
            id: 'room_2_executive_mg',
            name: 'Executive Suite MG',
            description: 'Spacious suite perfect for business travelers',
            pricePerNight: 4500,
            maxOccupancy: 2,
            roomSize: 350,
            amenities: ['AC', 'TV', 'WiFi', 'Work Desk', 'Coffee Machine'],
            images: [
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&h=600&fit=crop',
            ],
            isAvailable: true,
            availableRooms: 15,
          ),
        ],
        rating: 4.3,
        reviewCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        nearbyAttractions: ['UB City Mall', 'Cubbon Park'],
        hasParking: true,
        hasFreeWifi: true,
        hasBreakfast: true,
        hasPool: false,
        hasGym: true,
        hasSpa: false,
        hasRestaurant: true,
        hasRoomService: true,
        isVerified: true,
        checkInTime: '14:00',
        checkOutTime: '12:00',
        cancellationPolicy: 'Free cancellation up to 6 hours before check-in',
        languages: ['English', 'Hindi', 'Kannada'],
        isPetFriendly: true,
        hasAirConditioning: true,
        distanceFromCenter: 1.2,
        transportAccess: 'Near MG Road Metro',
        certificates: ['ISO Certified', 'Business Hotel Award'],
        managerName: 'Ms. Priya Nair',
        managerPhone: '+91-9876543201',
        hasConferenceRooms: true,
        totalRooms: 80,
        discountPercentage: 25,
      ),
      HotelProperty(
        id: 'hotel_3',
        name: 'Luxury Coastal Resort Marine',
        description: 'Premium beachfront resort with world-class amenities',
        location: 'Marine Drive',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 18.9267,
        longitude: 72.8233,
        pricePerNight: 8500,
        originalPrice: 12000,
        starRating: 5,
        images: [
          'https://media.istockphoto.com/id/96669695/photo/luxury-palace-courtyard.jpg?s=612x612&w=0&k=20&c=CAAsyEccQsjiIXST3omGGYzmYNgcad8SrucOyEOxCAs=',
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
        ],
        amenities: [
          'Free WiFi',
          'Swimming Pool',
          'Spa',
          'Restaurant',
          'Room Service',
        ],
        contactPhone: '+91-22-66661000',
        contactEmail: 'hotel1@example.com',
        website: 'www.luxurybeachresort.com',
        isAvailable: true,
        hotelType: 'Luxury',
        roomTypes: [
          RoomType(
            id: 'room_3_deluxe_coastal',
            name: 'Deluxe Coastal View',
            description: 'Spacious room with stunning ocean views',
            pricePerNight: 8500,
            maxOccupancy: 3,
            roomSize: 400,
            amenities: ['AC', 'TV', 'WiFi', 'Mini Bar', 'Ocean View'],
            images: [
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&h=600&fit=crop',
            ],
            isAvailable: true,
            availableRooms: 8,
          ),
        ],
        rating: 4.8,
        reviewCount: 125,
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
        updatedAt: DateTime.now(),
        nearbyAttractions: ['Gateway of India', 'Chhatrapati Shivaji Terminus'],
        hasParking: true,
        hasFreeWifi: true,
        hasBreakfast: true,
        hasPool: true,
        hasGym: true,
        hasSpa: true,
        hasRestaurant: true,
        hasRoomService: true,
        isVerified: true,
        checkInTime: '15:00',
        checkOutTime: '11:00',
        cancellationPolicy: 'Free cancellation up to 24 hours before check-in',
        languages: ['English', 'Hindi', 'Marathi'],
        isPetFriendly: false,
        hasAirConditioning: true,
        distanceFromCenter: 0.5,
        transportAccess: 'Near Churchgate Station',
        certificates: ['ISO Certified', '5-Star Rating'],
        managerName: 'Mr. Anil Kapoor',
        managerPhone: '+91-9876543200',
        hasConferenceRooms: true,
        totalRooms: 120,
        discountPercentage: 15,
      ),
      HotelProperty(
        id: 'hotel_4',
        name: 'Luxury Grand Resort Marine',
        description: 'Premium beachfront resort with world-class amenities',
        location: 'Marine Drive',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 18.9267,
        longitude: 72.8233,
        pricePerNight: 8500,
        originalPrice: 12000,
        starRating: 5,
        images: [
          'https://media.istockphoto.com/id/629006734/photo/city-palace-and-pichola-lake-in-udaipur-india.jpg?s=612x612&w=0&k=20&c=qhP5o-dpZoWuRdCyrOVJfu6IHf7472QGovEJmytYzrI=',
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
        ],
        amenities: [
          'Free WiFi',
          'Swimming Pool',
          'Spa',
          'Restaurant',
          'Room Service',
        ],
        contactPhone: '+91-22-66661000',
        contactEmail: 'hotel1@example.com',
        website: 'www.luxurybeachresort.com',
        isAvailable: true,
        hotelType: 'Luxury',
        roomTypes: [
          RoomType(
            id: 'room_4_deluxe_grand',
            name: 'Deluxe Grand Ocean View',
            description: 'Spacious room with stunning ocean views',
            pricePerNight: 8500,
            maxOccupancy: 3,
            roomSize: 400,
            amenities: ['AC', 'TV', 'WiFi', 'Mini Bar', 'Ocean View'],
            images: [
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&h=600&fit=crop',
            ],
            isAvailable: true,
            availableRooms: 8,
          ),
        ],
        rating: 4.8,
        reviewCount: 125,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        updatedAt: DateTime.now(),
        nearbyAttractions: ['Gateway of India', 'Chhatrapati Shivaji Terminus'],
        hasParking: true,
        hasFreeWifi: true,
        hasBreakfast: true,
        hasPool: true,
        hasGym: true,
        hasSpa: true,
        hasRestaurant: true,
        hasRoomService: true,
        isVerified: true,
        checkInTime: '15:00',
        checkOutTime: '11:00',
        cancellationPolicy: 'Free cancellation up to 24 hours before check-in',
        languages: ['English', 'Hindi', 'Marathi'],
        isPetFriendly: false,
        hasAirConditioning: true,
        distanceFromCenter: 0.5,
        transportAccess: 'Near Churchgate Station',
        certificates: ['ISO Certified', '5-Star Rating'],
        managerName: 'Mr. Anil Kapoor',
        managerPhone: '+91-9876543200',
        hasConferenceRooms: true,
        totalRooms: 120,
        discountPercentage: 15,
      ),
    ];
  }
}

// Optimized Filter and Sort Functions
List<RentProperty> _filterAndSortRentProperties(
  List<RentProperty> properties,
  String searchQuery,
  FilterOptions filterOptions,
  SortOption sortOption,
) {
  try {
    var filtered =
        properties.where((property) {
          // Search filter
          if (searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            final matchesSearch =
                (property.title.toLowerCase().contains(query) ?? false) ||
                (property.location.toLowerCase().contains(query) ?? false) ||
                (property.city.toLowerCase().contains(query) ?? false);
            if (!matchesSearch) return false;
          }

          // Price filters
          if (filterOptions.minPrice != null &&
              (property.monthlyRent ?? 0) < filterOptions.minPrice!) {
            return false;
          }
          if (filterOptions.maxPrice != null &&
              (property.monthlyRent ?? 0) > filterOptions.maxPrice!) {
            return false;
          }

          // Bedroom filters
          if (filterOptions.minBedrooms != null &&
              (property.bedrooms ?? 0) < filterOptions.minBedrooms!) {
            return false;
          }
          if (filterOptions.maxBedrooms != null &&
              (property.bedrooms ?? 0) > filterOptions.maxBedrooms!) {
            return false;
          }

          // Property type filter
          if (filterOptions.propertyTypes.isNotEmpty &&
              !filterOptions.propertyTypes.contains(property.propertyType)) {
            return false;
          }

          // Other filters
          if (filterOptions.amenities.isNotEmpty &&
              !filterOptions.amenities.every(
                (amenity) => property.amenities.contains(amenity),
              )) {
            return false;
          }
          if (filterOptions.furnishedType != null &&
              property.furnishedType != filterOptions.furnishedType) {
            return false;
          }
          if (filterOptions.hasParking != null) {
            final hasParking = property.parkingType != 'no parking';
            if (hasParking != filterOptions.hasParking) return false;
          }
          if (filterOptions.isVerified != null &&
              property.isVerified != filterOptions.isVerified) {
            return false;
          }
          if (filterOptions.city != null &&
              property.city.toLowerCase() !=
                  filterOptions.city!.toLowerCase()) {
            return false;
          }
          if (filterOptions.state != null &&
              property.state.toLowerCase() !=
                  filterOptions.state!.toLowerCase()) {
            return false;
          }
          if (filterOptions.minArea != null &&
              (property.areaSquareFeet ?? 0) < filterOptions.minArea!) {
            return false;
          }
          if (filterOptions.maxArea != null &&
              (property.areaSquareFeet ?? 0) > filterOptions.maxArea!) {
            return false;
          }
          if (filterOptions.minRating != null &&
              (property.rating ?? 0) < filterOptions.minRating!) {
            return false;
          }
          if (filterOptions.isPetFriendly != null &&
              property.petsAllowed != filterOptions.isPetFriendly) {
            return false;
          }

          return true;
        }).toList();

    // Sorting
    switch (sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort(
          (a, b) => (a.monthlyRent ?? 0).compareTo(b.monthlyRent ?? 0),
        );
        break;
      case SortOption.priceHighToLow:
        filtered.sort(
          (a, b) => (b.monthlyRent ?? 0).compareTo(a.monthlyRent ?? 0),
        );
        break;
      case SortOption.rating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.area:
        filtered.sort(
          (a, b) => (b.areaSquareFeet ?? 0).compareTo(a.areaSquareFeet ?? 0),
        );
        break;
      case SortOption.name:
        filtered.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case SortOption.distance:
        filtered.sort((a, b) => (a.latitude ?? 0).compareTo(b.latitude ?? 0));
        break;
    }

    return filtered;
  } catch (e, stackTrace) {
    debugPrint('Error filtering rent properties: $e\n$stackTrace');
    return properties;
  }
}

List<SellProperty> _filterAndSortSellProperties(
  List<SellProperty> properties,
  String searchQuery,
  FilterOptions filterOptions,
  SortOption sortOption,
) {
  try {
    var filtered =
        properties.where((property) {
          // Search filter
          if (searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            final matchesSearch =
                (property.title.toLowerCase().contains(query) ?? false) ||
                (property.location.toLowerCase().contains(query) ?? false) ||
                (property.city.toLowerCase().contains(query) ?? false);
            if (!matchesSearch) return false;
          }

          // Price filters
          if (filterOptions.minPrice != null &&
              (property.price ?? 0) < filterOptions.minPrice!) {
            return false;
          }
          if (filterOptions.maxPrice != null &&
              (property.price ?? 0) > filterOptions.maxPrice!) {
            return false;
          }

          // Bedroom filters
          if (filterOptions.minBedrooms != null &&
              (property.bedrooms ?? 0) < filterOptions.minBedrooms!) {
            return false;
          }
          if (filterOptions.maxBedrooms != null &&
              (property.bedrooms ?? 0) > filterOptions.maxBedrooms!) {
            return false;
          }

          // Property type filter
          if (filterOptions.propertyTypes.isNotEmpty &&
              !filterOptions.propertyTypes.contains(property.propertyType)) {
            return false;
          }

          // Other filters
          if (filterOptions.amenities.isNotEmpty &&
              !filterOptions.amenities.every(
                (amenity) => property.amenities.contains(amenity),
              )) {
            return false;
          }
          if (filterOptions.furnishedType != null &&
              property.furnishedType != filterOptions.furnishedType) {
            return false;
          }
          if (filterOptions.hasParking != null) {
            final hasParking = property.parkingType != 'no parking';
            if (hasParking != filterOptions.hasParking) return false;
          }
          if (filterOptions.isVerified != null &&
              property.isVerified != filterOptions.isVerified) {
            return false;
          }
          if (filterOptions.city != null &&
              property.city.toLowerCase() !=
                  filterOptions.city!.toLowerCase()) {
            return false;
          }
          if (filterOptions.state != null &&
              property.state.toLowerCase() !=
                  filterOptions.state!.toLowerCase()) {
            return false;
          }
          if (filterOptions.minArea != null &&
              (property.areaSquareFeet ?? 0) < filterOptions.minArea!) {
            return false;
          }
          if (filterOptions.maxArea != null &&
              (property.areaSquareFeet ?? 0) > filterOptions.maxArea!) {
            return false;
          }
          if (filterOptions.minRating != null &&
              (property.rating ?? 0) < filterOptions.minRating!) {
            return false;
          }
          if (filterOptions.facing != null &&
              property.facing != filterOptions.facing) {
            return false;
          }
          if (filterOptions.constructionStatus != null &&
              property.constructionStatus != filterOptions.constructionStatus) {
            return false;
          }

          return true;
        }).toList();

    // Sorting
    switch (sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case SortOption.rating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.area:
        filtered.sort(
          (a, b) => (b.areaSquareFeet ?? 0).compareTo(a.areaSquareFeet ?? 0),
        );
        break;
      case SortOption.name:
        filtered.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case SortOption.distance:
        filtered.sort((a, b) => (a.latitude ?? 0).compareTo(b.latitude ?? 0));
        break;
    }

    return filtered;
  } catch (e, stackTrace) {
    debugPrint('Error filtering sell properties: $e\n$stackTrace');
    return properties;
  }
}

List<HotelProperty> _filterAndSortHotelProperties(
  List<HotelProperty> properties,
  String searchQuery,
  FilterOptions filterOptions,
  SortOption sortOption,
) {
  try {
    var filtered =
        properties.where((property) {
          // Search filter
          if (searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            final matchesSearch =
                (property.name.toLowerCase().contains(query) ?? false) ||
                (property.location.toLowerCase().contains(query) ?? false) ||
                (property.city.toLowerCase().contains(query) ?? false);
            if (!matchesSearch) return false;
          }

          // Price filters
          if (filterOptions.minPrice != null &&
              (property.pricePerNight ?? 0) < filterOptions.minPrice!) {
            return false;
          }
          if (filterOptions.maxPrice != null &&
              (property.pricePerNight ?? 0) > filterOptions.maxPrice!) {
            return false;
          }

          // Star rating filters
          if (filterOptions.minStarRating != null &&
              (property.starRating ?? 0) < filterOptions.minStarRating!) {
            return false;
          }
          if (filterOptions.maxStarRating != null &&
              (property.starRating ?? 0) > filterOptions.maxStarRating!) {
            return false;
          }

          // Amenity filters
          if (filterOptions.amenities.isNotEmpty &&
              !filterOptions.amenities.every(
                (amenity) => property.amenities.contains(amenity),
              )) {
            return false;
          }
          if (filterOptions.hasWifi != null &&
              property.hasFreeWifi != filterOptions.hasWifi) {
            return false;
          }
          if (filterOptions.hasPool != null &&
              property.hasPool != filterOptions.hasPool) {
            return false;
          }
          if (filterOptions.hasGym != null &&
              property.hasGym != filterOptions.hasGym) {
            return false;
          }
          if (filterOptions.isPetFriendly != null &&
              property.isPetFriendly != filterOptions.isPetFriendly) {
            return false;
          }
          if (filterOptions.isVerified != null &&
              property.isVerified != filterOptions.isVerified) {
            return false;
          }
          if (filterOptions.city != null &&
              property.city.toLowerCase() !=
                  filterOptions.city!.toLowerCase()) {
            return false;
          }
          if (filterOptions.state != null &&
              property.state.toLowerCase() !=
                  filterOptions.state!.toLowerCase()) {
            return false;
          }
          if (filterOptions.minArea != null &&
              property.roomTypes.every(
                (room) => room.roomSize < filterOptions.minArea!,
              )) {
            return false;
          }
          if (filterOptions.maxArea != null &&
              property.roomTypes.every(
                (room) => room.roomSize > filterOptions.maxArea!,
              )) {
            return false;
          }
          if (filterOptions.minRating != null &&
              (property.rating ?? 0) < filterOptions.minRating!) {
            return false;
          }

          return true;
        }).toList();

    // Sorting
    switch (sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort(
          (a, b) => (a.pricePerNight ?? 0).compareTo(b.pricePerNight ?? 0),
        );
        break;
      case SortOption.priceHighToLow:
        filtered.sort(
          (a, b) => (b.pricePerNight ?? 0).compareTo(a.pricePerNight ?? 0),
        );
        break;
      case SortOption.rating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.area:
        filtered.sort(
          (a, b) => (b.starRating ?? 0).compareTo(a.starRating ?? 0),
        );
        break;
      case SortOption.name:
        filtered.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case SortOption.distance:
        filtered.sort(
          (a, b) =>
              (a.distanceFromCenter ?? 0).compareTo(b.distanceFromCenter ?? 0),
        );
        break;
    }

    return filtered;
  } catch (e, stackTrace) {
    debugPrint('Error filtering hotel properties: $e\n$stackTrace');
    return properties;
  }
}
