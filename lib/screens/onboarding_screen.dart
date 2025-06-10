import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart'; // ✅ 1. Импортируем плеер

class OnboardingScreen extends StatefulWidget { // ✅ 2. Преобразуем в StatefulWidget
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _audioPlayer = AudioPlayer(); // ✅ 3. Создаем экземпляр плеера

  @override
  void initState() {
    super.initState();
    // ✅ 4. Запускаем звук при инициализации экрана
    // Устанавливаем режим, чтобы звук не зацикливался
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    // Проигрываем звук из локальных ассетов
    _audioPlayer.play(AssetSource('audio/intro_sound.mp3'));
  }

  @override
  void dispose() {
    // ✅ 5. Освобождаем ресурсы плеера, когда экран уничтожается
    _audioPlayer.dispose();
    super.dispose();
  }

  // Функция для остановки звука и перехода
  void _onDone(context) {
    _audioPlayer.stop();
    GoRouter.of(context).go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Добро пожаловать в Funny Flower",
          body: "Откройте для себя мир мифических растений с волшебными свойствами.",
          image: Lottie.asset('assets/animations/flower_intro.json'),
          decoration: const PageDecoration(
            pageColor: Color(0xFF121212),
            titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
            bodyTextStyle: TextStyle(fontSize: 19.0, color: Colors.white70),
          ),
        ),
        PageViewModel(
          title: "Исследуйте каталог",
          body: "Найдите идеальное растение, которое подходит именно вам.",
          image: const Icon(Icons.search_rounded, size: 150, color: Colors.cyan),
          decoration: const PageDecoration(
            pageColor: Color(0xFF121212),
            titleTextStyle: TextStyle(color: Colors.white),
            bodyTextStyle: TextStyle(color: Colors.white70),
          ),
        ),
      ],
      // ✅ 6. Вызываем нашу функцию при нажатии "Начать"
      onDone: () => _onDone(context),
      // ✅ 7. Также останавливаем звук при пропуске
      onSkip: () => _onDone(context),
      // ✅ 8. Отслеживаем смену страниц, чтобы остановить звук
      onChange: (page) {
        if (page > 0) {
          _audioPlayer.stop();
        }
      },
      showSkipButton: true,
      skip: const Text("Пропустить", style: TextStyle(color: Colors.white)),
      next: const Icon(Icons.arrow_forward, color: Colors.white),
      done: const Text("Начать", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.secondary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }
}