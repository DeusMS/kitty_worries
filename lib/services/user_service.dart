import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static String get uid => _auth.currentUser!.uid;

  static Future<void> updateUserName(String name) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  static Future<void> uploadAvatar(File file) async {
    final ref = _storage.ref().child('avatars/$uid.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).set({
      'photoUrl': url,
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
  
  static Future<List<AppUser>> getAllUsers() async {
    final currentUid = _auth.currentUser?.uid;

    final query = await _firestore.collection('users').get();

    return query.docs
        .map((doc) => AppUser.fromMap(doc.id, doc.data()))
        .where((user) => user.uid != currentUid)
        .toList();
  }
}
