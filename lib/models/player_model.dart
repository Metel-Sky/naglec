class PlayerModel {
  /// Базовий максимум енергії до бонусу від сили.
  static const double baseMaxEnergy = 100.0;

  /// +20 до макс. енергії за кожні 100 пунктів сили (100→120, 200→140, 500→200).
  static double maxEnergyForStrength(int physicalFitness) {
    final steps = physicalFitness ~/ 100;
    return baseMaxEnergy + steps * 20.0;
  }

  int money = 2000;
  double energy = baseMaxEnergy;
  double maxEnergy = baseMaxEnergy;
  double arousal = 0.0;
  double maxArousal = 100.0;

  int lust = 0;
  int charisma = 0;
  int physical_fitness = 0; // Саме так, як у SaveService
  int fighting = 0;
  int programming = 0;
  int hacking = 0;
  int lockpicking = 0;
  int stealth_mode = 0;
  int massage_experience = 0;
  int college_success = 0;

  PlayerModel();

  /// Скидає всі стати до початкових значень (нова гра)
  void reset() {
    money = 2000;
    energy = baseMaxEnergy;
    arousal = 0.0;
    maxArousal = 100.0;
    lust = 0;
    charisma = 0;
    physical_fitness = 0;
    fighting = 0;
    programming = 0;
    hacking = 0;
    lockpicking = 0;
    stealth_mode = 0;
    massage_experience = 0;
    college_success = 0;
    syncMaxEnergyWithStrength();
  }

  /// Оновлює [maxEnergy] від [physical_fitness] і обрізає [energy], якщо потрібно.
  void syncMaxEnergyWithStrength() {
    maxEnergy = maxEnergyForStrength(physical_fitness);
    if (energy > maxEnergy) energy = maxEnergy;
  }

  // Додаємо методи, щоб SaveService став чистішим
  Map<String, dynamic> toJson() => {
    'money': money,
    'energy': energy,
    'arousal': arousal,
    'lust': lust,
    'charisma': charisma,
    'physical_fitness': physical_fitness,
    'fighting': fighting,
    'programming': programming,
    'hacking': hacking,
    'lockpicking': lockpicking,
    'stealth_mode': stealth_mode,
    'college_success': college_success,
  };
}