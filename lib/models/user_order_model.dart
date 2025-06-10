// lib/models/user_order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funny_flower/models/cart_item_model.dart';

/// Модель данных для одного завершенного заказа.
/// Этот класс описывает структуру документа, который хранится в коллекции 'orders' в Firestore.
class UserOrder {
  /// Уникальный идентификатор документа заказа в Firestore.
  final String id;

  /// ID пользователя (из Firebase Authentication), который сделал этот заказ.
  final String userId;

  /// Список товаров, которые были в этом заказе.
  final List<CartItem> items;

  /// Общая стоимость заказа.
  final double totalAmount;

  /// Дата и время, когда был сделан заказ.
  final DateTime orderDate;

  // ✅ 1. НОВЫЕ ПОЛЯ ДЛЯ ОТСЛЕЖИВАНИЯ ОПЛАТЫ
  /// Метод оплаты, выбранный пользователем (например, "Карта", "СБП").
  final String paymentMethod;
  /// Статус оплаты (например, "paid", "failed", "pending").
  final String paymentStatus;
  /// ID транзакции от платежной системы (необязательное поле).
  final String? transactionId;

  UserOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    // ✅ 2. ДОБАВЛЕНЫ В КОНСТРУКТОР
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
  });

  /// Метод для сериализации (преобразования) объекта UserOrder в Map для Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),

      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
    };
  }


  factory UserOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (data['items'] as List<dynamic>?)
          ?.map((itemData) => CartItem.fromJson(itemData as Map<String, dynamic>))
          .toList() ?? [], // Безопасная обработка пустого списка


      paymentMethod: data['paymentMethod'] ?? 'Неизвестно',
      paymentStatus: data['paymentStatus'] ?? 'pending', // По умолчанию "в ожидании"
      transactionId: data['transactionId'], // Может быть null
    );
  }
}