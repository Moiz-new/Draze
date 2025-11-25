import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../app/api_constants.dart';

class Due {
  final String dueId;
  final String dueName;
  final double amount;
  final DateTime dueDate;
  final String status;

  Due({
    required this.dueId,
    required this.dueName,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  factory Due.fromJson(Map<String, dynamic> json) {
    return Due(
      dueId: json['dueId'] ?? '',
      dueName: json['dueName'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      status: json['status'] ?? 'PENDING',
    );
  }
}

class Tenant {
  final String tenantId;
  final String tenantName;
  final int totalDues;
  final List<Due> dues;

  Tenant({
    required this.tenantId,
    required this.tenantName,
    required this.totalDues,
    required this.dues,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      tenantId: json['tenantId'] ?? '',
      tenantName: json['tenantName'] ?? 'Unknown Tenant',
      totalDues: json['totalDues'] ?? 0,
      dues: (json['dues'] as List<dynamic>?)
          ?.map((due) => Due.fromJson(due))
          .toList() ??
          [],
    );
  }

  double get totalAmount {
    return dues.fold(0, (sum, due) => sum + due.amount);
  }
}

class TenantDuesAgainstPropertyProvider extends ChangeNotifier {
  List<Tenant> _tenants = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String? _propertyId;

  List<Tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  String? get propertyId => _propertyId;

  int get totalTenants => _tenants.length;
  int get totalDuesCount => _tenants.fold(0, (sum, tenant) => sum + tenant.totalDues);
  double get totalDuesAmount => _tenants.fold(0, (sum, tenant) => sum + tenant.totalAmount);

  List<Tenant> get filteredTenants {
    var filtered = _tenants;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tenant) {
        final nameMatch = tenant.tenantName.toLowerCase().contains(_searchQuery.toLowerCase());
        final duesMatch = tenant.dues.any((due) =>
            due.dueName.toLowerCase().contains(_searchQuery.toLowerCase())
        );
        return nameMatch || duesMatch;
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter == 'Pending') {
      filtered = filtered.where((tenant) =>
          tenant.dues.any((due) => due.status == 'PENDING')
      ).toList();
    } else if (_selectedFilter == 'Paid') {
      filtered = filtered.where((tenant) =>
          tenant.dues.any((due) => due.status == 'PAID')
      ).toList();
    }

    return filtered;
  }

  Future<void> loadDues(String propertyId) async {
    _propertyId = propertyId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$base_url/api/dues/$propertyId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['tenants'] != null) {
          _tenants = (data['tenants'] as List<dynamic>)
              .map((tenant) => Tenant.fromJson(tenant))
              .toList();
          _error = null;
        } else {
          _error = 'Failed to load dues data';
          _tenants = [];
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        _tenants = [];
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _tenants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    if (_propertyId != null) {
      loadDues(_propertyId!);
    }
  }}