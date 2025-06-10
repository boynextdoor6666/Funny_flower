// lib/models/quiz_model.dart
import 'package:flutter/material.dart';

class QuizQuestion {
  final String text;
  final List<QuizAnswer> answers;

  QuizQuestion({required this.text, required this.answers});
}

class QuizAnswer {
  final String text;
  final IconData? icon; // Для визуальных ответов
  final Map<String, int> scores; // Какой эффект сколько очков получает

  QuizAnswer({required this.text, this.icon, required this.scores});
}