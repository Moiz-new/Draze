import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import your EnquiryModel - adjust the path based on your project structure
import 'package:draze/user/models/EnquiryModel.dart';

class EnquiriesProvider extends ChangeNotifier {
  List<EnquiryModel> _enquiries = [];
  bool _isLoading = false;
  String? _error;

  List<EnquiryModel> get enquiries => _enquiries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<EnquiryModel> get upcomingEnquiries =>
      _enquiries.where((enquiry) => enquiry.isUpcoming).toList();

  List<EnquiryModel> get pastEnquiries =>
      _enquiries.where((enquiry) => enquiry.isPast).toList();

  List<EnquiryModel> get pendingEnquiries =>
      _enquiries.where((enquiry) => enquiry.isPending).toList();

  Future<void> fetchEnquiries() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get user ID from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      // Make API call
      final response = await http.get(
        Uri.parse(
          'https://api.drazeapp.com/api/hotelbanquet/api/enquiries/user/$userId',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final EnquiriesResponse enquiriesResponse = EnquiriesResponse.fromJson(data);
          _enquiries = enquiriesResponse.data;

          // Sort enquiries by check-in date (upcoming first, then past)
          _enquiries.sort((a, b) {
            // First sort by upcoming/past status
            if (a.isUpcoming && !b.isUpcoming) return -1;
            if (!a.isUpcoming && b.isUpcoming) return 1;

            // Then sort by check-in date
            return a.checkInDate.compareTo(b.checkInDate);
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch enquiries');
        }
      } else {
        throw Exception('Failed to load enquiries: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshEnquiries() async {
    await fetchEnquiries();
  }

  // Helper method to get enquiry by ID
  EnquiryModel? getEnquiryById(String id) {
    try {
      return _enquiries.firstWhere((enquiry) => enquiry.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to update a specific enquiry
  void updateEnquiry(EnquiryModel updatedEnquiry) {
    final index = _enquiries.indexWhere((enquiry) => enquiry.id == updatedEnquiry.id);
    if (index != -1) {
      _enquiries[index] = updatedEnquiry;
      notifyListeners();
    }
  }

  // Helper method to add a new enquiry
  void addEnquiry(EnquiryModel newEnquiry) {
    _enquiries.add(newEnquiry);
    // Re-sort after adding
    _enquiries.sort((a, b) {
      if (a.isUpcoming && !b.isUpcoming) return -1;
      if (!a.isUpcoming && b.isUpcoming) return 1;
      return a.checkInDate.compareTo(b.checkInDate);
    });
    notifyListeners();
  }

  // Helper method to remove an enquiry
  void removeEnquiry(String enquiryId) {
    _enquiries.removeWhere((enquiry) => enquiry.id == enquiryId);
    notifyListeners();
  }
}