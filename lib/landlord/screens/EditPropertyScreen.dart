import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:draze/landlord/models/property_model.dart';

import '../providers/property_api_service.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> propertyData;

  const EditPropertyScreen({super.key, required this.propertyData});

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _contactController = TextEditingController();
  final _ownerNameController = TextEditingController();


  PropertyType _selectedType = PropertyType.pg;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PropertyApiService _apiService = PropertyApiService();

  String? propertyId;
  String? propertyIdForApi;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Initialize form with existing property data
    _initializeFormData();
  }

  void _initializeFormData() {
    final property = widget.propertyData;

    propertyId = property['_id'] ?? property['id'];
    propertyIdForApi = property['propertyId'];

    _nameController.text = property['name'] ?? '';
    _addressController.text = property['address'] ?? '';
    _cityController.text = property['city'] ?? '';
    _stateController.text = property['state'] ?? '';
    _pincodeController.text = property['pinCode'] ?? '';
    _descriptionController.text = property['description'] ?? '';
    _landmarkController.text = property['landmark'] ?? '';
    _contactController.text = property['contactNumber'] ?? '';
    _ownerNameController.text = property['ownerName'] ?? '';



    // Convert type string to PropertyType enum
    _selectedType = _getPropertyTypeFromString(property['type'] ?? 'PG');
  }

  PropertyType _getPropertyTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'pg':
        return PropertyType.pg;
      case 'hostel':
        return PropertyType.hostel;
      case 'rental':
        return PropertyType.rental;
      case '1 bhk':
        return PropertyType.oneBhk;
      case '2 bhk':
        return PropertyType.twoBhk;
      case '3 bhk':
        return PropertyType.threeBhk;
      case '4 bhk':
        return PropertyType.fourBhk;
      case '1 rk':
        return PropertyType.oneRk;
      case 'studio apartment':
        return PropertyType.studioApartment;
      case 'luxury bungalows':
        return PropertyType.luxuryBungalows;
      case 'villas':
        return PropertyType.villas;
      case 'builder floor':
        return PropertyType.builderFloor;
      case 'flat':
        return PropertyType.flat;
      case 'room':
        return PropertyType.room;
      default:
        return PropertyType.pg;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _descriptionController.dispose();
    _landmarkController.dispose();
    _contactController.dispose();
    _ownerNameController.dispose();

    super.dispose();
  }

  // API Integration Method for Update
  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (propertyIdForApi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate required fields
      if (_nameController.text.trim().isEmpty) {
        throw Exception('Property name is required');
      }
      if (_addressController.text.trim().isEmpty) {
        throw Exception('Address is required');
      }
      if (_cityController.text.trim().isEmpty) {
        throw Exception('City is required');
      }
      if (_stateController.text.trim().isEmpty) {
        throw Exception('State is required');
      }
      if (_pincodeController.text.trim().isEmpty) {
        throw Exception('Pincode is required');
      }

      // Call API with updated fields
      final response = await _apiService.updateProperty(
        propertyId: propertyId!,
        name: _nameController.text.trim(),
        type: _selectedType,
        address: _addressController.text.trim(),
        pinCode: _pincodeController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        landmark:
            _landmarkController.text.trim().isEmpty
                ? _addressController.text.trim()
                : _landmarkController.text.trim(),
        contactNumber:
            _contactController.text.trim().isEmpty
                ? 'Not provided'
                : _contactController.text.trim(),
        ownerName:
            _ownerNameController.text.trim().isEmpty
                ? 'Property Owner'
                : _ownerNameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? 'No description provided'
                : _descriptionController.text.trim(),

      );

      if (response != null && response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Property updated successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to update property');
      }
    } catch (e) {
      print('Error updating property: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(children: [Expanded(child: _buildStepperContent())]),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Edit Property',
        style: TextStyle(
          color: Colors.white,
          fontSize: AppSizes.mediumText(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepperContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      child: Column(
        children: [
          _buildBasicInfoCard(),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildAddressCard(),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildContactCard(),
          SizedBox(height: AppSizes.largePadding(context)),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppSizes.smallIcon(context),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: 'Basic Information',
      icon: Icons.home_outlined,
      children: [
        EnhancedTextField(
          controller: _nameController,
          label: 'Property Name *',
          hint: 'Enter a descriptive name for your property',
          icon: Icons.business_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter property name';
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        _buildPropertyTypeDropdown(),
        SizedBox(height: AppSizes.mediumPadding(context)),
        EnhancedTextField(
          controller: _ownerNameController,
          label: 'Owner Name',
          hint: 'Enter property owner name',
          icon: Icons.person_outlined,
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        EnhancedTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Describe your property features and highlights',
          icon: Icons.description_outlined,
          maxLines: 4,
        ),

      ],
    );
  }

  Widget _buildAddressCard() {
    return _buildCard(
      title: 'Address Details',
      icon: Icons.location_on_outlined,
      children: [
        EnhancedTextField(
          controller: _addressController,
          label: 'Complete Address *',
          hint: 'Enter street address, area, etc.',
          icon: Icons.home_outlined,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        EnhancedTextField(
          controller: _landmarkController,
          label: 'Landmark',
          hint: 'Enter nearby landmark',
          icon: Icons.location_searching_outlined,
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        Row(
          children: [
            Expanded(
              child: EnhancedTextField(
                controller: _cityController,
                label: 'City *',
                hint: 'Enter city',
                icon: Icons.location_city_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Expanded(
              child: EnhancedTextField(
                controller: _stateController,
                label: 'State *',
                hint: 'Enter state',
                icon: Icons.map_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.mediumPadding(context)),
        EnhancedTextField(
          controller: _pincodeController,
          label: 'Pincode *',
          hint: 'Enter 6-digit pincode',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter pincode';
            }
            if (value.trim().length != 6) {
              return 'Pincode must be 6 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      children: [
        EnhancedTextField(
          controller: _contactController,
          label: 'Contact Number',
          hint: 'Enter 10-digit mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (value) {
            if (value != null &&
                value.trim().isNotEmpty &&
                value.trim().length != 10) {
              return 'Contact number must be 10 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<PropertyType>(
        value: _selectedType,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.home_work_outlined, color: AppColors.primary),
          labelText: 'Property Type *',
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.smallText(context),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context),
            ),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        items:
            PropertyType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedType = value;
            });
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a property type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeight(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _updateProperty,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          child: Center(
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.update_outlined, color: Colors.white),
                        SizedBox(width: AppSizes.smallPadding(context)),
                        Text(
                          'Update Property',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.mediumText(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

// Enhanced TextField Widget (same as AddPropertyScreen)
class EnhancedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;

  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: AppColors.divider,
      end: AppColors.primary,
    ).animate(_animationController);

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context),
            ),
            boxShadow:
                _isFocused
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon:
                  widget.icon != null
                      ? Icon(
                        widget.icon,
                        color:
                            _isFocused
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      )
                      : null,
              suffixIcon: widget.suffixIcon,
              suffixStyle: TextStyle(
                fontSize: AppSizes.smallIcon(context),
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
              ),
              labelStyle: TextStyle(
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                fontSize: AppSizes.smallText(context) - 5,
                fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
              ),
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.smallText(context),
              ),
              filled: true,
              fillColor:
                  _isFocused
                      ? AppColors.surface
                      : AppColors.surface.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: _colorAnimation.value!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context),
                ),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
            ),
            validator: widget.validator,
          ),
        );
      },
    );
  }
}
