import 'dart:convert';
//import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
//import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class FcmV1Service {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  static const _jsonPath = 'lib/services/service-account.json';

  static Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    // Загружаем JSON
    final jsonStr = await rootBundle.loadString(_jsonPath);
    final jsonMap = json.decode(jsonStr);

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonMap);

    final client = await clientViaServiceAccount(accountCredentials, _scopes);

    final projectId = jsonMap['project_id'];

    final url =
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final message = {
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
        'android': {
          'priority': 'high',
        },
        'apns': {
          'headers': {
            'apns-priority': '10',
          }
        }
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
        debugPrint('❌ Ошибка при отправке: ${response.statusCode} ${response.body}');
      }
    }

    client.close();
  }
}
