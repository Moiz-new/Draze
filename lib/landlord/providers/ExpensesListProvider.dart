import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

class ExpensesListProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Getters
  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses => _filteredExpenses;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  bool get hasMore => _currentPage < _totalPages;

  // Fetch expenses with pagination
  Future<void> fetchExpenses({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || !hasMore) return;
      _isLoadingMore = true;
      _currentPage++;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _expenses.clear();
    }

    _error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String? landlordId = prefs.getString('landlord_id');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      if (landlordId == null || landlordId.isEmpty) {
        throw Exception('Landlord ID not found');
      }

      final response = await http.get(
        Uri.parse(
          '$base_url/api/expenses?landlord=$landlordId&page=$_currentPage',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> expensesJson = data['expenses'] ?? [];
          final newExpenses = expensesJson
              .map((json) => Expense.fromJson(json))
              .toList();

          if (loadMore) {
            _expenses.addAll(newExpenses);
          } else {
            _expenses = newExpenses;
          }

          _totalPages = data['pages'] ?? 1;
          _applyFilters();
          _error = null;
        } else {
          throw Exception(data['message'] ?? 'Failed to load expenses');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load expenses');
      }
    } catch (e) {
      _error = e.toString();
      if (!loadMore) {
        _expenses = [];
        _filteredExpenses = [];
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Update filter
  void updateFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredExpenses = _expenses.where((expense) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          expense.description.toLowerCase().contains(_searchQuery) ||
          expense.paidTo.toLowerCase().contains(_searchQuery) ||
          expense.category.name.toLowerCase().contains(_searchQuery);

      // Category filter
      final matchesFilter = _selectedFilter == 'All' ||
          expense.category.name == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Get unique categories for filter
  List<String> getUniqueCategories() {
    final categories = _expenses.map((e) => e.category.name).toSet().toList();
    return ['All', ...categories];
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh
  Future<void> refresh() async {
    await fetchExpenses(loadMore: false);
  }
}

// Expense Model
class Expense {
  final String id;
  final Category category;
  final double amount;
  final DateTime date;
  final String paidBy;
  final String paidTo;
  final String description;
  final String collectionMode;
  final String? billImage;
  final Landlord landlord;
  final Property? property;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.paidBy,
    required this.paidTo,
    required this.description,
    required this.collectionMode,
    this.billImage,
    required this.landlord,
    this.property,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'] ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      paidBy: json['paidBy'] ?? '',
      paidTo: json['paidTo'] ?? '',
      description: json['description'] ?? '',
      collectionMode: json['collectionMode'] ?? '',
      billImage: json['billImage'],
      landlord: Landlord.fromJson(json['landlord'] ?? {}),
      property: json['property'] != null
          ? Property.fromJson(json['property'])
          : null,
    );
  }
}

// Category Model
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
    );
  }
}

// Landlord Model
class Landlord {
  final String id;
  final String name;
  final String email;

  Landlord({required this.id, required this.name, required this.email});

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

// Property Model
class Property {
  final String id;
  final String name;
  final String address;

  Property({required this.id, required this.name, required this.address});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }
}