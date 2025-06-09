import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/models/user_order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ✅ ОБНОВЛЕННЫЕ МЕТОДЫ ДЛЯ ТОВАРОВ ---

  /// Получает товары для карусели "Выбор Шамана".
  /// Фильтрует по новому полю isShamanChoice.
  Stream<List<Product>> getShamanChoiceProducts() {
    return _db
        .collection('products')
        .where('isShamanChoice', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Получает список продуктов с возможностью фильтрации по эффекту.
  /// Также сортирует их по интенсивности, чтобы самые "сильные" были вверху.
  Stream<List<Product>> getProducts({String? effect}) {
    // Начинаем с базового запроса, который сортирует по интенсивности
    Query query = _db.collection('products').orderBy('intensity', descending: true);

    // Если передан эффект (и это не "Все"), добавляем фильтр
    if (effect != null && effect != 'Все') {
      query = query.where('effect', isEqualTo: effect);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Метод для получения одного продукта по ID остается без изменений.
  Future<Product> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    return Product.fromFirestore(doc);
  }

  // --- МЕТОДЫ ДЛЯ ЗАКАЗОВ И ПРОФИЛЯ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ ---

  Future<void> addOrder(UserOrder order) {
    return _db.collection('orders').add(order.toJson());
  }

  Stream<List<UserOrder>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserOrder.fromFirestore(doc))
        .toList());
  }

  Future<void> createUserProfile(UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toJson());
  }

  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> updateUserProfile(String uid, Map<String, Object?> data) {
    return _db.collection('users').doc(uid).update(data);
  }
}