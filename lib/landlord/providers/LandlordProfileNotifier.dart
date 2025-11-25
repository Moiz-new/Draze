import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/api_constants.dart';

// Bank Account Model
class BankAccount {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;

  BankAccount({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountHolderName: json['accountHolderName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      bankName: json['bankName'] ?? '',
      branchName: json['branchName'] ?? '',
    );
  }

  bool get isEmpty => accountHolderName.isEmpty && accountNumber.isEmpty;
}

// Model class for Landlord Profile
class LandlordProfile {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String aadhaarNumber;
  final String panNumber;
  final String address;
  final String pinCode;
  final String state;
  final String gender;
  final String dob;
  final List<dynamic> properties;
  final String profilePhoto;
  final String signature;
  final String createdAt;
  final int totalCollected;
  final int totalOutstanding;
  final BankAccount? bankAccount;

  LandlordProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.address,
    required this.pinCode,
    required this.state,
    required this.gender,
    required this.dob,
    required this.properties,
    required this.profilePhoto,
    required this.signature,
    required this.createdAt,
    required this.totalCollected,
    required this.totalOutstanding,
    this.bankAccount,
  });

  factory LandlordProfile.fromJson(Map<String, dynamic> json) {
    return LandlordProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      address: json['address'] ?? '',
      pinCode: json['pinCode'] ?? '',
      state: json['state'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      properties: json['properties'] ?? [],
      profilePhoto: json['profilePhoto'] ?? '',
      signature: json['signature'] ?? '',
      createdAt: json['createdAt'] ?? '',
      totalCollected: json['totalCollected'] ?? 0,
      totalOutstanding: json['totalOutstanding'] ?? 0,
      bankAccount: json['bankAccount'] != null
          ? BankAccount.fromJson(json['bankAccount'])
          : null,
    );
  }

  // Helper method to get full profile image URL
  String get fullProfileImageUrl {
    if (profilePhoto.isEmpty) return '';
    final photoPath = profilePhoto.startsWith('/')
        ? profilePhoto.substring(1)
        : profilePhoto;
    return '$base_url/$photoPath';
  }

  // Helper method to get full signature URL
  String get fullSignatureUrl {
    if (signature.isEmpty) return '';
    final signaturePath = signature.startsWith('/')
        ? signature.substring(1)
        : signature;
    return '$base_url/$signaturePath';
  }

  // Helper method to format joined date
  String get formattedJoinedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt;
    }
  }

  // Helper method to get phone with country code format
  String get formattedPhone {
    if (mobile.isEmpty) return '';
    return '+91 $mobile';
  }

  // Helper method to get full address
  String get fullAddress {
    if (address.isEmpty) return '';
    return '$address, $state $pinCode';
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });
}

// Provider for landlord profile
class LandlordProfileNotifier extends StateNotifier<AsyncValue<LandlordProfile?>> {
  LandlordProfileNotifier() : super(const AsyncValue.loading());

  static final String baseUrl = base_url;
  static const String profileEndpoint = '/api/landlord/profile';

  Future<void> fetchProfile() async {
    try {
      state = const AsyncValue.loading();

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null || authToken.isEmpty) {
        state = AsyncValue.error('Authentication token not found', StackTrace.current);
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl$profileEndpoint'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('Profile API Response Status: ${response.statusCode}');
      print('Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['landlord'] != null) {
          final profile = LandlordProfile.fromJson(jsonData['landlord']);
          print('Profile loaded successfully: ${profile.name}');
          print('Profile Image URL: ${profile.fullProfileImageUrl}');
          state = AsyncValue.data(profile);
        } else {
          state = AsyncValue.error(
            jsonData['message'] ?? 'Failed to load profile',
            StackTrace.current,
          );
        }
      } else if (response.statusCode == 401) {
        state = AsyncValue.error('Unauthorized access. Please login again.', StackTrace.current);
      } else {
        state = AsyncValue.error(
          'Failed to load profile. Status code: ${response.statusCode}',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      print('Profile fetch error: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error('Network error: ${e.toString()}', stackTrace);
    }
  }

  Future<void> refreshProfile() async {
    await fetchProfile();
  }
}

final landlordProfileProvider = StateNotifierProvider<LandlordProfileNotifier, AsyncValue<LandlordProfile?>>((ref) {
  return LandlordProfileNotifier();
});

final ownerDataProvider = Provider<Map<String, dynamic>>((ref) {
  final profileAsync = ref.watch(landlordProfileProvider);

  return profileAsync.when(
    data: (profile) {
      if (profile == null) {
        return _getDefaultOwnerData();
      }

      final totalRevenue = profile.totalCollected + profile.totalOutstanding;

      return {
        'name': profile.name.isNotEmpty ? profile.name : 'Unknown User',
        'email': profile.email,
        'phone': profile.formattedPhone,
        'address': profile.fullAddress.isNotEmpty ? profile.fullAddress : 'Address not provided',
        'profileImage': profile.fullProfileImageUrl.isNotEmpty
            ? profile.fullProfileImageUrl
            : 'https://via.placeholder.com/150x150?text=No+Image',
        'joinedDate': profile.formattedJoinedDate,
        'totalProperties': profile.properties.length,
        'totalTenants': profile.properties.length * 3,
        'monthlyRevenue': totalRevenue.toDouble(),
        'totalCollected': profile.totalCollected,
        'totalOutstanding': profile.totalOutstanding,
        'kycStatus': (profile.aadhaarNumber.isNotEmpty && profile.panNumber.isNotEmpty) ? 'Verified' : 'Pending',
        'accountType': 'Premium',
        'rating': 4.8,
        'completedDeals': profile.properties.length * 20,
      };
    },
    loading: () => _getDefaultOwnerData(),
    error: (error, stack) => _getDefaultOwnerData(),
  );
});

Map<String, dynamic> _getDefaultOwnerData() {
  return {
    'name': 'Loading...',
    'email': 'loading@example.com',
    'phone': '+91 0000000000',
    'address': 'Loading address...',
    'profileImage': 'https://via.placeholder.com/150x150?text=Loading',
    'joinedDate': '2022-03-15',
    'totalProperties': 0,
    'totalTenants': 0,
    'monthlyRevenue': 0.0,
    'totalCollected': 0,
    'totalOutstanding': 0,
    'kycStatus': 'Pending',
    'accountType': 'Premium',
    'rating': 0.0,
    'completedDeals': 0,
  };
}