// lib/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:funny_flower/models/user_model.dart';

// Импортируем все наши экраны
import 'package:funny_flower/screens/auth/login_screen.dart';
import 'package:funny_flower/screens/cart_screen.dart';
import 'package:funny_flower/screens/edit_profile_screen.dart';
import 'package:funny_flower/screens/home_screen.dart';
import 'package:funny_flower/screens/main_shell.dart';
import 'package:funny_flower/screens/onboarding_screen.dart';
import 'package:funny_flower/screens/product_detail_screen.dart';
import 'package:funny_flower/screens/profile_screen.dart';
import 'package:funny_flower/screens/quiz_screen.dart';
import 'package:funny_flower/screens/results_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: true,
    routes: [
      // --- ГЛАВНАЯ НАВИГАЦИЯ С BOTTOMNAVIGATIONBAR ---
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // 1. Главный экран и его дочерние роуты
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Роут для детальной страницы продукта
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),

              GoRoute(
                // Путь будет /home/results?effect=...
                path: 'results',
                builder: (context, state) {
                  // Извлекаем рекомендованный эффект из query-параметров
                  final effect = state.uri.queryParameters['effect'] ?? 'Все';
                  return ResultsScreen(recommendedEffect: effect);
                },
              ),
            ],
          ),

          // 2. Экран корзины
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),

          // 3. Экран профиля и его дочерний роут
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final user = state.extra as UserModel;
                  return EditProfileScreen(user: user);
                },
              ),
            ],
          ),
        ],
      ),

      // --- ОТДЕЛЬНЫЕ ЭКРАНЫ (БЕЗ BOTTOMNAVIGATIONBAR) ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
    ],

    // Обработчик ошибок
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Ошибка навигации')),
      body: Center(
        child: Text('Страница по адресу "${state.uri}" не найдена.\nОшибка: ${state.error}'),
      ),
    ),
  );
}