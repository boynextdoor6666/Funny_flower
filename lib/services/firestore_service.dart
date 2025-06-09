// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// ИЗМЕНЕНО: импортируем нашу переименованную модель
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // --- ИСПРАВЛЕННЫЙ МЕТОД ---
  // 1. Добавлено `async`
  // 2. Код внутри остался тем же, но теперь он корректен
  Future<Product> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    // 3. `async` функция автоматически "заворачивает" результат в Future,
    //    поэтому эта строка теперь тоже работает.
    return Product.fromFirestore(doc);
  }

  // --- ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ ЗАКАЗОВ ---
  // ИЗМЕНЕНО: Order -> UserOrder
  Future<void> addOrder(UserOrder order) {
    return _db.collection('orders').add(order.toJson());
  }

  // ИЗМЕНЕНО: Order -> UserOrder
  Stream<List<UserOrder>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
    // ИЗМЕНЕНО: Order -> UserOrder
        .map((doc) => UserOrder.fromFirestore(doc))
        .toList());
  }
}