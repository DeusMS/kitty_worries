import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/list_service.dart';
import '../services/firebase_task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final List<String> _customLists = ['Входящие'];

  List<Task> get tasks => [..._tasks];
  List<String> get customLists => [..._customLists];

  List<String> get allTags {
    return _tasks
        .expand((task) => task.tags)
        .toSet()
        .toList();
  }

  void addTask(Task task) {
    _tasks.add(task);
    if (!_customLists.contains(task.listName)) {
      _customLists.add(task.listName);
    }
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && task.id != null) {
        FirebaseTaskService().updateTask(uid, task.id!, task);
      }
    }
  }

  void deleteTask(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.date == null) return false;
      return task.date!.year == date.year &&
            task.date!.month == date.month &&
            task.date!.day == date.day;
    }).toList();
  }

  List<Task> tasksForToday() {
    final today = DateTime.now();
    return _tasks.where((t) =>
        t.date != null &&
        t.date!.year == today.year &&
        t.date!.month == today.month &&
        t.date!.day == today.day).toList();
  }

  List<Task> tasksForNext7Days() {
    final now = DateTime.now();
    final week = now.add(const Duration(days: 7));
    return _tasks.where((t) =>
        t.date != null &&
        t.date!.isAfter(now.subtract(const Duration(days: 1))) &&
        t.date!.isBefore(week)).toList();
  }

  List<Task> tasksWithTag(String tag) {
    return _tasks.where((t) => t.tags.contains(tag)).toList();
  }

  List<Task> tasksInList(String listName) {
    return _tasks.where((t) => t.listName == listName).toList();
  }

  Future<void> loadTasks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firebaseTasks = await FirebaseTaskService().getTasks(uid);
    _tasks
      ..clear()
      ..addAll(firebaseTasks);

    notifyListeners();
  }

  Future<void> loadCustomLists() async {
    final lists = await ListService.getLists();
    _customLists
      ..clear()
      ..addAll(lists.toSet())
      ..insert(0, 'Входящие');
    notifyListeners();
  }

  Future<void> createList(String name) async {
    await ListService.createList(name);
    if (!_customLists.contains(name)) {
      _customLists.add(name);
      notifyListeners();
    }
  }

  Future<void> renameList(String oldName, String newName) async {
    await ListService.renameList(oldName, newName);
    final index = _customLists.indexOf(oldName);
    if (index != -1) {
      _customLists[index] = newName;
      notifyListeners();
    }
  }

  Future<void> deleteList(String name) async {
    await ListService.deleteList(name);
    _customLists.remove(name);
    _tasks.removeWhere((t) => t.listName == name);
    notifyListeners();
  }
}
