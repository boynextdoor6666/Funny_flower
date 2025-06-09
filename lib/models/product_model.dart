// lib/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String latinName;
  final String description; // Описание эффектов, происхождения
  final double price;
  final String imageUrl;
  final String effect;     // <-- НОВОЕ ПОЛЕ: Основной эффект
  final int intensity;     // <-- НОВОЕ ПОЛЕ: Интенсивность (1-5)
  final bool isShamanChoice; // <-- НОВОЕ ПОЛЕ: Для карусели

  Product({
    required this.id,
    required this.name,
    required this.latinName,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.effect,
    required this.intensity,
    required this.isShamanChoice,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      latinName: data['latinName'] ?? 'Nomen Nescio',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      effect: data['effect'] ?? 'Неизвестный',
      intensity: (data['intensity'] as int?) ?? 1,
      isShamanChoice: data['isShamanChoice'] ?? false,
    );
  }
}