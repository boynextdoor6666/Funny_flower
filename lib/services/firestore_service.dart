// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funny_flower/models/journal_entry_model.dart'; // ✅ НОВЫЙ ИМПОРТ
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/models/user_order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- МЕТОДЫ ДЛЯ ПРОДУКТОВ ---

  Stream<List<Product>> getShamanChoiceProducts() {
    return _db
        .collection('products')
        .where('isShamanChoice', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getProducts({String? effect}) {
    Query query = _db.collection('products').orderBy('intensity', descending: true);
    if (effect != null && effect != 'Все') {
      query = query.where('effect', isEqualTo: effect);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    return Product.fromFirestore(doc);
  }

  // --- МЕТОДЫ ДЛЯ ПРОФИЛЯ ПОЛЬЗОВАТЕЛЯ ---

  Future<void> createUserProfile(UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toJson());
  }

  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> updateUserProfile(String uid, Map<String, Object?> data) {
    return _db.collection('users').doc(uid).update(data);
  }

  // --- МЕТОДЫ ДЛЯ ЗАКАЗОВ ---

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

  // ✅ --- МЕТОДЫ ДЛЯ ДНЕВНИКА ПУТЕШЕСТВИЙ (JOURNAL) --- ✅

  /// Получает поток всех записей дневника для конкретного пользователя,
  /// отсортированных по дате (сначала новые).
  Stream<List<JournalEntry>> getJournalEntries(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('journal') // Используем подколлекцию для записей
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => JournalEntry.fromFirestore(doc))
        .toList());
  }

  /// Сохраняет (создает или обновляет) запись в дневнике.
  /// ID записи должен быть уже сгенерирован и находиться внутри объекта `entry`.
  Future<void> setJournalEntry(String userId, JournalEntry entry) {
    // entry.id будет использоваться как ID документа
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('journal')
        .doc(entry.id);
    return docRef.set(entry.toMap());
  }

  /// Удаляет запись из дневника по ее ID.
  Future<void> deleteJournalEntry(String userId, String entryId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('journal')
        .doc(entryId)
        .delete();
  }
}