import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../app/api_constants.dart';
class AllTenantListModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String work;
  final String tenantId;
  final List<Accommodation> accommodations;
  final int complaintCount;

  AllTenantListModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.work,
    required this.tenantId,
    required this.accommodations,
    required this.complaintCount,
  });

  factory AllTenantListModel.fromJson(Map<String, dynamic> json) {
    return AllTenantListModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      work: json['work'] ?? '',
      tenantId: json['tenantId'] ?? '',
      accommodations: (json['accommodations'] as List? ?? [])
          .map((acc) => Accommodation.fromJson(acc))
          .toList(),
      complaintCount: (json['complaints'] as List? ?? []).length,
    );
  }

  Accommodation? get activeAccommodation {
    try {
      return accommodations.firstWhere((acc) => acc.isActive);
    } catch (e) {
      return accommodations.isNotEmpty ? accommodations.first : null;
    }
  }
}

class Accommodation {
  final String propertyName;
  final String roomId;
  final double rentAmount;
  final double pendingDues;
  final bool isActive;
  final DateTime moveInDate;

  Accommodation({
    required this.propertyName,
    required this.roomId,
    required this.rentAmount,
    required this.pendingDues,
    required this.isActive,
    required this.moveInDate,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      propertyName: json['propertyName'] ?? '',
      roomId: json['roomId'] ?? '',
      rentAmount: (json['rentAmount'] ?? 0).toDouble(),
      pendingDues: (json['pendingDues'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      moveInDate: DateTime.parse(json['moveInDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Tenant Provider
class AllTenantListProvider extends ChangeNotifier {
  List<AllTenantListModel> _tenants = [];
  bool _isLoading = false;
  String? _error;
  double _totalPendingDues = 0;
  double _totalMonthlyCollection = 0;

  List<AllTenantListModel> get tenants => _tenants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalPendingDues => _totalPendingDues;
  double get totalMonthlyCollection => _totalMonthlyCollection;

  List<AllTenantListModel> get activeTenants =>
      _tenants.where((t) => t.accommodations.any((a) => a.isActive)).toList();

  List<AllTenantListModel> get inactiveTenants =>
      _tenants.where((t) => !t.accommodations.any((a) => a.isActive)).toList();

  Future<void> fetchTenants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }


      final response = await http.get(
        Uri.parse('$base_url/api/landlord/tenant'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tenants = (data['tenants'] as List)
            .map((tenant) => AllTenantListModel.fromJson(tenant))
            .toList();
        _totalPendingDues = (data['totalPendingDues'] ?? 0).toDouble();
        _totalMonthlyCollection = (data['totalMonthlyCollection'] ?? 0).toDouble();
      } else {
        throw Exception('Failed to load tenants: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}