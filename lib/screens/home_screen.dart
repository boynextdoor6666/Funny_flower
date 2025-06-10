// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/providers/wishlist_provider.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/utils/intentions.dart';
import 'package:funny_flower/widgets/multi_wave_background.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedEffect = 'Все';
  final List<String> _effects = [
    'Все', 'Расслабляющий', 'Бодрящий', 'Целебный', 'Мистический', 'Вдохновляющий', 'Сновидческий'
  ];

  bool _isSearching = false;
  final _searchController = TextEditingController();

  // ✅ 2. Состояние для хранения текущего намерения
  String _currentIntention = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));

    // ✅ 3. Генерируем первое намерение при открытии экрана
    _currentIntention = IntentionGenerator.getRandomIntention();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: const Text('Funny Flower'),
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Поиск растений...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final wishlistProvider = context.watch<WishlistProvider>();
    final theme = Theme.of(context);

    return MultiWaveBackground(
      numAnimations: 20,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _isSearching ? _buildSearchAppBar() : _buildDefaultAppBar(),
        body: Stack(
          children: [
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
            if (_isSearching)
              _buildProductGrid(firestoreService, wishlistProvider, theme, ignoreEffectFilter: true)
            else
              _buildDefaultContent(firestoreService, wishlistProvider, theme),
          ],
        ),
      ),
    );
  }

  // ✅ 4. Создаем виджет для карточки с намерением
  Widget _buildIntentionCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Card(
        color: Colors.black.withOpacity(0.5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => setState(() => _currentIntention = IntentionGenerator.getRandomIntention()),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Фокус для Путешествия',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentIntention,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text('Нажми, чтобы сменить', style: TextStyle(fontSize: 12, color: Colors.white54)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 5. Создаем виджет для кнопки запуска теста
  Widget _buildQuizButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.psychology),
        label: const Text('Подобрать растение по духу'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.go('/quiz'),
      ),
    );
  }

  Widget _buildDefaultContent(FirestoreService firestoreService, WishlistProvider wishlistProvider, ThemeData theme) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // ✅ 6. Добавляем новые виджеты в начало списка
          SliverToBoxAdapter(child: _buildIntentionCard()),
          SliverToBoxAdapter(child: _buildQuizButton()),
          SliverToBoxAdapter(child: _buildShamanChoice(firestoreService)),
          SliverToBoxAdapter(child: _buildEffectFilters(theme)),
        ];
      },
      body: _buildProductGrid(firestoreService, wishlistProvider, theme),
    );
  }

  // Остальной код остается без изменений
  // ... _buildShamanChoice, _buildEffectFilters, _buildProductGrid ...

  Widget _buildShamanChoice(FirestoreService firestoreService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Выбор Шамана', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<List<Product>>(
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
                      color: Colors.black.withOpacity(0.4),
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
    );
  }

  Widget _buildEffectFilters(ThemeData theme) {
    return Column(
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
            itemCount: _effects.length,
            itemBuilder: (context, index) {
              final effect = _effects[index];
              final isSelected = effect == _selectedEffect;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(effect),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedEffect = effect);
                    }
                  },
                  selectedColor: theme.colorScheme.secondary,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.onSecondary : Colors.white70,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(FirestoreService firestoreService, WishlistProvider wishlistProvider, ThemeData theme, {bool ignoreEffectFilter = false}) {
    return StreamBuilder<List<Product>>(
      stream: firestoreService.getProducts(effect: ignoreEffectFilter ? 'Все' : _selectedEffect),
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

        var products = snapshot.data!;
        final searchQuery = _searchController.text.toLowerCase();

        if (searchQuery.isNotEmpty) {
          products = products.where((product) {
            return product.name.toLowerCase().contains(searchQuery);
          }).toList();
        }

        if (products.isEmpty) {
          return const Center(child: Text('Ничего не найдено', style: TextStyle(fontSize: 18)));
        }

        return GridView.builder(
          padding: _isSearching ? const EdgeInsets.fromLTRB(16, 16, 16, 16) : const EdgeInsets.all(16),
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
                            top: 4,
                            right: 4,
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
    );
  }
}