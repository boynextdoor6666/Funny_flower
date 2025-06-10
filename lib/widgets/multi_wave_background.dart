// lib/widgets/multi_wave_background.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Модель для хранения свойств каждой анимированной частицы
class _WaveParticle {
  late Offset position;
  final double size;
  final double speed;
  final double opacity;
  final double initialRotation;

  _WaveParticle({
    required this.position,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.initialRotation,
  });
}

class MultiWaveBackground extends StatefulWidget {
  final int numAnimations; // Количество анимаций, которое мы хотим видеть
  final Widget child;      // Контент, который будет поверх фона

  const MultiWaveBackground({
    Key? key,
    required this.child,
    this.numAnimations = 15, // По умолчанию создаем 15 анимаций
  }) : super(key: key);

  @override
  State<MultiWaveBackground> createState() => _MultiWaveBackgroundState();
}

class _MultiWaveBackgroundState extends State<MultiWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_WaveParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Длительность полного цикла анимации
    )..repeat(); // Запускаем анимацию в бесконечном цикле
  }

  void _initializeParticles(Size size) {
    // Инициализируем частицы только один раз
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < widget.numAnimations; i++) {
      _particles.add(
        _WaveParticle(
          position: Offset(
            _random.nextDouble() * size.width,
            _random.nextDouble() * size.height,
          ),
          size: _random.nextDouble() * 80 + 40, // Размер от 40 до 120
          speed: _random.nextDouble() * 20 + 10, // Скорость от 10 до 30
          opacity: _random.nextDouble() * 0.4 + 0.1, // Прозрачность от 0.1 до 0.5
          initialRotation: _random.nextDouble() * 2 * pi, // Начальный поворот
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder дает нам размеры экрана, чтобы правильно расположить частицы
    return LayoutBuilder(
      builder: (context, constraints) {
        // Получаем размеры доступного пространства
        final size = constraints.biggest;
        // Создаем частицы на основе этих размеров
        _initializeParticles(size);

        return Stack(
          children: [
            // Используем AnimatedBuilder для производительной анимации
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: _particles.map((p) {
                    // Рассчитываем новую позицию для каждой частицы
                    final newY = (p.position.dy - (_controller.value * p.speed)) % size.height;
                    // Если частица ушла за верхний край, она появится снизу
                    final currentY = newY < 0 ? size.height + newY : newY;

                    return Positioned(
                      left: p.position.dx - p.size / 2,
                      top: currentY - p.size / 2,
                      child: Transform.rotate(
                        angle: p.initialRotation,
                        child: Opacity(
                          opacity: p.opacity,
                          child: SizedBox(
                            width: p.size,
                            height: p.size,
                            child: Lottie.asset(
                              'assets/animations/wave.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            // Поверх всех анимаций рендерим дочерний виджет (ваш основной контент)
            widget.child,
          ],
        );
      },
    );
  }
}