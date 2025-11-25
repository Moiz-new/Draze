import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:draze/user/provider/reel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ReelVideoWidget extends StatefulWidget {
  final ReelModel reel;
  final bool isActive;

  const ReelVideoWidget({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  State<ReelVideoWidget> createState() => _ReelVideoWidgetState();
}

class _ReelVideoWidgetState extends State<ReelVideoWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  bool _showHeart = false;
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoFuture;
  bool _showDetails = false;
  Timer? _debounceTimer;
  bool _isInitializing = false;
  bool _hasError = false;
  bool _controllerManagedByProvider = false;

  @override
  void initState() {
    super.initState();
    print('ReelVideoWidget: initState for reel ${widget.reel.id}');

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeVideoController();
      }
    });
  }

  Future<void> _initializeVideoController() async {
    if (!mounted || _isInitializing) {
      print(
        'ReelVideoWidget: Skipping initialization - mounted: $mounted, initializing: $_isInitializing',
      );
      return;
    }

    _isInitializing = true;
    _hasError = false;

    try {
      final videoController = Provider.of<VideoControllersProvider>(context, listen: false);

      // Check if controller already exists and is valid
      final existingController = videoController.controllers[widget.reel.id];
      if (existingController != null &&
          existingController.value.isInitialized) {
        print(
          'ReelVideoWidget: Reusing existing controller for reel ${widget.reel.id}',
        );
        _videoController = existingController;
        _controllerManagedByProvider = true;
        if (mounted) {
          setState(() {});
        }
        _handleActiveStateChange();
        _isInitializing = false;
        return;
      }

      print(
        'ReelVideoWidget: Creating new controller for reel ${widget.reel.id}',
      );

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      _initializeVideoFuture = _videoController!
          .initialize()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
            'Video initialization timed out for reel ${widget.reel.id}',
            const Duration(seconds: 15),
          );
        },
      )
          .then((_) {
        if (!mounted) {
          print(
            'ReelVideoWidget: Widget disposed during initialization for reel ${widget.reel.id}',
          );
          _videoController?.dispose();
          _videoController = null;
          return;
        }

        print(
          'ReelVideoWidget: Successfully initialized controller for reel ${widget.reel.id}',
        );

        // Add controller to provider
        videoController.addController(widget.reel.id, _videoController!);
        _controllerManagedByProvider = true;

        // Set up video listeners
        _videoController!.addListener(_videoListener);

        if (mounted) {
          setState(() {});
          _handleActiveStateChange();
        }
      })
          .catchError((error, stackTrace) {
        print(
          'ReelVideoWidget: Error initializing video for reel ${widget.reel.id}: $error',
        );
        _hasError = true;
        if (mounted) {
          setState(() {});
        }
      });

      await _initializeVideoFuture;
    } catch (e) {
      print(
        'ReelVideoWidget: Exception during initialization for reel ${widget.reel.id}: $e',
      );
      _hasError = true;
      if (mounted) {
        setState(() {});
      }
    } finally {
      _isInitializing = false;
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(ReelVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      print(
        'ReelVideoWidget: Active state changed for reel ${widget.reel.id}: ${widget.isActive}',
      );
      _handleActiveStateChange();
    }
  }

  void _handleActiveStateChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
      final isOnReelsTab = reelsProvider.selectedTab == 1;

      if (widget.isActive && isOnReelsTab && !_hasError) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    });
  }

  void _playVideo() {
    if (_videoController != null &&
        _videoController!.value.isInitialized &&
        !_videoController!.value.isPlaying) {
      print('ReelVideoWidget: Playing video for reel ${widget.reel.id}');
      _videoController!.play();
      _videoController!.setLooping(true);
    }
  }

  void _pauseVideo() {
    if (_videoController != null &&
        _videoController!.value.isInitialized &&
        _videoController!.value.isPlaying) {
      print('ReelVideoWidget: Pausing video for reel ${widget.reel.id}');
      _videoController!.pause();
    }
  }

  @override
  void dispose() {
    print('ReelVideoWidget: Disposing for reel ${widget.reel.id}');
    _debounceTimer?.cancel();
    _heartAnimationController.dispose();

    if (_videoController != null) {
      _videoController!.removeListener(_videoListener);
      _pauseVideo();
      if (_controllerManagedByProvider) {
        // Notify provider to remove controller before disposal
        // Use a post-frame callback to ensure context is still valid
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            if (context.mounted) {
              final videoController = Provider.of<VideoControllersProvider>(context, listen: false);
              videoController.removeController(widget.reel.id);
            }
          } catch (e) {
            print('Error removing controller from provider: $e');
          }
        });
      } else {
        // Dispose controller directly if not managed by provider
        _videoController!.dispose();
      }
      _videoController = null;
    }

    super.dispose();
  }

  void _onDoubleTap() {
    if (!mounted) return;

    if (!widget.reel.isLiked) {
      final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
      reelsProvider.toggleLike(widget.reel.id);
      setState(() {
        _showHeart = true;
      });
      _heartAnimationController.forward().then((_) {
        _heartAnimationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showHeart = false;
            });
          }
        });
      });
    }
  }

  void _onPlayPauseTap() {
    if (!mounted ||
        _videoController == null ||
        !_videoController!.value.isInitialized) {
      return;
    }

    if (_videoController!.value.isPlaying) {
      print('ReelVideoWidget: Manual pause for reel ${widget.reel.id}');
      _videoController!.pause();
    } else {
      print('ReelVideoWidget: Manual play for reel ${widget.reel.id}');
      _videoController!.play();
      _videoController!.setLooping(true);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Stack(
      children: [
        _buildVideoPlayer(),

        // Heart animation for likes
        if (_showHeart)
          Center(
            child: AnimatedBuilder(
              animation: _heartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartAnimation.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 100,
                  ),
                );
              },
            ),
          ),

        // Play/Pause button overlay
        _buildPlayPauseOverlay(),

        // Content overlay (user info, description, etc.)
        _buildContentOverlay(),

        // Right side actions (like, comment, share, etc.)
        _buildRightActions(),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    // Show thumbnail while loading
    if (_videoController == null ||
        !_videoController!.value.isInitialized ||
        _hasError) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.reel.videoUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 50),
                ),
              ),
            ),
            if (_isInitializing)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 8),
                    const Text(
                      'Failed to load video',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                        });
                        _initializeVideoController();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      onTap: _onPlayPauseTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseOverlay() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final isPlaying = _videoController!.value.isPlaying;

    return AnimatedOpacity(
      opacity: isPlaying ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: GestureDetector(
          onTap: _onPlayPauseTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverlay() {
    // Add null safety checks to prevent crashes
    final user = widget.reel.user;

    return Positioned(
      left: 16,
      right: 80,
      bottom: 40,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: user?.profileImage != null && user!.profileImage.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: user.profileImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user?.name ?? 'Unknown User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user?.isVerified == true) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        user?.username ?? '@unknown',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _showDetails
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            if (_showDetails) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reel.title.isNotEmpty ? widget.reel.title : 'Property Reel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.reel.location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.reel.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.reel.propertyType.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.reel.propertyType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (widget.reel.propertyType.isNotEmpty)
                          const SizedBox(width: 8),
                        if (widget.reel.price.isNotEmpty && widget.reel.price != '0')
                          Text(
                            '${widget.reel.currency} ${widget.reel.price}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    if (widget.reel.bedrooms != null ||
                        widget.reel.bathrooms != null ||
                        widget.reel.area != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.reel.bedrooms != null) ...[
                            const Icon(
                              Icons.bed,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.reel.bedrooms} bed',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (widget.reel.bathrooms != null) ...[
                            const Icon(
                              Icons.bathtub,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.reel.bathrooms} bath',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (widget.reel.area != null) ...[
                            const Icon(
                              Icons.square_foot,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.reel.area!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (widget.reel.rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.reel.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (widget.reel.description.isNotEmpty)
                Text(
                  widget.reel.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              if (widget.reel.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: widget.reel.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRightActions() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _buildActionButton(
            icon: widget.reel.isLiked ? Icons.favorite : Icons.favorite_border,
            count: widget.reel.likes,
            onTap: () {
              if (mounted) {
                final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
                reelsProvider.toggleLike(widget.reel.id);
              }
            },
            isActive: widget.reel.isLiked,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.comment,
            count: widget.reel.comments,
            onTap: () {
              _showCommentsBottomSheet(context);
            },
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.share,
            count: widget.reel.shares,
            onTap: () {
              _showShareBottomSheet(context);
            },
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: widget.reel.isBookmarked
                ? Icons.bookmark
                : Icons.bookmark_border,
            onTap: () {
              if (mounted) {
                final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
                reelsProvider.toggleBookmark(widget.reel.id);
              }
            },
            isActive: widget.reel.isBookmarked,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.more_vert,
            onTap: () {
              _showMoreOptionsBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    int? count,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.red : Colors.white,
              size: 20,
            ),
          ),
          if (count != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(count),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments (${widget.reel.comments})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Comments feature coming soon!',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    if (mounted) {
      final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
      reelsProvider.incrementShare(widget.reel.id);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Property',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'Message'),
                _buildShareOption(Icons.email, 'Email'),
                _buildShareOption(Icons.link, 'Copy Link'),
                _buildShareOption(Icons.more_horiz, 'More'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label functionality coming soon!')),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'More Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildMoreOption(Icons.report, 'Report', Colors.red),
            _buildMoreOption(Icons.block, 'Block User', Colors.orange),
            _buildMoreOption(Icons.download, 'Download', Colors.blue),
            _buildMoreOption(Icons.info, 'Property Details', Colors.green),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label functionality coming soon!')),
        );
      },
    );
  }
}