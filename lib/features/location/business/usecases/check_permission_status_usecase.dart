import '../repositories/location_repository.dart';

class CheckPermissionStatusUseCase {
  final LocationRepository repository;

  CheckPermissionStatusUseCase({required this.repository});

  Future<PermissionStatus> call() async {
    return await repository.checkPermissionStatus();
  }
}
