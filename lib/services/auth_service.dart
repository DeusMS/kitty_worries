import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Стрим, который сообщает — авторизован ли пользователь
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Регистрация нового пользователя
  Future<User?> signUp(String email, String password) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credentials.user;
  }

  /// Вход существующего пользователя
  Future<User?> signIn(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credentials.user;
  }

  /// Выход из аккаунта
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Текущий пользователь (если авторизован)
  User? get currentUser => _auth.currentUser;
}