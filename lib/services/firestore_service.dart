import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/models/user_order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    return Product.fromFirestore(doc);
  }

  Future<void> addOrder(UserOrder order) {
    return _db.collection('orders').add(order.toJson());
  }

  // ✅ ВОТ МЕТОД, КОТОРЫЙ НЕ БЫЛ НАЙДЕН
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