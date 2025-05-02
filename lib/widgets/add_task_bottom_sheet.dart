import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String? selectedTag;
  DateTime? selectedDate;
  String? priority;

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
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Что бы вы хотели сделать?',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 20),
                  onPressed: () {
                    _showPriorityPicker();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.label_outline, size: 20),
                  onPressed: () {
                    _showTagPicker();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.event_outlined, size: 20),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (!context.mounted || pickedDate == null) return;

                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (!context.mounted || pickedTime == null) return;

                    setState(() {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  },
                ),
                const Icon(Icons.notifications_outlined, size: 20),
                const Icon(Icons.more_horiz, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Высокий'),
              onTap: () => Navigator.pop(context, 'high'),
            ),
            ListTile(
              title: const Text('Средний'),
              onTap: () => Navigator.pop(context, 'medium'),
            ),
            ListTile(
              title: const Text('Низкий'),
              onTap: () => Navigator.pop(context, 'low'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && mounted) {
        setState(() {
          priority = value;
        });
      }
    });
  }

  void _showTagPicker() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tags = taskProvider.allTags;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: tags.map((tag) {
            return ListTile(
              title: Text(tag),
              onTap: () => Navigator.pop(context, tag),
            );
          }).toList(),
        );
      },
    ).then((value) {
      if (value != null && mounted) {
        setState(() {
          selectedTag = value;
        });
      }
    });
  }
}