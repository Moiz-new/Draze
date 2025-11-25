import 'package:draze/landlord/widgets/reel_video.dart';
import 'package:draze/seller/providers/reels_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';

class LandlordReelsScreen extends ConsumerStatefulWidget {
  final int? initialReelIndex;

  const LandlordReelsScreen({super.key, this.initialReelIndex});

  @override
  ConsumerState<LandlordReelsScreen> createState() =>
      _LandlordReelsScreenState();
}

class _LandlordReelsScreenState extends ConsumerState<LandlordReelsScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialReelIndex ?? 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    if (widget.initialReelIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentReelIndexProvider.notifier).state =
            widget.initialReelIndex!;
      });
    }

    // Clear existing controllers when initializing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reelsProvider.notifier).clearControllers(ref);
    });
  }

  @override
  void dispose() {
    // Dispose all video controllers
    ref.read(reelsProvider.notifier).clearControllers(ref);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reelsState = ref.watch(reelsProvider);

    if (reelsState.isLoading) {
      return _buildLoadingScreen();
    }

    if (reelsState.error != null) {
      return _buildErrorScreen(reelsState.error!);
    }

    if (reelsState.reels.isEmpty) {
      return _buildEmptyScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reelsState.reels.length,
            onPageChanged: (index) {
              ref.read(currentReelIndexProvider.notifier).state = index;
              ref
                  .read(reelsProvider.notifier)
                  .incrementViews(reelsState.reels[index].id);
            },
            itemBuilder: (context, index) {
              return LandlordReelVideoWidget(
                reel: reelsState.reels[index],
                isActive: ref.watch(currentReelIndexProvider) == index,
              );
            },
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
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),
        ],
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
          Text(
            'Property Reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildTopBarButton(Icons.search, () {}),
              SizedBox(width: AppSizes.smallPadding(context)),
              _buildTopBarButton(Icons.more_vert, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.smallPadding(context)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: AppSizes.mediumIcon(context) * 0.8,
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
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
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppSizes.largeIcon(context) * 2,
            ),
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
            Text(
              error,
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppSizes.smallText(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.mediumPadding(context)),
            ElevatedButton(
              onPressed: () {
                ref.read(reelsProvider.notifier).loadReels();
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
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: Colors.white54,
              size: AppSizes.largeIcon(context) * 2,
            ),
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
      ),
    );
  }
}
