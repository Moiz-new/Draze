import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/seller/models/reels/reel_model.dart';
import 'package:draze/seller/providers/reels_provider.dart';
import 'package:draze/seller/widgets/coments.dart';
import 'package:draze/seller/widgets/more_options.dart';
import 'package:draze/seller/widgets/share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class ReelVideoWidget extends ConsumerStatefulWidget {
  final ReelModel reel;
  final bool isActive;

  const ReelVideoWidget({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  ConsumerState<ReelVideoWidget> createState() => _ReelVideoWidgetState();
}

class _ReelVideoWidgetState extends ConsumerState<ReelVideoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  bool _showHeart = false;
  VideoPlayerController? _videoController;
  bool _showPlayButton = true;

  @override
  void initState() {
    super.initState();
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

    if (widget.isActive) {
      _initializeVideoController();
    }
  }

  void _initializeVideoController() {
    final controllers = ref.read(videoControllersProvider);
    if (controllers.containsKey(widget.reel.id)) {
      _videoController = controllers[widget.reel.id];
      if (widget.isActive && _videoController!.value.isInitialized) {
        _videoController!.play();
        if (mounted) {
          setState(() {
            _showPlayButton = false;
          });
        }
      }
    } else {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
      );
      _videoController!
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() {});
              ref.read(videoControllersProvider.notifier).update((state) {
                return {...state, widget.reel.id: _videoController!};
              });
              if (widget.isActive) {
                _videoController!.play();
                setState(() {
                  _showPlayButton = false;
                });
              }
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load video: $error')),
                );
              });
            }
          });
    }
  }

  @override
  void didUpdateWidget(ReelVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && _videoController == null) {
      _initializeVideoController();
    } else if (_videoController != null &&
        _videoController!.value.isInitialized) {
      if (widget.isActive && !_videoController!.value.isPlaying) {
        _videoController!.play();
        setState(() {
          _showPlayButton = false;
        });
      } else if (!widget.isActive && _videoController!.value.isPlaying) {
        _videoController!.pause();
        setState(() {
          _showPlayButton = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _showPlayButton = true;
        } else {
          _videoController!.play();
          _showPlayButton = false;
        }
      });
    }
  }

  void _onDoubleTap() {
    if (!widget.reel.isLiked) {
      ref.read(reelsProvider.notifier).toggleLike(widget.reel.id);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildVideoPlayer(),
        if (_showHeart)
          Center(
            child: AnimatedBuilder(
              animation: _heartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartAnimation.value,
                  child: Icon(Icons.favorite, color: Colors.white, size: 100),
                );
              },
            ),
          ),
        if (_videoController != null && _videoController!.value.isInitialized)
          Center(
            child: AnimatedOpacity(
              opacity: _showPlayButton ? 0.7 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: AppSizes.largeIcon(context),
                  ),
                ),
              ),
            ),
          ),
        _buildContentOverlay(),
        _buildRightActions(),
        _buildBottomGradient(),
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: _onDoubleTap,
            onTap: _togglePlayPause,
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.reel.thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  Widget _buildContentOverlay() {
    return Positioned(
      left: AppSizes.mediumPadding(context),
      right: 80,
      bottom: 20,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.reel.user.profileImage),
                ),
                SizedBox(width: AppSizes.smallPadding(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.reel.user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.mediumText(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.reel.user.isVerified) ...[
                            SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        widget.reel.user.username,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: AppSizes.smallText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            Container(
              padding: EdgeInsets.all(AppSizes.smallPadding(context)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.reel.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.mediumText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.reel.location,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppSizes.smallText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.reel.propertyType,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.smallText(context) * 0.9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${widget.reel.currency} ${widget.reel.price}',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: AppSizes.mediumText(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            Text(
              widget.reel.description,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.smallText(context),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.smallPadding(context)),
            if (widget.reel.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children:
                    widget.reel.tags.take(3).map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.smallText(context) * 0.9,
                          ),
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightActions() {
    return Positioned(
      right: AppSizes.mediumPadding(context),
      bottom: 100,
      child: Column(
        children: [
          _buildActionButton(
            icon: widget.reel.isLiked ? Icons.favorite : Icons.favorite_border,
            count: widget.reel.likes,
            onTap: () {
              ref.read(reelsProvider.notifier).toggleLike(widget.reel.id);
            },
            isActive: widget.reel.isLiked,
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildActionButton(
            icon: Icons.comment,
            count: widget.reel.comments,
            onTap: () {
              _showCommentsBottomSheet(context);
            },
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildActionButton(
            icon: Icons.share,
            count: widget.reel.shares,
            onTap: () {
              _showShareBottomSheet(context);
            },
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          _buildActionButton(
            icon:
                widget.reel.isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_border,
            onTap: () {
              ref.read(reelsProvider.notifier).toggleBookmark(widget.reel.id);
            },
            isActive: widget.reel.isBookmarked,
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
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
            padding: EdgeInsets.all(AppSizes.smallPadding(context)),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: AppSizes.mediumIcon(context),
            ),
          ),
          if (count != null) ...[
            SizedBox(height: 4),
            Text(
              _formatCount(count),
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.smallText(context) * 0.8,
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

  Widget _buildBottomGradient() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CommentsBottomSheet(reel: widget.reel),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(reel: widget.reel),
    );
  }

  void _showMoreOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MoreOptionsBottomSheet(reel: widget.reel),
    );
  }
}
