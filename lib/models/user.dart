import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      uid: id,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }

  static AppUser fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
} 
