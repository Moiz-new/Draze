// lib/seller/providers/property_provider.dart
import 'package:draze/seller/models/seller_property_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State classes
class PropertyState {
  final List<Property> properties;
  final bool isLoading;
  final String? error;

  PropertyState({
    this.properties = const [],
    this.isLoading = false,
    this.error,
  });

  PropertyState copyWith({
    List<Property>? properties,
    bool? isLoading,
    String? error,
  }) {
    return PropertyState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddPropertyState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AddPropertyState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddPropertyState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return AddPropertyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Property Provider
class PropertyNotifier extends StateNotifier<PropertyState> {
  PropertyNotifier() : super(PropertyState()) {
    loadProperties();
  }

  Future<void> loadProperties() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call - replace with actual API implementation
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API response
      final properties = [
        Property(
          id: '1',
          title: 'Modern 2BHK Apartment',
          description: 'Beautiful apartment with all modern amenities',
          address: '123 Main Street',
          city: 'Indore',
          state: 'Madhya Pradesh',
          pincode: '452001',
          price: 2500000,
          propertyType: PropertyType.apartment,
          status: PropertyStatus.active,
          bedrooms: 2,
          bathrooms: 2,
          areaInSqFt: 1200,
          images: [
            'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
            'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
          ],
          amenities: ['Parking', 'Gym', 'Swimming Pool'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
          sellerId: 'seller1',
          contactNumber: '+91 9876543210',
          isNegotiable: true,
        ),
        Property(
          id: '2',
          title: 'Spacious 3BHK Villa',
          description: 'Independent villa with garden and parking',
          address: '456 Garden Colony',
          city: 'Indore',
          state: 'Madhya Pradesh',
          pincode: '452010',
          price: 5500000,
          propertyType: PropertyType.villa,
          status: PropertyStatus.active,
          bedrooms: 3,
          bathrooms: 3,
          areaInSqFt: 2500,
          images: [
            'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
            'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
          ],
          amenities: ['Garden', 'Parking', 'Security'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
          sellerId: 'seller1',
          contactNumber: '+91 9876543210',
          isNegotiable: false,
        ),
      ];

      state = state.copyWith(properties: properties, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshProperties() async {
    await loadProperties();
  }
}

// Add Property Provider
class AddPropertyNotifier extends StateNotifier<AddPropertyState> {
  AddPropertyNotifier() : super(AddPropertyState());

  Future<void> addProperty(CreatePropertyRequest request) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // Simulate API call - replace with actual API implementation
      await Future.delayed(const Duration(seconds: 2));

      // Here you would make the actual API call
      // await propertyRepository.createProperty(request);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetState() {
    state = AddPropertyState();
  }
}

// Providers
final propertyProvider = StateNotifierProvider<PropertyNotifier, PropertyState>(
  (ref) {
    return PropertyNotifier();
  },
);

final addPropertyProvider =
    StateNotifierProvider<AddPropertyNotifier, AddPropertyState>((ref) {
      return AddPropertyNotifier();
    });

// Search provider
final propertySearchProvider = StateProvider<String>((ref) => '');

// Filtered properties provider
final filteredPropertiesProvider = Provider<List<Property>>((ref) {
  final properties = ref.watch(propertyProvider).properties;
  final searchQuery = ref.watch(propertySearchProvider);

  if (searchQuery.isEmpty) {
    return properties;
  }

  return properties.where((property) {
    return property.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        property.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
        property.city.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();
});

// Property stats provider
final propertyStatsProvider = Provider<Map<String, int>>((ref) {
  final properties = ref.watch(propertyProvider).properties;

  return {
    'total': properties.length,
    'active': properties.where((p) => p.status == PropertyStatus.active).length,
    'sold': properties.where((p) => p.status == PropertyStatus.sold).length,
    'inactive':
        properties.where((p) => p.status == PropertyStatus.inactive).length,
  };
});

// Selected property provider for navigation
final selectedPropertyProvider = StateProvider<Property?>((ref) => null);
