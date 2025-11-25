import 'dart:io';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/property_image_provider.dart';


class AddPropertyImagesScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const AddPropertyImagesScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<AddPropertyImagesScreen> createState() => _AddPropertyImagesScreenState();
}

class _AddPropertyImagesScreenState extends ConsumerState<AddPropertyImagesScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

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

      if (images.isNotEmpty) {
        final currentImages = ref.read(propertyImagesProvider).selectedImages;
        final updatedImages = [...currentImages, ...images];

        // Limit to maximum 10 images
        if (updatedImages.length > 10) {
          final limitedImages = updatedImages.take(10).toList();
          ref.read(propertyImagesProvider.notifier).updateSelectedImages(limitedImages);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maximum 10 images allowed. Some images were not added.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          ref.read(propertyImagesProvider.notifier).updateSelectedImages(updatedImages);
        }
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

      if (image != null) {
        final currentImages = ref.read(propertyImagesProvider).selectedImages;

        if (currentImages.length >= 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maximum 10 images allowed'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        ref.read(propertyImagesProvider.notifier).addSelectedImage(image);
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
    ref.read(propertyImagesProvider.notifier).removeSelectedImage(index);
  }

  Future<void> _uploadImages() async {
    final propertyImagesNotifier = ref.read(propertyImagesProvider.notifier);
    final success = await propertyImagesNotifier.uploadImages(widget.propertyId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/properties');
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
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: AppColors.primary,
                ),
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
    final imageState = ref.watch(propertyImagesProvider);

    // Listen to errors and show snackbars
    ref.listen(propertyImagesProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
            ),
          );
          // Clear error after showing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(propertyImagesProvider.notifier).clearError();
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(imageState.selectedImages),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(child: _buildContent(imageState.selectedImages)),
            _buildBottomActions(imageState.selectedImages, imageState.isLoading),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(List<XFile> selectedImages) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Add Property Images',
        style: TextStyle(
          color: Colors.white,
          fontSize: AppSizes.mediumText(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (selectedImages.isNotEmpty)
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
                  '${selectedImages.length}/10',
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

  Widget _buildContent(List<XFile> selectedImages) {
    if (selectedImages.isEmpty) {
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
            'Selected Images (${selectedImages.length})',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.smallPadding(context)),
          _buildImageGrid(selectedImages),
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
              'Add up to 10 high-quality images of your property. First image will be the cover photo.',
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
              'Add attractive photos of your property to get more inquiries',
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

  Widget _buildImageGrid(List<XFile> selectedImages) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == selectedImages.length) {
          return _buildAddMoreButton(selectedImages.length);
        }
        return _buildImageItem(index, selectedImages);
      },
    );
  }

  Widget _buildImageItem(int index, List<XFile> selectedImages) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
            border: Border.all(color: AppColors.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
            child: Image.file(
              File(selectedImages[index].path),
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
  }

  Widget _buildAddMoreButton(int currentCount) {
    final canAddMore = currentCount < 10;

    return GestureDetector(
      onTap: canAddMore ? _showImageSourceDialog : null,
      child: Container(
        decoration: BoxDecoration(
          color: canAddMore
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
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
              color: canAddMore
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              canAddMore ? 'Add More' : 'Max Reached',
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                fontWeight: FontWeight.w600,
                color: canAddMore
                    ? AppColors.primary
                    : AppColors.textSecondary,
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
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
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

  Widget _buildBottomActions(List<XFile> selectedImages, bool isLoading) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildUploadButton(selectedImages, isLoading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(List<XFile> selectedImages, bool isLoading) {
    final bool hasImages = selectedImages.isNotEmpty;

    return Container(
      height: AppSizes.buttonHeight(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        gradient: hasImages
            ? LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
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
                  hasImages ? Icons.cloud_upload_outlined : Icons.add_photo_alternate_outlined,
                  color: hasImages ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Text(
                  hasImages ? 'Upload Images' : 'Add Images',
                  style: TextStyle(
                    color: hasImages ? Colors.white : AppColors.textSecondary,
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