import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import '../models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class FcmService {
  static const String _jsonPath = 'lib/services/service-account.json';
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  static Future<void> sendTaskNotification(String title, Task task) async {
    final token = await _getTargetToken();
    if (token.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ FCM Token не найден');
      }
      return;
    }

    final jsonStr = await rootBundle.loadString(_jsonPath);
    final jsonMap = json.decode(jsonStr);
    final credentials = ServiceAccountCredentials.fromJson(jsonMap);
    final client = await clientViaServiceAccount(credentials, _scopes);

    final projectId = jsonMap['project_id'];
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': task.title,
        },
        'data': {
          'taskId': task.id ?? '',
          'listName': task.listName,
        },
        'android': {
          'priority': 'high',
        },
      }
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('✅ Уведомление отправлено: ${response.body}');
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ Ошибка при отправке уведомления: ${response.statusCode} ${response.body}');
      }
    }

    client.close();

    // 🔔 Показываем локальное уведомление, только если не в фокусе
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'reminder_channel',
          title: title,
          body: task.title,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } else {
      if (kDebugMode) {
        debugPrint('ℹ️ Приложение в фокусе — локальное уведомление не отображено');
      }
    }
  }

  static Future<String> _getTargetToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return '';

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || !data.containsKey('fcm_token')) return '';

    return data['fcm_token'] as String;
  }
}
