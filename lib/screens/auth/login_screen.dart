// lib/screens/auth/login_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:funny_flower/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Ключ для нашей формы, чтобы управлять валидацией
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей ввода
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Состояние экрана
  bool _isLoginMode = true; // true - режим входа, false - режим регистрации
  bool _isLoading = false; // true - показываем индикатор загрузки

  // --- Метод, который будет вызываться при нажатии на главную кнопку ---
  Future<void> _submitForm() async {
    // 1. Проверяем, прошли ли поля валидацию
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Включаем индикатор загрузки
    setState(() {
      _isLoading = true;
    });

    // 3. Получаем доступ к нашему AuthService
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      User? user;
      // 4. В зависимости от режима, вызываем нужный метод
      if (_isLoginMode) {
        user = await authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        user = await authService.registerWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
      }

      // 5. Если вход/регистрация прошли успешно, пользователь не будет null
      if (user != null && mounted) {
        // Возвращаемся на предыдущий экран (деталей товара)
        context.pop();
      } else {
        // Показываем ошибку, если Firebase вернул null
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось войти. Проверьте данные или попробуйте позже.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Ловим любые другие ошибки
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла ошибка: $e')),
        );
      }
    } finally {
      // 6. В любом случае выключаем индикатор загрузки
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? "Вход" : "Регистрация"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Поле для Email ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Пожалуйста, введите корректный email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Поле для Пароля ---
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true, // Скрывает вводимые символы
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Пароль должен содержать не менее 6 символов';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // --- Кнопка действия (Вход/Регистрация) ---
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isLoginMode ? 'Войти' : 'Создать аккаунт'),
                  ),
                const SizedBox(height: 12),

                // --- Кнопка для переключения режима ---
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                    });
                  },
                  child: Text(
                    _isLoginMode
                        ? 'У меня еще нет аккаунта. Зарегистрироваться'
                        : 'У меня уже есть аккаунт. Войти',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}