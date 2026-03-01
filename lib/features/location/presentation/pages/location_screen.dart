import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_project/constants/app_colors.dart';
import 'package:onboarding_project/constants/app_style.dart';
import 'package:onboarding_project/constants/gradient_wrapper.dart';
import 'package:onboarding_project/core/router/app_router.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../widgets/location_hero_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(CheckPermissionStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationPermissionRequired &&
              state.status.isPermanentlyDenied) {
            _showPermissionDeniedDialog(context);
          } else if (state is LocationLoaded) {
            context.go(AppRoutes.alarms);
          } else if (state is LocationError && state.canRetry) {
            _showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is LocationLoading) {
            return _buildLoadingState();
          }
          return _buildPermissionRequestScreen(context);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryAccent),
          SizedBox(height: 16),
          Text('Processing...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPermissionRequestScreen(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            const LocationHeroWidget(),
            const SizedBox(height: 20),
            _buildCurrentLocationButton(context),
            const SizedBox(height: 16),
            _buildHomeButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Welcome! Your Smart Travel Alarm',
          style: AppStyles.locheadlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Stay on schedule and enjoy every moment of your journey.',
            style: AppStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: AppStyles.secondaryButtonStyle,
        onPressed: () {
          _showLocationPermissionDialog(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            // Add the image with proper sizing
            const SizedBox(width: 8), // Add spacing between icon and text
            const Text('Use Current Location', style: AppStyles.locbuttonText),
            SizedBox(
              width: 20, // Set appropriate width
              height: 20, // Set appropriate height
              child: Image.asset(
                'assets/icons/location-05.png', // Make sure extension is correct
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: AppStyles.primaryButtonStyle,
        onPressed: () {
          context.go(AppRoutes.alarms);
        },
        child: const Text('Home', style: AppStyles.locbuttonText),
      ),
    );
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primaryAccent, size: 28),
            SizedBox(width: 12),
            Text(
              'Location Permission',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Smart Travel Alarm needs access to your location to:\n\n'
          '• Calculate sunrise times for your area\n'
          '• Suggest nearby places of interest\n'
          '• Provide personalized wake-up recommendations\n\n'
          'Your location data stays on your device and is never shared.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Not Now',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocationBloc>().add(RequestLocationPermission());
            },
            child: const Text(
              'Allow Location',
              style: TextStyle(color: AppColors.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text(
              'Permission Denied',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'Location permission was denied. To enable location access:\n\n'
          '1. Tap "Open Settings"\n'
          '2. Find "Smart Travel Alarm"\n'
          '3. Enable "Location" permission\n\n'
          'You can also skip this step and use the app without location.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go(AppRoutes.alarms);
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: AppColors.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            context.read<LocationBloc>().add(RequestLocationPermission());
          },
        ),
      ),
    );
  }
}
