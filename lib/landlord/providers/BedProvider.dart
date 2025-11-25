import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model class for Available Bed
class AvailableBed {
  final String bedId;
  final double price;
  final String status;
  final String name;

  AvailableBed({
    required this.bedId,
    required this.price,
    required this.status,
    required this.name,
  });

  factory AvailableBed.fromJson(Map<String, dynamic> json) {
    return AvailableBed(
      bedId: json['bedId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedId': bedId,
      'name': name,
      'price': price,
      'status': status,
    };
  }
}

class BedProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _lastAddedBedId;
  List<AvailableBed> _availableBeds = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastAddedBedId => _lastAddedBedId;
  List<AvailableBed> get availableBeds => _availableBeds;

  // Fetch available beds from API
  Future<bool> fetchAvailableBeds({
    required String propertyId,
    required String roomId,
  }) async {
    _isLoading = true;
    _error = null;
    _availableBeds = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(
        '$base_url/api/landlord/properties/$propertyId/rooms/$roomId/available-beds',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _isLoading = false;

      print('Available beds response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final bedsList = data['beds'] as List;
          _availableBeds = bedsList
              .map((bed) => AvailableBed.fromJson(bed))
              .toList();
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to fetch available beds';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to fetch available beds. Status: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Add a new bed
  Future<bool> addBed({
    required String propertyId,
    required String roomId,
    required String name,
    required double price,
    required String status,
  }) async {
    _isLoading = true;
    _error = null;
    _lastAddedBedId = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(
        '$base_url/api/landlord/properties/$propertyId/rooms/$roomId/beds',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'price': price,
          'status': status,
        }),
      );

      _isLoading = false;

      print('Add bed response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _lastAddedBedId = data['bed']['bedId'];
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to add bed';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to add bed. Status: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete a bed
  Future<bool> deleteBed({
    required String propertyId,
    required String roomId,
    required String bedId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(
        '$base_url/api/landlord/properties/$propertyId/rooms/$roomId/beds/$bedId',
      );

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _isLoading = false;

      print('Delete bed response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to delete bed';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to delete bed. Status: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Upload bed images
  Future<bool> uploadBedImages(
      String propertyId,
      String roomId,
      String bedId,
      List<XFile> images,
      ) async {
    if (images.isEmpty) {
      _error = 'Please select at least one image';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(
        '$base_url/api/landlord/properties/$propertyId/rooms/$roomId/beds/$bedId/images',
      );

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            image.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _isLoading = false;

      print('Upload images response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to upload images';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to upload images. Status: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error uploading images: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Add this method to your BedProvider class

// Update/Edit a bed
  Future<bool> updateBed({
    required String propertyId,
    required String roomId,
    required String bedId,
    required double price,
    required String status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(
        '$base_url/api/landlord/properties/$propertyId/rooms/$roomId/beds/$bedId',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'price': price,
          'status': status,
        }),
      );

      _isLoading = false;

      print('Update bed response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to update bed';
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Failed to update bed. Status: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }




  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear last added bed ID
  void clearLastBedId() {
    _lastAddedBedId = null;
    notifyListeners();
  }

  // Clear available beds list
  void clearAvailableBeds() {
    _availableBeds = [];
    notifyListeners();
  }
}