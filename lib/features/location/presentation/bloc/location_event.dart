import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class CheckPermissionStatus extends LocationEvent {
  const CheckPermissionStatus();
}

class RequestLocationPermission extends LocationEvent {
  const RequestLocationPermission();
}

class GetCurrentLocation extends LocationEvent {
  const GetCurrentLocation();
}

class GetLastSavedLocation extends LocationEvent {
  const GetLastSavedLocation();
}

class SkipToHome extends LocationEvent {
  const SkipToHome();
}

class RetryLocationRequest extends LocationEvent {
  const RetryLocationRequest();
}

class OpenAppSettings extends LocationEvent {
  const OpenAppSettings();
}
