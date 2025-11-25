import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../app/api_constants.dart';
import '../models/RentPropertyModel.dart';

class RentPropertyProvider with ChangeNotifier {
  List<PropertyModel> _properties = [];
  List<PropertyModel> _paginatedProperties = [];
  List<PropertyModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _currentSearchQuery = '';

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 10;
  int _totalPages = 1;

  // Getters
  List<PropertyModel> get properties => _properties;

  List<PropertyModel> get paginatedProperties => _paginatedProperties;

  List<PropertyModel> get searchResults => _searchResults;

  bool get isLoading => _isLoading;

  bool get isSearching => _isSearching;

  String get currentSearchQuery => _currentSearchQuery;

  String? get error => _error;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get itemsPerPage => _itemsPerPage;

  // API Configuration
  static final String _baseUrl = '$base_url/api/public';
  static const String _propertiesEndpoint = '/all-properties';

  Future<void> fetchProperties() async {
    _setLoading(true);
    _clearError();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl$_propertiesEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final propertiesResponse = PropertiesResponse.fromJson(jsonData);

        if (propertiesResponse.success) {
          _properties = propertiesResponse.properties;
          _calculatePagination();
          _updatePaginatedProperties();

          // Clear search results when new data is fetched
          _clearSearch();
        } else {
          throw Exception(
            'Failed to fetch properties: API returned success: false',
          );
        }
      } else {
        throw Exception('Failed to fetch properties: ${response.statusCode}');
      }
    } catch (e) {
      _setError('Failed to load properties: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProperties() async {
    await fetchProperties();
  }

  // Search functionality
  List<PropertyModel> searchProperties(String query) {
    if (query.isEmpty) {
      _clearSearch();
      return _properties;
    }

    _currentSearchQuery = query;
    _isSearching = true;

    final lowerQuery = query.toLowerCase();
    _searchResults =
        _properties.where((property) {
          return property.name.toLowerCase().contains(lowerQuery) ||
              property.type.toLowerCase().contains(lowerQuery) ||
              property.location.city.toLowerCase().contains(lowerQuery) ||
              property.location.address.toLowerCase().contains(lowerQuery) ||
              property.location.state.toLowerCase().contains(lowerQuery);
        }).toList();

    notifyListeners();
    return _searchResults;
  }

  void clearSearch() {
    _searchResults.clear();
    _currentSearchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  void _clearSearch() {
    _searchResults.clear();
    _currentSearchQuery = '';
    _isSearching = false;
  }

  // Filter functionality
  List<PropertyModel> getAvailableProperties() {
    return _properties.where((property) => property.hasAvailability).toList();
  }

  List<PropertyModel> getPropertiesByType(String type) {
    return _properties
        .where((property) => property.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  List<PropertyModel> getPropertiesByCity(String city) {
    return _properties
        .where(
          (property) =>
              property.location.city.toLowerCase() == city.toLowerCase(),
        )
        .toList();
  }

  // Pagination methods
  void _calculatePagination() {
    _totalPages = (_properties.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
  }

  void _updatePaginatedProperties() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex < _properties.length) {
      _paginatedProperties = _properties.sublist(
        startIndex,
        endIndex > _properties.length ? _properties.length : endIndex,
      );
    } else {
      _paginatedProperties = [];
    }
    notifyListeners();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      _updatePaginatedProperties();
    }
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      _updatePaginatedProperties();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _updatePaginatedProperties();
    }
  }

  void setItemsPerPage(int items) {
    _itemsPerPage = items;
    _currentPage = 1;
    _calculatePagination();
    _updatePaginatedProperties();
  }

  // Utility methods for getting unique values for filters
  List<String> getUniquePropertyTypes() {
    final types = _properties.map((p) => p.type).toSet().toList();
    types.sort();
    return types;
  }

  List<String> getUniqueCities() {
    final cities =
        _properties
            .map((p) => p.location.city)
            .where((city) => city.isNotEmpty)
            .toSet()
            .toList();
    cities.sort();
    return cities;
  }

  List<String> getUniqueStates() {
    final states =
        _properties
            .map((p) => p.location.state)
            .where((state) => state.isNotEmpty)
            .toSet()
            .toList();
    states.sort();
    return states;
  }

  // Statistics methods
  int get totalAvailableRooms {
    return _properties.fold(
      0,
      (sum, property) => sum + property.availableRooms,
    );
  }

  int get totalAvailableBeds {
    return _properties.fold(0, (sum, property) => sum + property.availableBeds);
  }

  int get availablePropertiesCount {
    return _properties.where((property) => property.hasAvailability).length;
  }

  double get averagePrice {
    final propertiesWithPrice =
        _properties.where((p) => p.lowestPrice > 0).toList();
    if (propertiesWithPrice.isEmpty) return 0.0;

    final totalPrice = propertiesWithPrice.fold(
      0.0,
      (sum, property) => sum + property.lowestPrice,
    );
    return totalPrice / propertiesWithPrice.length;
  }

  List<PropertyModel> getPropertiesInPriceRange(
    double minPrice,
    double maxPrice,
  ) {
    return _properties
        .where(
          (property) =>
              property.lowestPrice >= minPrice &&
              property.lowestPrice <= maxPrice,
        )
        .toList();
  }

  // Private helper methods
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Advanced filtering method
  List<PropertyModel> filterProperties({
    String? type,
    String? city,
    String? state,
    double? minPrice,
    double? maxPrice,
    bool? hasAvailability,
    int? minRooms,
    int? maxRooms,
  }) {
    List<PropertyModel> sourceList =
        _isSearching ? _searchResults : _properties;

    return sourceList.where((property) {
      // Type filter
      if (type != null && type.isNotEmpty && type != 'All') {
        if (type == 'Available') {
          if (!property.hasAvailability) return false;
        } else {
          if (property.type.toLowerCase() != type.toLowerCase()) return false;
        }
      }

      // City filter
      if (city != null && city.isNotEmpty && city != 'All') {
        if (property.location.city.toLowerCase() != city.toLowerCase())
          return false;
      }

      // State filter
      if (state != null && state.isNotEmpty && state != 'All') {
        if (property.location.state.toLowerCase() != state.toLowerCase())
          return false;
      }

      // Price range filter
      if (minPrice != null && property.lowestPrice < minPrice) return false;
      if (maxPrice != null && property.lowestPrice > maxPrice) return false;

      // Availability filter
      if (hasAvailability != null &&
          property.hasAvailability != hasAvailability)
        return false;

      // Room count filter
      if (minRooms != null && property.totalRooms < minRooms) return false;
      if (maxRooms != null && property.totalRooms > maxRooms) return false;

      return true;
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
