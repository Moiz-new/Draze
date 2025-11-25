import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TenantDocument {
  final String id;
  final String tenantId;
  final String documentType;
  final String filePath;
  final String originalName;
  final String mimeType;
  final int size;
  final bool isVisibleToLandlord;
  final DateTime uploadedAt;

  TenantDocument({
    required this.id,
    required this.tenantId,
    required this.documentType,
    required this.filePath,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.isVisibleToLandlord,
    required this.uploadedAt,
  });

  factory TenantDocument.fromJson(Map<String, dynamic> json) {
    return TenantDocument(
      id: json['_id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      documentType: json['documentType'] ?? '',
      filePath: json['filePath'] ?? '',
      originalName: json['originalName'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      isVisibleToLandlord: json['isVisibleToLandlord'] ?? false,
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get fileExtension {
    return originalName.split('.').last.toUpperCase();
  }

  // Get full URL for the document
  String get documentUrl {
    return 'https://api.drazeapp.com${filePath}';
  }

  // Check if document is an image
  bool get isImage {
    final ext = fileExtension.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'gif' || ext == 'webp';
  }
}

class TenantDocumentProvider extends ChangeNotifier {
  List<TenantDocument> _documents = [];
  bool _isLoading = false;
  String? _error;
  String? _authToken;

  List<TenantDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get authToken => _authToken;

  Future<void> fetchDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      _authToken = token;

      final response = await http.get(
        Uri.parse(
            'https://api.drazeapp.com/api/tenant-documents/landlord/68b0937d2ee1cd75dcd77015'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _documents = (data['documents'] as List)
              .map((doc) => TenantDocument.fromJson(doc))
              .toList();
          _error = null;
        } else {
          _error = 'Failed to load documents';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get headers for authenticated image requests
  Map<String, String> get imageHeaders {
    return {
      'Authorization': 'Bearer $_authToken',
    };
  }
}