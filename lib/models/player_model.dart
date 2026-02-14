class PlayerModel {
  int money = 0;
  double energy = 100.0;
  double maxEnergy = 100.0;
  double arousal = 0.0;
  double maxArousal = 100.0;

  int lust = 0;
  int vitality = 100;
  int physical_fitness = 0; // Саме так, як у SaveService
  int fighting = 0;
  int programming = 0;
  int hacking = 0;
  int lockpicking = 0;
  int stealth_mode = 0;
  int massage_experience = 0;
  int influence = 0;
  int college_success = 0;

  PlayerModel();

  /// Скидає всі стати до початкових значень (нова гра)
  void reset() {
    money = 0;
    energy = 100.0;
    maxEnergy = 100.0;
    arousal = 0.0;
    maxArousal = 100.0;
    lust = 0;
    vitality = 100;
    physical_fitness = 0;
    fighting = 0;
    programming = 0;
    hacking = 0;
    lockpicking = 0;
    stealth_mode = 0;
    massage_experience = 0;
    influence = 0;
    college_success = 0;
  }

  // Додаємо методи, щоб SaveService став чистішим
  Map<String, dynamic> toJson() => {
    'money': money,
    'energy': energy,
    'arousal': arousal,
    'lust': lust,
    'vitality': vitality,
    'physical_fitness': physical_fitness,
    'fighting': fighting,
    'programming': programming,
    'hacking': hacking,
    'lockpicking': lockpicking,
    'stealth_mode': stealth_mode,
    'influence': influence,
    'college_success': college_success,
  };
}