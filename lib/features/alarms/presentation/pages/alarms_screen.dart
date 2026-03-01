import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding_project/constants/app_style.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/gradient_wrapper.dart';
import '../../../../core/router/app_router.dart';
import '../../../location/business/entities/location_entity.dart';
import '../../../location/business/repositories/location_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../business/entities/alarm_entity.dart';
import '../bloc/alarm_bloc.dart';
import '../bloc/alarm_event.dart';
import '../bloc/alarm_state.dart';
import '../widgets/alarm_card.dart';
import '../widgets/location_card.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  LocationEntity? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    context.read<AlarmBloc>().add(const LoadAlarms());
  }

  Future<void> _loadLocation() async {
    try {
      final repository = sl<LocationRepository>();
      final location = await repository.getLastSavedLocation();
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }
    } catch (e) {
      // Location not available
    }
  }

  String _formatLocation() {
    if (_currentLocation == null) return 'No location selected';

    if (_currentLocation!.city != null && _currentLocation!.city!.isNotEmpty) {
      if (_currentLocation!.country != null &&
          _currentLocation!.country!.isNotEmpty) {
        return '${_currentLocation!.city}, ${_currentLocation!.country}';
      }
      return _currentLocation!.city!;
    }

    if (_currentLocation!.address != null &&
        _currentLocation!.address!.isNotEmpty) {
      return _currentLocation!.address!;
    }

    return '${_currentLocation!.latitude.toStringAsFixed(2)}°N, ${_currentLocation!.longitude.toStringAsFixed(2)}°E';
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationCard(
              locationName: _formatLocation(),
              onTap: () => context.go(AppRoutes.location),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Alarms', style: AppStyles.headlineMedium),
            ),
            Expanded(
              child: BlocBuilder<AlarmBloc, AlarmState>(
                builder: (context, state) {
                  if (state is AlarmLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryAccent,
                      ),
                    );
                  }

                  if (state is AlarmError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  if (state is AlarmLoaded) {
                    if (state.alarms.isEmpty) {
                      return const _EmptyAlarmsWidget();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = state.alarms[index];
                        return AlarmCard(
                          alarm: alarm,
                          onToggle: (enabled) {
                            context.read<AlarmBloc>().add(
                              ToggleAlarm(alarm.id, enabled),
                            );
                          },
                          onDelete: () {
                            context.read<AlarmBloc>().add(
                              DeleteAlarm(alarm.id),
                            );
                          },
                          onEdit: (editedAlarm) {
                            _showEditAlarmDialog(context, editedAlarm);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(context),
        backgroundColor: AppColors.primaryAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.buttonText, size: 28),
      ),
    );
  }

  Future<void> _showAddAlarmDialog(BuildContext context) async {
    final now = DateTime.now();
    DateTime selectedDate = DateTime(now.year, now.month, now.day, 8, 0);
    if (selectedDate.isBefore(now)) {
      selectedDate = selectedDate.add(const Duration(days: 1));
    }
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAccent,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null && mounted) {
      final timeResult = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryAccent,
                onPrimary: AppColors.textPrimary,
                surface: AppColors.cardDark,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (timeResult != null && mounted) {
        selectedDate = DateTime(
          result.year,
          result.month,
          result.day,
          timeResult.hour,
          timeResult.minute,
        );

        final now = DateTime.now();
        if (selectedDate.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot set an alarm in the past'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final alarm = AlarmEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          time: selectedDate,
          isEnabled: true,
        );

        context.read<AlarmBloc>().add(AddAlarm(alarm));
      }
    }
  }

  Future<void> _showEditAlarmDialog(
    BuildContext context,
    AlarmEntity alarm,
  ) async {
    DateTime selectedDateTime = alarm.time;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(alarm.time);

    final result = await showDatePicker(
      context: context,
      initialDate: alarm.time.isBefore(DateTime.now())
          ? DateTime.now()
          : alarm.time,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryAccent,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null && mounted) {
      final timeResult = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryAccent,
                onPrimary: AppColors.textPrimary,
                surface: AppColors.cardDark,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (timeResult != null && mounted) {
        selectedDateTime = DateTime(
          result.year,
          result.month,
          result.day,
          timeResult.hour,
          timeResult.minute,
        );

        final now = DateTime.now();
        if (selectedDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot set an alarm in the past'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final updatedAlarm = AlarmEntity(
          id: alarm.id,
          time: selectedDateTime,
          isEnabled: alarm.isEnabled,
          label: alarm.label,
        );

        context.read<AlarmBloc>().add(UpdateAlarm(updatedAlarm));
      }
    }
  }
}

class _EmptyAlarmsWidget extends StatelessWidget {
  const _EmptyAlarmsWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alarm_off, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'No alarms set',
            style: TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add an alarm',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
