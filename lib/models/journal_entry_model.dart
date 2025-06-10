// lib/models/journal_entry_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;          // Уникальный ID записи (можно использовать doc.id)
  final String userId;      // ID пользователя, которому принадлежит запись
  final String productId;   // ID связанного продукта
  final String productName; // Название продукта на момент записи
  final String imageUrl;    // URL изображения продукта на момент записи
  final Timestamp timestamp; // Дата и время "путешествия"
  final String intention;   // Намерение пользователя
  final String dosage;      // Дозировка (в виде строки, т.к. может быть "2 шт", "1.5 г" и т.д.)
  final String report;      // Текстовый отчет об опыте
  final int intensity;      // Оценка интенсивности от 1 до 10

  JournalEntry({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.timestamp,
    required this.intention,
    required this.dosage,
    required this.report,
    required this.intensity,
  });


  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'intention': intention,
      'dosage': dosage,
      'report': report,
      'intensity': intensity,
    };
  }


  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id, // ID берем прямо из документа
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? 'Неизвестный продукт',
      imageUrl: data['imageUrl'] ?? '',
      // Для Timestamp важно проверить, что он не null, иначе используем текущее время
      timestamp: data['timestamp'] ?? Timestamp.now(),
      intention: data['intention'] ?? 'Намерение не указано',
      dosage: data['dosage'] ?? 'Дозировка не указана',
      report: data['report'] ?? 'Отчет пуст.',
      intensity: (data['intensity'] as int?) ?? 0,
    );
  }
}