// lib/screens/product_detail_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/product_model.dart';
import 'package:funny_flower/providers/cart_provider.dart';
import 'package:funny_flower/widgets/dosage_calculator.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  void _handleAddToCart(BuildContext context, Product product) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text('Требуется вход'),
          content: const Text('Чтобы добавить товар в корзину, необходимо войти или создать аккаунт.'),
          actions: [
            TextButton(child: const Text('Отмена'), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text('Войти'),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push('/login');
              },
            ),
          ],
        ),
      );
    } else {
      Provider.of<CartProvider>(context, listen: false).addToCart(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Товар добавлен в корзину!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'В КОРЗИНУ',
            textColor: Colors.white,
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<Product>(
        future: firestoreService.getProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки товара: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Товар не найден'));
          }

          final product = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                stretch: true,
                expandedHeight: 350.0,
                pinned: true,
                backgroundColor: const Color(0xFF1a1a1a),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  background: Hero(
                    tag: product.id,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSyncLoaded) {
                        if (wasSyncLoaded) return child;
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.latinName,
                        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${product.price.toStringAsFixed(0)} ₽',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Описание',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
                      ),


                      DosageCalculator(product: product),

                      const SizedBox(height: 24), // Добавим отступ перед кнопкой

                      ElevatedButton.icon(
                        icon: const Icon(Icons.shopping_basket_outlined),
                        label: const Text('Добавить в корзину'),
                        onPressed: () => _handleAddToCart(context, product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}