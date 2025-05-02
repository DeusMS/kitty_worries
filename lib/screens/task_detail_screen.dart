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
  List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _title = widget.existingTask!.title;
      _description = widget.existingTask!.description;
      _date = widget.existingTask!.date;
      _priority = widget.existingTask!.priority;
      _tags = [...widget.existingTask!.tags];
    } else {
      _title = '';
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newTask = Task(
        id: widget.existingTask?.id,
        title: _title,
        description: _description,
        date: _date,
        priority: _priority,
        isCompleted: widget.existingTask?.isCompleted ?? false,
        tags: _tags,
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

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Новая задача' : 'Редактировать'),
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
                validator: (val) => val == null || val.isEmpty ? 'Введите название' : null,
                onSaved: (val) => _title = val!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Описание'),
                onSaved: (val) => _description = val,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Срок'),
                subtitle: Text(_date != null
                    ? '${_date!.day}.${_date!.month}.${_date!.year}'
                    : 'Не задан'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _priority = val!),
                decoration: const InputDecoration(labelText: 'Приоритет'),
              ),
              const SizedBox(height: 24),
              Text('Метки', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 6,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                    },
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(hintText: 'Добавить метку'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final tag = _tagController.text.trim();
                      if (tag.isNotEmpty && !_tags.contains(tag)) {
                        setState(() {
                          _tags.add(tag);
                          _tagController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
