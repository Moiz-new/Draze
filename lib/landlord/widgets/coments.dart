// lib/widgets/comments_bottom_sheet.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart' show AppSizes;
import 'package:draze/seller/models/reels/reel_model.dart';
import 'package:flutter/material.dart';

class LandlordCommentsBottomSheet extends StatefulWidget {
  final ReelModel reel;

  const LandlordCommentsBottomSheet({super.key, required this.reel});

  @override
  State<LandlordCommentsBottomSheet> createState() =>
      _LandlordCommentsBottomSheetState();
}

class _LandlordCommentsBottomSheetState
    extends State<LandlordCommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<CommentModel> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadSampleComments();
  }

  void _loadSampleComments() {
    _comments.addAll([
      CommentModel(
        id: '1',
        user: UserModel(
          id: 'u4',
          name: 'Sarah Johnson',
          username: '@sarah_j',
          profileImage:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.0.3&w=150&q=80',
          userType: 'buyer',
        ),
        text: 'Beautiful property! Is it still available?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 5,
        isLiked: false,
      ),
      CommentModel(
        id: '2',
        user: UserModel(
          id: 'u5',
          name: 'Mike Chen',
          username: '@mike_c',
          profileImage:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&w=150&q=80',
          userType: 'buyer',
        ),
        text: 'What\'s the parking situation like?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 2,
        isLiked: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius(context) * 2),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: AppSizes.smallPadding(context)),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_comments.length} Comments',
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          Divider(color: AppColors.divider, height: 1),

          // Comments list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return _buildCommentItem(_comments[index]);
              },
            ),
          ),

          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(comment.user.profileImage),
          ),
          SizedBox(width: AppSizes.smallPadding(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user.name,
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: AppSizes.smallPadding(context)),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context) * 0.9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Toggle like
                      },
                      child: Icon(
                        comment.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color:
                            comment.isLiked
                                ? AppColors.error
                                : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      comment.likes.toString(),
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context) * 0.9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppSizes.mediumPadding(context)),
                    Text(
                      'Reply',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context) * 0.9,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppSizes.smallText(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.mediumPadding(context),
                    vertical: AppSizes.smallPadding(context),
                  ),
                ),
                style: TextStyle(
                  fontSize: AppSizes.smallText(context),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(width: AppSizes.smallPadding(context)),
            GestureDetector(
              onTap: _sendComment,
              child: Container(
                padding: EdgeInsets.all(AppSizes.smallPadding(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendComment() {
    if (_commentController.text.trim().isNotEmpty) {
      // Add comment logic here
      _commentController.clear();
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
