import 'package:permission_handler/permission_handler.dart' as ph;

import '../../business/entities/location_entity.dart';
import '../../business/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';
import '../datasources/location_local_datasource.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<PermissionStatus> checkPermissionStatus() async {
    try {
      final status = await remoteDataSource.checkPermission();
      return _mapPermissionStatus(status);
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    try {
      final status = await remoteDataSource.requestPermission();
      return _mapPermissionStatus(status);
    } catch (e) {
      return PermissionStatus.denied;
    }
  }

  @override
  Future<LocationEntity> getCurrentLocation() async {
    final position = await remoteDataSource.getCurrentPosition();
    final locationModel = await LocationModel.fromPosition(position);
    await localDataSource.saveLastLocation(locationModel);
    return locationModel.toEntity();
  }

  @override
  Future<LocationEntity?> getLastSavedLocation() async {
    try {
      final locationModel = await localDataSource.getLastLocation();
      return locationModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLocation(LocationEntity location) async {
    final locationModel = LocationModel.fromEntity(location);
    await localDataSource.saveLastLocation(locationModel);
  }

  @override
  Future<void> clearSavedLocation() async {
    await localDataSource.clearLastLocation();
  }

  @override
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }

  PermissionStatus _mapPermissionStatus(ph.PermissionStatus status) {
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
}
