import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Remote data source for GPS location
abstract class LocationRemoteDataSource {
  Future<Position> getCurrentPosition();
  Future<ph.PermissionStatus> checkPermission();
  Future<ph.PermissionStatus> requestPermission();
  Future<bool> isLocationServiceEnabled();
  Future<bool> openAppSettings();
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  @override
  Future<ph.PermissionStatus> checkPermission() async {
    return await ph.Permission.location.status;
  }

  @override
  Future<ph.PermissionStatus> requestPermission() async {
    final status = await ph.Permission.location.status;

    if (status.isGranted || status.isPermanentlyDenied) {
      return status;
    }

    return await ph.Permission.location.request();
  }

  @override
  Future<Position> getCurrentPosition() async {
    final status = await ph.Permission.location.status;
    if (!status.isGranted) {
      throw Exception('Location permission not granted');
    }

    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      throw Exception('Location services are disabled');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      throw Exception('Location request timed out');
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}
