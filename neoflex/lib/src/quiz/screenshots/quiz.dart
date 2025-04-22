import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neoflex/src/quiz/screenshots/main_page.dart';
import 'package:neoflex/src/quiz/screenshots/article.dart';

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

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/data/quiz_data.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _questions = jsonData[widget.articleKey] ?? [];
    });
  }

  void _submitQuiz() {
    int correctCount = 0;
    String textRes;
    String neoflexImg;
    int hearts = 0;

    for (int i = 0; i < _questions.length; i++) {
      final correct = _questions[i]['correct'];
      if (_answers[i] == correct) {
        correctCount++;
      }
    }

    final int percent = ((correctCount / _questions.length) * 100).round();
    final String status;
    if (percent <= 20) {
      textRes = "За что ты так со мной?";
      neoflexImg = "assets/img/sad_robot.png";
      hearts = -1;
      status="failed";
    } else {
      textRes = "Был уверен, что не подведешь!";
      neoflexImg = "assets/img/heart_robot.png";
      hearts = correctCount;
      status="passed";
    }
    Navigator.pop(context, {
      'articleKey': widget.articleKey,
      'status': status,
      'hearts': hearts,
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
                    hearts >= 0 ? '+$hearts' : '-1',
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
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
        title: Text('Квиз: ${widget.title}', style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
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
