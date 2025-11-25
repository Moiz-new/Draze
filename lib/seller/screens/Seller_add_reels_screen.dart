// lib/screens/LandlordAddReelScreen.dart
import 'dart:io';
import 'package:draze/app/api_constants.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../providers/SellerAddReelProvider.dart';
// Import your reel provider

class SellerAddReelScreen extends StatefulWidget {
  const SellerAddReelScreen({super.key});

  @override
  State<SellerAddReelScreen> createState() => _SellerAddReelScreenState();
}

class _SellerAddReelScreenState extends State<SellerAddReelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyTypeController = TextEditingController();

  File? _videoFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  // Property data from API
  List<Map<String, dynamic>> _properties = [];
  bool _isLoadingProperties = false;
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  @override
  void dispose() {
    _propertyTypeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // Fetch properties from API
  Future<void> _fetchProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _showErrorSnackBar(
          'Authentication token not found. Please login again.',
        );
        return;
      }

      final response = await http
          .get(
            Uri.parse('$base_url/api/seller/getproperties'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> propertiesJson = jsonData['properties'] ?? [];
          setState(() {
            _properties =
                propertiesJson
                    .map(
                      (property) => {
                        'id': property['_id'] as String? ?? '',
                        'name': property['name'] as String? ?? 'Unknown',
                        'type': property['type'] as String? ?? '',
                        'address': property['address'] as String? ?? '',
                        'city': property['city'] as String? ?? '',
                      },
                    )
                    .where(
                      (property) =>
                          property['id'] != null &&
                          (property['id'] as String).isNotEmpty,
                    )
                    .toList();
          });
        } else {
          _showErrorSnackBar(
            'Failed to load properties: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 401) {
        _showErrorSnackBar('Unauthorized. Please login again.');
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading properties: $e');
    } finally {
      setState(() {
        _isLoadingProperties = false;
      });
    }
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
      builder:
          (context) => Container(
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _uploadReel() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate video file
    if (_videoFile == null) {
      _showErrorSnackBar('Please select a video');
      return;
    }

    // Validate property selection
    if (_selectedPropertyId == null || _selectedPropertyId!.isEmpty) {
      _showErrorSnackBar('Please select a property');
      return;
    }

    // Get the ReelProvider
    final reelProvider = Provider.of<SellerReelProvider>(
      context,
      listen: false,
    );

    try {
      // Upload reel using provider
      final success = await reelProvider.uploadReel(
        videoFile: _videoFile!,
        propertyId: _selectedPropertyId!,
        baseUrl: base_url,
      );

      if (!mounted) return;

      if (success) {
        final uploadedReel = reelProvider.uploadedReel;

        // Show success message
        _showSuccessSnackBar('Reel uploaded successfully!');

        // Optional: Log the uploaded reel details
        if (uploadedReel != null) {
          print('Reel ID: ${uploadedReel['id']}');
          print('Video URL: ${uploadedReel['videoUrl']}');
          print('Thumbnail URL: ${uploadedReel['thumbnailUrl']}');
        }

        // Navigate back
        Navigator.pop(context, uploadedReel);
      } else {
        // Show error from provider
        final errorMessage =
            reelProvider.errorMessage ?? 'Failed to upload reel';
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Unexpected error: $e');
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
      body: Consumer<SellerReelProvider>(
        builder: (context, reelProvider, child) {
          return Stack(
            children: [
              Form(
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
                        child:
                            _videoFile == null
                                ? _buildVideoUploadPlaceholder()
                                : _buildVideoPreview(),
                      ),

                      SizedBox(height: AppSizes.mediumPadding(context)),

                      // Property Dropdown
                      _buildPropertyDropdown(),

                      SizedBox(height: AppSizes.mediumPadding(context)),

                      // Upload Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              reelProvider.isUploading ? null : _uploadReel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child:
                              reelProvider.isUploading
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
              ),
            ],
          );
        },
      ),
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
          child:
              _videoController != null && _videoController!.value.isInitialized
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

  Widget _buildPropertyDropdown() {
    return SizedBox(
      height: 70,
      child: DropdownButtonFormField<String>(
        value: _selectedPropertyId,
        decoration: InputDecoration(
          labelText: 'Select Property *',
          prefixIcon: const Icon(Icons.home),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon:
              _isLoadingProperties
                  ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  : null,
        ),
        hint: Text(
          _isLoadingProperties ? 'Loading properties...' : 'Select a property',
        ),
        items:
            _properties.map((property) {
              return DropdownMenuItem<String>(
                value: property['id'] as String?,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      property['name'] as String? ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged:
            _isLoadingProperties
                ? null
                : (String? value) {
                  setState(() {
                    _selectedPropertyId = value;
                  });
                },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a property';
          }
          return null;
        },
        isExpanded: true,
        menuMaxHeight: 300,
      ),
    );
  }
}
