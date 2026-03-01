import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboarding_project/core/services/logger_service.dart';
import 'location_event.dart';
import 'location_state.dart';
import '../../business/usecases/check_permission_status_usecase.dart';
import '../../business/usecases/get_current_location_usecase.dart';
import '../../business/usecases/request_location_permission_usecase.dart';
import '../../business/repositories/location_repository.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final CheckPermissionStatusUseCase checkPermissionStatus;
  final RequestLocationPermissionUseCase requestPermission;
  final GetCurrentLocationUseCase getCurrentLocation;
  final LocationRepository repository;
  final LoggerService _logger = LoggerService();

  LocationBloc({
    required this.checkPermissionStatus,
    required this.requestPermission,
    required this.getCurrentLocation,
    required this.repository,
  }) : super(LocationInitial()) {
    on<CheckPermissionStatus>(_onCheckPermissionStatus);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<GetLastSavedLocation>(_onGetLastSavedLocation);
    on<SkipToHome>(_onSkipToHome);
    on<RetryLocationRequest>(_onRetryLocationRequest);
    on<OpenAppSettings>(_onOpenAppSettings);
  }

  Future<void> _onCheckPermissionStatus(
    CheckPermissionStatus event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading(message: 'Checking permissions...'));

    try {
      final status = await checkPermissionStatus();
      _logger.debug('Permission status: $status', tag: 'LocationBloc');

      if (status.isGranted) {
        add(const GetLastSavedLocation());
      } else {
        emit(LocationPermissionRequired(status: status));
      }
    } catch (e) {
      _logger.error(
        'Failed to check permissions',
        tag: 'LocationBloc',
        error: e,
      );
      emit(LocationError(message: 'Failed to check permissions: $e'));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading(message: 'Requesting permission...'));

    try {
      final status = await requestPermission();
      _logger.debug('Request permission result: $status', tag: 'LocationBloc');

      if (status.isGranted) {
        add(const GetCurrentLocation());
      } else {
        emit(
          LocationPermissionRequired(
            status: status,
            errorMessage: _getPermissionErrorMessage(status),
          ),
        );
      }
    } catch (e) {
      _logger.error(
        'Failed to request permission',
        tag: 'LocationBloc',
        error: e,
      );
      emit(LocationError(message: 'Failed to request permission: $e'));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading(message: 'Getting your location...'));

    try {
      final location = await getCurrentLocation();
      _logger.info(
        'Location obtained: ${location.latitude}, ${location.longitude}',
        tag: 'LocationBloc',
      );
      emit(LocationLoaded(location: location));
    } catch (e) {
      _logger.error('Failed to get location', tag: 'LocationBloc', error: e);
      emit(
        LocationError(message: 'Failed to get location: $e', canRetry: true),
      );
    }
  }

  Future<void> _onGetLastSavedLocation(
    GetLastSavedLocation event,
    Emitter<LocationState> emit,
  ) async {
    try {
      final savedLocation = await repository.getLastSavedLocation();
      if (savedLocation != null) {
        _logger.info('Using saved location from cache', tag: 'LocationBloc');
        emit(LocationLoaded(location: savedLocation, isFromCache: true));
      } else {
        _logger.debug(
          'No saved location, getting current location',
          tag: 'LocationBloc',
        );
        add(const GetCurrentLocation());
      }
    } catch (e) {
      _logger.warning(
        'Error getting saved location, falling back to current',
        tag: 'LocationBloc',
        error: e,
      );
      add(const GetCurrentLocation());
    }
  }

  void _onSkipToHome(SkipToHome event, Emitter<LocationState> emit) {
    emit(state);
  }

  Future<void> _onRetryLocationRequest(
    RetryLocationRequest event,
    Emitter<LocationState> emit,
  ) async {
    add(const RequestLocationPermission());
  }

  Future<void> _onOpenAppSettings(
    OpenAppSettings event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading(message: 'Opening settings...'));
    try {
      await repository.openAppSettings();
      _logger.info('App settings opened', tag: 'LocationBloc');
      emit(
        const LocationPermissionRequired(
          status: PermissionStatus.denied,
          errorMessage: 'Please enable location permission in settings',
        ),
      );
    } catch (e) {
      _logger.error(
        'Failed to open app settings',
        tag: 'LocationBloc',
        error: e,
      );
      emit(LocationError(message: 'Failed to open settings: $e'));
    }
  }

  String _getPermissionErrorMessage(PermissionStatus status) {
    if (status.isPermanentlyDenied) {
      return 'Location permission is permanently denied. Please enable it in app settings.';
    }
    return 'Location permission is required to use this feature.';
  }
}
