import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository repository;

  GetCurrentLocationUseCase({required this.repository});

  Future<LocationEntity> call() async {
    return await repository.getCurrentLocation();
  }
}
