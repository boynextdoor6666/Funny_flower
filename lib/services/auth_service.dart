// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. Поток для отслеживания состояния пользователя ---
  // Этот поток будет оповещать приложение, когда пользователь
  // входит в систему или выходит из нее. Очень удобно для
  // автоматического перенаправления на нужный экран.
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Получить текущего пользователя (если он есть)
  User? get currentUser {
    return _auth.currentUser;
  }

  // --- 2. Вход по email и паролю ---
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      // Выводим ошибку в консоль для отладки
      debugPrint("Ошибка входа: ${e.message}");
      // Возвращаем null, чтобы UI мог понять, что вход не удался
      return null;
    }
  }

  // --- 3. Регистрация по email и паролю ---
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;

      // Здесь можно добавить логику для создания документа пользователя
      // в Firestore, например, сохранить его email.
      // await FirestoreService(uid: user.uid).updateUserData(...);

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Ошибка регистрации: ${e.message}");
      return null;
    }
  }

  // --- 4. Выход из системы ---
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      debugPrint("Ошибка выхода: ${e.toString()}");
      return;
    }
  }
}