import 'dart:convert';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddRoomServiceProvider {
  static final String baseUrl = '$base_url/api/landlord/properties';

  Future<Map<String, dynamic>?> addRoom({
    required String propertyId,
    required Map<String, dynamic> roomData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }
      final url = Uri.parse('$baseUrl/$propertyId/rooms');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode([roomData]),
      );

      print(propertyId);
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse and return the response data
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to add room: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding room: $e');
    }
  }

  // Update room method
  Future<bool> updateRoom({
    required String propertyId,
    required String roomId,
    required Map<String, dynamic> roomData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = Uri.parse('$baseUrl/$propertyId/rooms/$roomId');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(roomData),
      );

      print('Update Room - Property ID: $propertyId');
      print('Update Room - Room ID: $roomId');
      print('Update Room Response: ${response.body}');
      print('Update Room Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to update room: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating room: $e');
    }
  }

  // Helper method to map room type to API format
  static String mapRoomType(String type) {
    switch (type.toLowerCase()) {
      case 'pg':
        return 'PG';
      case 'ac':
        return 'AC';
      case 'single sharing':
        return 'Single Sharing';
      case 'double sharing':
        return 'Double Sharing';
      case 'triple sharing':
        return 'Triple Sharing';
      case 'four sharing':
        return 'Four Sharing';
      case 'five sharing':
        return 'Five Sharing';
      case 'six sharing':
        return 'Six Sharing';
      case 'more than 6 sharing':
        return 'More Than 6 Sharing';
      case 'private room':
      case 'single':
        return 'Private Room';
      case 'shared room':
      case 'double':
        return 'Shared Room';
      case 'couple':
        return 'Couple';
      case 'family':
        return 'Family';
      case 'male only':
        return 'Male Only';
      case 'female only':
        return 'Female Only';
      case 'unisex':
        return 'Unisex';
      case 'student only':
        return 'Student Only';
      case 'working professionals only':
        return 'Working Professionals Only';
      default:
        return 'Private Room';
    }
  }


  // Helper method to map status to API format
  static String mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'not available':
      case 'notavailable':
      case 'unavailable':
        return 'Not Available';
      case 'maintenance':
        return 'Maintenance';
      case 'reserved':
        return 'Reserved';
      default:
        return 'Available';
    }
  }
}
