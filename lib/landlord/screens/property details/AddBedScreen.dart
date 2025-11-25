import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/landlord/providers/room_provider.dart';

import '../../providers/BedProvider.dart';
import 'AddBedImagesScreen.dart';

class AddBedScreen extends StatefulWidget {
  final String propertyId;
  final String roomId;

  const AddBedScreen({
    super.key,
    required this.propertyId,
    required this.roomId,
  });

  @override
  State<AddBedScreen> createState() => _AddBedScreenState();
}

class _AddBedScreenState extends State<AddBedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedStatus = 'Available';

  final List<String> _statusOptions = ['Available', 'Maintenance'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Updated handleSubmit function for AddBedScreen
  // Replace your existing _handleSubmit method with this:

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final bedProvider = Provider.of<BedProvider>(context, listen: false);

      final success = await bedProvider.addBed(
        propertyId: widget.propertyId,
        roomId: widget.roomId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        status: _selectedStatus,
      );

      if (success && mounted) {
        final bedId = bedProvider.lastAddedBedId;

        if (bedId != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bed added successfully! Now add images.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );

          // Navigate to AddBedImagesScreen
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => AddBedImagesScreen(
                    propertyId: widget.propertyId,
                    roomId: widget.roomId,
                    bedId: bedId,
                  ),
            ),
          );

          // If images were uploaded successfully, refresh and pop
          if (result == true && mounted) {
            await Provider.of<RoomProvider>(
              context,
              listen: false,
            ).loadRooms(widget.propertyId);

            // Clear the last bed ID
            bedProvider.clearLastBedId();

            // The AddBedImagesScreen already pops both screens
            // So we don't need to pop here
          } else if (mounted) {
            // If user cancelled image upload, still refresh and pop
            await Provider.of<RoomProvider>(
              context,
              listen: false,
            ).loadRooms(widget.propertyId);

            bedProvider.clearLastBedId();
            context.pop();
          }
        } else {
          // If bedId is not available, just show success and pop
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bed added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );

          await Provider.of<RoomProvider>(
            context,
            listen: false,
          ).loadRooms(widget.propertyId);

          context.pop();
        }
      } else if (mounted && bedProvider.error != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bedProvider.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add New Bed',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<BedProvider>(
        builder: (context, bedProvider, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      SizedBox(height: 24.h),
                      _buildNameField(),
                      SizedBox(height: 20.h),
                      _buildPriceField(),
                      SizedBox(height: 20.h),
                      _buildStatusField(),
                      SizedBox(height: 32.h),
                      _buildSubmitButton(bedProvider),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              if (bedProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16.h),
                          Text(
                            'Adding bed...',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Fill in the details below to add a new bed to this room',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Icon(Icons.bed, size: 20.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  'Bed Name',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Bed 1, Corner Bed',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.red),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter bed name';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.currency_rupee,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Monthly Rent',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter monthly rent',
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 8.w),
                  child: Icon(
                    Icons.currency_rupee,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.red),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter monthly rent';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Bed Status',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children:
                  _statusOptions.map((status) {
                    final isSelected = _selectedStatus == status;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 18.sp,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BedProvider bedProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: bedProvider.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey[300],
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Add Bed',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
