import 'package:flutter/material.dart';
import 'package:neoflex/src/quiz/screenshots/login_screen.dart';
import 'package:neoflex/src/quiz/screenshots/quiz.dart';
import 'package:neoflex/src/quiz/screenshots/registration_screen.dart';
import 'package:neoflex/src/quiz/screenshots/database_helper.dart';
import 'package:neoflex/src/quiz/screenshots/main_page.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/quiz': (context) => const QuizHomePage(),
        '/signup': (context) => const RegisterScreen(), // ← добавь это
      },
    );
  }
}