import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/SellerPropertyModel.dart';
import '../providers/SellerPropertyProvider.dart';

class EditPropertyScreen extends StatefulWidget {
  final String propertyId;

  const EditPropertyScreen({super.key, required this.propertyId});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  PropertyModel? _property;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;
  late TextEditingController _landmarkController;
  late TextEditingController _contactController;
  late TextEditingController _ownerNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  String _selectedType = 'PG';
  List<String> _selectedAmenities = [];

  final List<String> _propertyTypes = [
    'PG',
    'Hostel',
    'Apartment',
    'House',
    'Villa',
    'Plot',
    'Commercial',
    'Office',
  ];

  final List<String> _availableAmenities = [
    'Parking',
    '24x7 Water',
    'WiFi',
    'Power Backup',
    'Security',
    'CCTV',
    'Gym',
    'Swimming Pool',
    'Garden',
    'Elevator',
    'Laundry',
    'Kitchen',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProperty();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pinCodeController = TextEditingController();
    _landmarkController = TextEditingController();
    _contactController = TextEditingController();
    _ownerNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  Future<void> _loadProperty() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<SellerPropertyProvider>(context, listen: false);
      _property = provider.getPropertyById(widget.propertyId);

      if (_property != null) {
        _populateForm();
      } else {
        _showError('Property not found');
        context.pop();
      }
    } catch (e) {
      _showError('Error loading property: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateForm() {
    if (_property == null) return;

    _nameController.text = _property!.name;
    _addressController.text = _property!.address;
    _cityController.text = _property!.city;
    _stateController.text = _property!.state;
    _pinCodeController.text = _property!.pinCode;
    _landmarkController.text = _property!.landmark;
    _contactController.text = _property!.contactNumber;
    _ownerNameController.text = _property!.ownerName;
    _descriptionController.text = _property!.description;
    _latitudeController.text = _property!.latitude?.toString() ?? '';
    _longitudeController.text = _property!.longitude?.toString() ?? '';
    _selectedType = _property!.type;
    _selectedAmenities = _parseAmenities(_property!.amenities);
  }

  List<String> _parseAmenities(dynamic amenities) {
    List<String> result = [];
    if (amenities is List) {
      for (var amenity in amenities) {
        String cleaned = amenity.toString().trim();
        if (cleaned.isNotEmpty) result.add(cleaned);
      }
    } else if (amenities is String) {
      String cleaned = amenities
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", '');
      List<String> items = cleaned.split(',');
      for (var item in items) {
        String trimmed = item.trim();
        if (trimmed.isNotEmpty) result.add(trimmed);
      }
    }
    return result;
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final body = {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pinCode': _pinCodeController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'amenities': _selectedAmenities,
        'latitude': double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      };

      final response = await http.put(
        Uri.parse('https://api.drazeapp.com/api/seller/edit-property/${_property!.propertyId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Refresh properties list
        await Provider.of<SellerPropertyProvider>(context, listen: false)
            .refreshProperties();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Property updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(true);
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update property');
      }
    } catch (e) {
      _showError('Error updating property: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _landmarkController.dispose();
    _contactController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Edit Property'),
          backgroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Edit Property'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
          children: [
            _buildPropertyImages(),
            SizedBox(height: AppSizes.largePadding(context)),
            _buildBasicInfoSection(),
            SizedBox(height: AppSizes.largePadding(context)),
            _buildLocationSection(),
            SizedBox(height: AppSizes.largePadding(context)),
            _buildContactSection(),
            SizedBox(height: AppSizes.largePadding(context)),
            _buildAmenitiesSection(),
            SizedBox(height: AppSizes.largePadding(context)),
            _buildCoordinatesSection(),
            SizedBox(height: AppSizes.buttonHeight(context) * 2),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPropertyImages() {
    if (_property?.images.isEmpty ?? true) return const SizedBox.shrink();

    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _property!.images.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(AppSizes.smallPadding(context)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
                child: CachedNetworkImage(
                  imageUrl: _property!.images[index],
                  width: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Property Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter property name';
                return null;
              },
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Property Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _propertyTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter description';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter address';
                return null;
              },
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter city';
                return null;
              },
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.map),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: TextFormField(
                    controller: _pinCodeController,
                    decoration: InputDecoration(
                      labelText: 'PIN Code *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pin),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (value!.length != 6) return 'Invalid PIN';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _landmarkController,
              decoration: InputDecoration(
                labelText: 'Landmark',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.near_me),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _ownerNameController,
              decoration: InputDecoration(
                labelText: 'Owner Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter owner name';
                return null;
              },
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: 'Contact Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter contact number';
                if (value!.length != 10) return 'Invalid phone number';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Wrap(
              spacing: AppSizes.smallPadding(context),
              runSpacing: AppSizes.smallPadding(context),
              children: _availableAmenities.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAmenities.add(amenity);
                      } else {
                        _selectedAmenities.remove(amenity);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesSection() {
    return Card(
      elevation: AppSizes.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coordinates (Optional)',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.my_location),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_searching),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveProperty,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: AppSizes.mediumPadding(context)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
            ),
          ),
          child: _isSaving
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : Text(
            'Save Changes',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}