import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/user/provider/property_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOptions = [
      {'label': 'Newest First', 'value': SortOption.newest},
      {'label': 'Oldest First', 'value': SortOption.oldest},
      {'label': 'Price: Low to High', 'value': SortOption.priceLowToHigh},
      {'label': 'Price: High to Low', 'value': SortOption.priceHighToLow},
      {'label': 'Rating: High to Low', 'value': SortOption.rating},
      {'label': 'Area: High to Low', 'value': SortOption.area},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort Properties',
                  style: TextStyle(
                    fontSize: AppSizes.largeText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortOptions.map(
              (option) => RadioListTile<SortOption>(
                title: Text(
                  option['label']! as String,
                  style: TextStyle(
                    fontSize: AppSizes.mediumText(context),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: option['value']! as SortOption,
                groupValue: ref.watch(sortOptionProvider),
                activeColor: AppColors.primary,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(sortOptionProvider.notifier).state = value;
                    // No need to call loadProperties since we're using static data
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(
                  double.infinity,
                  AppSizes.buttonHeight(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Apply Sort',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
