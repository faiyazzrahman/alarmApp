import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_screen.dart';
import '../../features/location/presentation/pages/location_screen.dart';
import '../../features/alarms/presentation/pages/alarms_screen.dart';

/// Route names for the app
class AppRoutes {
  static const String onboarding = '/';
  static const String location = '/location';
  static const String alarms = '/alarms';
}

/// GoRouter configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.onboarding,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.location,
      name: 'location',
      builder: (context, state) => const LocationScreen(),
    ),
    GoRoute(
      path: AppRoutes.alarms,
      name: 'alarms',
      builder: (context, state) => const AlarmsScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
