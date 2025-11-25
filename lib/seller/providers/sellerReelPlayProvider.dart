// lib/seller/providers/seller_reel_play_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../models/SellerReelModel.dart';

// Provider for managing seller reels playback
final sellerReelPlayProvider = StateNotifierProvider<SellerReelPlayNotifier, SellerReelPlayState>((ref) {
  return SellerReelPlayNotifier(ref);
});

// Provider for current reel index
final currentSellerReelIndexProvider = StateProvider<int>((ref) => 0);

// Provider for video controllers
final sellerVideoControllersProvider = StateProvider<Map<String, VideoPlayerController>>((ref) => {});

class SellerReelPlayState {
  final List<SellerReelModel> reels;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  SellerReelPlayState({
    this.reels = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  SellerReelPlayState copyWith({
    List<SellerReelModel>? reels,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return SellerReelPlayState(
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SellerReelPlayNotifier extends StateNotifier<SellerReelPlayState> {
  final StateNotifierProviderRef<SellerReelPlayNotifier, SellerReelPlayState> ref;

  SellerReelPlayNotifier(this.ref) : super(SellerReelPlayState());

  // Initialize reels with provided list
  void initializeReels(List<SellerReelModel> reels) {
    state = state.copyWith(
      reels: reels,
      isLoading: false,
      hasMore: false,
    );
  }

  // Load reels from API (implement your actual API call here)
  Future<void> loadReels() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      // For now, using empty list - replace with actual API response
      final fetchedReels = <SellerReelModel>[];

      state = state.copyWith(
        reels: fetchedReels,
        isLoading: false,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Dispose all video controllers
  void disposeControllers(Map<String, VideoPlayerController> controllers) {
    for (var controller in controllers.values) {
      controller.pause();
      controller.dispose();
    }
  }

  // Clear all video controllers
  void clearControllers(WidgetRef ref) {
    final controllers = ref.read(sellerVideoControllersProvider);
    disposeControllers(controllers);
    ref.read(sellerVideoControllersProvider.notifier).update((state) => {});
  }

  // Toggle like on a reel
  void toggleLike(String reelId) {
    final updatedReels = state.reels.map((reel) {
      if (reel.id == reelId) {
        final isCurrentlyLiked = reel.likes.isNotEmpty; // Assuming user ID is in likes list
        return SellerReelModel(
          id: reel.id,
          sellerId: reel.sellerId,
          propertyId: reel.propertyId,
          videoKey: reel.videoKey,
          videoUrl: reel.videoUrl,
          thumbnailKey: reel.thumbnailKey,
          thumbnailUrl: reel.thumbnailUrl,
          duration: reel.duration,
          views: reel.views,
          totalLikes: isCurrentlyLiked ? reel.totalLikes - 1 : reel.totalLikes + 1,
          totalComments: reel.totalComments,
          totalShares: reel.totalShares,
          totalSaves: reel.totalSaves,
          status: reel.status,
          tags: reel.tags,
          viewedBy: reel.viewedBy,
          likes: isCurrentlyLiked ? [] : ['current_user'], // Toggle like
          comments: reel.comments,
          shares: reel.shares,
          saves: reel.saves,
          createdAt: reel.createdAt,
          updatedAt: reel.updatedAt,
          engagementRate: reel.engagementRate,
          likesCount: isCurrentlyLiked ? reel.likesCount - 1 : reel.likesCount + 1,
          commentsCount: reel.commentsCount,
          sharesCount: reel.sharesCount,
          savesCount: reel.savesCount,
        );
      }
      return reel;
    }).toList();

    state = state.copyWith(reels: updatedReels);
  }

  // Toggle save/bookmark on a reel
  void toggleSave(String reelId) {
    final updatedReels = state.reels.map((reel) {
      if (reel.id == reelId) {
        final isCurrentlySaved = reel.saves.isNotEmpty;
        return SellerReelModel(
          id: reel.id,
          sellerId: reel.sellerId,
          propertyId: reel.propertyId,
          videoKey: reel.videoKey,
          videoUrl: reel.videoUrl,
          thumbnailKey: reel.thumbnailKey,
          thumbnailUrl: reel.thumbnailUrl,
          duration: reel.duration,
          views: reel.views,
          totalLikes: reel.totalLikes,
          totalComments: reel.totalComments,
          totalShares: reel.totalShares,
          totalSaves: isCurrentlySaved ? reel.totalSaves - 1 : reel.totalSaves + 1,
          status: reel.status,
          tags: reel.tags,
          viewedBy: reel.viewedBy,
          likes: reel.likes,
          comments: reel.comments,
          shares: reel.shares,
          saves: isCurrentlySaved ? [] : ['current_user'], // Toggle save
          createdAt: reel.createdAt,
          updatedAt: reel.updatedAt,
          engagementRate: reel.engagementRate,
          likesCount: reel.likesCount,
          commentsCount: reel.commentsCount,
          sharesCount: reel.sharesCount,
          savesCount: isCurrentlySaved ? reel.savesCount - 1 : reel.savesCount + 1,
        );
      }
      return reel;
    }).toList();

    state = state.copyWith(reels: updatedReels);
  }

  // Increment views for a reel
  void incrementViews(String reelId) {
    final updatedReels = state.reels.map((reel) {
      if (reel.id == reelId) {
        return SellerReelModel(
          id: reel.id,
          sellerId: reel.sellerId,
          propertyId: reel.propertyId,
          videoKey: reel.videoKey,
          videoUrl: reel.videoUrl,
          thumbnailKey: reel.thumbnailKey,
          thumbnailUrl: reel.thumbnailUrl,
          duration: reel.duration,
          views: reel.views + 1,
          totalLikes: reel.totalLikes,
          totalComments: reel.totalComments,
          totalShares: reel.totalShares,
          totalSaves: reel.totalSaves,
          status: reel.status,
          tags: reel.tags,
          viewedBy: [...reel.viewedBy, 'current_user'],
          likes: reel.likes,
          comments: reel.comments,
          shares: reel.shares,
          saves: reel.saves,
          createdAt: reel.createdAt,
          updatedAt: DateTime.now(),
          engagementRate: reel.engagementRate,
          likesCount: reel.likesCount,
          commentsCount: reel.commentsCount,
          sharesCount: reel.sharesCount,
          savesCount: reel.savesCount,
        );
      }
      return reel;
    }).toList();

    state = state.copyWith(reels: updatedReels);
  }

  // Increment shares for a reel
  void incrementShares(String reelId) {
    final updatedReels = state.reels.map((reel) {
      if (reel.id == reelId) {
        return SellerReelModel(
          id: reel.id,
          sellerId: reel.sellerId,
          propertyId: reel.propertyId,
          videoKey: reel.videoKey,
          videoUrl: reel.videoUrl,
          thumbnailKey: reel.thumbnailKey,
          thumbnailUrl: reel.thumbnailUrl,
          duration: reel.duration,
          views: reel.views,
          totalLikes: reel.totalLikes,
          totalComments: reel.totalComments,
          totalShares: reel.totalShares + 1,
          totalSaves: reel.totalSaves,
          status: reel.status,
          tags: reel.tags,
          viewedBy: reel.viewedBy,
          likes: reel.likes,
          comments: reel.comments,
          shares: [...reel.shares, 'current_user'],
          saves: reel.saves,
          createdAt: reel.createdAt,
          updatedAt: DateTime.now(),
          engagementRate: reel.engagementRate,
          likesCount: reel.likesCount,
          commentsCount: reel.commentsCount,
          sharesCount: reel.sharesCount + 1,
          savesCount: reel.savesCount,
        );
      }
      return reel;
    }).toList();

    state = state.copyWith(reels: updatedReels);
  }

  // Add a comment (increment count - actual comment handling would be separate)
  void incrementComments(String reelId) {
    final updatedReels = state.reels.map((reel) {
      if (reel.id == reelId) {
        return SellerReelModel(
          id: reel.id,
          sellerId: reel.sellerId,
          propertyId: reel.propertyId,
          videoKey: reel.videoKey,
          videoUrl: reel.videoUrl,
          thumbnailKey: reel.thumbnailKey,
          thumbnailUrl: reel.thumbnailUrl,
          duration: reel.duration,
          views: reel.views,
          totalLikes: reel.totalLikes,
          totalComments: reel.totalComments + 1,
          totalShares: reel.totalShares,
          totalSaves: reel.totalSaves,
          status: reel.status,
          tags: reel.tags,
          viewedBy: reel.viewedBy,
          likes: reel.likes,
          comments: reel.comments,
          shares: reel.shares,
          saves: reel.saves,
          createdAt: reel.createdAt,
          updatedAt: DateTime.now(),
          engagementRate: reel.engagementRate,
          likesCount: reel.likesCount,
          commentsCount: reel.commentsCount + 1,
          sharesCount: reel.sharesCount,
          savesCount: reel.savesCount,
        );
      }
      return reel;
    }).toList();

    state = state.copyWith(reels: updatedReels);
  }
}