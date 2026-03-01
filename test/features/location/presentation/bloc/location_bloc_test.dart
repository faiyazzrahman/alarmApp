import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onboarding_project/features/location/presentation/bloc/location_bloc.dart';
import 'package:onboarding_project/features/location/presentation/bloc/location_event.dart';
import 'package:onboarding_project/features/location/presentation/bloc/location_state.dart';
import 'package:onboarding_project/features/location/business/usecases/check_permission_status_usecase.dart';
import 'package:onboarding_project/features/location/business/usecases/get_current_location_usecase.dart';
import 'package:onboarding_project/features/location/business/usecases/request_location_permission_usecase.dart';
import 'package:onboarding_project/features/location/business/repositories/location_repository.dart';
import 'package:onboarding_project/features/location/business/entities/location_entity.dart';
import 'package:onboarding_project/features/location/data/repositories/location_repository_impl.dart';
import 'package:onboarding_project/features/location/data/datasources/location_remote_datasource.dart';
import 'package:onboarding_project/features/location/data/datasources/location_local_datasource.dart';
import 'package:onboarding_project/features/location/data/models/location_model.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

// Test fixtures
class FakeLocationRemoteDataSource implements LocationRemoteDataSource {
  ph.PermissionStatus permissionStatus = ph.PermissionStatus.denied;
  bool locationServiceEnabled = true;
  Position? mockPosition;
  Exception? throwError;

  @override
  Future<ph.PermissionStatus> checkPermission() async => permissionStatus;

  @override
  Future<ph.PermissionStatus> requestPermission() async => permissionStatus;

  @override
  Future<Position> getCurrentPosition() async {
    if (throwError != null) {
      throw throwError!;
    }
    return mockPosition ??
        Position(
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
  }

  @override
  Future<bool> isLocationServiceEnabled() async => locationServiceEnabled;

  @override
  Future<bool> openAppSettings() async => true;
}

class FakeLocationLocalDataSource implements LocationLocalDataSource {
  LocationModel? savedLocation;

  @override
  Future<LocationModel?> getLastLocation() async => savedLocation;

  @override
  Future<void> saveLastLocation(LocationModel location) async {
    savedLocation = location;
  }

  @override
  Future<void> clearLastLocation() async {
    savedLocation = null;
  }
}

void main() {
  late LocationRepositoryImpl repository;
  late FakeLocationRemoteDataSource fakeRemoteDataSource;
  late FakeLocationLocalDataSource fakeLocalDataSource;
  late CheckPermissionStatusUseCase checkPermissionStatus;
  late RequestLocationPermissionUseCase requestPermission;
  late GetCurrentLocationUseCase getCurrentLocation;

  setUp(() {
    fakeRemoteDataSource = FakeLocationRemoteDataSource();
    fakeLocalDataSource = FakeLocationLocalDataSource();
    repository = LocationRepositoryImpl(
      remoteDataSource: fakeRemoteDataSource,
      localDataSource: fakeLocalDataSource,
    );
    checkPermissionStatus = CheckPermissionStatusUseCase(
      repository: repository,
    );
    requestPermission = RequestLocationPermissionUseCase(
      repository: repository,
    );
    getCurrentLocation = GetCurrentLocationUseCase(repository: repository);
  });

  group('LocationBloc', () {
    test('initial state should be LocationInitial', () {
      final bloc = LocationBloc(
        checkPermissionStatus: checkPermissionStatus,
        requestPermission: requestPermission,
        getCurrentLocation: getCurrentLocation,
        repository: repository,
      );

      expect(bloc.state, isA<LocationInitial>());
    });

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationPermissionRequired] when permission is denied',
      build: () {
        fakeRemoteDataSource.permissionStatus = ph.PermissionStatus.denied;
        return LocationBloc(
          checkPermissionStatus: checkPermissionStatus,
          requestPermission: requestPermission,
          getCurrentLocation: getCurrentLocation,
          repository: repository,
        );
      },
      act: (bloc) => bloc.add(const CheckPermissionStatus()),
      expect: () => [isA<LocationLoading>(), isA<LocationPermissionRequired>()],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationError] when GetCurrentLocation fails',
      build: () {
        fakeRemoteDataSource.permissionStatus = ph.PermissionStatus.granted;
        fakeRemoteDataSource.throwError = Exception(
          'Location service disabled',
        );
        return LocationBloc(
          checkPermissionStatus: checkPermissionStatus,
          requestPermission: requestPermission,
          getCurrentLocation: getCurrentLocation,
          repository: repository,
        );
      },
      act: (bloc) => bloc.add(const GetCurrentLocation()),
      expect: () => [isA<LocationLoading>(), isA<LocationError>()],
    );

    blocTest<LocationBloc, LocationState>(
      'emits [LocationLoading, LocationPermissionRequired] when request permission is denied',
      build: () {
        fakeRemoteDataSource.permissionStatus = ph.PermissionStatus.denied;
        return LocationBloc(
          checkPermissionStatus: checkPermissionStatus,
          requestPermission: requestPermission,
          getCurrentLocation: getCurrentLocation,
          repository: repository,
        );
      },
      act: (bloc) => bloc.add(const RequestLocationPermission()),
      expect: () => [isA<LocationLoading>(), isA<LocationPermissionRequired>()],
    );
  });
}
