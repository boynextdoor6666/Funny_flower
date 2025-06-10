// lib/widgets/fake_payment_processor.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FakePaymentProcessor extends StatefulWidget {
  const FakePaymentProcessor({Key? key}) : super(key: key);

  @override
  State<FakePaymentProcessor> createState() => _FakePaymentProcessorState();
}

class _FakePaymentProcessorState extends State<FakePaymentProcessor> {
  String _status = 'Инициализация платежа...';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    // Имитируем разные этапы обработки
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _status = 'Отправка запроса в банк...';
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _status = 'Получение ответа...';
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // С вероятностью 90% платеж "успешен"
    _isSuccess = Random().nextDouble() < 0.9;

    setState(() {
      _status = _isSuccess ? 'Платеж одобрен!' : 'В оплате отказано.';
    });

    // Ждем еще секунду, чтобы пользователь увидел финальный статус
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Закрываем диалог и возвращаем результат (true или false)
    Navigator.of(context).pop(_isSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2a2a2a),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}