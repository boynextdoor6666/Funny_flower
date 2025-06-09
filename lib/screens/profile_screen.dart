// lib/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    if (user == null) {
      // Если пользователь не вошел, показываем приглашение
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Войдите, чтобы видеть свой профиль и заказы.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Войти или создать аккаунт'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Роутер автоматически перенаправит на /login, если настроен redirect
              context.go('/home');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Добро пожаловать!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(user.email ?? 'Анонимный пользователь', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('История заказов', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<UserOrder>>(
                stream: firestoreService.getUserOrders(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('У вас пока нет заказов.'));
                  }

                  final orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orders[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Text('Заказ от ${DateFormat('dd.MM.yyyy').format(order.orderDate)}'),
                          subtitle: Text('Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽'),
                          children: order.items.map((item) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(item.imageUrl),
                              ),
                              title: Text(item.name),
                              subtitle: Text('${item.quantity} шт. x ${item.price.toStringAsFixed(0)} ₽'),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}