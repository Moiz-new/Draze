// lib/widgets/more_options_bottom_sheet.dart
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/seller/models/reels/reel_model.dart';
import 'package:flutter/material.dart';

class LandlordMoreOptionsBottomSheet extends StatelessWidget {
  final ReelModel reel;

  const LandlordMoreOptionsBottomSheet({super.key, required this.reel});

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

          _buildOptionItem(
            context,
            icon: Icons.info_outline,
            title: 'Property Details',
            onTap: () {},
          ),

          _buildOptionItem(
            context,
            icon: Icons.phone,
            title: 'Contact Agent',
            onTap: () {},
          ),

          _buildOptionItem(
            context,
            icon: Icons.schedule,
            title: 'Schedule Visit',
            onTap: () {},
          ),

          _buildOptionItem(
            context,
            icon: Icons.report_outlined,
            title: 'Report',
            onTap: () {},
            isDestructive: true,
          ),

          _buildOptionItem(
            context,
            icon: Icons.block,
            title: 'Not Interested',
            onTap: () {},
            isDestructive: true,
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

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.mediumText(context),
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
