import 'package:draze/landlord/services/property_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:draze/landlord/models/property_model.dart';
import 'package:uuid/uuid.dart';

// Property Service Provider
final propertyServiceProvider = Provider<PropertyService>((ref) {
  return PropertyService();
});

// Property State Notifier
class PropertyNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  PropertyNotifier(this._propertyService) : super(const AsyncValue.loading()) {
    loadProperties();
  }

  final PropertyService _propertyService;

  Future<void> loadProperties() async {
    state = const AsyncValue.loading();
    try {
      final properties = await _propertyService.getAllProperties();
      if (properties.isEmpty) {
        // Add a static property if no properties exist
        final staticProperty = Property(
          id: const Uuid().v4(),
          name: 'My Property',
          type: PropertyType.studioApartment,
          address: '123 Main Street',
          city: 'Indore',
          state: 'Madhya Pradesh',
          pincode: '452001',
          description: 'A sample property for demonstration purposes.',
          totalArea: 1000.0,
          totalRooms: 3,
          landlordId: 'sample_landlord_id',
          contactNumber: '+91 9876543210',
          email: 'sample@property.com',
          amenities: ['WiFi', 'Parking', 'Security'],
          status: PropertyStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _propertyService.addProperty(staticProperty);
        state = AsyncValue.data([staticProperty]);
      } else {
        state = AsyncValue.data(properties);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addProperty(Property property) async {
    try {
      await _propertyService.addProperty(property);
      await loadProperties(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProperty(Property property) async {
    try {
      await _propertyService.updateProperty(property);
      await loadProperties(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    try {
      await _propertyService.deleteProperty(propertyId);
      await loadProperties(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Property?> getProperty(String propertyId) async {
    try {
      return await _propertyService.getProperty(propertyId);
    } catch (error) {
      return null;
    }
  }
}

// Property Provider
final propertyProvider =
    StateNotifierProvider<PropertyNotifier, AsyncValue<List<Property>>>((ref) {
      final propertyService = ref.watch(propertyServiceProvider);
      return PropertyNotifier(propertyService);
    });

// Selected Property Provider
final selectedPropertyProvider = StateProvider<Property?>((ref) => null);

// Property Type Filter Provider
final propertyFilterProvider = StateProvider<PropertyType?>((ref) => null);

// Property Status Filter Provider
final propertyStatusFilterProvider = StateProvider<PropertyStatus?>(
  (ref) => null,
);

// Property Price Range Filter Provider
final propertyPriceRangeProvider = StateProvider<RangeValues>(
  (ref) => const RangeValues(0, 100000),
);

// Property Search Provider
final propertySearchProvider = StateProvider<String>((ref) => '');

// Enhanced Filtered Properties Provider
final enhancedFilteredPropertiesProvider = Provider<AsyncValue<List<Property>>>(
  (ref) {
    final properties = ref.watch(propertyProvider);
    final searchQuery = ref.watch(propertySearchProvider);
    final typeFilter = ref.watch(propertyFilterProvider);
    final statusFilter = ref.watch(propertyStatusFilterProvider);
    final priceRange = ref.watch(propertyPriceRangeProvider);

    return properties.when(
      data: (propertyList) {
        var filteredList = propertyList;

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          filteredList =
              filteredList.where((property) {
                return property.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    property.address.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    property.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    property.city.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );
              }).toList();
        }

        // Apply type filter
        if (typeFilter != null) {
          filteredList =
              filteredList
                  .where((property) => property.type == typeFilter)
                  .toList();
        }

        // Apply status filter
        if (statusFilter != null) {
          filteredList =
              filteredList
                  .where((property) => property.status == statusFilter)
                  .toList();
        }

        // Apply price range filter (if applicable, requires pricing data)
        // Currently not implemented as Property model doesn't have price field

        return AsyncValue.data(filteredList);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  },
);

// Property Statistics Provider
final propertyStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final properties = ref.watch(propertyProvider);

  return properties.when(
    data: (propertyList) {
      final stats = <String, dynamic>{};

      // Basic counts
      stats['total'] = propertyList.length;
      stats['active'] =
          propertyList.where((p) => p.status == PropertyStatus.active).length;
      stats['rented'] =
          propertyList.where((p) => p.status == PropertyStatus.rented).length;
      stats['inactive'] =
          propertyList.where((p) => p.status == PropertyStatus.inactive).length;
      stats['maintenance'] =
          propertyList
              .where((p) => p.status == PropertyStatus.maintenance)
              .length;
      stats['pending'] =
          propertyList.where((p) => p.status == PropertyStatus.pending).length;

      // Count by property type
      for (final property in propertyList) {
        final typeKey = property.type.displayName;
        stats[typeKey] = (stats[typeKey] ?? 0) + 1;
      }

      // Placeholder for growth calculations (requires historical data)
      stats['totalGrowth'] = calculateGrowth(propertyList.length, 0);
      stats['activeGrowth'] = calculateGrowth(
        propertyList.where((p) => p.status == PropertyStatus.active).length,
        0,
      );
      stats['rentedGrowth'] = calculateGrowth(
        propertyList.where((p) => p.status == PropertyStatus.rented).length,
        0,
      );
      stats['maintenanceGrowth'] = calculateGrowth(
        propertyList
            .where((p) => p.status == PropertyStatus.maintenance)
            .length,
        0,
      );

      return stats;
    },
    loading: () => <String, dynamic>{},
    error: (_, __) => <String, dynamic>{},
  );
});

// Helper function for growth calculation
String calculateGrowth(int current, int previous) {
  if (previous == 0) return '+0%';
  final growth = ((current - previous) / previous * 100).toStringAsFixed(1);
  return growth.contains('-') ? '$growth%' : '+$growth%';
}
