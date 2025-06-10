// lib/widgets/dosage_calculator.dart
import 'package:flutter/material.dart';
import 'package:funny_flower/models/product_model.dart';

class DosageCalculator extends StatefulWidget {
  final Product product;
  const DosageCalculator({Key? key, required this.product}) : super(key: key);

  @override
  State<DosageCalculator> createState() => _DosageCalculatorState();
}

class _DosageCalculatorState extends State<DosageCalculator> {
  // 0: light, 1: medium, 2: heavy
  int _selectedIntensity = 1;

  String _getDosageText() {
    final p = widget.product;
    if (p.dosageUnit == null) return "Информация о дозировке отсутствует.";

    double? dosage;
    if (_selectedIntensity == 0) dosage = p.dosageLight;
    if (_selectedIntensity == 1) dosage = p.dosageMedium;
    if (_selectedIntensity == 2) dosage = p.dosageHeavy;

    if (dosage == null || dosage == 0) return "Для этого уровня эффект не определен.";

    return "Примерно: ${dosage.toStringAsFixed(1)} ${p.dosageUnit}";
  }

  @override
  Widget build(BuildContext context) {
    // Если данных для калькулятора нет, не показываем его
    if (widget.product.dosageUnit == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Гайд по Дозировкам",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            ),
            const SizedBox(height: 16),
            const Text("Выберите желаемую интенсивность:"),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [_selectedIntensity == 0, _selectedIntensity == 1, _selectedIntensity == 2],
              onPressed: (index) => setState(() => _selectedIntensity = index),
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              color: Colors.white,
              fillColor: Theme.of(context).colorScheme.secondary,
              borderColor: Colors.grey,
              selectedBorderColor: Theme.of(context).colorScheme.secondary,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Знакомство")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Стандарт")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Глубина")),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _getDosageText(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Внимание: это лишь примерные значения. Всегда начинайте с малого. Ваша реакция индивидуальна.",
              style: TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}