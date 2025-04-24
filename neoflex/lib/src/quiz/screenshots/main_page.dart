import 'package:flutter/material.dart';
import 'package:neoflex/src/quiz/screenshots/quiz.dart';
import 'package:neoflex/src/quiz/screenshots/shop_page.dart';
import 'package:neoflex/src/quiz/screenshots/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';// путь подставь свой


import 'article.dart';

/// Главная страница теперь StatefulWidget, чтобы хранить текущее количество сердечек и статусы квизов
class QuizHomePage extends StatefulWidget {
  @override
  _QuizHomePageState createState() => _QuizHomePageState();
}



class _QuizHomePageState extends State<QuizHomePage> {
  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
    _loadStatuses();
  }

  int heartsCurrent=0;
  // Список статей (ключи совпадают с JSON)
  final List<String> _articles = const [
    'Neoflex',
    'Учебный центр',
    'DevOps',
  ];

  Future<void> _loadDataFromDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email'); // получаем email
    final db = DatabaseHelper.instance;
    int points = await db.getPoints(email!); // передаем email в запрос

    setState(() {
      heartsCurrent = points;
    });
  }
    // Статусы пройденных/непройденных квизов, ключ — articleKey
     Map<String, String> _statuses = {};
  Future<void> _loadStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    // Загружаем все сохраненные статусы из SharedPreferences
    setState(() {
      _statuses = prefs.getKeys().fold<Map<String, String>>({}, (Map<String, String> map, String key) {
        map[key] = prefs.getString(key) ?? '';
        return map;
      });
    });
  }

    Color getStatusColor(String articleKey) {
      final status = _statuses[articleKey] ?? '';
      _saveStatusToSharedPreferences(articleKey, status);
      switch (status) {
        case 'failed':
          return const Color.fromRGBO(255, 101, 150, 0.50);
        case 'passed':
          return const Color.fromRGBO(83, 228, 119, 0.50);
        default:
          return Colors.grey[300]!;
      }
    }
  Future<void> _saveStatusToSharedPreferences(String articleKey, String status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(articleKey, status); // Сохраняем статус по ключу articleKey
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
                      icon: Image.asset(
                        'assets/img/neoflex.png', // Замени на свой путь
                        width: 30,
                        height: 30,
                      ),
                      onPressed: () {
                        print('Изображение нажато!');
                      },
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.white),
                          onPressed: () async {
                            // Ожидание закрытия ShopPage и получение обновленных сердец
                            final updatedPoints = await Navigator.push<int>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ShopPage(),
                              ),
                            );
                            // Обновляем количество сердец, если оно не null
                            if (updatedPoints != null) {
                              setState(() {
                                heartsCurrent = updatedPoints; // Обновляем количество сердец на текущей странице
                              });
                            }
                          },

                        ),
                        Positioned(
                          top: 3,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(204, 37, 91, 1),
                              shape: BoxShape.circle,

                            ),
                            child:  Text(
                              "$heartsCurrent",
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
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      WidgetSpan(
                        child: Icon(
                            Icons.favorite, size: 16, color: Colors.white),
                      ),
                      TextSpan(
                        text: ' и обменивай на мерч',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
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
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ArticleDetailPage(
                                          articleKey: 'article_$index',
                                          title: title,
                                        ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0); // Слева направо
                                      const end = Offset.zero;
                                      const curve = Curves.ease;

                                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                      final offsetAnimation = animation.drive(tween);

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },


                            ),
                          ],),
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
                                color: getStatusColor('article_$index'),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.play_arrow, size: 16),
                                onPressed: _statuses['article_$index'] == 'passed'
                                  ? null : () async {
                                  // Запуск квиза и ожидание результата
                                  final result = await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizFormPage(articleKey: 'article_$index', title: title),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      // Обновляем общее число сердечек
                                      heartsCurrent += result['hearts'] as int;
                                      // Сохраняем статус данного квиза
                                      _statuses[result['articleKey'] as String] = result['status'] as String;
                                    });
                                  }
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


