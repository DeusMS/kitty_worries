import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'time_picker_bottom_sheet.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;

  const DatePickerBottomSheet({
    super.key,
    this.initialDate,
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late DateTime selectedDate;
  late DateTime focusedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    focusedDate = selectedDate;
  }

  void _apply() {
    Navigator.pop(context, selectedDate);
  }

  void _pickTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TimePickerBottomSheet(
        initialTime: selectedDate,
        onTimeSelected: (time) {
          setState(() {
            selectedDate = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              time.hour,
              time.minute,
            );
          });
        },
      ),
    );
  }

  void _setQuickDate(DateTime date) {
    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        selectedDate.hour,
        selectedDate.minute,
      );
      focusedDate = selectedDate;
    });
  }

  DateTime _nextMonday() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final daysToAdd = (DateTime.monday - weekday + 7) % 7;
    return now.add(Duration(days: daysToAdd == 0 ? 7 : daysToAdd));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;
    final accentColor = isDark ? Colors.orange : const Color(0xFF2979FF);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена', style: textTheme.bodyMedium),
              ),
              Text('Дата', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _apply,
                child: Text('Применить', style: TextStyle(color: accentColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Быстрые кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickButton('Сегодня', DateTime.now(), accentColor),
              _quickButton('Завтра', DateTime.now().add(const Duration(days: 1)), accentColor),
              _quickButton('Следующий Понедельник', _nextMonday(), accentColor),
            ],
          ),

          const SizedBox(height: 12),

          TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: focusedDate,
            selectedDayPredicate: (day) =>
                day.year == selectedDate.year &&
                day.month == selectedDate.month &&
                day.day == selectedDate.day,
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDate = DateTime(
                  selected.year,
                  selected.month,
                  selected.day,
                  selectedDate.hour,
                  selectedDate.minute,
                );
                focusedDate = focused;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.arrow_back_ios_new, color: accentColor),
              rightChevronIcon: Icon(Icons.arrow_forward_ios, color: accentColor),
              titleTextStyle: TextStyle(color: textTheme.bodyLarge?.color),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withAlpha(128)),
              ),
              todayTextStyle: textTheme.bodyMedium!,
              selectedDecoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: textTheme.bodyMedium!,
              defaultTextStyle: textTheme.bodyMedium!,
              outsideTextStyle: textTheme.bodySmall!.copyWith(color: theme.hintColor),
            ),
          ),

          const SizedBox(height: 16),

          ListTile(
            leading: Icon(Icons.access_time, color: accentColor),
            title: Text('Срок исполнения', style: textTheme.bodyLarge),
            trailing: Text(
              DateFormat('HH:mm').format(selectedDate),
              style: textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }

  Widget _quickButton(String label, DateTime date, Color color) {
    final isSelected = selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            backgroundColor: isSelected ? color : color.withAlpha(25),
            foregroundColor: isSelected ? Colors.white : color,
            textStyle: const TextStyle(fontSize: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _setQuickDate(date),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
