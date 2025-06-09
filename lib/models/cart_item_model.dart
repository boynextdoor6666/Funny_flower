// lib/models/cart_item_model.dart
import 'package:funny_flower/models/product_model.dart';

class CartItem {
  final String id; // Уникальный ID для элемента корзины (обычно productId)
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  // Метод для преобразования в JSON (для сохранения в Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  // Фабричный конструктор для создания из JSON (для чтения из Firestore)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }
}