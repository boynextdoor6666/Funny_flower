// lib/providers/wishlist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:funny_flower/models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<String> _wishlistProductIds = [];

  List<String> get wishlistProductIds => _wishlistProductIds;

  bool isFavorite(String productId) {
    return _wishlistProductIds.contains(productId);
  }

  void toggleFavorite(Product product) {
    final productId = product.id;
    if (isFavorite(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    notifyListeners();
  }
}