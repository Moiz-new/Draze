// lib/screens/landlord_reels_screen.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/seller/screens/reels_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/LandloardReelModel.dart';
import '../models/ReelMySubcriptionModel.dart';
import '../providers/LandlordReelsProvider.dart';
import '../providers/MySubscriptionProvider.dart';
import 'LandlordAddReelScreen.dart';
import 'SubscriptionPlansScreen.dart';

class LandlordReelsScreen extends StatefulWidget {
  const LandlordReelsScreen({
    super.key,
    required GlobalKey<ScaffoldState> scaffoldKey,
  });

  @override
  State<LandlordReelsScreen> createState() => _LandlordReelsScreenState();
}

class _LandlordReelsScreenState extends State<LandlordReelsScreen> {
  @override
  void initState() {
    super.initState();
    // Load subscriptions and reels when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  // Modified _initializeScreen method
  Future<void> _initializeScreen() async {
    final subscriptionProvider = Provider.of<MySubscriptionProvider>(
      context,
      listen: false,
    );

    // First fetch subscriptions
    await subscriptionProvider.fetchReelSubscriptions();

    // Load reels regardless of subscription status
    Provider.of<LandlordReelsProvider>(context, listen: false).loadReels();
  }

  // Modified _checkSubscriptionAndAddReel method
  Future<void> _checkSubscriptionAndAddReel() async {
    final subscriptionProvider = Provider.of<MySubscriptionProvider>(
      context,
      listen: false,
    );

    // Refresh subscription status
    await subscriptionProvider.fetchReelSubscriptions();

    // Check if user has any subscription
    if (subscriptionProvider.reelSubscriptions.isEmpty) {
      _showNoSubscriptionDialog();
      return;
    }

    // Check if subscription is active and has remaining reels
    final activeSubscription = subscriptionProvider.reelSubscriptions
        .firstWhere(
          (sub) => sub.status == 'active' && sub.canUploadMoreReels,
          orElse: () => subscriptionProvider.reelSubscriptions.first,
        );

    if (activeSubscription.status != 'active') {
      _showNoSubscriptionDialog();
      return;
    }

    // Check if reel limit is reached
    if (!activeSubscription.canUploadMoreReels) {
      _showReelLimitReachedDialog(activeSubscription);
      return;
    }

    // Proceed to add reel
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LandlordAddReelScreen()),
    );

    // If reel was added successfully, refresh the list
    if (result == true && mounted) {
      await subscriptionProvider
          .fetchReelSubscriptions(); // Refresh subscription to update counts
      Provider.of<LandlordReelsProvider>(context, listen: false).loadReels();
    }
  }

  void _showNoSubscriptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Subscription Required'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You need an active reel subscription to upload and manage reels.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Get unlimited reel uploads',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  //Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  ).then((_) {
                    // Refresh subscriptions when coming back
                    _initializeScreen();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Buy Plan'),
              ),
            ],
          ),
    );
  }

  void _showReelLimitReachedDialog(ReelSubscription subscription) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Reel Limit Reached'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have uploaded ${subscription.reelsUploaded} out of ${subscription.reelLimit} reels available in your ${subscription.planName} plan.',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Upgrade your plan to upload more reels',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  await Future.delayed(const Duration(milliseconds: 100));

                  if (!mounted) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  );

                  if (mounted) {
                    _initializeScreen();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Upgrade Plan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'My Reels',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _checkSubscriptionAndAddReel,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add, color: AppColors.primary, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<LandlordReelsProvider, MySubscriptionProvider>(
        builder: (context, reelsProvider, subscriptionProvider, child) {
          // Show loading if either provider is loading
          if (reelsProvider.isLoading || subscriptionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check for subscription first
          if (subscriptionProvider.reelSubscriptions.isEmpty) {
            return _buildNoSubscriptionState(context);
          }

          // Check for active subscription
          final hasActiveSubscription = subscriptionProvider.reelSubscriptions
              .any((sub) => sub.status == 'active');

          if (!hasActiveSubscription) {
            return _buildExpiredSubscriptionState(context);
          }

          // Show error state
          if (reelsProvider.errorMessage != null) {
            return _buildErrorState(reelsProvider.errorMessage!);
          }

          // Show empty state
          if (reelsProvider.reels.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Subscription Info Banner
              _buildSubscriptionBanner(context, subscriptionProvider),

              // Stats Header
              _buildStatsHeader(context, reelsProvider),

              // Reels Grid
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await reelsProvider.loadReels();
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: reelsProvider.reels.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOutBack,
                        child: EnhancedReelCard(
                          reel: reelsProvider.reels[index],
                          index: index,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LandlordReelsVideoScreen(
                                      initialReelIndex: index,
                                    ),
                              ),
                            );
                          },
                          onMore:
                              () => _showReelOptions(
                                context,
                                reelsProvider.reels[index],
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionBanner(
    BuildContext context,
    MySubscriptionProvider provider,
  ) {
    if (provider.reelSubscriptions.isEmpty) return const SizedBox.shrink();

    final subscription = provider.reelSubscriptions.first;

    return Container(
      margin: EdgeInsets.all(AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.card_membership, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.planName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.mediumText(context),
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${subscription.reelsUploaded}/${subscription.reelLimit} reels uploaded • ${subscription.remainingReels} remaining',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator
          Container(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value:
                      subscription.reelLimit > 0
                          ? subscription.reelsUploaded / subscription.reelLimit
                          : 0,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
                Center(
                  child: Text(
                    '${subscription.remainingReels}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership,
                size: 64,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Subscription',
              style: TextStyle(
                fontSize: AppSizes.largeText(context),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need an active reel subscription to upload and manage your reels',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPlansScreen(),
                  ),
                ).then((_) {
                  _initializeScreen();
                });
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Buy Subscription Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredSubscriptionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Subscription Expired',
              style: TextStyle(
                fontSize: AppSizes.largeText(context),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your reel subscription has expired. Renew now to continue uploading reels',
              style: TextStyle(
                fontSize: AppSizes.mediumText(context),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPlansScreen(),
                  ),
                ).then((_) {
                  _initializeScreen();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Renew Subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    LandlordReelsProvider provider,
  ) {
    // Calculate totals
    int totalLikes = 0;
    int totalViews = 0;
    int totalComments = 0;

    for (var reel in provider.reels) {
      totalLikes += reel.totalLikes;
      totalViews += reel.views;
      totalComments += reel.totalComments;
    }

    return Container(
      margin: EdgeInsets.all(AppSizes.mediumPadding(context)),
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.video_library,
            provider.reels.length.toString(),
            'Reels',
          ),
          _buildStatItem(
            context,
            Icons.favorite,
            _formatNumber(totalLikes),
            'Likes',
          ),
          _buildStatItem(
            context,
            Icons.visibility,
            _formatNumber(totalViews),
            'Views',
          ),
          _buildStatItem(
            context,
            Icons.chat_bubble_outline,
            _formatNumber(totalComments),
            'Comments',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.mediumText(context),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_library_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No reels yet',
            style: TextStyle(
              fontSize: AppSizes.largeText(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first reel to engage with customers',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _checkSubscriptionAndAddReel,
            icon: const Icon(Icons.add),
            label: const Text('Create Reel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    print(error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<LandlordReelsProvider>(
                context,
                listen: false,
              ).loadReels();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showReelOptions(BuildContext context, LandloardReelModel reel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
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

                /* ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    // Share reel
                  },
                ),*/
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, reel);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LandloardReelModel reel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reel'),
            content: const Text(
              'Are you sure you want to delete this reel? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Call delete method
                  final provider = Provider.of<LandlordReelsProvider>(
                    context,
                    listen: false,
                  );

                  bool success = await provider.deleteReel(reel.id);

                  // Show result
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Reel deleted successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ?? 'Failed to delete reel',
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
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

class EnhancedReelCard extends StatefulWidget {
  final dynamic reel;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const EnhancedReelCard({
    super.key,
    required this.reel,
    required this.index,
    required this.onTap,
    required this.onMore,
  });

  @override
  State<EnhancedReelCard> createState() => _EnhancedReelCardState();
}

class _EnhancedReelCardState extends State<EnhancedReelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              widget.onTap();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail with overlay
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[100]!,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child:
                                  widget.reel.thumbnailUrl != null
                                      ? Image.network(
                                        widget.reel.thumbnailUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.video_library,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                          );
                                        },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.video_library,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                            ),

                            // Play button overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),

                            // More options button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: widget.onMore,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content section
                      Padding(
                        padding: EdgeInsets.all(
                          AppSizes.mediumPadding(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              widget.reel.title ?? 'Untitled',
                              style: TextStyle(
                                fontSize: AppSizes.smallText(context),
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: AppSizes.smallPadding(context)),

                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      _buildStatChip(
                                        Icons.favorite,
                                        widget.reel.totalLikes,
                                        Colors.red[400]!,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatChip(
                                        Icons.chat_bubble_outline,
                                        widget.reel.totalComments,
                                        Colors.blue[400]!,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatNumber(widget.reel.views)} views',
                                  style: TextStyle(
                                    fontSize: AppSizes.smallText(context) * 0.9,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (widget.reel.totalShares > 0)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.share,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _formatNumber(widget.reel.totalShares),
                                        style: TextStyle(
                                          fontSize:
                                              AppSizes.smallText(context) * 0.9,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            _formatNumber(value),
            style: TextStyle(
              fontSize: 10,
              color: color,
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
