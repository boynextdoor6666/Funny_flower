// lib/services/loyalty_service.dart
import 'package:flutter/material.dart';

// Модель для хранения данных о каждом ранге
class LoyaltyTier {
  final String name;
  final IconData icon;
  final Color color;
  final double discountPercent; // Скидка в процентах (e.g., 5 для 5%)
  final int nextLevelXp;       // Сколько очков нужно для следующего ранга

  LoyaltyTier({
    required this.name,
    required this.icon,
    required this.color,
    required this.discountPercent,
    required this.nextLevelXp,
  });
}

class LoyaltyService {
  // Определяем наши ранги и их пороги
  static final LoyaltyTier _neophyte = LoyaltyTier(name: 'Неофит', icon: Icons.brightness_7, color: Colors.grey, discountPercent: 0, nextLevelXp: 1000);
  static final LoyaltyTier _adept = LoyaltyTier(name: 'Адепт', icon: Icons.star_border, color: Colors.cyanAccent, discountPercent: 3, nextLevelXp: 5000);
  static final LoyaltyTier _alchemist = LoyaltyTier(name: 'Алхимик', icon: Icons.science_outlined, color: Colors.amberAccent, discountPercent: 5, nextLevelXp: 15000);
  static final LoyaltyTier _shaman = LoyaltyTier(name: 'Шаман', icon: Icons.auto_awesome, color: Colors.purpleAccent, discountPercent: 7, nextLevelXp: -1); // -1 означает максимальный уровень

  // Главный метод: по очкам опыта возвращает текущий ранг и его бонусы
  static LoyaltyTier getTierForXp(int xp) {
    if (xp >= 15000) return _shaman;
    if (xp >= 5000) return _alchemist;
    if (xp >= 1000) return _adept;
    return _neophyte;
  }
}