import 'dart:io';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/BedProvider.dart';

class AddBedImagesScreen extends StatefulWidget {
  final String propertyId;
  final String roomId;
  final String bedId;

  const AddBedImagesScreen({
    super.key,
    required this.propertyId,
    required this.roomId,
    required this.bedId,
  });

  @override
  State<AddBedImagesScreen> createState() => _AddBedImagesScreenState();
}

class _AddBedImagesScreenState extends State<AddBedImagesScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (images.isNotEmpty && mounted) {
        setState(() {
          final updatedImages = [..._selectedImages, ...images];
          if (updatedImages.length > 10) {
            _selectedImages = updatedImages.take(10).toList();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Maximum 10 images allowed. Some images were not added.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            _selectedImages = updatedImages;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        if (_selectedImages.length >= 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 10 images allowed'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Future<void> _uploadImages() async {
    final provider = context.read<BedProvider>();
    final success = await provider.uploadBedImages(
      widget.propertyId,
      widget.roomId,
      widget.bedId,
      _selectedImages,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bed images uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Pop both screens and return true to indicate success
        Navigator.of(context).pop(true); // Pop AddBedImagesScreen
        Navigator.of(context).pop(true); // Pop AddBedScreen
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.cardCornerRadius(context) * 2),
          ),
        ),
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Text(
              'Add Images',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImages();
                    },
                  ),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Column(
              children: [
                Icon(icon, size: 40, color: AppColors.primary),
                SizedBox(height: AppSizes.smallPadding(context)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BedProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: Colors.red,
                ),
              );
              provider.clearError();
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(child: _buildContent()),
                _buildBottomActions(provider.isLoading),
              ],
            ),
          ),
        );
      },
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
        'Add Bed Images',
        style: TextStyle(
          color: Colors.white,
          fontSize: AppSizes.mediumText(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_selectedImages.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: AppSizes.smallPadding(context)),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.smallPadding(context),
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedImages.length}/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_selectedImages.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Text(
            'Selected Images (${_selectedImages.length})',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.smallPadding(context)),
          _buildImageGrid(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: AppSizes.smallIcon(context),
          ),
          SizedBox(width: AppSizes.smallPadding(context)),
          Expanded(
            child: Text(
              'Add up to 10 high-quality images of your bed. First image will be the cover photo.',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.largePadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Text(
              'No Images Added Yet',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              'Add attractive photos of your bed to get more inquiries',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.largePadding(context)),
            _buildAddImageButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return _buildAddMoreButton();
        }
        return _buildImageItem(index);
      },
    );
  }

  Widget _buildImageItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context),
            ),
            border: Border.all(color: AppColors.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius(context),
            ),
            child: Image.file(
              File(_selectedImages[index].path),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.divider,
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.textSecondary,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Cover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.smallText(context) - 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    final canAddMore = _selectedImages.length < 10;

    return GestureDetector(
      onTap: canAddMore ? _showImageSourceDialog : null,
      child: Container(
        decoration: BoxDecoration(
          color: canAddMore
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          border: Border.all(
            color: canAddMore
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.divider,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: canAddMore ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              canAddMore ? 'Add More' : 'Max Reached',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                fontWeight: FontWeight.w600,
                color: canAddMore ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeight(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showImageSourceDialog,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.smallPadding(context)),
              Text(
                'Add Images',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.mediumText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isLoading) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(child: _buildUploadButton(isLoading)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(bool isLoading) {
    final bool hasImages = _selectedImages.isNotEmpty;

    return Container(
      height: AppSizes.buttonHeight(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        gradient: hasImages
            ? LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null,
        color: hasImages ? null : AppColors.divider,
        boxShadow: hasImages
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasImages
              ? (isLoading ? null : _uploadImages)
              : _showImageSourceDialog,
          borderRadius: BorderRadius.circular(
            AppSizes.cardCornerRadius(context),
          ),
          child: Center(
            child: isLoading
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
                Icon(
                  hasImages
                      ? Icons.cloud_upload_outlined
                      : Icons.add_photo_alternate_outlined,
                  color:
                  hasImages ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Text(
                  hasImages ? 'Upload Images' : 'Add Images',
                  style: TextStyle(
                    color: hasImages
                        ? Colors.white
                        : AppColors.textSecondary,
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