// lib/utils/quiz_data.dart
import 'package:flutter/material.dart';
import 'package:funny_flower/models/quiz_model.dart';

final List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    text: 'Что ты ищешь в своем путешествии?',
    answers: [
      QuizAnswer(
        text: 'Глубокое самопознание',
        icon: Icons.psychology_alt,
        scores: {'Мистический': 3, 'Целебный': 1},
      ),
      QuizAnswer(
        text: 'Творческий прорыв',
        icon: Icons.lightbulb_outline,
        scores: {'Вдохновляющий': 3, 'Бодрящий': 1},
      ),
      QuizAnswer(
        text: 'Полное расслабление',
        icon: Icons.self_improvement,
        scores: {'Расслабляющий': 3},
      ),
      QuizAnswer(
        text: 'Яркие и осознанные сны',
        icon: Icons.bedtime_outlined,
        scores: {'Сновидческий': 3, 'Расслабляющий': 1},
      ),
    ],
  ),
  QuizQuestion(
    text: 'Какому пейзажу ты доверяешь свою тайну?',
    answers: [
      QuizAnswer(
        text: 'Ночной лес под звездами',
        icon: Icons.forest,
        scores: {'Мистический': 2, 'Сновидческий': 1},
      ),
      QuizAnswer(
        text: 'Залитые солнцем горные вершины',
        icon: Icons.filter_hdr,
        scores: {'Бодрящий': 3},
      ),
      QuizAnswer(
        text: 'Тихая заводь, окутанная туманом',
        icon: Icons.water,
        scores: {'Расслабляющий': 2, 'Целебный': 1},
      ),
      QuizAnswer(
        text: 'Библиотека со старинными книгами',
        icon: Icons.menu_book,
        scores: {'Вдохновляющий': 2},
      ),
    ],
  ),
  // Добавьте еще 1-2 вопроса по аналогии
];