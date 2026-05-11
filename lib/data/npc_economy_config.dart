import 'package:flutter/material.dart';

/// Конфіг економіки NPC: хто «працює», межі гаманця, кольори індикатора в галереї.
abstract final class NpcEconomyConfig {
  /// Нижня та верхня межа грошей NPC (узгоджено з ТЗ).
  static const int moneyMin = -1000;
  static const int moneyMax = 10000;

  /// Працюючі: зарплата (пн) + комуналка (пт). Усі інші NPC у грі — пасивні модель.
  ///
  /// Працюють: Mom, Cherie, Danielle, Manuel (`korish_father`), Sasha, Nicole, Lisa, Amia,
  /// India Summer (`india_summer`), Jessa, Luda.
  /// Другорядні (`dekan`, `loshok`, `rockefeller`) — без економіки та без грошей у UI.
  /// Не працюють (пасивні): Piper, Elsa, Anya, Sem, Den, Faye/Emily/Ariana тощо.
  static const Set<String> employedNpcIds = {
    'mom',
    'cherie',
    'danielle',
    'korish_father',
    'sasha',
    'nicole',
    'lisa',
    'amia',
    'india_summer',
    'jessa',
    'luda',
  };

  static bool isEmployed(String npcId) => employedNpcIds.contains(npcId);

  /// Іконка долара в галереї персонажів (5 сходинок за замовчуванням ТЗ).
  static Color moneyTierColor(int money) {
    if (money < -300) return Colors.red.shade700;
    if (money <= 0) return Colors.deepOrange.shade700;
    if (money <= 500) return Colors.amber.shade700;
    if (money <= 1500) return Colors.lightGreen.shade600;
    return Colors.green.shade600;
  }
}
