import 'package:flutter/material.dart';
import 'package:onboarding_project/constants/app_colors.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onSettingsPressed;
  final VoidCallback onCancelPressed;

  const LocationPermissionDialog({
    super.key,
    required this.onSettingsPressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardDark,
      title: const Text(
        'Location Permission Required',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Location permission is permanently denied. Please enable it in app settings to use location-based features.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: onCancelPressed,
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: onSettingsPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
          ),
          child: const Text('Open Settings'),
        ),
      ],
    );
  }
}
