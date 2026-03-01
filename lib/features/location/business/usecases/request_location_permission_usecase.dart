import '../repositories/location_repository.dart';

class RequestLocationPermissionUseCase {
  final LocationRepository repository;

  RequestLocationPermissionUseCase({required this.repository});

  Future<PermissionStatus> call() async {
    return await repository.requestPermission();
  }
}
