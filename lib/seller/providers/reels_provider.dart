import 'package:draze/seller/models/reels/reel_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// Provider for managing reels data
final reelsProvider = StateNotifierProvider<ReelsNotifier, ReelsState>((ref) {
  return ReelsNotifier(ref);
});

// Provider for current reel index
final currentReelIndexProvider = StateProvider<int>((ref) => 0);

// Provider for video controllers
final videoControllersProvider =
    StateProvider<Map<String, VideoPlayerController>>((ref) => {});

class ReelsState {
  final List<ReelModel> reels;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  ReelsState({
    this.reels = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  ReelsState copyWith({
    List<ReelModel>? reels,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return ReelsState(
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ReelsNotifier extends StateNotifier<ReelsState> {
  final StateNotifierProviderRef<ReelsNotifier, ReelsState> ref;

  ReelsNotifier(this.ref) : super(ReelsState());

  final String currentUserId = 'u1';

  Future<void> loadReels() async {
    if (state.isLoading || !state.hasMore) return; // Prevent duplicate loads
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final sampleReels = _generateSampleReels();
      final sellerReels =
          sampleReels.where((reel) => reel.user.id == currentUserId).toList();
      state = state.copyWith(
        reels: sellerReels,
        isLoading: false,
        hasMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addReel({
    required String videoUrl,
    required String thumbnailUrl,
    required String title,
    required String description,
    required String propertyType,
    required String location,
    required double price,
    required String currency,
    required UserModel user,
    List<String>? tags,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final newReel = ReelModel(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        title: title,
        description: description,
        propertyType: propertyType,
        location: location,
        price: price,
        currency: currency,
        user: user,
        likes: 0,
        comments: 0,
        shares: 0,
        views: 0,
        createdAt: DateTime.now(),
        tags: tags ?? [],
      );
      state = state.copyWith(
        reels: [...state.reels, newReel],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void disposeControllers(Map<String, VideoPlayerController> controllers) {
    for (var controller in controllers.values) {
      controller.pause();
      controller.dispose();
    }
  }

  void clearControllers(WidgetRef ref) {
    final controllers = ref.read(videoControllersProvider);
    disposeControllers(controllers);
    ref.read(videoControllersProvider.notifier).update((state) => {});
  }

  void toggleLike(String reelId) {
    final updatedReels =
        state.reels.map((reel) {
          if (reel.id == reelId) {
            return reel.copyWith(
              isLiked: !reel.isLiked,
              likes: reel.isLiked ? reel.likes - 1 : reel.likes + 1,
            );
          }
          return reel;
        }).toList();
    state = state.copyWith(reels: updatedReels);
  }

  void toggleBookmark(String reelId) {
    final updatedReels =
        state.reels.map((reel) {
          if (reel.id == reelId) {
            return reel.copyWith(isBookmarked: !reel.isBookmarked);
          }
          return reel;
        }).toList();
    state = state.copyWith(reels: updatedReels);
  }

  void incrementViews(String reelId) {
    final updatedReels =
        state.reels.map((reel) {
          if (reel.id == reelId) {
            return reel.copyWith(views: reel.views + 1);
          }
          return reel;
        }).toList();
    state = state.copyWith(reels: updatedReels);
  }

  List<ReelModel> _generateSampleReels() {
    return [
      ReelModel(
        id: '1',
        videoUrl: 'https://www.w3schools.com/tags/mov_bbb.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Luxury Villa Tour',
        description:
            '🏡 Stunning 4BHK villa with swimming pool and garden. Perfect for families looking for luxury living in prime location.',
        propertyType: 'Villa',
        location: 'Bandra West, Mumbai',
        price: 2.5,
        currency: '₹ Cr',
        user: UserModel(
          id: 'u1',
          name: 'Rajesh Sharma',
          username: '@rajesh_properties',
          profileImage:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&w=150&q=80',
          isVerified: true,
          userType: 'agent',
        ),
        likes: 245,
        comments: 32,
        shares: 18,
        views: 1250,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['luxury', 'villa', 'swimming_pool', 'garden'],
      ),
      ReelModel(
        id: '2',
        videoUrl: 'https://www.w3schools.com/tags/mov_bbb.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Modern Apartment',
        description:
            '✨ Brand new 2BHK apartment with modern amenities and city view. Ready to move in!',
        propertyType: 'Apartment',
        location: 'Koramangala, Bangalore',
        price: 85,
        currency: '₹ Lakh',
        user: UserModel(
          id: 'u1',
          name: 'Rajesh Sharma',
          username: '@rajesh_properties',
          profileImage:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&w=150&q=80',
          isVerified: true,
          userType: 'agent',
        ),
        likes: 189,
        comments: 24,
        shares: 12,
        views: 890,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        tags: ['modern', 'apartment', 'city_view', 'ready_to_move'],
      ),
      ReelModel(
        id: '3',
        videoUrl: 'https://www.w3schools.com/tags/mov_bbb.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
        title: 'Cozy Studio',
        description:
            '🌟 Perfect studio apartment for young professionals. Fully furnished with all modern amenities.',
        propertyType: 'Studio',
        location: 'Gurgaon Sector 29',
        price: 45,
        currency: '₹ Lakh',
        user: UserModel(
          id: 'u1',
          name: 'Rajesh Sharma',
          username: '@rajesh_properties',
          profileImage:
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&w=150&q=80',
          isVerified: true,
          userType: 'agent',
        ),
        likes: 156,
        comments: 19,
        shares: 8,
        views: 675,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        tags: ['studio', 'furnished', 'professional', 'modern'],
      ),
    ];
  }
}
