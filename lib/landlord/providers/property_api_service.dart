// lib/landlord/services/property_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draze/landlord/models/property_model.dart';

import '../../app/api_constants.dart';

class PropertyApiService {
  static final String baseUrl = '$base_url/api/landlord';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<String?> _getLandlordId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('landlord_id');
    } catch (e) {
      print('Error getting landlord ID: $e');
      return null;
    }
  }

  // Add property to API
  Future<Map<String, dynamic>?> addProperty({
    required String name,
    required PropertyType type,
    required String address,
    required String pinCode,
    required String city,
    required String state,
    required String landmark,
    required String contactNumber,
    required String ownerName,
    required String description,
    required int totalBeds,
    required int totalRooms,
    required double price,
    required int capacity,
  }) async {
    try {
      final authToken = await _getAuthToken();
      final landlordId = await _getLandlordId();

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (landlordId == null || landlordId.isEmpty) {
        throw Exception('Landlord ID not found. Please login again.');
      }

      // Prepare request headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Convert PropertyType enum to API format
      String getApiPropertyType(PropertyType type) {
        switch (type) {
          case PropertyType.pg:
            return 'PG';
          case PropertyType.hostel:
            return 'Hostel';
          case PropertyType.rental:
            return 'Rental';
          case PropertyType.oneBhk:
            return '1 BHK';
          case PropertyType.twoBhk:
            return '2 BHK';
          case PropertyType.threeBhk:
            return '3 BHK';
          case PropertyType.fourBhk:
            return '4 BHK';
          case PropertyType.oneRk:
            return '1 RK';
          case PropertyType.studioApartment:
            return 'Studio Apartment';
          case PropertyType.luxuryBungalows:
            return 'Luxury Bungalows';
          case PropertyType.villas:
            return 'Villas';
          case PropertyType.builderFloor:
            return 'Builder Floor';
          case PropertyType.flat:
            return 'Flat';
          case PropertyType.room:
            return 'Room';
          default:
            return 'PG';
        }
      }

      final body = {
        'landlordId': landlordId,
        'name': name.trim(),
        'type': getApiPropertyType(type),
        'address': address.trim(),
        'pinCode': pinCode.trim(),
        'city': city.trim(),
        'state': "Available",
        'landmark': landmark.trim(),
        'contactNumber': contactNumber.trim(),
        'ownerName': ownerName.trim(),
        'description': description.trim(),
        'totalBeds': totalBeds,
        'totalRooms': totalRooms,
        'price': price,
        'capacity': capacity,
      };

      print('API Request URL: $baseUrl/properties');
      print('API Request Headers: $headers');
      print('API Request Body: ${jsonEncode(body)}');

      // Make API request
      final response = await http.post(
        Uri.parse('$baseUrl/properties'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check if the response has the expected structure
        if (responseData != null && responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData?['message'] ?? 'Failed to add property');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request data');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Access denied. You don\'t have permission to perform this action.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'Failed to add property. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in addProperty API call: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: Unable to connect to server');
      }
    }
  }

  // Update property API
  Future<Map<String, dynamic>?> updateProperty({
    required String propertyId,
    required String name,
    required PropertyType type,
    required String address,
    required String pinCode,
    required String city,
    required String state,
    required String landmark,
    required String contactNumber,
    required String ownerName,
    required String description,
  }) async {
    try {
      final authToken = await _getAuthToken();
      final landlordId = await _getLandlordId();

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (landlordId == null || landlordId.isEmpty) {
        throw Exception('Landlord ID not found. Please login again.');
      }

      // Prepare request headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      // Convert PropertyType enum to API format
      String getApiPropertyType(PropertyType type) {
        switch (type) {
          case PropertyType.pg:
            return 'PG';
          case PropertyType.hostel:
            return 'Hostel';
          case PropertyType.rental:
            return 'Rental';
          case PropertyType.oneBhk:
            return '1 BHK';
          case PropertyType.twoBhk:
            return '2 BHK';
          case PropertyType.threeBhk:
            return '3 BHK';
          case PropertyType.fourBhk:
            return '4 BHK';
          case PropertyType.oneRk:
            return '1 RK';
          case PropertyType.studioApartment:
            return 'Studio Apartment';
          case PropertyType.luxuryBungalows:
            return 'Luxury Bungalows';
          case PropertyType.villas:
            return 'Villas';
          case PropertyType.builderFloor:
            return 'Builder Floor';
          case PropertyType.flat:
            return 'Flat';
          case PropertyType.room:
            return 'Room';
          default:
            return 'PG';
        }
      }

      final body = {
        'propertyId': propertyId,
        'landlordId': landlordId,
        'name': name.trim(),
        'type': getApiPropertyType(type),
        'address': address.trim(),
        'pinCode': pinCode.trim(),
        'city': city.trim(),
        'state': state.trim(),
        'landmark': landmark.trim(),
        'contactNumber': contactNumber.trim(),
        'ownerName': ownerName.trim(),
        'description': description.trim(),
      };

      print('API Request URL: $baseUrl/properties');
      print('API Request Headers: $headers');
      print('API Request Body: ${jsonEncode(body)}');

      // Make PUT API request
      final response = await http.put(
        Uri.parse('$baseUrl/properties'),
        headers: headers,
        body: jsonEncode(body),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check if the response has the expected structure
        if (responseData != null && responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
            responseData?['message'] ?? 'Failed to update property',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid request data');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Access denied. You don\'t have permission to perform this action.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
          'Failed to update property. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in updateProperty API call: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Network error: Unable to connect to server');
      }
    }
  }

  // Get all properties (optional - for future use)
  Future<List<Map<String, dynamic>>> getAllProperties() async {
    try {
      final authToken = await _getAuthToken();
      final landlordId = await _getLandlordId();

      if (authToken == null || landlordId == null) {
        return [];
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/properties?landlordId=$landlordId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true &&
            responseData['properties'] != null) {
          return List<Map<String, dynamic>>.from(responseData['properties']);
        }
      }

      return [];
    } catch (e) {
      print('Error getting properties: $e');
      return [];
    }
  }
}
