import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draze/app/api_constants.dart';
import 'package:http_parser/http_parser.dart';

class AddExpensesProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isCreatingExpense = false;
  String? _error;

  List<Category> get categories => _categories;

  bool get isLoading => _isLoading;

  bool get isCreatingExpense => _isCreatingExpense;

  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
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
        Uri.parse('$base_url/api/expense-categories?landlord=$landlordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _categories = data.map((json) => Category.fromJson(json)).toList();
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      _error = e.toString();
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new category
  Future<bool> addCategory(String categoryName) async {
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

      final response = await http.post(
        Uri.parse('$base_url/api/expense-categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': categoryName, 'landlord': landlordId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['category'] != null) {
          final newCategory = Category.fromJson(data['category']);
          _categories.add(newCategory);
          notifyListeners();
          return true;
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add category');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
    return false;
  }

  // Create expense with the correct API
  Future<Map<String, dynamic>?> createExpense({
    required String categoryId,
    required double amount,
    required DateTime date,
    required String paidBy,
    required String paidTo,
    required String description,
    required String collectionMode,
    required String landlordId,
    String? propertyId,
    File? billImage,
  }) async {
    _isCreatingExpense = true;
    _error = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$base_url/api/expenses'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add required fields
      request.fields['category'] = categoryId;
      request.fields['amount'] = amount.toString();
      request.fields['date'] = date.toIso8601String();
      request.fields['paidBy'] = paidBy;
      request.fields['paidTo'] = paidTo;
      request.fields['description'] = description;
      request.fields['collectionMode'] = collectionMode;
      request.fields['landlord'] = landlordId;

      // Add optional property field
      if (propertyId != null && propertyId.isNotEmpty) {
        request.fields['property'] = propertyId;
      }

      // Add bill image if provided
      // Add bill image if provided
      if (billImage != null) {
        // Get the file extension
        String fileName = billImage.path.split('/').last;
        String extension = fileName.split('.').last.toLowerCase();

        // Determine the correct MIME type
        String mimeType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'pdf':
            mimeType = 'application/pdf';
            break;
          default:
            mimeType = 'image/jpeg'; // fallback
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'billImage',
            billImage.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
      print(billImage!.path);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _error = null;
          _isCreatingExpense = false;
          notifyListeners();
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to create expense');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      _isCreatingExpense = false;
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class Category {
  final String id;
  final String name;
  final String landlord;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.landlord,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      landlord: json['landlord'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'landlord': landlord,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
