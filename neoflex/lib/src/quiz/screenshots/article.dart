import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neoflex/src/quiz/screenshots/quiz.dart'; // Для rootBundle

/// Страница детального просмотра статьи
class ArticleDetailPage extends StatelessWidget {
  /// Ключ статьи, соответствует имени файла без расширения
  final String articleKey;
  final String title;

  const ArticleDetailPage({
    Key? key,
    required this.articleKey,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Используем AppBar с кнопкой назад
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(41, 49, 52, 1),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<String>(
        future: _loadArticleContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки статьи'));
          }
          final content = snapshot.data ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Содержимое статьи
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
              // Кнопка перехода к квизу была да всплыла
              ],
            ),
          );
        },
      ),
    );
  }

  /// Метод для загрузки содержимого статьи из assets/articles/{articleKey}.txt
  Future<String> _loadArticleContent() async {
    final path = 'assets/articles/$articleKey.txt';
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      debugPrint('Ошибка загрузки файла \$path: \$e');
      return 'Не удалось загрузить статью.';
    }
  }
}

/// В pubspec.yaml необходимо указать:
/// flutter:
///   assets:
///     - assets/articles/
