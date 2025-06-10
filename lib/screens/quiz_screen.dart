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
    if (_totalScores.isEmpty) {
      context.go('/home');
      return;
    }
    final resultEffect = _totalScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    print("Рекомендованный эффект: $resultEffect");
    context.go('/home/results?effect=$resultEffect');
  }

  @override
  Widget build(BuildContext context) {
    final question = quizQuestions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Вопрос ${_currentQuestionIndex + 1} из ${quizQuestions.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Выйти из теста',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
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
                    // ✅✅✅ ВОТ ЗДЕСЬ ВСЕ ИЗМЕНЕНИЯ ✅✅✅
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      // Устанавливаем цвет текста и иконки
                      foregroundColor: Colors.cyanAccent,
                      // Делаем фон кнопки темным и полупрозрачным
                      backgroundColor: Colors.black.withOpacity(0.4),
                      // Добавляем стилизованную рамку
                      side: const BorderSide(color: Colors.cyanAccent, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      // Добавляем жирность к тексту
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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