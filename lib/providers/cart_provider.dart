// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:funny_flower/models/cart_item_model.dart';
import 'package:funny_flower/models/product_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};


  double _totalAmount = 0.0;

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {

    return _items.length;
  }


  double get totalAmount {
    return _totalAmount;
  }

  void _recalculateTotal() {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    _totalAmount = total;
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      // Увеличить количество
      _items.update(
        product.id,
            (existingCartItem) => CartItem(
          // id и другие поля берем из существующего элемента
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Добавить новый товар
      _items.putIfAbsent(
        product.id,
            () => CartItem(
          // ID для нового элемента (можно использовать productId, если он уникален)
          id: DateTime.now().toString(),
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: 1,
        ),
      );
    }
    _recalculateTotal(); // Пересчитываем сумму
    notifyListeners();   // Уведомляем слушателей
  }


  void addSingleItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
            (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + 1, // Просто увеличиваем количество
        ),
      );
      _recalculateTotal();
      notifyListeners();
    }
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      // Уменьшить количество
      _items.update(
        productId,
            (existing) => CartItem(
          id: existing.id,
          productId: existing.productId,
          name: existing.name,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      // Удалить товар, если он один
      _items.remove(productId);
    }
    _recalculateTotal();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _recalculateTotal();
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    _totalAmount = 0.0; // Также сбрасываем сумму
    notifyListeners();
  }
}