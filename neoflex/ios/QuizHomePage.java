import 'package:flutter/material.dart';

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  // Пример данных
  final List<String> _articles = const [
    'Название статьи 1',
    'Название статьи 2',
    'Название статьи 3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя панель иконок
            Container(
              color: Color.fromRGBO(59, 96, 160, 1),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _IconCircle(Icons.account_circle),
                  _IconCircle(Icons.settings),
                  _IconCircle(Icons.close),
                  _IconCircle(Icons.card_giftcard),
                  _IconCircleWithBadge(Icons.favorite, badgeCount: 10),
                ],
              ),
            ),

            // Баннер "Проходи квизы и получай баллы"
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Color.fromRGBO(59, 96, 160, 1),
                borderRadius: const BorderRadius.only(
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
                              // TODO: Навигация к экрану статьи
                            },
                          ),
                        ],
                      ),
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
                              color: Colors.grey[300],
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

// Круглая иконка без бейджа
class _IconCircle extends StatelessWidget {
  final IconData icon;
  const _IconCircle(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}

// Круглая иконка с бейджем
class _IconCircleWithBadge extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  const _IconCircleWithBadge(this.icon, {Key? key, required this.badgeCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _IconCircle(icon),
        if (badgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
