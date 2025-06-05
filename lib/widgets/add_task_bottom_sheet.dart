import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'date_picker_bottom_sheet.dart';
//import '../services/firebase_task_service.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final String listName; // ← теперь указывается список, куда добавить задачу

  const AddTaskBottomSheet({super.key, this.listName = 'Входящие'});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedTag;
  DateTime? selectedDate;
  String? priority;

  @override
  void initState() {
    super.initState();

    // Автофокус после открытия модального окна
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Костыль для iOS Web: принудительная перерисовка после фокуса
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _descriptionController.dispose();
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
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.dialogBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: SingleChildScrollView(
            // Скролл появится только если нужно
            child: Column(
              mainAxisSize: MainAxisSize.min, // минимально нужная высота
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await showModalBottomSheet<DateTime>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => DatePickerBottomSheet(
                        initialDate: selectedDate,
                      ),
                    );
                    if (picked != null && mounted) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd.MM.yyyy HH:mm', 'ru').format(selectedDate!)
                          : 'Дата',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Заголовок задачи',
                    border: InputBorder.none,
                  ),
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
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.send, color: accentColor),
                      onPressed: () async {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          final task = Task(
                            title: text,
                            description: _descriptionController.text.trim(),
                            date: selectedDate,
                            tags: selectedTag != null ? [selectedTag!] : [],
                            listName: widget.listName,
                          );
                          if (!mounted) return;
                          Provider.of<TaskProvider>(context, listen: false).addTask(task);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
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