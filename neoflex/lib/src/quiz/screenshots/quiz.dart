import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neoflex/src/quiz/screenshots/main_page.dart';
import 'package:neoflex/src/quiz/screenshots/article.dart';
import 'package:neoflex/src/quiz/screenshots/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizFormPage extends StatefulWidget {
  final String articleKey;
  final String title;

  const QuizFormPage({super.key, required this.articleKey, required this.title});

  @override
  State<QuizFormPage> createState() => _QuizFormPageState();
}

class _QuizFormPageState extends State<QuizFormPage> {
  List<dynamic> _questions = [];
  final Map<int, int?> _answers = {};
  String _email ="";
  int? _userId;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadDataFromDatabase();
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/data/quiz_data.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _questions = jsonData[widget.articleKey] ?? [];
    });
  }
  Future<void> _loadDataFromDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;// получаем email
    final db = DatabaseHelper.instance;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (users.isNotEmpty) {
      final userId = users.first['id'];
      print('User found: id = $userId');
    } else {
      print('No user found for email $_email');
    }
    setState(() {
      _email =email!;
      _userId = users.first['id'];
    });
  }
  void _submitQuiz() async {

    if (_userId == null) return; // Перенесено в начало

    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      final correct = _questions[i]['correct'];
      if (_answers[i] == correct) {
        correctCount++;
      }
    }

    final db = await DatabaseHelper.instance.database;
    // Получаем старое значение по articleKey
    final List<Map<String, dynamic>> existing = await db.query(
      'quiz_results',
      where: 'articleKey = ? AND user_id = ?',
      whereArgs: [widget.articleKey, _userId],
      limit: 1,
    );



    int previousHearts = 0;
    if (existing.isNotEmpty) {
      previousHearts = existing.first['hearts'] ?? 0;
    }

    int delta = correctCount - previousHearts;
    int addedHearts = delta > 0 ? delta : 0;

    String status;
    String textRes;
    String neoflexImg;

    if ((correctCount / _questions.length) * 100 <= 20) {
      textRes = "За что ты так со мной?";
      neoflexImg = "assets/img/sad_robot.png";
      status = "failed";
      addedHearts = -1;
      _audioPlayer.play(AssetSource('sounds/fail.mp3'), volume: 0.8) ;
    } else {
      textRes = "Был уверен, что не подведешь!";
      neoflexImg = "assets/img/heart_robot.png";
      status = "passed";
      _audioPlayer.play(AssetSource('sounds/pass.mp3'), volume: 0.8) ;
    }

    // Обновим общие очки
    await DatabaseHelper.instance.saveQuizResult(_email,addedHearts);

    final userId = _userId;
    if (userId == null) return; // или покажи ошибку


    // Сохраним/обновим лучший результат
    if (existing.isEmpty) {
      await db.insert('quiz_results', {
        'user_id': userId,  // Сохраняем user_id
        'articleKey': widget.articleKey,
        'hearts': correctCount,
      });


    } else if (correctCount > previousHearts) {
      await db.update(
        'quiz_results',
        {'hearts': correctCount},
        where: 'user_id = ? AND articleKey = ?',
        whereArgs: [userId, widget.articleKey],
      );
    }

    Navigator.pop(context, {
      'articleKey': widget.articleKey,
      'status': status,
      'hearts': addedHearts,
    });

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correctCount из ${_questions.length}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              // Иконка сердечек
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    addedHearts >= 0 ? '+$addedHearts' : '-1',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Icon(Icons.favorite,  color: Color.fromRGBO(204, 37, 91, 1) ),
                  const SizedBox(width: 6),
                ],
              ),
              const SizedBox(height: 20),

              // Сообщение
              Text(
                textRes,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Кнопки: К статье и На главную
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(204, 37, 91, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),),),
                    onPressed: () {
                      Navigator.pop(context); // Закрыть диалог
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailPage(
                              title: widget.title,
                              articleKey: widget.articleKey,

                          ),
                        ),
                      );

                    },
                    child: const Text('К статье'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(204, 37, 91, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),),),
                    onPressed: () {
                      Navigator.pop(context);},
                    child: const Text('На главную'),
                  ),
                ],
              ),
              // Картинка
              Padding(
                padding: const EdgeInsets.only(top: 20), // сдвинь вверх/вниз
                child: Image.asset(
                  neoflexImg,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              )

            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromRGBO(41, 49, 52, 1),
          title: Text('Квиз: ${widget.title}',style: const TextStyle(color: Colors.white))),
      backgroundColor: Colors.white,
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length + 1,
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(204, 37, 91, 1),
              foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),),),
              onPressed: _submitQuiz,
              child: const Text('Отправить'),
            );
          }

          final question = _questions[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ${question['question']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(question['options'].length, (i) {
                return RadioListTile<int>(
                  title: Text(question['options'][i]),
                  value: i,
                  groupValue: _answers[index],
                    activeColor:   Color.fromRGBO(204, 37, 91, 1),
                  onChanged: (value) {
                    setState(() {
                      _answers[index] = value;
                    });
                  },
                );
              }),
              const Divider(height: 32),
            ],
          );
        },
      ),
    );
  }
}
