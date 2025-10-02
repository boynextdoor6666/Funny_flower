// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/models/user_order_model.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/services/loyalty_service.dart';
import 'package:funny_flower/widgets/multi_wave_background.dart';
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

    // --- Блок для неавторизованного пользователя ---
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
    // ✅ ИСПРАВЛЕНИЕ 1: Создаем non-nullable переменную, чтобы избежать ошибок с authUser.uid
    final User currentUser = authUser;

    return MultiWaveBackground(
      child: StreamBuilder<DocumentSnapshot>(
        stream: firestoreService.getUserProfileStream(currentUser.uid),
        builder: (context, userSnapshot) {



          // Сценарий 1: Загрузка
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
          }

          // Сценарий 2: Ошибка
          else if (userSnapshot.hasError) {
            return Scaffold(appBar: AppBar(title: const Text('Профиль')), body: Center(child: Text('Ошибка загрузки: ${userSnapshot.error}')));
          }

          // Сценарий 3: Данных нет, нужно создать профиль
          else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(title: const Text('Создание профиля')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Ваш профиль еще не создан.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final defaultName = currentUser.email?.split('@')[0] ?? 'Пользователь';
                        final newUser = UserModel(uid: currentUser.uid, email: currentUser.email!, displayName: defaultName);
                        await firestoreService.createUserProfile(newUser);
                      },
                      child: const Text('Создать профиль'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Сценарий 4 (основной): Данные есть, отображаем профиль
          else {
            final userProfile = UserModel.fromFirestore(userSnapshot.data!);
            final tier = LoyaltyService.getTierForXp(userProfile.experiencePoints);

            double progress = 0.0;
            if (tier.nextLevelXp > 0) {
              int previousLevelXp = 0;
              if (tier.name == 'Адепт') previousLevelXp = 1000;
              if (tier.name == 'Алхимик') previousLevelXp = 5000;
              final currentTierXp = userProfile.experiencePoints - previousLevelXp;
              final totalTierXp = tier.nextLevelXp - previousLevelXp;
              progress = totalTierXp > 0 ? (currentTierXp / totalTierXp).clamp(0.0, 1.0) : 1.0;
            } else {
              progress = 1.0;
            }

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
                    Text('Путь Посвященного', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.black.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(tier.icon, color: tier.color, size: 30),
                                const SizedBox(width: 12),
                                Text(tier.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: tier.color)),
                                const Spacer(),
                                if (tier.discountPercent > 0)
                                  Text('${tier.discountPercent.toStringAsFixed(0)}% скидка', style: TextStyle(color: tier.color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(tier.color),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            if (tier.nextLevelXp > 0)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${userProfile.experiencePoints} XP'),
                                  Text('До ${tier.nextLevelXp} XP'),
                                ],
                              )
                            else
                              const Center(child: Text('Вы достигли высшего пути! ✨', style: TextStyle(fontStyle: FontStyle.italic))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    Text('История заказов', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<List<UserOrder>>(
                        stream: firestoreService.getUserOrders(currentUser.uid),
                        builder: (context, orderSnapshot) {
                          if (orderSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (orderSnapshot.hasError) {
                            return Center(child: Text('Ошибка загрузки заказов: ${orderSnapshot.error}'));
                          } else if (!orderSnapshot.hasData || orderSnapshot.data!.isEmpty) {
                            return const Center(child: Text('У вас пока нет заказов.'));
                          } else {
                            final orders = orderSnapshot.data!;
                            return ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (ctx, i) {
                                final order = orders[i];
                                return Card(
                                  color: Colors.black.withOpacity(0.4),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ExpansionTile(
                                    iconColor: theme.colorScheme.secondary,
                                    collapsedIconColor: Colors.white70,
                                    title: Text('Заказ от ${DateFormat('dd.MM.yyyy').format(order.orderDate)}'),
                                    subtitle: Text('Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽ (${order.paymentMethod})'),
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
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}