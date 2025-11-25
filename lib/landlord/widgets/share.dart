// lib/widgets/share_bottom_sheet.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/seller/models/reels/reel_model.dart';
import 'package:flutter/material.dart';

class LandlordShareBottomSheet extends StatelessWidget {
  final ReelModel reel;

  const LandlordShareBottomSheet({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius(context) * 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Share Property',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: AppSizes.mediumPadding(context)),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: AppSizes.mediumPadding(context),
            crossAxisSpacing: AppSizes.mediumPadding(context),
            children: [
              _buildShareOption(
                context,
                icon: Icons.message,
                label: 'Message',
                color: AppColors.primary,
                onTap: () {},
              ),
              _buildShareOption(
                context,
                icon: Icons.copy,
                label: 'Copy Link',
                color: AppColors.textSecondary,
                onTap: () {},
              ),
              _buildShareOption(
                context,
                icon: Icons.email,
                label: 'Email',
                color: AppColors.error,
                onTap: () {},
              ),
              _buildShareOption(
                context,
                icon: Icons.more_horiz,
                label: 'More',
                color: AppColors.textSecondary,
                onTap: () {},
              ),
            ],
          ),

          SizedBox(height: AppSizes.mediumPadding(context)),

          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSizes.mediumPadding(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius(context),
                    ),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppSizes.mediumText(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSizes.mediumIcon(context)),
          ),
          SizedBox(height: AppSizes.smallPadding(context)),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.9,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
