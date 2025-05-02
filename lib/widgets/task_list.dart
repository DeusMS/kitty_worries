import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_bottom_sheet.dart';

class TaskList extends StatelessWidget {
  final DateTime selectedDate;
  final String? tagFilter;

  const TaskList({super.key, required this.selectedDate, this.tagFilter});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = tagFilter != null
        ? taskProvider.tasksWithTag(tagFilter!)
        : taskProvider.tasksForDate(selectedDate);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskItem(task: tasks[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddTaskBottomSheet(),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text('Добавить задачу', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}