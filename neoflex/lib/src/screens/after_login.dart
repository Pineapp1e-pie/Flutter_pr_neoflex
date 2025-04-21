import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экран друга'),
      ),
      body: const Center(
        child: Text(
          'Тут будет код друга',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
