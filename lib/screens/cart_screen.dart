// lib/screens/cart_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/providers/cart_provider.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/widgets/multi_wave_background.dart'; // ✅ 1. Импорт фона
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  // ... (метод _checkout остается без изменений) ...
  void _checkout(BuildContext context, CartProvider cart, FirestoreService firestoreService) async {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    // ✅ 2. Оборачиваем Scaffold в наш фон
    return MultiWaveBackground(
      child: Scaffold(
        // ✅ 3. Делаем фон прозрачным
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Корзина'),
          centerTitle: true,
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
        ),
        body: cart.items.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'Ваша корзина пуста',
                style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8.0),
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) {
                  final item = cart.items.values.toList()[i];
                  return Dismissible(
                    key: ValueKey(item.productId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      Provider.of<CartProvider>(context, listen: false).removeItem(item.productId);
                    },
                    background: Container(
                      color: Colors.redAccent.withOpacity(0.7),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    // ✅ 4. Стилизуем карточку товара
                    child: Card(
                      color: Colors.black.withOpacity(0.4),
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(item.imageUrl),
                        ),
                        title: Text(item.name),
                        subtitle: Text('Всего: ${(item.price * item.quantity).toStringAsFixed(0)} ₽'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.remove, color: theme.colorScheme.secondary), onPressed: () => cart.removeSingleItem(item.productId)),
                            Text('${item.quantity} x'),
                            IconButton(icon: Icon(Icons.add, color: theme.colorScheme.secondary), onPressed: () => cart.addSingleItem(item.productId)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ✅ 5. Стилизуем итоговую панель
            Card(
              color: Colors.black.withOpacity(0.6),
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Итого', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          '${cart.totalAmount.toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      child: const Text('Оформить заказ'),
                      onPressed: (cart.items.isEmpty || user == null) ? null : () => _checkout(context, cart, firestoreService),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}