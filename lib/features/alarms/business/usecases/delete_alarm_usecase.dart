import '../repositories/alarm_repository.dart';

class DeleteAlarmUseCase {
  final AlarmRepository repository;

  DeleteAlarmUseCase({required this.repository});

  Future<void> call(String alarmId) async {
    return await repository.deleteAlarm(alarmId);
  }
}
