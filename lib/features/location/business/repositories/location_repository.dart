import 'package:permission_handler/permission_handler.dart' as ph;

import '../entities/location_entity.dart';

enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  loading,
  initial;

  static PermissionStatus fromPermissionHandler(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return PermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return PermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return PermissionStatus.restricted;
      case ph.PermissionStatus.limited:
        return PermissionStatus.limited;
      default:
        return PermissionStatus.denied;
    }
  }

  bool get isGranted => this == PermissionStatus.granted;
  bool get isDenied => this == PermissionStatus.denied;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
  bool get isLoading => this == PermissionStatus.loading;
}

abstract class LocationRepository {
  Future<PermissionStatus> checkPermissionStatus();
  Future<PermissionStatus> requestPermission();
  Future<LocationEntity> getCurrentLocation();
  Future<LocationEntity?> getLastSavedLocation();
  Future<void> saveLocation(LocationEntity location);
  Future<void> clearSavedLocation();
  Future<bool> openAppSettings();
}
