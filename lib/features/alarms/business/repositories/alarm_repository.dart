import '../entities/alarm_entity.dart';

abstract class AlarmRepository {
  /// Get all alarms
  Future<List<AlarmEntity>> getAlarms();

  /// Add a new alarm
  Future<void> addAlarm(AlarmEntity alarm);

  /// Update an existing alarm
  Future<void> updateAlarm(AlarmEntity alarm);

  /// Delete an alarm
  Future<void> deleteAlarm(String id);

  /// Toggle alarm enabled/disabled
  Future<void> toggleAlarm(String id, bool isEnabled);
}
