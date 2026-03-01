import 'package:equatable/equatable.dart';

class AlarmEntity extends Equatable {
  final String id;
  final DateTime time;
  final bool isEnabled;
  final String? label;
  final List<int> repeatDays; // 1-7 for Mon-Sun

  const AlarmEntity({
    required this.id,
    required this.time,
    this.isEnabled = true,
    this.label,
    this.repeatDays = const [],
  });

  AlarmEntity copyWith({
    String? id,
    DateTime? time,
    bool? isEnabled,
    String? label,
    List<int>? repeatDays,
  }) {
    return AlarmEntity(
      id: id ?? this.id,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  @override
  List<Object?> get props => [id, time, isEnabled, label, repeatDays];
}
