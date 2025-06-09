// lib/models/user_order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funny_flower/models/cart_item_model.dart';

// ИЗМЕНЕНО: Order -> UserOrder
class UserOrder {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;

  UserOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
    };
  }

  factory UserOrder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserOrder(
      id: doc.id,
      userId: data['userId'],
      totalAmount: data['totalAmount'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>)
          .map((itemData) => CartItem.fromJson(itemData))
          .toList(),
    );
  }
}