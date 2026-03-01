import 'package:equatable/equatable.dart';

import '../../business/entities/alarm_entity.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlarms extends AlarmEvent {
  const LoadAlarms();
}

class AddAlarm extends AlarmEvent {
  final AlarmEntity alarm;

  const AddAlarm(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

class UpdateAlarm extends AlarmEvent {
  final AlarmEntity alarm;

  const UpdateAlarm(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

class DeleteAlarm extends AlarmEvent {
  final String id;

  const DeleteAlarm(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleAlarm extends AlarmEvent {
  final String id;
  final bool isEnabled;

  const ToggleAlarm(this.id, this.isEnabled);

  @override
  List<Object?> get props => [id, isEnabled];
}

class AlarmTriggered extends AlarmEvent {
  final String alarmId;

  const AlarmTriggered(this.alarmId);

  @override
  List<Object?> get props => [alarmId];
}
