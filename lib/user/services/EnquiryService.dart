import 'dart:convert';
import 'package:http/http.dart' as http;

class EnquiryService {
  static const String baseUrl = 'https://api.drazeapp.com/api/hotelbanquet/api';

  static Future<Map<String, dynamic>> createEnquiry({
    required String hotelId,
    required String userId,
    required String name,
    required String phone,
    required String email,
    required String checkInDate,
    required String checkOutDate,
    required int numberOfGuests,
    required int numberOfRooms,
    required String enquiryType,
    required Map<String, int> budgetRange,
    String? message,
    required String contactPreference,
  }) async {
    try {
      // Validate required fields
      if (hotelId.isEmpty) {
        throw Exception('Hotel ID is required');
      }
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }
      if (name.trim().isEmpty) {
        throw Exception('Name is required');
      }
      if (phone.trim().isEmpty) {
        throw Exception('Phone number is required');
      }
      if (email.trim().isEmpty) {
        throw Exception('Email is required');
      }

      final body = {
        "hotelId": hotelId,
        "userId": userId,
        "name": name.trim(),
        "phone": phone.trim(),
        "email": email.trim(),
        "checkInDate": checkInDate,
        "checkOutDate": checkOutDate,
        "numberOfGuests": numberOfGuests,
        "numberOfRooms": numberOfRooms,
        "enquiryType": enquiryType,
        "budgetRange": {
          "min": budgetRange['min'] ?? 0,
          "max": budgetRange['max'] ?? 0,
        },
        "message": message?.trim() ?? "",
        "contactPreference": contactPreference,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/enquiries/create'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Enquiry submitted successfully',
            'data': responseData['data'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to submit enquiry',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Server error occurred',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}