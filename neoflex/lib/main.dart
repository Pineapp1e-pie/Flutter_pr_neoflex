import 'package:flutter/material.dart';
import 'package:neoflex/src/screens/login_screen.dart';
import 'package:neoflex/src/screens/registration_screen.dart';
import 'package:neoflex/src/screens/database_helper.dart';
import 'package:neoflex/src/screens/after_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // Инициализация БД
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/register': (context) => const RegisterScreen(), // ← добавь это
      },
    );
  }
}