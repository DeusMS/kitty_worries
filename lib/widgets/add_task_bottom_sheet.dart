import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? selectedTag;
  DateTime? selectedDate;
  String? priority;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showPriorityPicker() {
    // TODO: реализовать выбор приоритета
  }

  void _showTagPicker() {
    // TODO: реализовать выбор тега
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Укажите задачу',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      final task = Task(
                        title: text,
                        date: selectedDate,
                        tags: selectedTag != null ? [selectedTag!] : [],
                      );
                      if (!mounted) return;
                      Provider.of<TaskProvider>(context, listen: false).addTask(task);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (selectedDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(selectedDate!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 20),
                  onPressed: _showPriorityPicker,
                ),
                IconButton(
                  icon: const Icon(Icons.label_outline, size: 20),
                  onPressed: _showTagPicker,
                ),
                Builder(
                  builder: (newContext) => IconButton(
                    icon: const Icon(Icons.event_outlined, size: 20),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: newContext,
                        locale: const Locale('ru', 'RU'),
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate == null) return;

                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime == null) return;

                      final fullDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      if (mounted) {
                        setState(() => selectedDate = fullDateTime);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
