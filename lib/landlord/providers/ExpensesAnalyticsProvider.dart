import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

class ExpenseSummaryItem {
  final String id;
  final double totalAmount;
  final int count;

  ExpenseSummaryItem({
    required this.id,
    required this.totalAmount,
    required this.count,
  });

  factory ExpenseSummaryItem.fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryItem(
      id: json['_id'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class MonthlyDataItem {
  final String month;
  final double totalAmount;
  final int count;

  MonthlyDataItem({
    required this.month,
    required this.totalAmount,
    required this.count,
  });

  factory MonthlyDataItem.fromJson(Map<String, dynamic> json) {
    return MonthlyDataItem(
      month: json['month'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class YearlyDataItem {
  final int year;
  final double totalAmount;
  final int count;

  YearlyDataItem({
    required this.year,
    required this.totalAmount,
    required this.count,
  });

  factory YearlyDataItem.fromJson(Map<String, dynamic> json) {
    return YearlyDataItem(
      year: json['year'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

// Provider
class ExpensesAnalyticsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  double _grandTotal = 0;
  List<ExpenseSummaryItem> _summary = [];
  List<MonthlyDataItem> _monthlyData = [];
  List<YearlyDataItem> _yearlyData = [];
  int _selectedYear = 2025;

  bool get isLoading => _isLoading;

  String? get error => _error;

  double get grandTotal => _grandTotal;

  List<ExpenseSummaryItem> get summary => _summary;

  List<MonthlyDataItem> get monthlyData => _monthlyData;

  List<YearlyDataItem> get yearlyData => _yearlyData;

  int get selectedYear => _selectedYear;

  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadSummary(),
        _loadMonthlyTrend(),
        _loadYearlyTrend(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSummary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? landlordId = prefs.getString('landlord_id');
    String? token = prefs.getString('auth_token');
    print(landlordId);
    final url =
        '$base_url/api/expenses/analytics/summary?landlord=$landlordId';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _grandTotal = (data['grandTotal'] ?? 0).toDouble();
      _summary =
          (data['summary'] as List)
              .map((item) => ExpenseSummaryItem.fromJson(item))
              .toList();
    }
  }

  Future<void> _loadMonthlyTrend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? landlordId = prefs.getString('landlord_id');
    String? token = prefs.getString('auth_token');
    final url =
        '$base_url/api/expenses/analytics/monthly-trend?landlord=$landlordId&year=$_selectedYear';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _monthlyData =
          (data['monthlyData'] as List)
              .map((item) => MonthlyDataItem.fromJson(item))
              .toList();
    }
  }

  Future<void> _loadYearlyTrend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? landlordId = prefs.getString('landlord_id');
    String? token = prefs.getString('auth_token');
    final url =
        '$base_url/api/expenses/analytics/yearly-trend?landlord=$landlordId';
    final response = await http.get(
      Uri.parse(url),

      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _yearlyData =
          (data['yearlyData'] as List)
              .map((item) => YearlyDataItem.fromJson(item))
              .toList();
    }
  }

  void changeYear(int year) {
    _selectedYear = year;
    _loadMonthlyTrend();
  }
}
