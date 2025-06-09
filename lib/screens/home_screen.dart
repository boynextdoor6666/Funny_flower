// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/providers/wishlist_provider.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // <-- ИЗМЕНЕНИЕ: Теперь фильтруем по эффекту, а не категории
  String _selectedEffect = 'Все';
  // <-- ИЗМЕНЕНИЕ: Обновите этот список вашими реальными эффектами из Firestore
  final List<String> _effects = ['Все', 'Расслабляющий', 'Бодрящий', 'Целебный', 'Мистический'];

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Funny Flower'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // <-- ИЗМЕНЕНИЕ: Текст заголовка обновлен
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Выбор Шамана', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  StreamBuilder<List<Product>>(
                    // <-- ИЗМЕНЕНИЕ: Используем новый метод getShamanChoiceProducts
                    stream: firestoreService.getShamanChoiceProducts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
                      final featuredProducts = snapshot.data!;
                      return SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product = featuredProducts[index];
                            return GestureDetector(
                              onTap: () => context.go('/home/product/${product.id}'),
                              child: Card(
                                margin: const EdgeInsets.all(4),
                                clipBehavior: Clip.antiAlias,
                                child: SizedBox(
                                  width: 150,
                                  child: Column(
                                    children: [
                                      Expanded(child: Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity)),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text('Каталог по эффектам', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      // <-- ИЗМЕНЕНИЕ: Используем список эффектов
                      itemCount: _effects.length,
                      itemBuilder: (context, index) {
                        // <-- ИЗМЕНЕНИЕ: Работаем с переменной effect
                        final effect = _effects[index];
                        final isSelected = effect == _selectedEffect;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(effect),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  // <-- ИЗМЕНЕНИЕ: Обновляем выбранный эффект
                                  _selectedEffect = effect;
                                });
                              }
                            },
                            selectedColor: theme.colorScheme.secondary,
                            labelStyle: TextStyle(
                              color: isSelected ? theme.colorScheme.onSecondary : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: StreamBuilder<List<Product>>(
          // <-- ИЗМЕНЕНИЕ: Вызываем getProducts с параметром effect
          stream: firestoreService.getProducts(effect: _selectedEffect),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Растений с таким эффектом нет'));
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
                return GestureDetector(
                  onTap: () => context.go('/home/product/${product.id}'),
                  child: Card(
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
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                  child: IconButton(
                                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white),
                                    onPressed: () {
                                      wishlistProvider.toggleFavorite(product);
                                    },
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
      ),
    );
  }
}