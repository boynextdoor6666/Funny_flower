import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Добро пожаловать в Funny Flower",
          body: "Откройте для себя мир мифических растений с волшебными свойствами.",
          image: Lottie.asset('assets/animations/flower_intro.json'), // ✅ JSON Анимация!
          decoration: const PageDecoration(
            pageColor: Color(0xFF121212),
            titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(fontSize: 19.0),
          ),
        ),
        PageViewModel(
          title: "Исследуйте каталог",
          body: "Найдите идеальное растение, которое подходит именно вам.",
          image: const Icon(Icons.search_rounded, size: 150, color: Colors.cyan),
          decoration: const PageDecoration(
            pageColor: Color(0xFF121212),
          ),
        ),
      ],
      onDone: () => context.go('/home'),
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