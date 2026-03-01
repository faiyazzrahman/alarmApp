import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants/app_colors.dart';
import '../../business/entities/alarm_entity.dart';

class AlarmCard extends StatelessWidget {
  final AlarmEntity alarm;
  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final Function(AlarmEntity) onEdit;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time); // "7:10 pm"
  }

  String _formatDate(DateTime time) {
    return DateFormat('EEE, d MMM yyyy').format(time); // "Fri, 21 Mar 2025"
  }

  void _showAlarmOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AlarmOptionsSheet(
        alarm: alarm,
        onEdit: () {
          Navigator.pop(context);
          onEdit(alarm);
        },
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
        onToggle: (value) {
          Navigator.pop(context);
          onToggle(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAlarmOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.divider.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(61),
        ),
        child: Row(
          children: [
            // Time and date in same row
            Expanded(
              child: Row(
                children: [
                  Text(
                    _formatTime(alarm.time),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(width: 32),
                  const SizedBox(width: 16),
                  Text(
                    _formatDate(alarm.time),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Toggle switch
            Switch(
              value: alarm.isEnabled,
              onChanged: onToggle,
              activeColor: AppColors.primaryAccent,
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.cardLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlarmOptionsSheet extends StatelessWidget {
  final AlarmEntity alarm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggle;

  const _AlarmOptionsSheet({
    required this.alarm,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  String _formatDate(DateTime time) {
    return DateFormat('EEEE, MMMM d, yyyy').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Alarm time display
            Center(
              child: Column(
                children: [
                  Text(
                    _formatTime(alarm.time),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(alarm.time),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Options
            _OptionTile(
              icon: Icons.edit_outlined,
              title: 'Edit Alarm',
              onTap: onEdit,
            ),
            const SizedBox(height: 8),

            _OptionTile(
              icon: alarm.isEnabled ? Icons.alarm_off : Icons.alarm_on,
              title: alarm.isEnabled ? 'Disable Alarm' : 'Enable Alarm',
              onTap: () => onToggle(!alarm.isEnabled),
            ),
            const SizedBox(height: 8),

            _OptionTile(
              icon: Icons.delete_outline,
              title: 'Delete Alarm',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: onDelete,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryAccent).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: textColor ?? AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
