import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if permission is granted
  static Future<bool> isPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  // Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied() async {
    return await Permission.location.isPermanentlyDenied;
  }

  // Request location permission
  static Future<PermissionStatus> requestPermission() async {
    return await Permission.location.request();
  }

  // Get current position
  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
