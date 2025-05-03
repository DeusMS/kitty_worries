import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? existingTask;

  const TaskDetailScreen({super.key, this.existingTask});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  DateTime? _date;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _title = task.title;
      _description = task.description;
      _date = task.date;
      _priority = task.priority;
    } else {
      _title = '';
    }
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final newTask = Task(
        id: widget.existingTask?.id,
        title: _title,
        description: _description,
        date: _date,
        priority: _priority,
        isCompleted: widget.existingTask?.isCompleted ?? false,
        tags: widget.existingTask?.tags ?? [],
      );

      final provider = Provider.of<TaskProvider>(context, listen: false);
      if (widget.existingTask == null) {
        provider.addTask(newTask);
      } else {
        provider.updateTask(newTask);
      }

      Navigator.pop(context);
    }
  }

  Future<DateTime?> showTickTickDateTimePicker(
    BuildContext context, {
    DateTime? initialDateTime,
  }) {
    DateTime tempPicked = initialDateTime ?? DateTime.now();

    return showModalBottomSheet<DateTime>(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Выберите дату и время',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: initialDateTime ?? DateTime.now(),
                  mode: CupertinoDatePickerMode.dateAndTime,
                  use24hFormat: true,
                  onDateTimeChanged: (value) {
                    tempPicked = value;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(tempPicked),
                    child: const Text('ОК'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Новая задача' : 'Редактировать задачу'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Введите название' : null,
                onSaved: (val) => _title = val!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Описание'),
                onSaved: (val) => _description = val,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Дата и время'),
                subtitle: Text(
                  _date != null
                      ? '${_date!.day}.${_date!.month}.${_date!.year} ${_date!.hour.toString().padLeft(2, '0')}:${_date!.minute.toString().padLeft(2, '0')}'
                      : 'Не выбрано',
                ),
                onTap: () async {
                  final result = await showTickTickDateTimePicker(context, initialDateTime: _date);
                  if (result != null) {
                    setState(() => _date = result);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                items: TaskPriority.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
                decoration: const InputDecoration(labelText: 'Приоритет'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}