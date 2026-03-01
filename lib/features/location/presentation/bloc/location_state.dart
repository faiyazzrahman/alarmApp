import 'package:equatable/equatable.dart';
import '../../business/entities/location_entity.dart';
import '../../business/repositories/location_repository.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {
  final String message;

  const LocationLoading({this.message = 'Processing...'});

  @override
  List<Object> get props => [message];
}

class LocationPermissionRequired extends LocationState {
  final PermissionStatus status;
  final String? errorMessage;

  const LocationPermissionRequired({required this.status, this.errorMessage});

  @override
  List<Object?> get props => [status, errorMessage];
}

class LocationLoaded extends LocationState {
  final LocationEntity location;
  final bool isFromCache;

  const LocationLoaded({required this.location, this.isFromCache = false});

  @override
  List<Object> get props => [location, isFromCache];
}

class LocationError extends LocationState {
  final String message;
  final bool canRetry;

  const LocationError({required this.message, this.canRetry = true});

  @override
  List<Object> get props => [message, canRetry];
}
