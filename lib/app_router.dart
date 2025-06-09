// lib/app_router.dart

import 'package:flutter/material.dart'; // Нужен для Scaffold в errorBuilder
import 'package:go_router/go_router.dart';

// Импортируем все наши экраны
import 'package:funny_flower/screens/auth/login_screen.dart';
import 'package:funny_flower/screens/cart_screen.dart';
import 'package:funny_flower/screens/home_screen.dart';
import 'package:funny_flower/screens/main_shell.dart';
import 'package:funny_flower/screens/onboarding_screen.dart';
import 'package:funny_flower/screens/product_detail_screen.dart';
import 'package:funny_flower/screens/profile_screen.dart';

class AppRouter {
  static final router = GoRouter(
    // Начинаем с вводных экранов. В будущем можно добавить логику
    // для проверки, видел ли пользователь их уже.
    initialLocation: '/onboarding',

    // Включаем логирование для легкой отладки роутинга
    debugLogDiagnostics: true,

    routes: [
      // --- ГЛАВНАЯ НАВИГАЦИЯ С BOTTOMNAVIGATIONBAR ---
      // ShellRoute создает общую оболочку (MainShell) для дочерних роутов.
      // Все они будут отображаться внутри Scaffold с нижней панелью.
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // 1. Главный экран
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            // Вложенный роут для детальной страницы товара.
            // Он будет открываться ПОВЕРХ MainShell, но будет иметь доступ
            // ко всем провайдерам, так как находится в том же дереве.
            routes: [
              GoRoute(
                // Путь относительный, поэтому без слеша: /home/product/:id
                path: 'product/:id',
                builder: (context, state) {
                  // Извлекаем ID товара из параметров пути
                  final productId = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
          ),

          // 2. Экран корзины
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),

          // 3. Экран профиля
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // --- ОТДЕЛЬНЫЕ ЭКРАНЫ (БЕЗ BOTTOMNAVIGATIONBAR) ---
      // Эти роуты находятся на верхнем уровне и будут занимать весь экран.

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],

    // Обработчик ошибок: если go_router не найдет путь, он покажет этот экран.
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Ошибка навигации')),
      body: Center(
        child: Text('Страница по адресу "${state.uri}" не найдена.\nОшибка: ${state.error}'),
      ),
    ),
  );
}