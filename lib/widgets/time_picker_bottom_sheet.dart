import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerBottomSheet extends StatefulWidget {
  final DateTime initialTime;
  final void Function(TimeOfDay) onTimeSelected;

  const TimePickerBottomSheet({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.fromDateTime(widget.initialTime);
  }

  void _apply() {
    Navigator.pop(context);
    widget.onTimeSelected(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final textStyle = theme.textTheme.bodyLarge;

    return Container(
      height: 280,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена', style: textStyle),
              ),
              Text('Время', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _apply,
                child: Text('ОК', style: TextStyle(color: color)),
              ),
            ],
          ),
          const Divider(height: 1),

          // Cupertino time picker
          Expanded(
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: Duration(
                hours: _selectedTime.hour,
                minutes: _selectedTime.minute,
              ),
              onTimerDurationChanged: (Duration newDuration) {
                setState(() {
                  _selectedTime = TimeOfDay(
                    hour: newDuration.inHours,
                    minute: newDuration.inMinutes % 60,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
