// import 'dart:io';
// import 'package:draze/core/constants/appColors.dart';
// import 'package:draze/core/constants/appSizes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import '../providers/SellerAddPropertyProvider.dart';

// class SellerAddPropertyScreen extends StatefulWidget {
//   const SellerAddPropertyScreen({super.key});

//   @override
//   State<SellerAddPropertyScreen> createState() =>
//       _SellerAddPropertyScreenState();
// }

// class _SellerAddPropertyScreenState extends State<SellerAddPropertyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ImagePicker _picker = ImagePicker();

//   // Form controllers
//   final _nameController = TextEditingController();
//   final _typeController = TextEditingController(text: 'PG');
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pinCodeController = TextEditingController();
//   final _landmarkController = TextEditingController();
//   final _contactNumberController = TextEditingController();
//   final _ownerNameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _latitudeController = TextEditingController();
//   final _longitudeController = TextEditingController();

//   final List<String> _selectedAmenities = [];
//   final List<File> _selectedImages = [];
//   final List<String> _availableAmenities = [
//     'WiFi',
//     'CCTV',
//     'Parking',
//     '24x7 Water',
//     'Laundry',
//     'Food',
//     'AC',
//     'Geyser',
//     'TV',
//     'Fridge',
//   ];

//   final List<String> _propertyTypes = ['PG', 'Hostel', 'Flat', 'Room'];

//   @override
//   void initState() {
//     super.initState();
//     _stateController.text = 'Madhya Pradesh';
//     _cityController.text = 'Indore';
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _typeController.dispose();
//     _addressController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pinCodeController.dispose();
//     _landmarkController.dispose();
//     _contactNumberController.dispose();
//     _ownerNameController.dispose();
//     _descriptionController.dispose();
//     _latitudeController.dispose();
//     _longitudeController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImages() async {
//     try {
//       final List<XFile> images = await _picker.pickMultiImage(
//         imageQuality: 70,
//         maxWidth: 1920,
//         maxHeight: 1080,
//       );

//       if (images.isNotEmpty) {
//         setState(() {
//           for (var image in images) {
//             _selectedImages.add(File(image.path));
//           }
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error picking images: $e'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 70,
//         maxWidth: 1920,
//         maxHeight: 1080,
//       );

//       if (image != null) {
//         setState(() {
//           _selectedImages.add(File(image.path));
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error taking photo: $e'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   void _removeImage(int index) {
//     setState(() {
//       _selectedImages.removeAt(index);
//     });
//   }

//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.surface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(AppSizes.cardCornerRadius(context) * 2),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: Icon(Icons.photo_library, color: AppColors.primary),
//                   title: Text(
//                     'Choose from Gallery',
//                     style: TextStyle(
//                       fontSize: AppSizes.mediumText(context) - 2,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImages();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.camera_alt, color: AppColors.primary),
//                   title: Text(
//                     'Take a Photo',
//                     style: TextStyle(
//                       fontSize: AppSizes.mediumText(context) - 2,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImageFromCamera();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => context.pop(),
//         ),
//         title: Text(
//           'Add Property',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: AppSizes.titleText(context) - 5,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Consumer<SellerAddPropertyProvider>(
//         builder: (context, provider, child) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (provider.isSuccess && mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text('Property added successfully!'),
//                   backgroundColor: AppColors.success,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//               provider.resetState();
//               context.pop();
//             } else if (provider.errorMessage != null && mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(provider.errorMessage!),
//                   backgroundColor: AppColors.error,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//               provider.clearError();
//             }
//           });

//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildSectionTitle('Property Information'),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         _buildTextFormField(
//                           controller: _nameController,
//                           label: 'Property Name',
//                           hint: 'e.g., Green Valley PG',
//                           validator: (value) {
//                             if (value?.trim().isEmpty ?? true) {
//                               return 'Please enter property name';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         _buildDropdownField(
//                           label: 'Property Type',
//                           value: _typeController.text,
//                           items: _propertyTypes,
//                           onChanged: (String? value) {
//                             if (value != null) {
//                               setState(() {
//                                 _typeController.text = value;
//                               });
//                             }
//                           },
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         _buildTextFormField(
//                           controller: _addressController,
//                           label: 'Address',
//                           hint: '123 MG Road',
//                           maxLines: 2,
//                           validator: (value) {
//                             if (value?.trim().isEmpty ?? true) {
//                               return 'Please enter address';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _cityController,
//                                 label: 'City',
//                                 hint: 'Indore',
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: AppSizes.mediumPadding(context)),
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _stateController,
//                                 label: 'State',
//                                 hint: 'Madhya Pradesh',
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _pinCodeController,
//                                 label: 'Pin Code',
//                                 hint: '452001',
//                                 keyboardType: TextInputType.number,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.digitsOnly,
//                                 ],
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   if (value!.length != 6) {
//                                     return 'Invalid';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: AppSizes.mediumPadding(context)),
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _landmarkController,
//                                 label: 'Landmark',
//                                 hint: 'Near Metro Station',
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _contactNumberController,
//                                 label: 'Contact Number',
//                                 hint: '9876543210',
//                                 keyboardType: TextInputType.phone,
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   if (value!.length != 10) {
//                                     return 'Invalid';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: AppSizes.mediumPadding(context)),
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _ownerNameController,
//                                 label: 'Owner Name',
//                                 hint: 'Ramesh Kumar',
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         _buildTextFormField(
//                           controller: _descriptionController,
//                           label: 'Description',
//                           hint: 'Spacious PG with all facilities',
//                           maxLines: 4,
//                           validator: (value) {
//                             if (value?.trim().isEmpty ?? true) {
//                               return 'Please enter description';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _latitudeController,
//                                 label: 'Latitude',
//                                 hint: '12.9716',
//                                 keyboardType: const TextInputType.numberWithOptions(
//                                   decimal: true,
//                                 ),
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   if (double.tryParse(value!) == null) {
//                                     return 'Invalid';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: AppSizes.mediumPadding(context)),
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _longitudeController,
//                                 label: 'Longitude',
//                                 hint: '77.5946',
//                                 keyboardType: const TextInputType.numberWithOptions(
//                                   decimal: true,
//                                 ),
//                                 validator: (value) {
//                                   if (value?.trim().isEmpty ?? true) {
//                                     return 'Required';
//                                   }
//                                   if (double.tryParse(value!) == null) {
//                                     return 'Invalid';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         _buildAmenitiesSection(),
//                         SizedBox(height: AppSizes.mediumPadding(context)),
//                         _buildImagesSection(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               _buildSubmitButton(provider),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: AppSizes.mediumText(context),
//         fontWeight: FontWeight.bold,
//         color: AppColors.textPrimary,
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//     List<TextInputFormatter>? inputFormatters,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: AppSizes.smallText(context),
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: AppSizes.smallPadding(context) / 2),
//         TextFormField(
//           controller: controller,
//           validator: validator,
//           keyboardType: keyboardType,
//           inputFormatters: inputFormatters,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: AppSizes.smallText(context),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.divider),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.divider),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.primary, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.error),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: AppSizes.mediumPadding(context),
//               vertical: AppSizes.mediumPadding(context),
//             ),
//             filled: true,
//             fillColor: AppColors.surface,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownField({
//     required String label,
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: AppSizes.smallText(context),
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: AppSizes.smallPadding(context) / 2),
//         DropdownButtonFormField<String>(
//           value: value,
//           onChanged: onChanged,
//           items: items.map((item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(
//                 item,
//                 style: TextStyle(
//                   fontSize: AppSizes.smallText(context),
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             );
//           }).toList(),
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.divider),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.divider),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//               borderSide: BorderSide(color: AppColors.primary, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: AppSizes.mediumPadding(context),
//               vertical: AppSizes.mediumPadding(context),
//             ),
//             filled: true,
//             fillColor: AppColors.surface,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAmenitiesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Amenities',
//           style: TextStyle(
//             fontSize: AppSizes.smallText(context),
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: AppSizes.smallPadding(context)),
//         Wrap(
//           spacing: AppSizes.smallPadding(context),
//           runSpacing: AppSizes.smallPadding(context),
//           children: _availableAmenities.map((amenity) {
//             bool isSelected = _selectedAmenities.contains(amenity);
//             return FilterChip(
//               label: Text(
//                 amenity,
//                 style: TextStyle(
//                   fontSize: AppSizes.smallText(context) * 0.9,
//                   color: isSelected ? Colors.white : AppColors.textSecondary,
//                 ),
//               ),
//               selected: isSelected,
//               onSelected: (selected) {
//                 setState(() {
//                   if (selected) {
//                     _selectedAmenities.add(amenity);
//                   } else {
//                     _selectedAmenities.remove(amenity);
//                   }
//                 });
//               },
//               selectedColor: AppColors.primary,
//               backgroundColor: AppColors.surface,
//               checkmarkColor: Colors.white,
//               side: BorderSide(
//                 color: isSelected ? AppColors.primary : AppColors.divider,
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildImagesSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Property Images',
//           style: TextStyle(
//             fontSize: AppSizes.smallText(context),
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         SizedBox(height: AppSizes.smallPadding(context)),
//         OutlinedButton.icon(
//           onPressed: _showImageSourceDialog,
//           icon: const Icon(Icons.add_photo_alternate),
//           label: const Text('Add Images'),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: AppColors.primary,
//             side: BorderSide(color: AppColors.primary),
//             padding: EdgeInsets.symmetric(
//               horizontal: AppSizes.mediumPadding(context),
//               vertical: AppSizes.mediumPadding(context),
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//             ),
//           ),
//         ),
//         if (_selectedImages.isNotEmpty) ...[
//           SizedBox(height: AppSizes.mediumPadding(context)),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: AppSizes.smallPadding(context),
//               mainAxisSpacing: AppSizes.smallPadding(context),
//             ),
//             itemCount: _selectedImages.length,
//             itemBuilder: (context, index) {
//               return Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(
//                       AppSizes.cardCornerRadius(context),
//                     ),
//                     child: Image.file(
//                       _selectedImages[index],
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   ),
//                   Positioned(
//                     top: 4,
//                     right: 4,
//                     child: GestureDetector(
//                       onTap: () => _removeImage(index),
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: AppColors.error,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildSubmitButton(SellerAddPropertyProvider provider) {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, -2),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: provider.isLoading ? null : _submitForm,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.success,
//             foregroundColor: Colors.white,
//             padding: EdgeInsets.symmetric(
//               vertical: AppSizes.mediumPadding(context),
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(
//                 AppSizes.cardCornerRadius(context),
//               ),
//             ),
//           ),
//           child: provider.isLoading
//               ? const SizedBox(
//             height: 20,
//             width: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: Colors.white,
//             ),
//           )
//               : Text(
//             'Add Property',
//             style: TextStyle(
//               fontSize: AppSizes.mediumText(context) - 2,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _submitForm() {
//     if (_formKey.currentState?.validate() ?? false) {
//       if (_selectedImages.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Please add at least one image'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         return;
//       }

//       if (_selectedAmenities.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Please select at least one amenity'),
//             backgroundColor: AppColors.error,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         return;
//       }

//       final propertyData = {
//         'name': _nameController.text.trim(),
//         'type': _typeController.text.trim(),
//         'address': _addressController.text.trim(),
//         'city': _cityController.text.trim(),
//         'state': _stateController.text.trim(),
//         'pinCode': _pinCodeController.text.trim(),
//         'landmark': _landmarkController.text.trim(),
//         'contactNumber': _contactNumberController.text.trim(),
//         'ownerName': _ownerNameController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'amenities': _selectedAmenities,
//         'latitude': double.parse(_latitudeController.text.trim()),
//         'longitude': double.parse(_longitudeController.text.trim()),
//       };

//       Provider.of<SellerAddPropertyProvider>(
//         context,
//         listen: false,
//       ).addProperty(propertyData, _selectedImages);
//     }
//   }
// }






import 'dart:io';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/SellerAddPropertyProvider.dart';
import '../../seller/screens/SellerSubscriptionPlansScreen.dart'; // Adjust the import path as per your project structure

class SellerAddPropertyScreen extends StatefulWidget {
  const SellerAddPropertyScreen({super.key});

  @override
  State<SellerAddPropertyScreen> createState() =>
      _SellerAddPropertyScreenState();
}

class _SellerAddPropertyScreenState extends State<SellerAddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _typeController = TextEditingController(text: 'PG');
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final List<String> _selectedAmenities = [];
  final List<File> _selectedImages = [];
  final List<String> _availableAmenities = [
    'WiFi',
    'CCTV',
    'Parking',
    '24x7 Water',
    'Laundry',
    'Food',
    'AC',
    'Geyser',
    'TV',
    'Fridge',
  ];

  final List<String> _propertyTypes = ['PG', 'Hostel', 'Flat', 'Room'];

  @override
  void initState() {
    super.initState();
    _stateController.text = 'Madhya Pradesh';
    _cityController.text = 'Indore';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _landmarkController.dispose();
    _contactNumberController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            _selectedImages.add(File(image.path));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius(context) * 2),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primary),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: AppSizes.mediumText(context) - 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primary),
                  title: Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontSize: AppSizes.mediumText(context) - 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubscriptionDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Required'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  // Assuming GoRouter route; adjust as per your configuration
                  // context.push('/seller-subscription-plans');
                  // Alternative if using MaterialPageRoute:
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SellerSubscriptionPlansScreen()));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Buy Plan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Property',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppSizes.titleText(context) - 5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<SellerAddPropertyProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.isSuccess && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Property added successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              provider.resetState();
              if (mounted) {
                context.pop();
              }
            } else if (provider.errorMessage != null && mounted) {
              final errorMsg = provider.errorMessage!;
              _showSubscriptionDialog(errorMsg);
              // Check for property limit error specifically
              // if (errorMsg.toLowerCase().contains('property limit')) {
                
              // } else {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(errorMsg),
              //       backgroundColor: AppColors.error,
              //       behavior: SnackBarBehavior.floating,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //   );
              // }
              provider.clearError();
            }
          });

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Property Information'),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        _buildTextFormField(
                          controller: _nameController,
                          label: 'Property Name',
                          hint: 'e.g., Green Valley PG',
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter property name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        _buildDropdownField(
                          label: 'Property Type',
                          value: _typeController.text,
                          items: _propertyTypes,
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                _typeController.text = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        _buildTextFormField(
                          controller: _addressController,
                          label: 'Address',
                          hint: '123 MG Road',
                          maxLines: 2,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'Indore',
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: AppSizes.mediumPadding(context)),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'Madhya Pradesh',
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _pinCodeController,
                                label: 'Pin Code',
                                hint: '452001',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  if (value!.length != 6) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: AppSizes.mediumPadding(context)),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _landmarkController,
                                label: 'Landmark',
                                hint: 'Near Metro Station',
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _contactNumberController,
                                label: 'Contact Number',
                                hint: '9876543210',
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  if (value!.length != 10) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: AppSizes.mediumPadding(context)),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _ownerNameController,
                                label: 'Owner Name',
                                hint: 'Ramesh Kumar',
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        _buildTextFormField(
                          controller: _descriptionController,
                          label: 'Description',
                          hint: 'Spacious PG with all facilities',
                          maxLines: 4,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Please enter description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _latitudeController,
                                label: 'Latitude',
                                hint: '12.9716',
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value!) == null) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: AppSizes.mediumPadding(context)),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _longitudeController,
                                label: 'Longitude',
                                hint: '77.5946',
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value!) == null) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        _buildAmenitiesSection(),
                        SizedBox(height: AppSizes.mediumPadding(context)),
                        _buildImagesSection(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSubmitButton(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: AppSizes.mediumText(context),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context) / 2),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.smallText(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.mediumPadding(context),
              vertical: AppSizes.mediumPadding(context),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context) / 2),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.mediumPadding(context),
              vertical: AppSizes.mediumPadding(context),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context)),
        Wrap(
          spacing: AppSizes.smallPadding(context),
          runSpacing: AppSizes.smallPadding(context),
          children: _availableAmenities.map((amenity) {
            bool isSelected = _selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(
                amenity,
                style: TextStyle(
                  fontSize: AppSizes.smallText(context) * 0.9,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
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
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Images',
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSizes.smallPadding(context)),
        OutlinedButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Images'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.mediumPadding(context),
              vertical: AppSizes.mediumPadding(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: AppSizes.mediumPadding(context)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSizes.smallPadding(context),
              mainAxisSpacing: AppSizes.smallPadding(context),
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(SellerAddPropertyProvider provider) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: AppSizes.mediumPadding(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius(context),
              ),
            ),
          ),
          child: provider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Add Property',
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context) - 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add at least one image'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_selectedAmenities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least one amenity'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final propertyData = {
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pinCode': _pinCodeController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'amenities': _selectedAmenities,
        'latitude': double.parse(_latitudeController.text.trim()),
        'longitude': double.parse(_longitudeController.text.trim()),
      };

      Provider.of<SellerAddPropertyProvider>(
        context,
        listen: false,
      ).addProperty(propertyData, _selectedImages);
    }
  }
}