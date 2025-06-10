// lib/screens/results_screen.dart

import 'package:flutter/material.dart';
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/providers/wishlist_provider.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/widgets/multi_wave_background.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResultsScreen extends StatelessWidget {
  final String recommendedEffect;

  const ResultsScreen({
    Key? key,
    required this.recommendedEffect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final theme = Theme.of(context);

    return MultiWaveBackground(
      numAnimations: 20,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Рекомендации для вас: $recommendedEffect'),
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Градиент для читаемости
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Сетка с продуктами
            StreamBuilder<List<Product>>(
              stream: firestoreService.getProducts(effect: recommendedEffect),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'К сожалению, для эффекта "$recommendedEffect"\nничего не найдено.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                final products = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isFav = wishlistProvider.isFavorite(product.id);
                    // Копируем карточку товара из HomeScreen для консистентности
                    return GestureDetector(
                      onTap: () => context.go('/home/product/${product.id}'),
                      child: Card(
                        color: Colors.black.withOpacity(0.4),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Hero(
                                      tag: product.id,
                                      child: Image.network(product.imageUrl, fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4, right: 4,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black.withOpacity(0.5),
                                      child: IconButton(
                                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white),
                                        onPressed: () => wishlistProvider.toggleFavorite(product),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(product.name, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(bottom: 8.0),
                              child: Text('${product.price} ₽', style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}