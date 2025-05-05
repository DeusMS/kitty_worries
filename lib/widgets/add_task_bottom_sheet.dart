import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'date_picker_bottom_sheet.dart';
import '../services/firebase_task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final String listName; // ← теперь указывается список, куда добавить задачу

  const AddTaskBottomSheet({super.key, this.listName = 'Входящие'});

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

  void _showPriorityPicker() {}
  void _showTagPicker() {}

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    final prefix = target == today
        ? 'Сегодня'
        : target == tomorrow
            ? 'Завтра'
            : DateFormat('dd.MM.yyyy').format(date);

    return '$prefix ${DateFormat('HH:mm').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? Colors.orange : const Color(0xFF2979FF);
    final textStyle = theme.textTheme.bodyLarge;

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
            // Заголовок задачи
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Укажите задачу',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: theme.hintColor),
                    ),
                    style: textStyle?.copyWith(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: accentColor),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      final task = Task(
                        title: text,
                        date: selectedDate,
                        tags: selectedTag != null ? [selectedTag!] : [],
                        listName: widget.listName, // ← здесь сохраняем список
                      );
                      if (!mounted) return;
                      final provider = Provider.of<TaskProvider>(context, listen: false);
                      provider.addTask(task);

                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid != null) {
                        await FirebaseTaskService().addTask(uid, task);
                      }
                      if (context.mounted) {
                      Navigator.pop(context);
                      }
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Отображение выбранной даты
            if (selectedDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Дата: ${_formatDate(selectedDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ),

            const SizedBox(height: 8),

            // Кнопки: приоритет, теги, календарь
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.flag_outlined, size: 20, color: accentColor),
                  onPressed: _showPriorityPicker,
                ),
                IconButton(
                  icon: Icon(Icons.label_outline, size: 20, color: accentColor),
                  onPressed: _showTagPicker,
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, size: 20, color: accentColor),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => DatePickerBottomSheet(
                        initialDate: selectedDate,
                        onDateSelected: (picked) {
                          if (mounted) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
