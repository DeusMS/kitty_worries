//import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../services/list_service.dart';
import '../services/firebase_task_service.dart';
//import '../services/fcm_service.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final List<String> _customLists = ['Входящие'];

  List<Task> get tasks => [..._tasks];
  List<String> get customLists => [..._customLists];

  List<String> get allTags {
    return _tasks.expand((task) => task.tags).toSet().toList();
  }

  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  List<Task> get incompleteTasks => _tasks.where((t) => !t.isCompleted).toList();

  List<Task> tasksWithTag(String tag) => _tasks.where((t) => t.tags.contains(tag)).toList();

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

  List<Task> tasksInList(String listName) =>
      _tasks.where((t) => t.listName == listName).toList();

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
    final lists = await ListService.getAccessibleLists();
    _customLists
      ..clear()
      ..addAll(lists.map((l) => l['name'] as String).toSet())
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

  Future<void> addTask(Task task) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final taskWithId = await FirebaseTaskService().addTask(uid, task);
      _tasks.add(taskWithId);
      notifyListeners();
      //await FcmService.sendTaskNotification('Задача создана', taskWithId);
      await scheduleNotification(taskWithId);
    }
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && task.id != null) {
        await FirebaseTaskService().updateTask(uid, task.id!, task);
        //await FcmService.sendTaskNotification('Задача обновлена', task);

        await NotificationService.cancel(task.hashCode);
        await scheduleNotification(task);
      }
    }
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && task.id != null) {
      await FirebaseTaskService().deleteTask(uid, task.id!);
      if (kIsWeb) {
        await NotificationService.cancel(task.hashCode);
        }
      //await FcmService.sendTaskNotification('Задача удалена', task);
      await NotificationService.cancel(task.hashCode);
    }
  }

  Future<void> loadTasksFromUserForList(String listName, String ownerId) async {
    final query = await FirebaseFirestore.instance
      .collection('users')
      .doc(ownerId) // ✅ не currentUser!
      .collection('tasks')
      .where('list', isEqualTo: listName)
      .get();
    _tasks.clear();
    _tasks.addAll(query.docs.map((doc) => Task.fromMap(doc.data())));
    notifyListeners();
  }

  Future<String?> getListIdByName(String name) async {
    final query = await FirebaseFirestore.instance
        .collection('lists')
        .where('name', isEqualTo: name)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  Future<List<String>> getSharedWithByListId(String id) async {
    final lists = await ListService.getAccessibleLists();
    final match = lists.firstWhere((list) => list['id'] == id, orElse: () => {});
    return List<String>.from(match['sharedWith'] ?? []);
  }
  Future<void> scheduleNotification(Task task) async {
    if (kDebugMode) {
      debugPrint("📦 scheduleNotification вызван: ${task.title}");
      debugPrint("📅 Дата задачи: ${task.date}");
      debugPrint("🕓 Сейчас: ${DateTime.now()}");
    }

    if (task.date == null || task.date!.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint("❌ Пропуск уведомления: дата не указана или в прошлом");
      }  
      return;
    }
    if (kIsWeb) {
      // Web → Telegram bot
      final url = Uri.parse("https://telegramm-bot-notification.onrender.com/notify");
      final payload = {
        "chat_id": 793549413,
        "text": task.title,
        "notify_at": task.date!.toUtc().toIso8601String(),
      };
      try {
        final res = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );
        if (res.statusCode == 200) {
          if (kDebugMode) {
            debugPrint("🔔 Уведомление отправлено через Telegram Bot");
          }
        } else {
          if (kDebugMode) {
            debugPrint("⚠️ Ошибка Telegram Bot: \${res.body}");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("❌ Telegram error: $e");
        }
      }
    } else {
      // Android/iOS → локальное уведомление
      await NotificationService.schedule(
        id: task.hashCode,
        title: 'Напоминание',
        body: task.title,
        scheduledDate: task.date!,
      );
    }
  }
}
