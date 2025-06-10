// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:funny_flower/app_router.dart';
import 'package:funny_flower/providers/cart_provider.dart';
import 'package:funny_flower/providers/wishlist_provider.dart';
import 'package:funny_flower/services/auth_service.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/services/storage_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),


        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<WishlistProvider>(
          create: (_) => WishlistProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Funny Flower',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.deepPurple,
            secondary: Colors.tealAccent,
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          textTheme: GoogleFonts.nunitoTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}