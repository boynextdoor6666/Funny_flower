// lib/screens/cart_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/providers/cart_provider.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/widgets/fake_payment_processor.dart';
import 'package:funny_flower/widgets/multi_wave_background.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  /// Показывает BottomSheet с вариантами оплаты
  void _showPaymentOptions(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1e1e1e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Выберите способ оплаты',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildPaymentMethodTile(context, cart, 'Банковская карта', Icons.credit_card),
            const Divider(color: Colors.white24),
            _buildPaymentMethodTile(context, cart, 'Система Быстрых Платежей (СБП)', Icons.qr_code_2),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Вспомогательный виджет для пункта меню в BottomSheet
  Widget _buildPaymentMethodTile(BuildContext context, CartProvider cart, String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(method),
      onTap: () {
        Navigator.of(context).pop();
        _processCheckout(context, cart, method);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Основная логика, которая вызывает имитатор
  void _processCheckout(BuildContext context, CartProvider cart, String paymentMethod) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bool? paymentSuccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const FakePaymentProcessor(),
    );

    if (paymentSuccess == null || !paymentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось завершить оплату.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final newOrder = UserOrder(
        id: '',
        userId: user.uid,
        items: cart.items.values.toList(),
        totalAmount: cart.totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: paymentMethod,
        paymentStatus: 'paid',
      );

      await firestoreService.addOrder(newOrder);
      cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ успешно оплачен!'), backgroundColor: Colors.green),
      );
      context.go('/home');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при создании заказа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return MultiWaveBackground(
      child: Scaffold(
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
              // ✅ ВОССТАНОВЛЕННЫЙ КОД ДЛЯ СПИСКА ТОВАРОВ
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
                    // ✅ ПОЛНОСТЬЮ ВОССТАНОВЛЕННАЯ КНОПКА
                    ElevatedButton(
                      child: const Text('К оплате'),
                      onPressed: (cart.items.isEmpty || user == null)
                          ? null
                          : () => _showPaymentOptions(context, cart),
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