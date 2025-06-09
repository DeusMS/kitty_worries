import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart' as auth_service;
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_themes.dart';
import 'firebase_options.dart';

// Только для мобильных платформ
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
	
	// Перехватываем все Flutter ошибки
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  if (!kIsWeb) {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await NotificationService.init();
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'Напоминания',
          channelDescription: 'Уведомления о задачах',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
    await NotificationService.requestPermission();
  }

  await initializeDateFormatting('ru_RU', null);
  tz.initializeTimeZones();

  runApp(const TickTickCloneApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('📦 [FCM BACKGROUND] ${message.notification?.title}: ${message.notification?.body}');
  }
}

class TickTickCloneApp extends StatefulWidget {
  const TickTickCloneApp({super.key});

  @override
  State<TickTickCloneApp> createState() => _TickTickCloneAppState();
}

class _TickTickCloneAppState extends State<TickTickCloneApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _setupFCM();
    }
  }

  void _setupFCM() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      debugPrint('🔑 FCM Token: $token');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcm_token': token}, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null && kDebugMode) {
        debugPrint('📲 [FCM] ${notification.title}: ${notification.body}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Kitty Worries',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', 'RU'),
          ],
          home: StreamBuilder(
            stream: auth_service.AuthService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return const HomeScreen();
              }
              return const AuthScreen();
            },
          ),
        ),
      ),
    );
  }
}
