// lib/widgets/animated_background.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Делаем фон самого Scaffold прозрачным, чтобы была видна анимация из Stack
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // --- 1. АНИМИРОВАННЫЙ ФОН ---
          // Он будет занимать все доступное пространство
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/wave.json', // Укажите путь к вашему файлу
              fit: BoxFit.cover,
            ),
          ),

          // --- 2. ГРАДИЕНТ-ЗАТЕМНЕНИЕ (Опционально, но рекомендуется) ---
          // Этот градиент делает фон темнее, чтобы текст и контент
          // на переднем плане были более читаемыми.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // --- 3. ВАШ ОСНОВНОЙ КОНТЕНТ ---
          // Поверх фона и градиента будет отображаться дочерний виджет
          // (например, ваш HomeScreen или ProfileScreen).
          child,
        ],
      ),
    );
  }
}