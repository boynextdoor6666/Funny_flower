// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:funny_flower/utils/quiz_data.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _totalScores = {};

  void _answerQuestion(Map<String, int> scores) {
    // Суммируем очки
    scores.forEach((key, value) {
      _totalScores[key] = (_totalScores[key] ?? 0) + value;
    });

    if (_currentQuestionIndex < quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    // Находим эффект с максимальным количеством очков
    if (_totalScores.isEmpty) {
      // Если пользователь как-то пропустил все вопросы
      context.go('/home');
      return;
    }
    final resultEffect = _totalScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Передаем результат на специальный экран или фильтруем главный
    // Пока просто перейдем на главный, а дальше сделаем экран результатов
    // Для этого нужно будет настроить роутинг
    print("Рекомендованный эффект: $resultEffect");
    context.go('/home/results?effect=$resultEffect');
  }

  @override
  Widget build(BuildContext context) {
    final question = quizQuestions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Вопрос ${_currentQuestionIndex + 1} из ${quizQuestions.length}')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1a232f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                question.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ...question.answers.map((answer) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(answer.icon),
                    label: Text(answer.text),
                    onPressed: () => _answerQuestion(answer.scores),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}