import '../entities/alarm_entity.dart';
import '../repositories/alarm_repository.dart';

class UpdateAlarmUseCase {
  final AlarmRepository repository;

  UpdateAlarmUseCase({required this.repository});

  Future<void> call(AlarmEntity alarm) async {
    return await repository.updateAlarm(alarm);
  }
}
