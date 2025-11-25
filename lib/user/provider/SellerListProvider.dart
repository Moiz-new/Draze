import 'package:draze/app/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:draze/user/models/SllerListPropertyModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PropertyLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class SellerListProvider with ChangeNotifier {
  // Private fields
  List<SellerListModel> _properties = [];
  List<SellerListModel> _filteredProperties = [];
  PropertyLoadingState _loadingState = PropertyLoadingState.initial;
  String _errorMessage = '';
  String _searchQuery = '';
  Timer? _debounceTimer;

  // Visit scheduling related fields
  bool _isSchedulingVisit = false;
  String? _visitScheduleError;
  String? _visitScheduleSuccess;

  // Getters
  List<SellerListModel> get properties => List.unmodifiable(_properties);
  List<SellerListModel> get filteredProperties => List.unmodifiable(_filteredProperties);
  PropertyLoadingState get loadingState => _loadingState;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  bool get isLoading => _loadingState == PropertyLoadingState.loading;
  bool get hasError => _loadingState == PropertyLoadingState.error;
  bool get isEmpty => _filteredProperties.isEmpty && _loadingState == PropertyLoadingState.loaded;
  bool get hasData => _properties.isNotEmpty;

  // Visit scheduling getters
  bool get isSchedulingVisit => _isSchedulingVisit;
  String? get visitScheduleError => _visitScheduleError;
  String? get visitScheduleSuccess => _visitScheduleSuccess;

  // API endpoints
  static final String _apiUrl = '$base_url/api/seller/sellerproperties';
  static final String _visitApiUrl = '$base_url/api/seller/visit';

  /// Load ALL properties from the API (no pagination)
  Future<void> loadProperties({bool forceRefresh = false}) async {
    // If already loaded and not forcing refresh, don't reload
    if (_properties.isNotEmpty && !forceRefresh) {
      debugPrint('SellerListProvider: Properties already loaded, skipping API call');
      return;
    }

    _setLoadingState(PropertyLoadingState.loading);
    _clearError();

    try {
      debugPrint('SellerListProvider: Starting API call to load all properties');

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 30));
        },
      );

      debugPrint('SellerListProvider: API Response Status Code: ${response.statusCode}');
      debugPrint('SellerListProvider: API Response Body Length: ${response.body.length}');
      debugPrint('bodyyyyyyyyyyyyyyyyyyyyyyyyyyyyy: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('SellerListProvider: Parsed response data keys: ${data.keys}');

        if (data['success'] == true && data['properties'] != null) {
          final List<dynamic> propertiesJson = data['properties'];
          debugPrint('SellerListProvider: Total properties from API: ${propertiesJson.length}');

          // Convert all properties from JSON
          final List<SellerListModel> allProperties = [];
          int activeCount = 0;
          int inactiveCount = 0;

          for (int i = 0; i < propertiesJson.length; i++) {
            try {
              final property = SellerListModel.fromJson(propertiesJson[i]);
              allProperties.add(property);

              if (property.isActive) {
                activeCount++;
              } else {
                inactiveCount++;
              }
            } catch (e) {
              debugPrint('SellerListProvider: Error parsing property at index $i: $e');
              // Continue with other properties even if one fails
            }
          }

          debugPrint('SellerListProvider: Successfully parsed ${allProperties.length} properties');
          debugPrint('SellerListProvider: Active properties: $activeCount, Inactive: $inactiveCount');

          // Store ALL properties (including inactive ones for debugging)
          _properties = allProperties.where((property) => property.isActive).toList();

          debugPrint('SellerListProvider: Final active properties count: ${_properties.length}');

          // Apply current filter to show properties
          _applyCurrentFilter();
          _setLoadingState(PropertyLoadingState.loaded);

          debugPrint('SellerListProvider: Filtered properties count: ${_filteredProperties.length}');
        } else {
          final errorMsg = data['message'] ?? 'Invalid response format';
          debugPrint('SellerListProvider: API returned error: $errorMsg');
          throw Exception('API Error: $errorMsg');
        }
      } else {
        debugPrint('SellerListProvider: HTTP Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load properties. Status code: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      debugPrint('SellerListProvider: Timeout error: $e');
      _setError('Request timeout. Please check your internet connection and try again.');
    } catch (e) {
      debugPrint('SellerListProvider: General error: $e');
      _setError('Failed to load properties: ${e.toString()}');
    }
  }

  /// Schedule a visit for a property
  Future<void> scheduleVisit({
    required String propertyId,
    required String name,
    required String mobile,
    required DateTime scheduledDate,
    required String purpose,
    required String notes,
  }) async {
    _isSchedulingVisit = true;
    _visitScheduleError = null;
    _visitScheduleSuccess = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final body = {
        'propertyId': propertyId,
        'name': name,
        'mobile': mobile,
        'scheduledDate': scheduledDate.toIso8601String(),
        'purpose': purpose,
        'notes': notes,
      };

      final response = await http.post(
        Uri.parse(_visitApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          _visitScheduleSuccess = responseData['message'] ?? 'Visit scheduled successfully';
          _visitScheduleError = null;
        } else {
          _visitScheduleError = responseData['message'] ?? 'Failed to schedule visit';
          _visitScheduleSuccess = null;
        }
      } else {
        _visitScheduleError = responseData['message'] ?? 'Failed to schedule visit. Please try again.';
        _visitScheduleSuccess = null;
      }
    } catch (e) {
      _visitScheduleError = 'Failed to schedule visit: ${e.toString()}';
      _visitScheduleSuccess = null;
    } finally {
      _isSchedulingVisit = false;
      notifyListeners();
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Clear visit messages
  void clearVisitMessages() {
    _visitScheduleError = null;
    _visitScheduleSuccess = null;
    notifyListeners();
  }

  /// Refresh properties (force reload from API)
  Future<void> refreshProperties() async {
    await loadProperties(forceRefresh: true);
  }

  /// Search properties with debouncing
  void searchProperties(String query, {Duration debounceTime = const Duration(milliseconds: 300)}) {
    _searchQuery = query;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set up new timer for debounced search
    _debounceTimer = Timer(debounceTime, () {
      _filterProperties(query);
    });
  }

  /// Search properties and return results immediately (no debounce)
  List<SellerListModel> searchPropertiesAndReturn(String query) {
    if (query.isEmpty) {
      debugPrint('SellerListProvider searchPropertiesAndReturn: Empty query, returning all ${_properties.length} properties');
      return List.from(_properties);
    }

    final lowerQuery = query.toLowerCase().trim();
    debugPrint('SellerListProvider searchPropertiesAndReturn: Searching for "$lowerQuery" in ${_properties.length} properties');

    final searchResults = _properties.where((property) {
      final matchesName = property.name.toLowerCase().contains(lowerQuery);
      final matchesType = property.type.toLowerCase().contains(lowerQuery);
      final matchesCity = property.city.toLowerCase().contains(lowerQuery);
      final matchesAddress = property.address.toLowerCase().contains(lowerQuery);
      final matchesState = property.state.toLowerCase().contains(lowerQuery);
      final matchesLandmark = property.landmark.toLowerCase().contains(lowerQuery);
      final matchesOwner = property.ownerName.toLowerCase().contains(lowerQuery);
      final matchesDescription = property.description.toLowerCase().contains(lowerQuery);
      final matchesAmenities = property.amenities.any((amenity) =>
          amenity.toLowerCase().contains(lowerQuery));

      return matchesName || matchesType || matchesCity || matchesAddress ||
          matchesState || matchesLandmark || matchesOwner ||
          matchesDescription || matchesAmenities;
    }).toList();

    debugPrint('SellerListProvider searchPropertiesAndReturn: Found ${searchResults.length} matching properties');

    return searchResults;
  }

  /// Clear search and show all properties
  void clearSearch() {
    _searchQuery = '';
    _debounceTimer?.cancel();
    _filteredProperties = List.from(_properties);
    debugPrint('SellerListProvider clearSearch: Showing all ${_filteredProperties.length} properties');
    notifyListeners();
  }

  /// Filter properties based on search query
  void _filterProperties(String query) {
    if (query.isEmpty) {
      _filteredProperties = List.from(_properties);
    } else {
      final lowercaseQuery = query.toLowerCase().trim();
      _filteredProperties = _properties.where((property) {
        return property.name.toLowerCase().contains(lowercaseQuery) ||
            property.city.toLowerCase().contains(lowercaseQuery) ||
            property.type.toLowerCase().contains(lowercaseQuery) ||
            property.address.toLowerCase().contains(lowercaseQuery) ||
            property.state.toLowerCase().contains(lowercaseQuery) ||
            property.landmark.toLowerCase().contains(lowercaseQuery) ||
            property.ownerName.toLowerCase().contains(lowercaseQuery) ||
            property.description.toLowerCase().contains(lowercaseQuery) ||
            property.amenities.any((amenity) =>
                amenity.toLowerCase().contains(lowercaseQuery));
      }).toList();
    }

    debugPrint('SellerListProvider _filterProperties: Query "$query" resulted in ${_filteredProperties.length} properties');
    notifyListeners();
  }

  /// Apply current filter (used after loading properties)
  void _applyCurrentFilter() {
    if (_searchQuery.isEmpty) {
      _filteredProperties = List.from(_properties);
    } else {
      _filterProperties(_searchQuery);
    }
    debugPrint('SellerListProvider _applyCurrentFilter: Applied filter, showing ${_filteredProperties.length} properties');
  }

  /// Get properties by type
  List<SellerListModel> getPropertiesByType(String type) {
    return _properties.where((property) =>
    property.type.toLowerCase() == type.toLowerCase()).toList();
  }

  /// Get properties by city
  List<SellerListModel> getPropertiesByCity(String city) {
    return _properties.where((property) =>
    property.city.toLowerCase() == city.toLowerCase()).toList();
  }

  /// Get properties with rating above threshold
  List<SellerListModel> getPropertiesWithMinRating(double minRating) {
    return _properties.where((property) =>
    property.averageRating >= minRating && property.totalRatings > 0).toList();
  }

  /// Get properties with specific amenity
  List<SellerListModel> getPropertiesWithAmenity(String amenity) {
    return _properties.where((property) =>
        property.amenities.any((a) =>
            a.toLowerCase().contains(amenity.toLowerCase()))).toList();
  }

  /// Get property by ID
  SellerListModel? getPropertyById(String id) {
    try {
      return _properties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sort properties by rating (high to low)
  void sortByRating({bool ascending = false}) {
    _filteredProperties.sort((a, b) {
      final comparison = b.averageRating.compareTo(a.averageRating);
      return ascending ? -comparison : comparison;
    });
    notifyListeners();
  }

  /// Sort properties by name (A to Z)
  void sortByName({bool ascending = true}) {
    _filteredProperties.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    notifyListeners();
  }

  /// Get unique cities from all properties
  List<String> getUniqueCities() {
    return _properties.map((property) => property.city)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get unique property types
  List<String> getUniquePropertyTypes() {
    return _properties.map((property) => property.type)
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get unique amenities from all properties
  List<String> getUniqueAmenities() {
    final allAmenities = <String>{};
    for (final property in _properties) {
      allAmenities.addAll(property.amenities);
    }
    return allAmenities.toList()..sort();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    if (_properties.isEmpty) {
      return {
        'totalProperties': 0,
        'averageRating': 0.0,
        'totalRatings': 0,
        'propertiesWithImages': 0,
        'citiesCount': 0,
        'typesCount': 0,
      };
    }

    final propertiesWithRatings = _properties.where((p) => p.totalRatings > 0);
    final avgRating = propertiesWithRatings.isEmpty
        ? 0.0
        : propertiesWithRatings.map((p) => p.averageRating).reduce((a, b) => a + b) / propertiesWithRatings.length;

    return {
      'totalProperties': _properties.length,
      'filteredProperties': _filteredProperties.length,
      'averageRating': avgRating,
      'totalRatings': _properties.map((p) => p.totalRatings).reduce((a, b) => a + b),
      'propertiesWithImages': _properties.where((p) => p.images.isNotEmpty).length,
      'citiesCount': getUniqueCities().length,
      'typesCount': getUniquePropertyTypes().length,
      'amenitiesCount': getUniqueAmenities().length,
    };
  }

  /// Private helper methods
  void _setLoadingState(PropertyLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = PropertyLoadingState.error;
    _errorMessage = message;
    debugPrint('SellerListProvider Error: $message');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Extension for additional filtering options
extension SellerListProviderFilters on SellerListProvider {
  /// Apply multiple filters at once
  void applyFilters({
    String? city,
    String? propertyType,
    double? minRating,
    List<String>? requiredAmenities,
  }) {
    List<SellerListModel> filtered = List.from(_properties);

    if (city != null && city.isNotEmpty) {
      filtered = filtered.where((p) =>
      p.city.toLowerCase() == city.toLowerCase()).toList();
    }

    if (propertyType != null && propertyType.isNotEmpty) {
      filtered = filtered.where((p) =>
      p.type.toLowerCase() == propertyType.toLowerCase()).toList();
    }

    if (minRating != null && minRating > 0) {
      filtered = filtered.where((p) =>
      p.averageRating >= minRating && p.totalRatings > 0).toList();
    }

    if (requiredAmenities != null && requiredAmenities.isNotEmpty) {
      filtered = filtered.where((p) =>
          requiredAmenities.every((amenity) =>
              p.amenities.any((a) =>
                  a.toLowerCase().contains(amenity.toLowerCase())))).toList();
    }

    _filteredProperties = filtered;
    debugPrint('SellerListProvider applyFilters: Applied filters, showing ${_filteredProperties.length} properties');
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _searchQuery = '';
    _filteredProperties = List.from(_properties);
    debugPrint('SellerListProvider resetFilters: Reset filters, showing ${_filteredProperties.length} properties');
    notifyListeners();
  }
}