import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/landlord/models/room_model.dart';
import 'package:provider/provider.dart';

import '../models/FetchRoomModel.dart';
import '../providers/AddRoomServiceProvider.dart';
import '../providers/room_provider.dart';

class EditRoomScreen extends StatefulWidget {
  final String propertyId;
  final String roomId;

  const EditRoomScreen({
    super.key,
    required this.propertyId,
    required this.roomId,
  });

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _capacityController = TextEditingController();
  final _securityDepositController = TextEditingController();
  final _noticePeriodController = TextEditingController();

  RoomType _selectedType = RoomType.singleSharing;
  RoomStatus _selectedStatus = RoomStatus.available;
  final Map<String, bool> _selectedFacilities = {
    'bed': false,
    'table': false,
    'chair': false,
    'fan': false,
    'light': false,
    'ac': false,
    'geyser': false,
    'attachedWashroom': false,
    'westernToilet': false,
    'wifi': false,
    'powerBackup': false,
    'laundry': false,
    'housekeeping': false,
    'cctv': false,
    'securityGuard': false,
    'bikeParking': false,
    'carParking': false,
    'kitchen': false,
    'balcony': false,
    'market': false,
    'hospital': false,
  };
  bool _isLoading = false;
  bool _isLoadingData = true;

  final AddRoomServiceProvider _roomService = AddRoomServiceProvider();

  final Map<String, Map<String, dynamic>> _facilitiesData = {
    'Room Essentials': {
      'bed': {'name': 'Bed', 'icon': Icons.bed_outlined},
      'table': {'name': 'Table', 'icon': Icons.table_restaurant},
      'chair': {'name': 'Chair', 'icon': Icons.chair},
      'fan': {'name': 'Fan', 'icon': Icons.wind_power},
      'light': {'name': 'Light', 'icon': Icons.lightbulb_outline},
    },
    'Comfort Features': {
      'ac': {'name': 'AC', 'icon': Icons.ac_unit},
      'geyser': {'name': 'Geyser', 'icon': Icons.hot_tub},
    },
    'Washroom': {
      'attachedWashroom': {'name': 'Attached Washroom', 'icon': Icons.bathroom},
      'westernToilet': {'name': 'Western Toilet', 'icon': Icons.wc},
    },
    'Utilities': {
      'wifi': {'name': 'WiFi', 'icon': Icons.wifi},
      'powerBackup': {'name': 'Power Backup', 'icon': Icons.power},
    },
    'Services': {
      'laundry': {'name': 'Laundry', 'icon': Icons.local_laundry_service},
      'housekeeping': {'name': 'Housekeeping', 'icon': Icons.cleaning_services},
    },
    'Security': {
      'cctv': {'name': 'CCTV', 'icon': Icons.videocam},
      'securityGuard': {'name': 'Security Guard', 'icon': Icons.security},
    },
    'Parking': {
      'bikeParking': {'name': 'Bike Parking', 'icon': Icons.two_wheeler},
      'carParking': {'name': 'Car Parking', 'icon': Icons.directions_car},
    },
    'Property Features': {
      'kitchen': {'name': 'Kitchen', 'icon': Icons.kitchen},
      'balcony': {'name': 'Balcony', 'icon': Icons.balcony},
    },
    'Nearby': {
      'market': {'name': 'Market', 'icon': Icons.shopping_cart},
      'hospital': {'name': 'Hospital', 'icon': Icons.local_hospital},
    },
  };

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      await roomProvider.loadRooms(widget.propertyId);

      final room = roomProvider.rooms.firstWhere(
            (r) => r.roomId == widget.roomId,
        orElse: () => throw Exception('Room not found'),
      );

      _populateFormWithRoomData(room);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading room data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _populateFormWithRoomData(FetchRoomModel room) {
    _roomNumberController.text = room.name;
    _monthlyRentController.text = room.price.toStringAsFixed(0);
    _capacityController.text = room.capacity.toString();

    // Populate new fields - handle null values
    _securityDepositController.text = room.securityDeposit?.toStringAsFixed(0) ?? '0';
    _noticePeriodController.text = room.noticePeriod?.toString() ?? '30';

    _selectedType = _mapStringToRoomType(room.type);
    _selectedStatus = _mapStringToRoomStatus(room.status);

    if (room.facilities != null) {
      final facilities = room.facilities!;

      _selectedFacilities['bed'] = facilities.roomEssentials?.bed ?? false;
      _selectedFacilities['table'] =
          facilities.roomEssentials?.tableStudyDesk ?? false;
      _selectedFacilities['chair'] = facilities.roomEssentials?.chair ?? false;
      _selectedFacilities['fan'] = facilities.roomEssentials?.fan ?? false;
      _selectedFacilities['light'] = facilities.roomEssentials?.light ?? false;

      _selectedFacilities['ac'] = facilities.comfortFeatures?.ac ?? false;

      _selectedFacilities['attachedWashroom'] =
          facilities.washroomHygiene?.washBasins ?? false;
      _selectedFacilities['westernToilet'] =
          facilities.washroomHygiene?.westernToilet ?? false;

      _selectedFacilities['wifi'] =
          facilities.utilitiesConnectivity?.wifi ?? false;
      _selectedFacilities['powerBackup'] =
          facilities.utilitiesConnectivity?.powerBackup ?? false;

      _selectedFacilities['laundry'] =
          facilities.laundryHousekeeping?.laundryArea ?? false;

      _selectedFacilities['cctv'] = facilities.securitySafety?.cctv ?? false;
      _selectedFacilities['securityGuard'] =
          facilities.securitySafety?.securityGuard ?? false;

      _selectedFacilities['bikeParking'] =
          facilities.parkingTransport?.bikeParking ?? false;
      _selectedFacilities['carParking'] =
          facilities.parkingTransport?.carParking ?? false;

      _selectedFacilities['kitchen'] =
          facilities.propertySpecific?.modularKitchen ?? false;

      _selectedFacilities['hospital'] =
          facilities.nearbyFacilities?.hospital ?? false;
    }

    setState(() {});
  }

  RoomType _mapStringToRoomType(String type) {
    switch (type.toLowerCase()) {
      case 'private room':
        return RoomType.singleSharing;
      case 'shared room':
        return RoomType.doubleSharing;

      default:
        return RoomType.singleSharing;
    }
  }

  RoomStatus _mapStringToRoomStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return RoomStatus.available;
      case 'occupied':
        return RoomStatus.unavailable;
      default:
        return RoomStatus.available;
    }
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _monthlyRentController.dispose();
    _capacityController.dispose();
    _securityDepositController.dispose();
    _noticePeriodController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFacilitiesObject() {
    return {
      'roomEssentials': {
        'bed': _selectedFacilities['bed'] ?? false,
        'table': _selectedFacilities['table'] ?? false,
        'chair': _selectedFacilities['chair'] ?? false,
        'fan': _selectedFacilities['fan'] ?? false,
        'light': _selectedFacilities['light'] ?? false,
      },
      'comfortFeatures': {
        'ac': _selectedFacilities['ac'] ?? false,
        'geyser': _selectedFacilities['geyser'] ?? false,
      },
      'washroomHygiene': {
        'attachedWashroom': _selectedFacilities['attachedWashroom'] ?? false,
        'westernToilet': _selectedFacilities['westernToilet'] ?? false,
      },
      'utilitiesConnectivity': {
        'wifi': _selectedFacilities['wifi'] ?? false,
        'powerBackup': _selectedFacilities['powerBackup'] ?? false,
      },
      'laundryHousekeeping': {
        'laundry': _selectedFacilities['laundry'] ?? false,
        'housekeeping': _selectedFacilities['housekeeping'] ?? false,
      },
      'securitySafety': {
        'cctv': _selectedFacilities['cctv'] ?? false,
        'securityGuard': _selectedFacilities['securityGuard'] ?? false,
      },
      'parkingTransport': {
        'bikeParking': _selectedFacilities['bikeParking'] ?? false,
        'carParking': _selectedFacilities['carParking'] ?? false,
      },
      'propertySpecific': {
        'kitchen': _selectedFacilities['kitchen'] ?? false,
        'balcony': _selectedFacilities['balcony'] ?? false,
      },
      'nearbyFacilities': {
        'market': _selectedFacilities['market'] ?? false,
        'hospital': _selectedFacilities['hospital'] ?? false,
      },
    };
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final capacity = int.tryParse(_capacityController.text) ?? 1;
        final price = double.tryParse(_monthlyRentController.text) ?? 0.0;
        final securityDeposit = double.tryParse(_securityDepositController.text) ?? 0.0;
        final noticePeriod = int.tryParse(_noticePeriodController.text) ?? 30;

        final roomData = {
          'name': _roomNumberController.text,
          'type': AddRoomServiceProvider.mapRoomType(_selectedType.name),
          'price': price,
          'capacity': capacity,
          'status': AddRoomServiceProvider.mapStatus(_selectedStatus.name),
          'securityDeposit': securityDeposit,
          'noticePeriod': noticePeriod,
          'facilities': _buildFacilitiesObject(),
        };

        final success = await _roomService.updateRoom(
          propertyId: widget.propertyId,
          roomId: widget.roomId,
          roomData: roomData,
        );

        if (success && mounted) {
          await Provider.of<RoomProvider>(
            context,
            listen: false,
          ).loadRooms(widget.propertyId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Room updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context) * 0.8,
                ),
              ),
            ),
          );

          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating room: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context) * 0.8,
                ),
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text('Edit Room', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(AppSizes.smallPadding(context) * 0.8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context) * 0.8,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                AppSizes.smallPadding(context) * 0.8 * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius(context) * 0.8,
                ),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 19.2),
            ),
            SizedBox(width: AppSizes.smallPadding(context) * 0.8),
            Text(
              'Edit Room',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.titleText(context) * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.2),
          child: Container(
            height: 3.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 0.8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _buildEnhancedTextField(
                      controller: _roomNumberController,
                      label: 'Room Name/Number',
                      hint: 'Enter room name (e.g., Luxury Room 101)',
                      icon: Icons.room_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter room name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
                    _buildRoomTypeCard(),
                    SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
                    _buildRoomStatusCard(),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
              _buildSectionCard(
                title: 'Pricing & Capacity',
                icon: Icons.currency_rupee,
                child: Column(
                  children: [
                    _buildEnhancedTextField(
                      controller: _monthlyRentController,
                      label: 'Monthly Rent',
                      hint: 'Enter amount',
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                      prefix: '₹ ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
                    _buildEnhancedTextField(
                      controller: _securityDepositController,
                      label: 'Security Deposit',
                      hint: 'Enter deposit amount',
                      icon: Icons.shield_outlined,
                      keyboardType: TextInputType.number,
                      prefix: '₹ ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
                    _buildEnhancedTextField(
                      controller: _noticePeriodController,
                      label: 'Notice Period',
                      hint: 'Enter days (e.g., 30)',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      suffix: ' days',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
                    _buildEnhancedTextField(
                      controller: _capacityController,
                      label: 'Capacity',
                      hint: 'Number of beds',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
              _buildSectionCard(
                title: 'Facilities & Amenities',
                icon: Icons.star_outline,
                child: _buildFacilitiesSection(),
              ),
              SizedBox(height: AppSizes.largePadding(context) * 0.8),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 0.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 0.8,
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.smallPadding(context) * 0.8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context) * 0.8,
              ),
            ),
            child: const Icon(Icons.edit_note, color: Colors.white, size: 25.6),
          ),
          SizedBox(width: AppSizes.mediumPadding(context) * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Room Details',
                  style: TextStyle(
                    fontSize: AppSizes.largeText(context) * 0.8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSizes.smallPadding(context) * 0.5 * 0.8),
                Text(
                  'Modify the information below to update the room',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context) * 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 1.6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 0.8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  AppSizes.cardCornerRadius(context) * 0.8,
                ),
                topRight: Radius.circular(
                  AppSizes.cardCornerRadius(context) * 0.8,
                ),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 19.2),
                SizedBox(width: AppSizes.smallPadding(context) * 0.8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.largeText(context) * 0.8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 0.8),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        prefixIcon: Container(
          margin: EdgeInsets.all(AppSizes.smallPadding(context) * 0.5 * 0.8),
          padding: EdgeInsets.all(AppSizes.smallPadding(context) * 0.5 * 0.8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context) * 0.8 * 0.5,
            ),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppSizes.mediumText(context) * 0.8,
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withOpacity(0.7),
          fontSize: AppSizes.mediumText(context) * 0.8,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 0.8,
          ),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 0.8,
          ),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 0.8,
          ),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context) * 0.8,
          ),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildRoomTypeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 0.8,
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<RoomType>(
        value: _selectedType,
        decoration: InputDecoration(
          labelText: 'Room Type',
          prefixIcon: Container(
            margin: EdgeInsets.all(AppSizes.smallPadding(context) * 0.5 * 0.8),
            padding: EdgeInsets.all(AppSizes.smallPadding(context) * 0.5 * 0.8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context) * 0.8 * 0.5,
              ),
            ),
            child: Icon(Icons.bed_outlined, color: AppColors.primary, size: 16),
          ),
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.mediumText(context) * 0.8,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.mediumPadding(context) * 0.8,
            vertical: AppSizes.smallPadding(context) * 0.8,
          ),
        ),
        items: RoomType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              type.displayName,
              style: TextStyle(
                fontSize: AppSizes.mediumText(context) * 0.8,
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
      ),
    );
  }

  Widget _buildRoomStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 0.8,
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<RoomStatus>(
        value: _selectedStatus,
        decoration: InputDecoration(
          labelText: 'Room Status',
          prefixIcon: Container(
            margin: EdgeInsets.all(AppSizes.smallPadding(context) * 0.5 * 0.8),
            padding: EdgeInsets.all(AppSizes.smallPadding(context) * 0.5 * 0.8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context) * 0.8 * 0.5,
              ),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppSizes.mediumText(context) * 0.8,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.mediumPadding(context) * 0.8,
            vertical: AppSizes.smallPadding(context) * 0.8,
          ),
        ),
        items:
            RoomStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 9.6,
                      height: 9.6,
                      decoration: BoxDecoration(
                        color:
                            status == RoomStatus.available
                                ? Colors.green
                                : status == RoomStatus.unavailable
                                ? Colors.orange
                                : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSizes.smallPadding(context) * 0.8),
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: AppSizes.mediumText(context) * 0.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedStatus = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _facilitiesData.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSizes.smallPadding(context) * 0.8,
                    top: AppSizes.smallPadding(context) * 0.4,
                  ),
                  child: Text(
                    category.key,
                    style: TextStyle(
                      fontSize: AppSizes.mediumText(context) * 0.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 9.6,
                    mainAxisSpacing: 9.6,
                    childAspectRatio: 1,
                  ),
                  itemCount: category.value.length,
                  itemBuilder: (context, index) {
                    final facilityKey = category.value.keys.elementAt(index);
                    final facility = category.value[facilityKey];
                    final isSelected =
                        _selectedFacilities[facilityKey] ?? false;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFacilities[facilityKey] = !isSelected;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.background,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius(context) * 0.8,
                          ),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.divider,
                            width: isSelected ? 1.6 : 0.8,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 6.4,
                                      offset: const Offset(0, 1.6),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              facility['icon'],
                              color:
                                  isSelected ? Colors.white : AppColors.primary,
                              size: 19.2,
                            ),
                            SizedBox(
                              height:
                                  AppSizes.smallPadding(context) * 0.5 * 0.8,
                            ),
                            Text(
                              facility['name'],
                              style: TextStyle(
                                fontSize:
                                    AppSizes.smallText(context) * 0.9 * 0.8,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeight(context) * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(
          AppSizes.cardCornerRadius(context) * 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 9.6,
            offset: const Offset(0, 3.2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context) * 0.8,
            ),
          ),
        ),
        child:
            _isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1.6,
                    ),
                    SizedBox(width: AppSizes.smallPadding(context) * 0.8),
                    Text(
                      'Updating Room...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.mediumText(context) * 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: AppSizes.smallPadding(context) * 0.8),
                    Text(
                      'Update Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.mediumText(context) * 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
