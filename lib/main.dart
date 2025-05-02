import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  runApp(const TickTickCloneApp());
}

class TickTickCloneApp extends StatelessWidget {
  const TickTickCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Kitty Worries',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          cardColor: Colors.white,
          primaryColor: const Color(0xFF2979FF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF5F5F7),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFF5F5F7),
            selectedItemColor: Color(0xFF2979FF),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2979FF),
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          listTileTheme: const ListTileThemeData(
            iconColor: Colors.black54,
            textColor: Colors.black87,
            dense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
        home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<TaskProvider>(context, listen: false).loadTasks();
              });
              return const HomeScreen();
            } else {
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}
