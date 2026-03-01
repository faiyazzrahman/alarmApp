import '../repositories/alarm_repository.dart';

class ToggleAlarmUseCase {
  final AlarmRepository repository;

  ToggleAlarmUseCase({required this.repository});

  Future<void> call(String alarmId, bool isEnabled) async {
    return await repository.toggleAlarm(alarmId, isEnabled);
  }
}
