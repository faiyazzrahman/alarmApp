import 'package:flutter/material.dart';
import 'package:onboarding_project/constants/app_style.dart';

import '../../../../constants/app_colors.dart';

class LocationCard extends StatelessWidget {
  final String locationName;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.locationName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selected Location', style: AppStyles.headlineMedium),
          const SizedBox(height: 8),
          // Location info card
          Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.divider.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(61),
            ),
            child: Row(
              children: [
                Image.asset('assets/icons/Frame.png'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
