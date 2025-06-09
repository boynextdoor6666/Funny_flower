// lib/screens/cart_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/providers/cart_provider.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  void _checkout(BuildContext context, CartProvider cart, FirestoreService firestoreService) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Этого не должно случиться, если кнопка заблокирована, но для надежности
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Для оформления заказа необходимо войти в аккаунт.')),
      );
      return;
    }

    final newOrder = UserOrder(
      id: '', // Firestore сгенерирует ID
      userId: user.uid,
      items: cart.items.values.toList(),
      totalAmount: cart.totalAmount,
      orderDate: DateTime.now(),
    );

    try {
      await firestoreService.addOrder(newOrder);
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заказ успешно оформлен!'),
          backgroundColor: Colors.green,
        ),
      );
      // Можно перейти на главный экран или экран "Спасибо за покупку"
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при оформлении заказа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? const Center(
        child: Text('Ваша корзина пуста', style: TextStyle(fontSize: 20)),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 40),
                  ),
                  child: Card(
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
                          IconButton(icon: const Icon(Icons.remove), onPressed: () => cart.removeSingleItem(item.productId)),
                          Text('${item.quantity} x'),
                          // IconButton(icon: Icon(Icons.add), onPressed: () => cart.addToCart(product)), // Для этого нужна модель Product
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Итого', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '${cart.totalAmount.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: const Text('Оформить заказ'),
                    onPressed: (cart.items.isEmpty || user == null) ? null : () => _checkout(context, cart, firestoreService),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}