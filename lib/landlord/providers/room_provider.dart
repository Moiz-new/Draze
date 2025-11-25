import 'package:draze/app/api_constants.dart';
import 'package:draze/landlord/models/FetchRoomModel.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<FetchRoomModel> _rooms = [];
  bool _isLoading = false;
  String? _error;

  List<FetchRoomModel> get rooms => _rooms;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadRooms(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _roomService.getRoomsByProperty(propertyId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _rooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getRoomImages(String propertyId, String roomId) async {
    try {
      return await _roomService.getRoomImages(propertyId, roomId);
    } catch (e) {
      return [];
    }
  }

  Future<DeleteRoomResult> deleteRoom(String propertyId, String roomId) async {
    try {
      final message = await _roomService.deleteRoom(propertyId, roomId);
      // Clear any previous errors before reloading
      _error = null;
      await loadRooms(propertyId);
      return DeleteRoomResult(success: true, message: message);
    } catch (e) {
      // Reload rooms even on error to reset the loading state
      await loadRooms(propertyId);
      // Don't set the provider error - handle it locally in the UI
      // This prevents the error from affecting the room list display
      return DeleteRoomResult(
        success: false,
        message: _extractErrorMessage(e.toString()),
      );
    }
  }

  String _extractErrorMessage(String error) {
    // Extract user-friendly message from error
    if (error.contains('Cannot delete room with active tenants')) {
      return 'Cannot delete room with active tenants. Please remove all tenants first.';
    } else if (error.contains('Error deleting room:')) {
      return error.replaceAll('Exception: Error deleting room: ', '');
    }
    return 'Failed to delete room. Please try again.';
  }

  Future<bool> addRoom(FetchRoomModel room, String propertyId) async {
    try {
      await _roomService.addRoom(room);
      await loadRooms(propertyId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoom(FetchRoomModel room, String propertyId) async {
    try {
      await _roomService.updateRoom(room);
      await loadRooms(propertyId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class DeleteRoomResult {
  final bool success;
  final String message;

  DeleteRoomResult({required this.success, required this.message});
}

class RoomService {
  static final String baseUrl = '$base_url/api/landlord';

  Future<List<FetchRoomModel>> getRoomsByProperty(String propertyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('$baseUrl/properties/$propertyId/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['rooms'] != null) {
          return (data['rooms'] as List)
              .map((room) => FetchRoomModel.fromJson(room))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rooms: $e');
    }
  }

  Future<List<String>> getRoomImages(String propertyId, String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/properties/$propertyId/room/$roomId/images'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['images'] != null) {
          return List<String>.from(data['images']);
        }
        return [];
      } else {
        throw Exception('Failed to load room images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching room images: $e');
    }
  }

  Future<String> deleteRoom(String propertyId, String roomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/properties/$propertyId/rooms/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      print(data);
      if (response.statusCode == 200) {
        return data['message'] ?? 'Room deleted successfully';
      } else {
        // Return the error message from server
        throw Exception(data['message'] ?? 'Failed to delete room');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error deleting room: $e');
    }
  }

  Future<void> addRoom(FetchRoomModel room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(room.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding room: $e');
    }
  }

  Future<void> updateRoom(FetchRoomModel room) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$baseUrl/rooms/${room.roomId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(room.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update room: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating room: $e');
    }
  }
}
