// lib/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String latinName;
  final String description;
  final double price;
  final String imageUrl;
  final String effect;
  final int intensity;
  final bool isShamanChoice;

  
  final double? dosageLight;      // Доза для легкого эффекта ("Знакомство")
  final double? dosageMedium;     // Доза для стандартного эффекта ("Стандарт")
  final double? dosageHeavy;      // Доза для глубокого эффекта ("Глубина")
  final String? dosageUnit;       // Единица измерения (например, "г", "шт", "мл")

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
    // ✅ 2. ДОБАВЛЕНЫ В КОНСТРУКТОР
    this.dosageLight,
    this.dosageMedium,
    this.dosageHeavy,
    this.dosageUnit,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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


      dosageLight: (data['dosageLight'] as num?)?.toDouble(),
      dosageMedium: (data['dosageMedium'] as num?)?.toDouble(),
      dosageHeavy: (data['dosageHeavy'] as num?)?.toDouble(),
      dosageUnit: data['dosageUnit'],
    );
  }
}