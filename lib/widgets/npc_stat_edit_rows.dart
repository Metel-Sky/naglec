import 'package:flutter/material.dart';

/// Підпис рівня хтивості / відносин / поведінки (як у картці NPC у телефоні).
abstract final class NpcStatTierLabels {
  NpcStatTierLabels._();

  static String lust(int v) {
    if (v < 100) return 'Скромна';
    if (v < 200) return 'Звичайна';
    if (v < 300) return 'Розкріпачена';
    if (v < 400) return 'Без комплексів';
    if (v < 500) return 'Розпущена';
    if (v < 600) return 'Розпущена';
    if (v < 800) return 'Розбещена';
    return 'Вавилонська блудниця';
  }

  static String relationship(int v) {
    if (v < 100) return 'Ненавидить';
    if (v < 200) return 'Негативне';
    if (v < 300) return 'Недолюблює';
    if (v < 400) return 'Нейтральне';
    if (v < 500) return 'Доброзичливе';
    if (v < 600) return 'Доброзичливе';
    if (v < 800) return 'Завжди готова допомогти';
    return 'Готова на все';
  }

  static String behavior(int v) {
    if (v < 100) return 'Високомірна';
    if (v < 250) return 'Вперта';
    if (v < 400) return 'Нормальна';
    if (v < 600) return 'Поступлива';
    if (v < 800) return 'Залежна';
    return 'Покірна';
  }
}

/// Рядок стата NPC з кнопками ± (чити / ручне редагування).
class NpcStatEditRow extends StatelessWidget {
  const NpcStatEditRow({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.tier,
    this.labelWidth = 140,
    this.valueFontSize = 16,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String? tier;
  final double labelWidth;
  final double valueFontSize;

  static const double _buttonWidth = 36;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
          _miniBtn('-', onMinus),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (tier != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      tier!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _miniBtn('+', onPlus),
        ],
      ),
    );
  }

  Widget _miniBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: _buttonWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Тільки відображення (без ±).
class NpcStatReadOnlyRow extends StatelessWidget {
  const NpcStatReadOnlyRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 140,
  });

  final String label;
  final String value;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
