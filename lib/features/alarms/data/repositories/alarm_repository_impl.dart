import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../business/entities/alarm_entity.dart';
import '../../business/repositories/alarm_repository.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final SharedPreferences sharedPreferences;
  static const String _kAlarmsKey = 'alarms';

  AlarmRepositoryImpl({required this.sharedPreferences});

  @override
  Future<List<AlarmEntity>> getAlarms() async {
    final jsonString = sharedPreferences.getString(_kAlarmsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => _alarmFromJson(json)).toList();
  }

  @override
  Future<void> addAlarm(AlarmEntity alarm) async {
    final alarms = await getAlarms();
    alarms.add(alarm);
    await _saveAlarms(alarms);
  }

  @override
  Future<void> updateAlarm(AlarmEntity alarm) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);
    if (index != -1) {
      alarms[index] = alarm;
      await _saveAlarms(alarms);
    }
  }

  @override
  Future<void> deleteAlarm(String id) async {
    final alarms = await getAlarms();
    alarms.removeWhere((a) => a.id == id);
    await _saveAlarms(alarms);
  }

  @override
  Future<void> toggleAlarm(String id, bool isEnabled) async {
    final alarms = await getAlarms();
    final index = alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      alarms[index] = alarms[index].copyWith(isEnabled: isEnabled);
      await _saveAlarms(alarms);
    }
  }

  Future<void> _saveAlarms(List<AlarmEntity> alarms) async {
    final jsonList = alarms.map((a) => _alarmToJson(a)).toList();
    await sharedPreferences.setString(_kAlarmsKey, jsonEncode(jsonList));
  }

  Map<String, dynamic> _alarmToJson(AlarmEntity alarm) {
    return {
      'id': alarm.id,
      'time': alarm.time.toIso8601String(),
      'isEnabled': alarm.isEnabled,
      'label': alarm.label,
      'repeatDays': alarm.repeatDays,
    };
  }

  AlarmEntity _alarmFromJson(Map<String, dynamic> json) {
    return AlarmEntity(
      id: json['id'],
      time: DateTime.parse(json['time']),
      isEnabled: json['isEnabled'] ?? true,
      label: json['label'],
      repeatDays: List<int>.from(json['repeatDays'] ?? []),
    );
  }
}
