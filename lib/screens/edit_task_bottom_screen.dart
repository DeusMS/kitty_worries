import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/date_picker_bottom_sheet.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class TaskBottomSheet extends StatefulWidget {
  final Task task;

  const TaskBottomSheet({super.key, required this.task});

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  late Task _editedTask;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _editedTask = widget.task;
    _titleController = TextEditingController(text: _editedTask.title);
    _descriptionController = TextEditingController(text: _editedTask.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateTask({bool reschedule = false}) {
    final updated = _editedTask.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    Provider.of<TaskProvider>(context, listen: false).updateTask(updated);

    if (reschedule && updated.date != null && updated.date!.isAfter(DateTime.now())) {
      NotificationService.schedule(
        id: updated.hashCode,
        title: 'Напоминание',
        body: updated.title,
        scheduledDate: updated.date!,
      );
    }
  }

  void _pickDate() async {
    final newDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DatePickerBottomSheet(initialDate: _editedTask.date),
    );

    if (newDate != null) {
      setState(() {
        _editedTask = _editedTask.copyWith(date: newDate);
      });
      _updateTask(reschedule: true);
    }
  }

    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            color: theme.dialogBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_editedTask.date != null)
                  GestureDetector(
                    onTap: _pickDate,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('dd.MM.yyyy HH:mm', 'ru').format(_editedTask.date!), // только часы:минуты
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors. orange,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Заголовок задачи',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _updateTask(),
                ),
                TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Описание',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => _updateTask(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.label_outline, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: _editedTask.tags.map((tag) {
                          return Chip(label: Text(tag));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
