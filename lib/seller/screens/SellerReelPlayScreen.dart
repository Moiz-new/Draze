// lib/seller/screens/seller_reel_play_screen.dart

import 'package:draze/seller/models/SellerReelModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';

import '../providers/sellerReelPlayProvider.dart';
import '../widgets/SellerReelVideoWidget.dart';

class SellerReelPlayScreen extends ConsumerStatefulWidget {
  final List<SellerReelModel> reels;
  final int? initialReelIndex;

  const SellerReelPlayScreen({
    super.key,
    required this.reels,
    this.initialReelIndex,
  });

  @override
  ConsumerState<SellerReelPlayScreen> createState() => _SellerReelPlayScreenState();
}

class _SellerReelPlayScreenState extends ConsumerState<SellerReelPlayScreen>
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

    // Initialize reels in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellerReelPlayProvider.notifier).initializeReels(widget.reels);
      if (widget.initialReelIndex != null) {
        ref.read(currentSellerReelIndexProvider.notifier).state = widget.initialReelIndex!;
      }
      // Clear existing controllers when initializing
      ref.read(sellerReelPlayProvider.notifier).clearControllers(ref);
    });
  }

  @override
  void dispose() {
    // Dispose all video controllers
    ref.read(sellerReelPlayProvider.notifier).clearControllers(ref);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reelsState = ref.watch(sellerReelPlayProvider);

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
              ref.read(currentSellerReelIndexProvider.notifier).state = index;
              ref.read(sellerReelPlayProvider.notifier).incrementViews(
                reelsState.reels[index].id,
              );
            },
            itemBuilder: (context, index) {
              return SellerReelVideoWidget(
                reel: reelsState.reels[index],
                isActive: ref.watch(currentSellerReelIndexProvider) == index,
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
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
        ],
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.largePadding(context),
              ),
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
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.largePadding(context),
                  vertical: AppSizes.mediumPadding(context),
                ),
              ),
              child: Text(
                'Go Back',
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
            SizedBox(height: AppSizes.mediumPadding(context)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.largePadding(context),
                  vertical: AppSizes.mediumPadding(context),
                ),
              ),
              child: Text(
                'Go Back',
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
}