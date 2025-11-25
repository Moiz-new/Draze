import 'package:draze/landlord/models/property_model.dart';

class PropertyService {
  // Simulated in-memory storage
  final List<Property> _properties = [];

  Future<List<Property>> getAllProperties() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_properties);
  }

  Future<Property?> getProperty(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _properties.firstWhere((property) => property.id == propertyId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addProperty(Property property) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _properties.add(property);
  }

  Future<void> updateProperty(Property property) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _properties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      _properties[index] = property.copyWith(updatedAt: DateTime.now());
    } else {
      throw Exception('Property not found');
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _properties.removeWhere((property) => property.id == propertyId);
  }
}
