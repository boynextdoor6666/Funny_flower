// lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:funny_flower/providers/cart_provider.dart';
import 'package:funny_flower/widgets/animated_background.dart'; // <-- 1. ИМПОРТИРУЕМ НАШУ ОБЕРТКУ
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- 2. ОБОРАЧИВАЕМ ВСЕ В ANIMATEDBACKGROUND ---
    return AnimatedBackground(
      child: Scaffold(
        // --- 3. ДЕЛАЕМ ФОН ПРОЗРАЧНЫМ ---
        // Это обязательно, чтобы фон из AnimatedBackground был виден.
        backgroundColor: Colors.transparent,

        // Тело Scaffold остается прежним
        body: child,

        // --- 4. СТИЛИЗУЕМ BOTTOMNAVIGATIONBAR ---
        // Добавляем полупрозрачный фон и настраиваем цвета иконок,
        // чтобы они хорошо смотрелись на темном анимированном фоне.
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black.withOpacity(0.7), // Полупрозрачный фон
          type: BottomNavigationBarType.fixed, // Чтобы все иконки были видны
          unselectedItemColor: Colors.white60, // Цвет неактивных иконок
          selectedItemColor: Theme.of(context).colorScheme.secondary, // Цвет активной иконки

          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cart, ch) => Badge(
                  label: Text(cart.itemCount.toString()),
                  isLabelVisible: cart.itemCount > 0,
                  child: ch,
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Корзина',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }

  // Методы _calculateSelectedIndex и _onItemTapped остаются без изменений
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/cart')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/cart');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}