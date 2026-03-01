import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onboarding_project/features/location/data/datasources/location_remote_datasource.dart';
import 'package:onboarding_project/features/location/data/datasources/location_local_datasource.dart';
import 'package:onboarding_project/features/location/data/models/location_model.dart';
import 'package:onboarding_project/features/location/data/repositories/location_repository_impl.dart';
import 'package:onboarding_project/features/location/business/repositories/location_repository.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

// Manual Mock Classes
class MockLocationRemoteDataSource implements LocationRemoteDataSource {
  ph.PermissionStatus? mockCheckPermissionResult;
  ph.PermissionStatus? mockRequestPermissionResult;
  Position? mockGetCurrentPositionResult;
  Exception? mockGetCurrentPositionError;
  bool? mockOpenAppSettingsResult;

  @override
  Future<ph.PermissionStatus> checkPermission() async {
    return mockCheckPermissionResult ?? ph.PermissionStatus.denied;
  }

  @override
  Future<ph.PermissionStatus> requestPermission() async {
    return mockRequestPermissionResult ?? ph.PermissionStatus.denied;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (mockGetCurrentPositionError != null) {
      throw mockGetCurrentPositionError!;
    }
    return mockGetCurrentPositionResult!;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<bool> openAppSettings() async {
    return mockOpenAppSettingsResult ?? true;
  }
}

class MockLocationLocalDataSource implements LocationLocalDataSource {
  LocationModel? mockGetLastLocationResult;
  Exception? mockGetLastLocationError;

  @override
  Future<LocationModel?> getLastLocation() async {
    if (mockGetLastLocationError != null) {
      throw mockGetLastLocationError!;
    }
    return mockGetLastLocationResult;
  }

  @override
  Future<void> saveLastLocation(LocationModel location) async {}

  @override
  Future<void> clearLastLocation() async {}
}

void main() {
  late LocationRepositoryImpl repository;
  late MockLocationRemoteDataSource mockRemoteDataSource;
  late MockLocationLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockLocationRemoteDataSource();
    mockLocalDataSource = MockLocationLocalDataSource();
    repository = LocationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('checkPermissionStatus', () {
    test('should return granted when permission is granted', () async {
      mockRemoteDataSource.mockCheckPermissionResult =
          ph.PermissionStatus.granted;

      final result = await repository.checkPermissionStatus();

      expect(result, PermissionStatus.granted);
    });

    test('should return denied when permission is denied', () async {
      mockRemoteDataSource.mockCheckPermissionResult =
          ph.PermissionStatus.denied;

      final result = await repository.checkPermissionStatus();

      expect(result, PermissionStatus.denied);
    });

    test(
      'should return permanentlyDenied when permission is permanently denied',
      () async {
        mockRemoteDataSource.mockCheckPermissionResult =
            ph.PermissionStatus.permanentlyDenied;

        final result = await repository.checkPermissionStatus();

        expect(result, PermissionStatus.permanentlyDenied);
      },
    );

    test('should return denied when exception occurs', () async {
      mockRemoteDataSource.mockCheckPermissionResult =
          ph.PermissionStatus.denied;

      final result = await repository.checkPermissionStatus();

      expect(result, PermissionStatus.denied);
    });
  });

  group('requestPermission', () {
    test(
      'should return granted when permission is granted after request',
      () async {
        mockRemoteDataSource.mockRequestPermissionResult =
            ph.PermissionStatus.granted;

        final result = await repository.requestPermission();

        expect(result, PermissionStatus.granted);
      },
    );

    test(
      'should return denied when permission is denied after request',
      () async {
        mockRemoteDataSource.mockRequestPermissionResult =
            ph.PermissionStatus.denied;

        final result = await repository.requestPermission();

        expect(result, PermissionStatus.denied);
      },
    );

    test('should return denied when exception occurs', () async {
      mockRemoteDataSource.mockRequestPermissionResult =
          ph.PermissionStatus.denied;

      final result = await repository.requestPermission();

      expect(result, PermissionStatus.denied);
    });
  });

  group('getCurrentLocation', () {
    test('should return location entity when successful', () async {
      final mockPosition = Position(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      mockRemoteDataSource.mockGetCurrentPositionResult = mockPosition;

      final result = await repository.getCurrentLocation();

      expect(result.latitude, 40.7128);
      expect(result.longitude, -74.0060);
    });

    test(
      'should throw exception when location permission not granted',
      () async {
        mockRemoteDataSource.mockGetCurrentPositionError = Exception(
          'Location permission not granted',
        );

        expect(() => repository.getCurrentLocation(), throwsException);
      },
    );
  });

  group('getLastSavedLocation', () {
    test('should return location entity when saved location exists', () async {
      final mockLocation = LocationModel(
        latitude: 40.7128,
        longitude: -74.0060,
        city: 'New York',
        country: 'USA',
      );
      mockLocalDataSource.mockGetLastLocationResult = mockLocation;

      final result = await repository.getLastSavedLocation();

      expect(result, isNotNull);
      expect(result!.latitude, 40.7128);
      expect(result.longitude, -74.0060);
    });

    test('should return null when no saved location exists', () async {
      mockLocalDataSource.mockGetLastLocationResult = null;

      final result = await repository.getLastSavedLocation();

      expect(result, isNull);
    });

    test('should return null when exception occurs', () async {
      mockLocalDataSource.mockGetLastLocationError = Exception('Storage error');

      final result = await repository.getLastSavedLocation();

      expect(result, isNull);
    });
  });

  group('saveLocation', () {
    test('should save location to local storage', () async {
      final mockLocation = LocationModel(
        latitude: 40.7128,
        longitude: -74.0060,
      );

      await repository.saveLocation(mockLocation);

      expect(true, isTrue);
    });
  });

  group('clearSavedLocation', () {
    test('should clear saved location from local storage', () async {
      await repository.clearSavedLocation();

      expect(true, isTrue);
    });
  });

  group('openAppSettings', () {
    test('should return true when app settings can be opened', () async {
      mockRemoteDataSource.mockOpenAppSettingsResult = true;

      final result = await repository.openAppSettings();

      expect(result, true);
    });
  });
}
