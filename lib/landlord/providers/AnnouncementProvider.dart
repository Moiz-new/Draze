import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../app/api_constants.dart';





class Announcement {
  final String id;
  final String title;
  final String message;
  final String? tenantId;
  final String createdById;
  final String createdByType;
  final bool isActive;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.tenantId,
    required this.createdById,
    required this.createdByType,
    required this.isActive,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      tenantId: json['tenantId'],
      createdById: json['createdById'] ?? '',
      createdByType: json['createdByType'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// announcement_service.dart


class AnnouncementService {
  static final String baseUrl = '$base_url/api';

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final token = await _getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/announcement/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> announcementsJson = data['announcements'] ?? [];

        return announcementsJson
            .map((json) => Announcement.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load announcements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }
}

// announcement_provider.dart

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  List<Announcement> _announcements = [];
  List<Announcement> _filteredAnnouncements = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Active, Inactive

  List<Announcement> get announcements => _announcements;
  List<Announcement> get filteredAnnouncements => _filteredAnnouncements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  Future<void> loadAnnouncements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _service.fetchAnnouncements();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void updateFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = _announcements;

    // Apply status filter
    if (_selectedFilter == 'Active') {
      filtered = filtered.where((a) => a.isActive).toList();
    } else if (_selectedFilter == 'Inactive') {
      filtered = filtered.where((a) => !a.isActive).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((announcement) {
        final query = _searchQuery.toLowerCase();
        return announcement.title.toLowerCase().contains(query) ||
            announcement.message.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _filteredAnnouncements = filtered;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
