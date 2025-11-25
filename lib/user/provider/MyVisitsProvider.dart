import 'package:draze/app/api_constants.dart';
import 'package:draze/user/models/MyVisitModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VisitsProvider extends ChangeNotifier {
  List<MyVisitModel> _visits = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;

  List<MyVisitModel> get visits => _visits;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  String? get error => _error;

  bool get hasMoreData => _hasMoreData;

  List<MyVisitModel> get upcomingVisits =>
      _visits.where((visit) => visit.isUpcoming).toList();

  List<MyVisitModel> get pastVisits =>
      _visits.where((visit) => visit.isPast).toList();

  List<MyVisitModel> get pendingVisits =>
      _visits.where((visit) => visit.isPending).toList();

  Future<void> fetchVisits({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!_hasMoreData || _isLoadingMore) return;
        _isLoadingMore = true;
        _currentPage++;
      } else {
        _isLoading = true;
        _currentPage = 1;
        _visits.clear();
      }

      _error = null;
      notifyListeners();

      // Get user ID from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      // Make API call with pagination
      final response = await http.get(
        Uri.parse(
          '$base_url/api/visits/user/$userId?page=$_currentPage&limit=10',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer ${token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Use the response wrapper
          final MyVisitsResponse visitsResponse = MyVisitsResponse.fromJson(
            data,
          );

          if (loadMore) {
            _visits.addAll(visitsResponse.visits);
          } else {
            _visits = visitsResponse.visits;
          }

          // Update pagination info
          _totalPages = visitsResponse.pagination.totalPages;
          _hasMoreData = _currentPage < _totalPages;

          // Sort visits by effective date (upcoming first, then past)
          _visits.sort((a, b) {
            // First sort by upcoming/past status
            if (a.isUpcoming && !b.isUpcoming) return -1;
            if (!a.isUpcoming && b.isUpcoming) return 1;

            // Then sort by date
            return a.effectiveDate.compareTo(b.effectiveDate);
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch visits');
        }
      } else {
        throw Exception('Failed to load visits: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      if (loadMore) {
        _currentPage--; // Revert page increment on error
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Method to load all pages at once
  Future<void> fetchAllVisits() async {
    try {
      _isLoading = true;
      _error = null;
      _visits.clear();
      notifyListeners();

      // Get user ID from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      int page = 1;
      bool hasMore = true;
      List<MyVisitModel> allVisits = [];

      while (hasMore) {
        final response = await http.get(
          Uri.parse('$base_url/api/visits/user/$userId?page=$page&limit=10'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['success'] == true) {
            final MyVisitsResponse visitsResponse = MyVisitsResponse.fromJson(
              data,
            );
            allVisits.addAll(visitsResponse.visits);

            // Check pagination
            final int totalPages = visitsResponse.pagination.totalPages;
            hasMore = page < totalPages;
            page++;
          } else {
            throw Exception(data['message'] ?? 'Failed to fetch visits');
          }
        } else {
          throw Exception('Failed to load visits: ${response.statusCode}');
        }
      }

      _visits = allVisits;
      _currentPage = page - 1;
      _totalPages = page - 1;
      _hasMoreData = false;

      // Sort visits by effective date (upcoming first, then past)
      _visits.sort((a, b) {
        // First sort by upcoming/past status
        if (a.isUpcoming && !b.isUpcoming) return -1;
        if (!a.isUpcoming && b.isUpcoming) return 1;

        // Then sort by date
        return a.effectiveDate.compareTo(b.effectiveDate);
      });
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

  Future<void> refreshVisits() async {
    await fetchVisits();
  }

  // Method to load more data (for infinite scroll)
  Future<void> loadMoreVisits() async {
    await fetchVisits(loadMore: true);
  }

  // Helper method to get visit by ID
  MyVisitModel? getVisitById(String id) {
    try {
      return _visits.firstWhere((visit) => visit.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to update a specific visit
  void updateVisit(MyVisitModel updatedVisit) {
    final index = _visits.indexWhere((visit) => visit.id == updatedVisit.id);
    if (index != -1) {
      _visits[index] = updatedVisit;
      notifyListeners();
    }
  }

  // Helper method to add a new visit
  void addVisit(MyVisitModel newVisit) {
    _visits.add(newVisit);
    // Re-sort after adding
    _visits.sort((a, b) {
      if (a.isUpcoming && !b.isUpcoming) return -1;
      if (!a.isUpcoming && b.isUpcoming) return 1;
      return a.effectiveDate.compareTo(b.effectiveDate);
    });
    notifyListeners();
  }

  // Helper method to remove a visit
  void removeVisit(String visitId) {
    _visits.removeWhere((visit) => visit.id == visitId);
    notifyListeners();
  }
}
