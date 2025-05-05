import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get uid => _auth.currentUser!.uid;

  static CollectionReference get _lists => _firestore.collection('lists');
  static CollectionReference _userTasks(String uid) =>
      _firestore.collection('users').doc(uid).collection('tasks');

  /// Создание нового списка
  static Future<void> createList(String name) async {
    await _lists.add({
      'name': name,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Получение всех списков пользователя
  static Future<List<String>> getLists() async {
    final query = await _lists.where('userId', isEqualTo: uid).get();
    return query.docs.map((doc) => doc['name'] as String).toList();
  }

  /// Переименование списка + обновление задач
  static Future<void> renameList(String oldName, String newName) async {
    // Обновить имя в списках
    final query = await _lists
        .where('userId', isEqualTo: uid)
        .where('name', isEqualTo: oldName)
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({'name': newName});
    }

    // Обновить listName у задач в users/{uid}/tasks
    final tasksQuery = await _userTasks(uid)
        .where('listName', isEqualTo: oldName)
        .get();

    for (var doc in tasksQuery.docs) {
      await doc.reference.update({'listName': newName});
    }
  }

  /// Удаление списка и всех его задач
  static Future<void> deleteList(String listName) async {
    // Удалить список из lists
    final query = await _lists
        .where('userId', isEqualTo: uid)
        .where('name', isEqualTo: listName)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    // Удалить задачи из users/{uid}/tasks
    final tasksQuery = await _userTasks(uid)
        .where('listName', isEqualTo: listName)
        .get();

    for (var doc in tasksQuery.docs) {
      await doc.reference.delete();
    }
  }
}
