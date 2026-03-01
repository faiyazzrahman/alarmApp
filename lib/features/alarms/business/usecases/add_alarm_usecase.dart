import '../entities/alarm_entity.dart';
import '../repositories/alarm_repository.dart';

class AddAlarmUseCase {
  final AlarmRepository repository;

  AddAlarmUseCase({required this.repository});

  Future<void> call(AlarmEntity alarm) async {
    return await repository.addAlarm(alarm);
  }
}
