import 'dart:io';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../providers/reel_provider.dart';

class LandlordAddReelScreen extends StatefulWidget {
  const LandlordAddReelScreen({super.key});

  @override
  State<LandlordAddReelScreen> createState() => _AddReelScreenState();
}

class _AddReelScreenState extends State<LandlordAddReelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  File? _videoFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();
  ReelProperty? _selectedProperty;

  @override
  void initState() {
    super.initState();
    // Load properties when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelProvider>().loadProperties();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
        });

        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking video: $e');
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        setState(() {
          _videoFile = File(video.path);
        });

        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
      }
    } catch (e) {
      _showErrorSnackBar('Error recording video: $e');
    }
  }

  void _showVideoSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            const Text(
              'Select Video Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppColors.primary),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.video_library,
                color: AppColors.primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  List<String> _parseTags(String tagsString) {
    if (tagsString.trim().isEmpty) {
      return [];
    }
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _uploadReel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_videoFile == null) {
      _showErrorSnackBar('Please select a video');
      return;
    }

    if (_selectedProperty == null) {
      _showErrorSnackBar('Please select a property');
      return;
    }

    final reelProvider = context.read<ReelProvider>();

    final tags = _parseTags(_tagsController.text);

    final success = await reelProvider.uploadReel(
      videoFile: _videoFile!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyId: _selectedProperty!.id,
      tags: tags,
    );

    if (success) {
      _showSuccessSnackBar(reelProvider.successMessage ?? 'Reel uploaded successfully!');
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      _showErrorSnackBar(reelProvider.errorMessage ?? 'Failed to upload reel');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Reel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ReelProvider>(
        builder: (context, reelProvider, child) {
          // Show error message if any
          if (reelProvider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorSnackBar(reelProvider.errorMessage!);
              reelProvider.clearMessages();
            });
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Upload Section
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _videoFile == null
                        ? _buildVideoUploadPlaceholder()
                        : _buildVideoPreview(),
                  ),
                  SizedBox(height: AppSizes.largePadding(context)),

                  // Property Dropdown
                  _buildPropertyDropdown(reelProvider),
                  SizedBox(height: AppSizes.mediumPadding(context)),

                  // Title Field
                  _buildTextFormField(
                    controller: _titleController,
                    label: 'Title *',
                    hint: 'Enter reel title',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),

                  // Description Field
                  _buildTextFormField(
                    controller: _descriptionController,
                    label: 'Description *',
                    hint: 'Describe your property',
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),

                  // Tags Field
                  _buildTextFormField(
                    controller: _tagsController,
                    label: 'Tags',
                    hint: 'Enter tags separated by commas (e.g., hostel, pg, room)',
                    prefixIcon: Icons.tag,
                  ),
                  SizedBox(height: AppSizes.largePadding(context)),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: reelProvider.isUploadingReel ? null : _uploadReel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: reelProvider.isUploadingReel
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Uploading...'),
                        ],
                      )
                          : const Text(
                        'Upload Reel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyDropdown(ReelProvider reelProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: reelProvider.isLoadingProperties
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : reelProvider.properties.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('No properties available'),
                TextButton(
                  onPressed: () => reelProvider.loadProperties(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : DropdownButtonFormField<ReelProperty>(
            value: _selectedProperty,
            decoration: const InputDecoration(
              hintText: 'Select a property',
              prefixIcon: Icon(Icons.home),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            isExpanded: true,
            // Remove the default underline
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            // Customize dropdown menu
            dropdownColor: Colors.white,
            menuMaxHeight: 300,
            items: reelProvider.properties.map((property) {
              return DropdownMenuItem<ReelProperty>(
                value: property,
                child: Text(
                  property.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: (ReelProperty? value) {
              setState(() {
                _selectedProperty = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a property';
              }
              return null;
            },
            // Show selected value with better formatting
            selectedItemBuilder: (BuildContext context) {
              return reelProvider.properties.map((property) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }
  Widget _buildVideoUploadPlaceholder() {
    return InkWell(
      onTap: _showVideoSourceBottomSheet,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call, size: 48, color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              'Tap to add video',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Max duration: 2 minutes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
              : Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _videoFile = null;
                  _videoController?.dispose();
                  _videoController = null;
                });
              },
            ),
          ),
        ),
        if (_videoController != null && _videoController!.value.isInitialized)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}