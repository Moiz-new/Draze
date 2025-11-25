import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/UserReelsProvider.dart';
import 'PropertyDetailScreen.dart';

class UserReelsScreen extends StatefulWidget {
  const UserReelsScreen({Key? key}) : super(key: key);

  @override
  State<UserReelsScreen> createState() => _UserReelsScreenState();
}

class _UserReelsScreenState extends State<UserReelsScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserReelsProvider>().fetchReels();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle lifecycle changes if needed
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<UserReelsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) provider.fetchReels();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (provider.reels.isEmpty) {
            return const Center(
              child: Text(
                'No reels available',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: provider.reels.length,
            onPageChanged: (index) {
              provider.setCurrentIndex(index);
            },
            itemBuilder: (context, index) {
              return ReelItem(
                reel: provider.reels[index],
                isCurrentPage: provider.currentIndex == index,
              );
            },
          );
        },
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final UserReelModel reel;
  final bool isCurrentPage;

  const ReelItem({Key? key, required this.reel, required this.isCurrentPage})
      : super(key: key);

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showPlayPause = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  String? _getProperImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    if (imageUrl.startsWith('file://')) {
      imageUrl = imageUrl.replaceFirst('file://', '');
    }
    if (imageUrl.startsWith('/')) {
      return 'https://api.drazeapp.com$imageUrl';
    }
    return 'https://api.drazeapp.com/$imageUrl';
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage != oldWidget.isCurrentPage) {
      if (widget.isCurrentPage) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    try {
      _controller = VideoPlayerController.network(widget.reel.videoUrl);
      await _controller!.initialize();
      if (_isDisposed) {
        _controller?.dispose();
        return;
      }
      _controller!.setLooping(true);
      if (widget.isCurrentPage) {
        _controller!.play();
      }
      if (mounted && !_isDisposed) {
        setState(() => _isInitialized = true);
      }
      _controller!.addListener(() {
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      });
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() => _isInitialized = false);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || _isDisposed) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      _showPlayPause = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        setState(() => _showPlayPause = false);
      }
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showVendorProfile(BuildContext context) {
    final landlord = widget.reel.landlordId;
    if (landlord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor information not available')));
      return;
    }
    _controller?.pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final vendorAvatar = _getProperImageUrl(landlord.profilePhoto);
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[700],
                backgroundImage:
                vendorAvatar != null ? NetworkImage(vendorAvatar) : null,
                child: vendorAvatar == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
                onBackgroundImageError: vendorAvatar != null
                    ? (e, s) {
                  print('Error loading vendor avatar: $e');
                }
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                landlord.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.reel.title,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (widget.reel.propertyId != null) {
                      _controller?.pause();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailScreen(propertyId: widget.reel.propertyId!),
                        ),
                      );
                      if (mounted && widget.isCurrentPage && !_isDisposed) {
                        _controller?.play();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Property details not available')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Property Details',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (mounted && widget.isCurrentPage && !_isDisposed) {
        _controller?.play();
      }
    });
  }

  Future<void> _shareReel() async {
    try {
      final provider = context.read<UserReelsProvider>();
      await Share.share(widget.reel.videoUrl, subject: widget.reel.title);
      provider.incrementShares(widget.reel.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final avatarUrl = _getProperImageUrl(widget.reel.landlordId?.profilePhoto);
    return Consumer<UserReelsProvider>(
      builder: (context, provider, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: Center(
                child: _isInitialized && _controller != null
                    ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
                    : Container(
                  color: Colors.black,
                  child: widget.reel.thumbnailUrl != null
                      ? Image.network(
                    widget.reel.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                      : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
            if (_showPlayPause)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller?.value.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
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
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
            ),
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
            Positioned(
              right: 12,
              bottom: 80,
              child: Column(
                children: [
                  _ActionButton(
                    icon:
                    provider.isLiked(widget.reel.id) ? Icons.favorite : Icons.favorite_border,
                    label: _formatCount(widget.reel.likesCount),
                    color: provider.isLiked(widget.reel.id) ? Colors.red : Colors.white,
                    onTap: () => provider.toggleLike(widget.reel.id),
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.comment,
                    label: _formatCount(widget.reel.commentsCount),
                    onTap: () => _showCommentsSheet(context),
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.send,
                    label: _formatCount(widget.reel.sharesCount),
                    onTap: _shareReel,
                  ),
                  const SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.more_vert,
                    onTap: () => _showMoreOptions(context),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 80,
              bottom: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _showVendorProfile(context),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                          onBackgroundImageError: avatarUrl != null
                              ? (e, s) {
                            print('Error loading avatar: $e');
                          }
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.reel.landlordId?.name ??
                                'Seller ${widget.reel.id.substring(0, 8)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_formatCount(widget.reel.views)} views',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  if (widget.reel.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.reel.tags
                          .map(
                            (tag) => Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 50,
              right: 16,
              child: IconButton(
                onPressed: () {
                  provider.toggleMute();
                  _controller?.setVolume(provider.isMuted ? 0 : 1);
                },
                icon: Icon(
                  provider.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            if (_isInitialized && _controller != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white38,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showCommentsSheet(BuildContext context) {
    _controller?.pause();
    final TextEditingController commentController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserReelsProvider>().fetchComments(widget.reel.id);
      }
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<UserReelsProvider>(
            builder: (context, provider, child) {
              final comments = provider.getComments(widget.reel.id);
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${comments.length} Comments',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  Expanded(
                    child: provider.isLoadingComments
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : comments.isEmpty
                        ? Center(
                      child: Text(
                        'No comments yet\nBe the first to comment!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    )
                        : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _CommentItem(comment: comment);
                      },
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                    ),
                    color: Colors.grey[900],
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (text) async {
                              if (text.trim().isNotEmpty) {
                                final success =
                                await provider.postComment(widget.reel.id, text);
                                if (success) {
                                  commentController.clear();
                                  FocusScope.of(context).unfocus();
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('Failed to post comment'),
                                  ));
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        provider.isPostingComment
                            ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                            : IconButton(
                          onPressed: () async {
                            if (commentController.text.trim().isNotEmpty) {
                              final success = await provider.postComment(
                                  widget.reel.id, commentController.text);
                              if (success) {
                                commentController.clear();
                                FocusScope.of(context).unfocus();
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Failed to post comment'),
                                ));
                              }
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    ).whenComplete(() {
      commentController.dispose();
      if (mounted && widget.isCurrentPage && !_isDisposed) {
        _controller?.play();
      }
    });
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.white),
              title: const Text('Report', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.white),
              title: const Text('Not interested', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('About this reel', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== COMMENT ITEM ====================
class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  String? _getProperImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    if (imageUrl.startsWith('file://')) {
      imageUrl = imageUrl.replaceFirst('file://', '');
    }
    if (imageUrl.startsWith('/')) {
      return 'https://api.drazeapp.com$imageUrl';
    }
    return 'https://api.drazeapp.com/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getProperImageUrl(comment.userPhoto);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[700],
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? const Icon(Icons.person, size: 20, color: Colors.white)
                : null,
            onBackgroundImageError: imageUrl != null
                ? (e, s) {
              print('Error loading comment user image: $e');
            }
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ACTION BUTTON ====================
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
