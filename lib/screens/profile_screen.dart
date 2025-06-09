// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    // --- Блок для неавторизованного пользователя ---
    if (authUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Войдите, чтобы видеть свой профиль и заказы.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
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

    // --- Блок для авторизованного пользователя ---
    return StreamBuilder<DocumentSnapshot>(
      stream: firestoreService.getUserProfileStream(authUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (userSnapshot.hasError) {
          return Scaffold(appBar: AppBar(title: const Text('Профиль')), body: Center(child: Text('Ошибка загрузки: ${userSnapshot.error}')));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Создание профиля')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ваш профиль еще не создан.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final defaultName = authUser.email?.split('@')[0] ?? 'Пользователь';
                      final newUser = UserModel(
                        uid: authUser.uid,
                        email: authUser.email!,
                        displayName: defaultName,
                      );
                      await firestoreService.createUserProfile(newUser);
                    },
                    child: const Text('Создать профиль'),
                  ),
                ],
              ),
            ),
          );
        }

        final userProfile = UserModel.fromFirestore(userSnapshot.data!);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Редактировать',
                onPressed: () => context.push('/profile/edit', extra: userProfile),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Выйти',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/home');
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty
                          ? NetworkImage(userProfile.photoUrl!)
                          : null,
                      child: userProfile.photoUrl == null || userProfile.photoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userProfile.displayName, style: Theme.of(context).textTheme.headlineSmall, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(userProfile.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('История заказов', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),

                // --- ✅ ВОССТАНОВЛЕННЫЙ КОД ВНУТРИ EXPANDED ---
                Expanded(
                  child: StreamBuilder<List<UserOrder>>(
                    stream: firestoreService.getUserOrders(authUser.uid),
                    // ВОТ ЭТОТ BUILDER БЫЛ ПРОПУЩЕН:
                    builder: (context, orderSnapshot) {
                      if (orderSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (orderSnapshot.hasError) {
                        return Center(child: Text('Ошибка загрузки заказов: ${orderSnapshot.error}'));
                      }
                      if (!orderSnapshot.hasData || orderSnapshot.data!.isEmpty) {
                        return const Center(child: Text('У вас пока нет заказов.'));
                      }

                      final orders = orderSnapshot.data!;
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
      },
    );
  }
}