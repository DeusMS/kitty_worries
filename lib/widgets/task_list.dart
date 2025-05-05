import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = widget.tasks.where((t) => !t.isCompleted).toList();
    final completed = widget.tasks.where((t) => t.isCompleted).toList();

    return widget.tasks.isEmpty
        ? const Center(child: Text('Нет задач'))
        : ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              ...active.map((task) => _buildCard(task, theme)),
              if (completed.isNotEmpty) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    'Выполнено (${completed.length})',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  trailing: Icon(
                    showCompleted ? Icons.expand_less : Icons.expand_more,
                    color: theme.iconTheme.color,
                  ),
                  onTap: () => setState(() => showCompleted = !showCompleted),
                ),
                if (showCompleted)
                  ...completed.map((task) => _buildCard(task, theme)),
              ],
            ],
          );
  }

  Widget _buildCard(Task task, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      child: Card(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: TaskItem(task: task),
        ),
      ),
    );
  }
}
