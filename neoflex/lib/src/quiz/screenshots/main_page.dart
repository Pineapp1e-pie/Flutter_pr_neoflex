import 'package:flutter/material.dart';

import 'article.dart';

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  // Пример данных
  final List<String> _articles = const [
    'Neoflex',
    'Учебный центр',
    'DevOps',
  ];
  final List<String> _statuses = const [
    'passed',
    'failed',
    'notStarted',
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'failed':
        return Color.fromRGBO(255, 101, 150, 1);
      case 'pass':
        return Color.fromRGBO(83, 228, 119, 1);
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель иконок
            Container(
              color: const Color.fromRGBO(41, 49, 52, 1),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  IconButton(
              icon: Image.asset(
                'assets/img/default.png', // Замени на свой путь
                width: 30,
                height: 30,
              ),
              onPressed: () {
                print('Изображение нажато!');
              },
            ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/img/neoflex.png', // Замени на свой путь
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      print('Изображение нажато!');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.card_giftcard, color: Colors.white),
                    onPressed: () {},
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '10',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Баннер "Проходи квизы и получай баллы"
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(204, 37, 91, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              alignment: Alignment.center,
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Зарабатывай ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    WidgetSpan(
                      child: Icon(Icons.favorite, size: 16, color: Colors.white),
                    ),
                    TextSpan(
                      text: ' и обменивай на мерч',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            // Список статей + кнопки
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final title = _articles[index];
                 final status = 'notStarted'; //TODO getStatus в тесте
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Статья с кнопкой перехода
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => ArticleDetailPage(
                                  articleKey:'article_$index', // Передай содержание статьи
                                  title: title, // Передай заголовок статьи
                                ),
                                ),
                                );
                                },
                                ),],),

                      const SizedBox(height: 4),
                      const Divider(thickness: 1),
                      const SizedBox(height: 12),

                      // Квиз с кнопкой перехода
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Квиз',
                            style: TextStyle(fontSize: 16),
                          ),



                  Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.play_arrow, size: 16),
                              onPressed: () {
                                // TODO: Навигация к экрану теста
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(thickness: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
