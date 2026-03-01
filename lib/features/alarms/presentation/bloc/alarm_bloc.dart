import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../business/repositories/alarm_repository.dart';
import '../../business/usecases/get_alarms_usecase.dart';
import '../../business/usecases/add_alarm_usecase.dart';
import '../../business/usecases/delete_alarm_usecase.dart';
import '../../business/usecases/toggle_alarm_usecase.dart';
import '../../business/usecases/update_alarm_usecase.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepository repository;
  final NotificationService notificationService;
  final GetAlarmsUseCase getAlarmsUseCase;
  final AddAlarmUseCase addAlarmUseCase;
  final DeleteAlarmUseCase deleteAlarmUseCase;
  final ToggleAlarmUseCase toggleAlarmUseCase;
  final UpdateAlarmUseCase updateAlarmUseCase;

  AlarmBloc({
    required this.repository,
    required this.notificationService,
    required this.getAlarmsUseCase,
    required this.addAlarmUseCase,
    required this.deleteAlarmUseCase,
    required this.toggleAlarmUseCase,
    required this.updateAlarmUseCase,
  }) : super(AlarmInitial()) {
    notificationService.onAlarmTriggered = _onAlarmTriggeredFromNotification;

    on<LoadAlarms>(_onLoadAlarms);
    on<AddAlarm>(_onAddAlarm);
    on<UpdateAlarm>(_onUpdateAlarm);
    on<DeleteAlarm>(_onDeleteAlarm);
    on<ToggleAlarm>(_onToggleAlarm);
    on<AlarmTriggered>(_onAlarmTriggered);
  }

  void _onAlarmTriggeredFromNotification(String alarmId) {
    add(AlarmTriggered(alarmId));
  }

  Future<void> _onAlarmTriggered(
    AlarmTriggered event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await toggleAlarmUseCase(event.alarmId, false);
      await notificationService.cancelAlarm(event.alarmId);
      add(const LoadAlarms());
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _onLoadAlarms(LoadAlarms event, Emitter<AlarmState> emit) async {
    emit(AlarmLoading());
    try {
      final alarms = await getAlarmsUseCase();
      alarms.sort((a, b) => a.time.compareTo(b.time));
      emit(AlarmLoaded(alarms));
    } catch (e) {
      emit(AlarmError('Failed to load alarms: $e'));
    }
  }

  Future<void> _onAddAlarm(AddAlarm event, Emitter<AlarmState> emit) async {
    try {
      await addAlarmUseCase(event.alarm);
      if (event.alarm.isEnabled) {
        await notificationService.scheduleAlarm(event.alarm);
      }
      add(const LoadAlarms());
    } catch (e) {
      emit(AlarmError('Failed to add alarm: $e'));
    }
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await updateAlarmUseCase(event.alarm);
      if (event.alarm.isEnabled) {
        await notificationService.scheduleAlarm(event.alarm);
      } else {
        await notificationService.cancelAlarm(event.alarm.id);
      }
      add(const LoadAlarms());
    } catch (e) {
      emit(AlarmError('Failed to update alarm: $e'));
    }
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await notificationService.cancelAlarm(event.id);
      await deleteAlarmUseCase(event.id);
      add(const LoadAlarms());
    } catch (e) {
      emit(AlarmError('Failed to delete alarm: $e'));
    }
  }

  Future<void> _onToggleAlarm(
    ToggleAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await toggleAlarmUseCase(event.id, event.isEnabled);

      final alarms = await getAlarmsUseCase();
      final alarm = alarms.firstWhere((a) => a.id == event.id);

      if (event.isEnabled) {
        await notificationService.scheduleAlarm(alarm);
      } else {
        await notificationService.cancelAlarm(event.id);
      }

      add(const LoadAlarms());
    } catch (e) {
      emit(AlarmError('Failed to toggle alarm: $e'));
    }
  }
}
