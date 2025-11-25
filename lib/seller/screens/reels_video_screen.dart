// lib/landlord/screens/landlord_reels_video_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';

import '../../landlord/models/LandloardReelModel.dart';
import '../../landlord/providers/LandlordReelsProvider.dart';

class LandlordReelsVideoScreen extends StatefulWidget {
  final int initialReelIndex;

  const LandlordReelsVideoScreen({super.key, required this.initialReelIndex});

  @override
  State<LandlordReelsVideoScreen> createState() =>
      _LandlordReelsVideoScreenState();
}

class _LandlordReelsVideoScreenState extends State<LandlordReelsVideoScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialReelIndex;
    _pageController = PageController(initialPage: widget.initialReelIndex);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize video for current page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoForIndex(_currentIndex);
    });
  }

  void _initializeVideoForIndex(int index) {
    final provider = Provider.of<LandlordReelsProvider>(context, listen: false);
    if (index >= 0 && index < provider.reels.length) {
      final reel = provider.reels[index];
      if (reel.videoUrl != null && !_videoControllers.containsKey(index)) {
        _createVideoController(index, reel.videoUrl!);
      }
    }
  }

  void _createVideoController(int index, String videoUrl) {
    final controller = VideoPlayerController.network(videoUrl);
    _videoControllers[index] = controller;

    controller
        .initialize()
        .then((_) {
          if (mounted && _currentIndex == index) {
            setState(() {});
            controller.play();
            controller.setLooping(true);
          }
        })
        .catchError((error) {
          print('Error initializing video: $error');
        });
  }

  void _onPageChanged(int index) {
    setState(() {
      // Pause previous video
      _videoControllers[_currentIndex]?.pause();

      // Update current index
      _currentIndex = index;

      // Initialize and play new video
      _initializeVideoForIndex(index);
      if (_videoControllers[index]?.value.isInitialized ?? false) {
        _videoControllers[index]?.play();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<LandlordReelsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingScreen();
          }

          if (provider.errorMessage != null) {
            return _buildErrorScreen(provider.errorMessage!);
          }

          if (provider.reels.isEmpty) {
            return _buildEmptyScreen();
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: provider.reels.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return ReelVideoWidget(
                    reel: provider.reels[index],
                    controller: _videoControllers[index],
                    isActive: _currentIndex == index,
                  );
                },
              ),
              // Top gradient overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Top bar
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: _buildTopBar(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding(context),
        vertical: AppSizes.smallPadding(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(AppSizes.smallPadding(context)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: AppSizes.mediumIcon(context) * 0.8,
              ),
            ),
          ),
          Text(
            'Property Reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: AppSizes.mediumIcon(context)),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Text(
            'Loading Reels...',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.mediumText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.smallPadding(context)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppSizes.smallText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          ElevatedButton(
            onPressed: () {
              Provider.of<LandlordReelsProvider>(
                context,
                listen: false,
              ).loadReels();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.largePadding(context),
                vertical: AppSizes.mediumPadding(context),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.mediumText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, color: Colors.white54, size: 64),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Text(
            'No Reels Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.smallPadding(context)),
          Text(
            'Check back later for new property videos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.smallText(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Reel Video Widget
class ReelVideoWidget extends StatefulWidget {
  final LandloardReelModel reel;
  final VideoPlayerController? controller;
  final bool isActive;

  const ReelVideoWidget({
    super.key,
    required this.reel,
    this.controller,
    required this.isActive,
  });

  @override
  State<ReelVideoWidget> createState() => _ReelVideoWidgetState();
}

class _ReelVideoWidgetState extends State<ReelVideoWidget> {
  bool _showControls = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return GestureDetector(
      onTap: () {
        if (controller != null && controller.value.isInitialized) {
          setState(() {
            if (controller.value.isPlaying) {
              controller.pause();
              _showControls = true;
            } else {
              controller.play();
              _showControls = false;
            }
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          if (controller != null && controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // Reel information
          Positioned(
            bottom: 0,
            left: 0,
            right: 80,
            child: Padding(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  if (widget.reel.title != null)
                    Text(
                      widget.reel.title!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.mediumText(context),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: AppSizes.smallPadding(context)),

                  // Description
                  if (widget.reel.description != null)
                    Text(
                      widget.reel.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: AppSizes.smallText(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: AppSizes.smallPadding(context)),

                  // Property info
                  if (widget.reel.propertyInfo?.id != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${"" ?? ''} • "" ?? '
                            '}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: AppSizes.smallText(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Side action buttons
          Positioned(
            bottom: 80,
            right: 12,
            child: Column(
              children: [
                _buildActionButton(
                  Icons.favorite_border,
                  widget.reel.totalLikes?.toString() ?? '0',
                  () {},
                ),
                SizedBox(height: 20),
                _buildActionButton(
                  Icons.chat_bubble_outline,
                  widget.reel.totalComments?.toString() ?? '0',
                  () {},
                ),
                SizedBox(height: 20),
                _buildActionButton(
                  Icons.share,
                  widget.reel.totalShares?.toString() ?? '0',
                  () {},
                ),
                SizedBox(height: 20),
                _buildActionButton(
                  Icons.visibility,
                  _formatNumber(widget.reel.views ?? 0),
                  () {},
                ),
              ],
            ),
          ),

          // Play/Pause overlay
          if (_showControls)
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 48),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
