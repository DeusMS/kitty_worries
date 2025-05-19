import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart'; // <— добавь этот импорт

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Стрим, который сообщает — авторизован ли пользователь
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Регистрация нового пользователя
  Future<User?> signUp(String email, String password) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;
    if (user != null) {
      await _saveUserToFirestore(user); // ⬅️ сохраняем в Firestore
    }

    return user;
  }

  /// Вход существующего пользователя
  Future<User?> signIn(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;
    if (user != null) {
      await _saveUserToFirestore(user); // ⬅️ убеждаемся, что он есть в базе
    }

    return user;
  }

  /// Сохраняет пользователя в Firestore (если ещё не сохранён)
  Future<void> _saveUserToFirestore(User user) async {
  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await docRef.get();

  if (!doc.exists) {
    await docRef.set({
      'email': user.email ?? 'unknown',
      'createdAt': FieldValue.serverTimestamp(), // опционально
    });
    print('✅ User document created in Firestore');
  } else {
    print('ℹ️ User document already exists');
  }
}

  /// Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Текущий пользователь (если авторизован)
  User? get currentUser => _auth.currentUser;
}
