// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/widgets/multi_wave_background.dart'; // ✅ 1. Импорт фона
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final theme = Theme.of(context);

    // --- Блок для неавторизованного пользователя (теперь с фоном) ---
    if (authUser == null) {
      return MultiWaveBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Профиль'),
            backgroundColor: Colors.black.withOpacity(0.3),
            elevation: 0,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- Блок для авторизованного пользователя ---
    return MultiWaveBackground( // ✅ 2. Оборачиваем основной Scaffold
      child: StreamBuilder<DocumentSnapshot>(
        stream: firestoreService.getUserProfileStream(authUser.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
          }
          // ... (обработка ошибок и создания профиля остается без изменений) ...

          final userProfile = UserModel.fromFirestore(userSnapshot.data!);

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Профиль'),
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 0,
              actions: [
                IconButton(icon: const Icon(Icons.edit), tooltip: 'Редактировать', onPressed: () => context.push('/profile/edit', extra: userProfile)),
                IconButton(icon: const Icon(Icons.logout), tooltip: 'Выйти', onPressed: () async { await FirebaseAuth.instance.signOut(); if (context.mounted) context.go('/home'); }),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 3. Стилизуем карточку профиля
                  Card(
                    color: Colors.black.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.5),
                            backgroundImage: userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty ? NetworkImage(userProfile.photoUrl!) : null,
                            child: userProfile.photoUrl == null || userProfile.photoUrl!.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userProfile.displayName, style: theme.textTheme.headlineSmall, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(userProfile.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('История заказов', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),

                  Expanded(
                    child: StreamBuilder<List<UserOrder>>(
                      stream: firestoreService.getUserOrders(authUser.uid),
                      builder: (context, orderSnapshot) {
                        // ... (логика загрузки и ошибок) ...
                        if (!orderSnapshot.hasData || orderSnapshot.data!.isEmpty) {
                          return const Center(child: Text('У вас пока нет заказов.'));
                        }

                        final orders = orderSnapshot.data!;
                        return ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (ctx, i) {
                            final order = orders[i];
                            // ✅ 4. Стилизуем карточку заказа
                            return Card(
                              color: Colors.black.withOpacity(0.4),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                iconColor: theme.colorScheme.secondary,
                                collapsedIconColor: Colors.white70,
                                title: Text('Заказ от ${DateFormat('dd.MM.yyyy').format(order.orderDate)}'),
                                subtitle: Text('Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽'),
                                children: order.items.map((item) {
                                  return ListTile(
                                    leading: CircleAvatar(backgroundImage: NetworkImage(item.imageUrl)),
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
      ),
    );
  }
}