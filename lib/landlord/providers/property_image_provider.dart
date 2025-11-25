import 'dart:convert';
import 'dart:io';
import 'package:draze/app/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

// Models
class PropertyImageUploadState {
  final bool isLoading;
  final String? error;
  final PropertyResponse? response;
  final List<XFile> selectedImages;

  PropertyImageUploadState({
    this.isLoading = false,
    this.error,
    this.response,
    this.selectedImages = const [],
  });

  PropertyImageUploadState copyWith({
    bool? isLoading,
    String? error,
    PropertyResponse? response,
    List<XFile>? selectedImages,
  }) {
    return PropertyImageUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      response: response ?? this.response,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}

class PropertyResponse {
  final bool success;
  final Property property;

  PropertyResponse({required this.success, required this.property});

  factory PropertyResponse.fromJson(Map<String, dynamic> json) {
    return PropertyResponse(
      success: json['success'] ?? false,
      property: Property.fromJson(json['property'] ?? {}),
    );
  }
}

class Property {
  final String id;
  final String propertyId;
  final String landlordId;
  final String name;
  final String type;
  final String address;
  final String pinCode;
  final String city;
  final String state;
  final String landmark;
  final String contactNumber;
  final String description;
  final List<String> images;
  final int totalRooms;
  final int totalBeds;
  final int monthlyCollection;
  final int pendingDues;
  final int totalCapacity;
  final int occupiedSpace;
  final bool isActive;
  final List<dynamic> rooms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RatingSummary ratingSummary;
  final int commentCount;

  Property({
    required this.id,
    required this.propertyId,
    required this.landlordId,
    required this.name,
    required this.type,
    required this.address,
    required this.pinCode,
    required this.city,
    required this.state,
    required this.landmark,
    required this.contactNumber,
    required this.description,
    required this.images,
    required this.totalRooms,
    required this.totalBeds,
    required this.monthlyCollection,
    required this.pendingDues,
    required this.totalCapacity,
    required this.occupiedSpace,
    required this.isActive,
    required this.rooms,
    required this.createdAt,
    required this.updatedAt,
    required this.ratingSummary,
    required this.commentCount,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      pinCode: json['pinCode'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      landmark: json['landmark'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      totalRooms: json['totalRooms'] ?? 0,
      totalBeds: json['totalBeds'] ?? 0,
      monthlyCollection: json['monthlyCollection'] ?? 0,
      pendingDues: json['pendingDues'] ?? 0,
      totalCapacity: json['totalCapacity'] ?? 0,
      occupiedSpace: json['occupiedSpace'] ?? 0,
      isActive: json['isActive'] ?? false,
      rooms: List<dynamic>.from(json['rooms'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      ratingSummary: RatingSummary.fromJson(json['ratingSummary'] ?? {}),
      commentCount: json['commentCount'] ?? 0,
    );
  }
}

class RatingSummary {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingDistribution;

  RatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      ratingDistribution: Map<String, int>.from(
        json['ratingDistribution'] ?? {},
      ),
    );
  }
}

// Provider
class PropertyImagesNotifier extends StateNotifier<PropertyImageUploadState> {
  PropertyImagesNotifier() : super(PropertyImageUploadState());

  static final String _baseUrl = base_url;
  static const String _uploadEndpoint = '/landlord/properties/images';

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  void updateSelectedImages(List<XFile> images) {
    state = state.copyWith(selectedImages: images, error: null);
  }

  void addSelectedImage(XFile image) {
    final updatedImages = [...state.selectedImages, image];
    // Limit to maximum 10 images
    if (updatedImages.length > 10) {
      updatedImages.removeRange(10, updatedImages.length);
    }
    state = state.copyWith(selectedImages: updatedImages, error: null);
  }

  void removeSelectedImage(int index) {
    final updatedImages = [...state.selectedImages];
    if (index >= 0 && index < updatedImages.length) {
      updatedImages.removeAt(index);
      state = state.copyWith(selectedImages: updatedImages, error: null);
    }
  }

  void clearSelectedImages() {
    state = state.copyWith(selectedImages: [], error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<bool> uploadImages(String propertyId) async {
    if (state.selectedImages.isEmpty) {
      state = state.copyWith(error: 'Please add at least one image');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Authentication token not found. Please login again.',
        );
        return false;
      }

      final uri = Uri.parse('$base_url/api/landlord/properties/images');
      final request = http.MultipartRequest('POST', uri);

      // Add headers - DO NOT manually set Content-Type
      request.headers['Authorization'] = 'Bearer $authToken';

      // Add propertyId to the request
      request.fields['propertyId'] = propertyId;

      // Add images to the request
      for (int i = 0; i < state.selectedImages.length; i++) {
        final image = state.selectedImages[i];
        final file = File(image.path);

        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'images', // Verify this matches your Postman request
            bytes,
            filename: image.name ?? 'image_$i.jpg',
          );
          request.files.add(multipartFile);
          print('Added file: ${image.name}, size: ${bytes.length}');
        } else {
          print('File not found: ${image.path}');
        }
      }

      print('Uploading ${request.files.length} files to: $uri');
      print('PropertyId: $propertyId');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        final propertyResponse = PropertyResponse.fromJson(jsonData);

        state = state.copyWith(
          isLoading: false,
          response: propertyResponse,
          selectedImages: [],
        );
        return true;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Upload failed';

        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');

      String errorMessage = 'An error occurred while uploading images';

      if (e is SocketException) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e is http.ClientException) {
        errorMessage = 'Network error occurred. Please try again.';
      } else if (e is FormatException) {
        errorMessage = 'Invalid response from server.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }}

final propertyImagesProvider =
    StateNotifierProvider<PropertyImagesNotifier, PropertyImageUploadState>((
      ref,
    ) {
      return PropertyImagesNotifier();
    });
