// lib/models/user_order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funny_flower/models/cart_item_model.dart';

/// Модель данных для одного завершенного заказа.
/// Этот класс описывает структуру документа, который хранится в коллекции 'orders' в Firestore.
class UserOrder {
  /// Уникальный идентификатор документа заказа в Firestore.
  final String id;

  /// ID пользователя (из Firebase Authentication), который сделал этот заказ.
  /// Используется для поиска всех заказов конкретного пользователя.
  final String userId;

  /// Список товаров, которые были в этом заказе.
  /// Хранит копии данных о товарах на момент покупки.
  final List<CartItem> items;

  /// Общая стоимость заказа.
  final double totalAmount;

  /// Дата и время, когда был сделан заказ.
  final DateTime orderDate;

  UserOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
  });

  /// Метод для сериализации (преобразования) объекта UserOrder в Map.
  /// Этот Map затем используется для записи данных в Firestore.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      // Преобразуем каждый объект CartItem в списке в его JSON-представление.
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      // DateTime преобразуется в специальный тип Timestamp, который использует Firestore.
      'orderDate': Timestamp.fromDate(orderDate),
    };
  }

  /// Фабричный конструктор для десериализации (создания) объекта UserOrder из документа Firestore.
  /// Принимает `DocumentSnapshot`, который является "снимком" данных из базы.
  factory UserOrder.fromFirestore(DocumentSnapshot doc) {
    // Получаем данные документа в виде Map.
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserOrder(
      // ID документа берем напрямую из `doc.id`, а не из поля внутри документа.
      id: doc.id,
      userId: data['userId'],
      totalAmount: (data['totalAmount'] as num).toDouble(), // Безопасное приведение к double
      // Преобразуем Timestamp из Firestore обратно в привычный DateTime.
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      // Преобразуем список Map'ов из Firestore в список объектов CartItem.
      items: (data['items'] as List<dynamic>)
          .map((itemData) => CartItem.fromJson(itemData))
          .toList(),
    );
  }
}