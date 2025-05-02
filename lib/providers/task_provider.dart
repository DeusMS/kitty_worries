import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/firebase_task_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseTaskService _firebaseService = FirebaseTaskService();
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<String> get allTags {
    return _tasks.expand((task) => task.tags).toSet().toList();
  }

  void loadTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _firebaseService.getTasksStream(user.uid).listen((taskList) {
      _tasks.clear();
      _tasks.addAll(taskList);
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firebaseService.addTask(user.uid, task);
  }

  Future<void> updateTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || task.id == null) return;

    await _firebaseService.updateTask(user.uid, task.id!, task);
  }

  Future<void> deleteTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || task.id == null) return;

    await _firebaseService.deleteTask(user.uid, task.id!);
  }

  List<Task> tasksWithTag(String tag) =>
      _tasks.where((task) => task.tags.contains(tag)).toList();

  List<Task> tasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.date == null) return false;
      return task.date!.year == date.year &&
            task.date!.month == date.month &&
            task.date!.day == date.day;
    }).toList();
  }
}
