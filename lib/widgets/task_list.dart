import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_bottom_sheet.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? const Center(child: Text('Нет задач'))
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: tasks.length + 1,
            itemBuilder: (context, index) {
              if (index < tasks.length) {
                return TaskItem(task: tasks[index]);
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddTaskBottomSheet(),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20, color: Colors.blue),
                      label: const Text(
                        'Добавить задачу',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                );
              }
            },
          );
  }
}
