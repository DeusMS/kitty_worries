import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<void> addTask(String uid, Task task) async {
    await _userTasksRef(uid).add(task.toMap());
  }

  Future<void> updateTask(String uid, String taskId, Task task) async {
    await _userTasksRef(uid).doc(taskId).update(task.toMap());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _userTasksRef(uid).doc(taskId).delete();
  }

  Stream<List<Task>> getTasksStream(String uid) {
    return _userTasksRef(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final task = Task.fromMap(doc.data());
        task.id = doc.id;
        return task;
      }).toList();
    });
  }
}