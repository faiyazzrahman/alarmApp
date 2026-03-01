import '../entities/alarm_entity.dart';
import '../repositories/alarm_repository.dart';

class GetAlarmsUseCase {
  final AlarmRepository repository;

  GetAlarmsUseCase({required this.repository});

  Future<List<AlarmEntity>> call() async {
    return await repository.getAlarms();
  }
}
