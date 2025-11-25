import 'package:draze/user/provider/reel_provider.dart';
import 'package:draze/user/widgets/reel_video_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  ReelsScreenState createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _initializeReelsScreen();
      }
    });
    debugPrint('ReelsScreen: initState called');
  }

  void _initializeReelsScreen() async {
    if (!mounted || _isDisposed || _isInitialized) return;

    _isInitialized = true;
    debugPrint('ReelsScreen: Initializing reels screen');

    try {
      final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);

      // Mark reels tab as active
      reelsProvider.setReelsTabActive(true);

      // Clear any existing error
      reelsProvider.setError(null);

      // Load reels from API
      reelsProvider.setLoading(true);
      await reelsProvider.loadReelsFromApi();

      // Start playing the first video if we're on reels tab and have data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed && reelsProvider.selectedTab == 1) {
          _playCurrentVideo();
        }
      });
    } catch (e) {
      debugPrint('ReelsScreen: Error loading reels: $e');
      if (mounted && !_isDisposed) {
        final reelsProvider = Provider.of<ReelsProvider>(
          context,
          listen: false,
        );
        reelsProvider.setError('Failed to load reels. Please try again.');
      }
    } finally {
      if (mounted && !_isDisposed) {
        final reelsProvider = Provider.of<ReelsProvider>(
          context,
          listen: false,
        );
        reelsProvider.setLoading(false);
      }
    }
  }

  void _playCurrentVideo() {
    if (!mounted || _isDisposed) return;

    final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
    final videoController = Provider.of<VideoControllersProvider>(
      context,
      listen: false,
    );

    final reels = reelsProvider.reels;
    final currentIndex = reelsProvider.currentPageIndex;

    if (reels.isNotEmpty && currentIndex < reels.length) {
      final currentReel = reels[currentIndex];
      debugPrint(
        'ReelsScreen: Playing current video for reel ${currentReel.id}',
      );

      // Pause all other videos first
      videoController.pauseAllExcept(currentReel.id);

      // Resume current video
      videoController.resume(currentReel.id);
    }
  }

  void _pauseAllVideos() {
    if (!mounted || _isDisposed) {
      debugPrint(
        'ReelsScreen: Not mounted or disposed, skipping pause all videos',
      );
      return;
    }
    debugPrint('ReelsScreen: Pausing all videos');
    final videoController = Provider.of<VideoControllersProvider>(
      context,
      listen: false,
    );
    videoController.pauseAll();
  }

  Future<void> _refreshReels() async {
    if (!mounted || _isDisposed) return;

    debugPrint('ReelsScreen: Refreshing reels');

    final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);

    // Clear error state
    reelsProvider.setError(null);

    try {
      reelsProvider.setLoading(true);
      await reelsProvider.refreshReels();

      // Reset to first page
      reelsProvider.setCurrentPageIndex(0);

      // Play first video if on reels tab
      if (mounted && !_isDisposed && reelsProvider.selectedTab == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            _playCurrentVideo();
          }
        });
      }
    } catch (e) {
      debugPrint('ReelsScreen: Error refreshing reels: $e');
      if (mounted && !_isDisposed) {
        reelsProvider.setError('Failed to refresh reels. Please try again.');
      }
    } finally {
      if (mounted && !_isDisposed) {
        reelsProvider.setLoading(false);
      }
    }
  }

  void _showProfilePopup(BuildContext context, ReelModel reel) {
    final landlord = reel.landlordId;

    if (landlord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Landlord information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: landlord.profilePhoto != null &&
                      landlord.profilePhoto!.isNotEmpty
                      ? NetworkImage(
                    // Replace with your base URL
                    'https://your-api-url.com${landlord.profilePhoto}',
                  )
                      : null,
                  child: landlord.profilePhoto == null ||
                      landlord.profilePhoto!.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  landlord.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Email (if available)
                if (landlord.email != null && landlord.email!.isNotEmpty)
                  Text(
                    landlord.email!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),

                // Property Title
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reel.title,
                    style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // View Property Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close popup

                      // Check if propertyId exists
                      if (reel.propertyId != null &&
                          reel.propertyId!.isNotEmpty) {
                        // Navigate to PropertyDetailScreen
                        Navigator.pushNamed(
                          context,
                          '/property-detail', // Replace with your actual route name
                          arguments: {
                            'propertyId': reel.propertyId,
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Property information not available'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Property',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Close Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareReel(ReelModel reel) async {
    try {
      final videoUrl = reel.videoUrl;
      final title = reel.title.isNotEmpty ? reel.title : 'Check out this property reel';
      final description = reel.description;

      final shareText = '''
$title${description.isNotEmpty ? '\n\n$description' : ''}

Watch the video: $videoUrl
''';

      await Share.share(
        shareText,
        subject: title,
      );

      // Increment share count in provider
      final reelsProvider = Provider.of<ReelsProvider>(context, listen: false);
      reelsProvider.incrementShare(reel.id);

      debugPrint('ReelsScreen: Shared reel ${reel.id}');
    } catch (e) {
      debugPrint('ReelsScreen: Error sharing reel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share reel'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_isDisposed) return;

    debugPrint('ReelsScreen: App lifecycle state changed to $state');

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pauseAllVideos();
    } else if (state == AppLifecycleState.resumed) {
      // Only resume if we're currently on reels tab
      if (mounted && !_isDisposed) {
        final reelsProvider = Provider.of<ReelsProvider>(
          context,
          listen: false,
        );
        if (reelsProvider.selectedTab == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isDisposed) {
              _playCurrentVideo();
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    debugPrint('ReelsScreen: dispose called');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No reels available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or check back later',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshReels,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshReels,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Loading reels...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<ReelsProvider>(
      builder: (context, reelsProvider, child) {
        final reels = reelsProvider.reels;
        final isLoading = reelsProvider.isLoading;
        final error = reelsProvider.error;
        final isTabActive = reelsProvider.selectedTab == 1;
        final currentPageIndex = reelsProvider.currentPageIndex;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Property Reels',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            actions: [
              if (!isLoading)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refreshReels,
                  tooltip: 'Refresh reels',
                ),
            ],
          ),
          backgroundColor: Colors.black,
          body: Builder(
            builder: (context) {
              // Show loading state
              if (isLoading && reels.isEmpty) {
                return _buildLoadingState();
              }

              // Show error state
              if (error != null && reels.isEmpty) {
                return _buildErrorState(error);
              }

              // Show empty state
              if (reels.isEmpty && !isLoading) {
                return _buildEmptyState();
              }

              // Show reels
              return RefreshIndicator(
                onRefresh: _refreshReels,
                color: Colors.white,
                backgroundColor: Colors.grey[900],
                child: Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: reels.length,
                      onPageChanged: (index) {
                        if (_isDisposed) return;

                        // Use addPostFrameCallback to avoid setState during build
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted || _isDisposed) return;

                          debugPrint('ReelsScreen: Page changed to index $index');
                          reelsProvider.setCurrentPageIndex(index);

                          // Only handle video playback if we're on reels tab
                          if (isTabActive && index < reels.length) {
                            final currentReel = reels[index];
                            final videoController =
                            Provider.of<VideoControllersProvider>(
                              context,
                              listen: false,
                            );

                            // Pause all videos except the current one
                            videoController.pauseAllExcept(currentReel.id);

                            // Small delay to ensure smooth transition
                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mounted &&
                                  !_isDisposed &&
                                  reelsProvider.selectedTab == 1) {
                                videoController.resume(currentReel.id);
                              }
                            });
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        if (index >= reels.length) return const SizedBox.shrink();

                        final reel = reels[index];
                        final isActive = currentPageIndex == index;
                        final shouldPlay = isActive && isTabActive;

                        return ReelVideoWidget(
                          reel: reel,
                          isActive: shouldPlay,
                          key: ValueKey('${reel.id}_$index'),
                        );
                      },
                    ),

                    // Profile and Share buttons overlay
                    if (reels.isNotEmpty && currentPageIndex < reels.length)
                      Positioned(
                        right: 12,
                        bottom: 100,
                        child: Column(
                          children: [
                            // Profile Button
                            GestureDetector(
                              onTap: () => _showProfilePopup(
                                context,
                                reels[currentPageIndex],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[800],
                                      backgroundImage: reels[currentPageIndex]
                                          .landlordId?.profilePhoto !=
                                          null &&
                                          reels[currentPageIndex]
                                              .landlordId!
                                              .profilePhoto!
                                              .isNotEmpty
                                          ? NetworkImage(
                                        // Replace with your base URL
                                        'https://your-api-url.com${reels[currentPageIndex].landlordId!.profilePhoto}',
                                      )
                                          : null,
                                      child: reels[currentPageIndex]
                                          .landlordId?.profilePhoto ==
                                          null ||
                                          reels[currentPageIndex]
                                              .landlordId!
                                              .profilePhoto!
                                              .isEmpty
                                          ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Share Button
                            GestureDetector(
                              onTap: () => _shareReel(reels[currentPageIndex]),
                              child: Column(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800]?.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${reels[currentPageIndex].shares}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}