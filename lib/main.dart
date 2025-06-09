// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:funny_flower/app_router.dart';      // Ваш роутер
import 'package:funny_flower/providers/cart_provider.dart'; // <-- НОВЫЙ ИМПОРТ
import 'package:funny_flower/services/auth_service.dart';   // Ваш сервис аутентификации
import 'package:funny_flower/services/firestore_service.dart'; // Ваш сервис Firestore
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Этот файл генерируется FlutterFire CLI

void main() async {
  // Убеждаемся, что все биндинги Flutter инициализированы перед запуском асинхронных операций
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем Firebase с конфигурацией для текущей платформы
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Запускаем наше приложение
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем MultiProvider, чтобы предоставить доступ к нашим сервисам
    // и провайдерам состояния всем виджетам ниже по дереву.
    return MultiProvider(
      providers: [
        // --- СЕРВИСЫ (ОБЫЧНЫЕ PROVIDER) ---
        // Предоставляем экземпляр AuthService
        Provider<AuthService>(create: (_) => AuthService()),
        // Предоставляем экземпляр FirestoreService
        Provider<FirestoreService>(create: (_) => FirestoreService()),

        // --- ПРОВАЙДЕРЫ СОСТОЯНИЯ (CHANGENOTIFIERPROVIDER) ---
        // ✅ ДОБАВЛЕН CartProvider.
        // Мы используем ChangeNotifierProvider, так как CartProvider будет
        // уведомлять виджеты об изменениях (добавление/удаление товаров).
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Funny Flower',
        debugShowCheckedModeBanner: false, // Убираем дебаг-ленту в углу

        // Настраиваем темную тему приложения
        theme: ThemeData.dark().copyWith(
          // Использование copyWith для более точной настройки
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurple,
            secondary: Colors.tealAccent, // Пример вторичного цвета для кнопок
          ),
          scaffoldBackgroundColor: const Color(0xFF121212), // Основной фон
          // Используем кастомный шрифт Google Fonts для всего текста
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),

        // Подключаем конфигурацию роутинга из нашего файла app_router.dart
        routerConfig: AppRouter.router,
      ),
    );
  }
}