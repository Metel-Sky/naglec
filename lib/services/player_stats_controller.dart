import 'package:flutter/material.dart';
import '../models/player_model.dart';

class PlayerStatsController with ChangeNotifier {
  final PlayerModel player = PlayerModel();

  // Геттери для сумісності зі старим кодом (Screen 1 & 2)
  int get money => player.money;
  double get arousal => player.arousal;
  int get lust => player.lust;
  int get charisma => player.charisma;
  int get physical_fitness => player.physical_fitness;
  int get fighting => player.fighting;
  int get college_success => player.college_success;
  int get massage_experience => player.massage_experience;

  // Статус для хедера
  String get energyStatus => "${player.energy.toInt()} / ${player.maxEnergy.toInt()}";
  String get arousalStatus => "${player.arousal.toInt()} / ${player.maxArousal.toInt()}";

  // Максимальні значення (заглушки для шкал)
  int get maxLust => 1000;
  int get maxCharisma => 300;
  int get maxPhysical_fitness => 500;
  int get maxFighting => 100;
  int get maxCollege_success => 100;
  int get maxMassage_experience => 500;

  void changeEnergy(double amount) {
    player.energy = (player.energy + amount).clamp(0, player.maxEnergy);
    notifyListeners();
  }

  void changeArousal(double amount) {
    player.arousal = (player.arousal + amount).clamp(0, player.maxArousal);
    notifyListeners();
  }

  void changeMoney(int amount) {
    player.money = (player.money + amount).clamp(0, 999999999);
    notifyListeners();
  }

  void changeLust(int amount) {
    player.lust = (player.lust + amount).clamp(0, maxLust);
    notifyListeners();
  }

  void changeCharisma(int amount) {
    player.charisma = (player.charisma + amount).clamp(0, maxCharisma);
    notifyListeners();
  }

  void changePhysicalFitness(int amount) {
    player.physical_fitness = (player.physical_fitness + amount).clamp(0, maxPhysical_fitness);
    player.syncMaxEnergyWithStrength();
    notifyListeners();
  }

  void changeFighting(int amount) {
    player.fighting = (player.fighting + amount).clamp(0, maxFighting);
    notifyListeners();
  }

  void changeProgramming(int amount) {
    player.programming = (player.programming + amount).clamp(0, 100);
    notifyListeners();
  }

  void changeHacking(int amount) {
    player.hacking = (player.hacking + amount).clamp(0, 100);
    notifyListeners();
  }

  void changeLockpicking(int amount) {
    player.lockpicking = (player.lockpicking + amount).clamp(0, 100);
    notifyListeners();
  }

  void changeStealthMode(int amount) {
    player.stealth_mode = (player.stealth_mode + amount).clamp(0, 100);
    notifyListeners();
  }

  void changeMassageExperience(int amount) {
    player.massage_experience = (player.massage_experience + amount).clamp(0, maxMassage_experience);
    notifyListeners();
  }

  void changeCollegeSuccess(int amount) {
    player.college_success = (player.college_success + amount).clamp(0, maxCollege_success);
    notifyListeners();
  }

  void updateUI() => notifyListeners();

  // --- Уроки програмування на ноутбуці (1–5, 1 раз на день, по порядку) ---
  int programmingLessonsCompleted = 0; // 0..5: скільки уроків переглянуто
  DateTime? programmingLastWatchedDate; // дата (день) останнього перегляду

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Чи можна сьогодні дивитись урок (лише 1 раз на день).
  bool canWatchProgrammingLessonToday(DateTime gameDate) {
    if (programmingLastWatchedDate == null) return true;
    return !_sameDay(programmingLastWatchedDate!, gameDate);
  }

  /// Урок [lessonIndex1Based] (1..5) доступний лише якщо попередні переглянуті.
  bool isProgrammingLessonUnlocked(int lessonIndex1Based) {
    return lessonIndex1Based >= 1 &&
        lessonIndex1Based <= 5 &&
        lessonIndex1Based <= programmingLessonsCompleted + 1;
  }

  /// Після перегляду відео: +20% програмування, оновлення прогресу та дати.
  void completeProgrammingLesson(int lessonIndex1Based, DateTime gameDate) {
    if (lessonIndex1Based < 1 || lessonIndex1Based > 5) return;
    changeProgramming(20);
    if (lessonIndex1Based > programmingLessonsCompleted) {
      programmingLessonsCompleted = lessonIndex1Based;
    }
    programmingLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  // --- Уроки «злам замків» на ноутбуці (1–5, 1 раз на день, по порядку) ---
  int lockpickLessonsCompleted = 0;
  DateTime? lockpickLastWatchedDate;

  bool canWatchLockpickLessonToday(DateTime gameDate) {
    if (lockpickLastWatchedDate == null) return true;
    return !_sameDay(lockpickLastWatchedDate!, gameDate);
  }

  bool isLockpickLessonUnlocked(int lessonIndex1Based) {
    return lessonIndex1Based >= 1 &&
        lessonIndex1Based <= 5 &&
        lessonIndex1Based <= lockpickLessonsCompleted + 1;
  }

  void completeLockpickLesson(int lessonIndex1Based, DateTime gameDate) {
    if (lessonIndex1Based < 1 || lessonIndex1Based > 5) return;
    changeLockpicking(20);
    if (lessonIndex1Based > lockpickLessonsCompleted) {
      lockpickLessonsCompleted = lessonIndex1Based;
    }
    lockpickLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  // --- Уроки «пересуватись безшумно» на ноутбуці (1–5, 1 раз на день, по порядку) ---
  int stealthLessonsCompleted = 0;
  DateTime? stealthLastWatchedDate;

  bool canWatchStealthLessonToday(DateTime gameDate) {
    if (stealthLastWatchedDate == null) return true;
    return !_sameDay(stealthLastWatchedDate!, gameDate);
  }

  bool isStealthLessonUnlocked(int lessonIndex1Based) {
    return lessonIndex1Based >= 1 &&
        lessonIndex1Based <= 5 &&
        lessonIndex1Based <= stealthLessonsCompleted + 1;
  }

  void completeStealthLesson(int lessonIndex1Based, DateTime gameDate) {
    if (lessonIndex1Based < 1 || lessonIndex1Based > 5) return;
    changeStealthMode(20);
    if (lessonIndex1Based > stealthLessonsCompleted) {
      stealthLessonsCompleted = lessonIndex1Based;
    }
    stealthLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  // --- Уроки «взламувати паролі» (1–5, 1 раз на день, по порядку, +10 hacking) ---
  int passwordLessonsCompleted = 0;
  DateTime? passwordLastWatchedDate;

  bool canWatchPasswordLessonToday(DateTime gameDate) {
    if (passwordLastWatchedDate == null) return true;
    return !_sameDay(passwordLastWatchedDate!, gameDate);
  }

  bool isPasswordLessonUnlocked(int lessonIndex1Based) {
    return lessonIndex1Based >= 1 &&
        lessonIndex1Based <= 5 &&
        lessonIndex1Based <= passwordLessonsCompleted + 1;
  }

  void completePasswordLesson(int lessonIndex1Based, DateTime gameDate) {
    if (lessonIndex1Based < 1 || lessonIndex1Based > 5) return;
    changeHacking(10);
    if (lessonIndex1Based > passwordLessonsCompleted) {
      passwordLessonsCompleted = lessonIndex1Based;
    }
    passwordLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  // --- Уроки «взламувати телефони» (відкриваються після всіх 5 уроків паролів; +10 hacking) ---
  int phoneLessonsCompleted = 0;
  DateTime? phoneLastWatchedDate;

  bool get isPhoneCourseUnlocked => passwordLessonsCompleted >= 5;

  bool canWatchPhoneLessonToday(DateTime gameDate) {
    if (phoneLastWatchedDate == null) return true;
    return !_sameDay(phoneLastWatchedDate!, gameDate);
  }

  bool isPhoneLessonUnlocked(int lessonIndex1Based) {
    return isPhoneCourseUnlocked &&
        lessonIndex1Based >= 1 &&
        lessonIndex1Based <= 5 &&
        lessonIndex1Based <= phoneLessonsCompleted + 1;
  }

  void completePhoneLesson(int lessonIndex1Based, DateTime gameDate) {
    if (lessonIndex1Based < 1 || lessonIndex1Based > 5) return;
    changeHacking(10);
    if (lessonIndex1Based > phoneLessonsCompleted) {
      phoneLessonsCompleted = lessonIndex1Based;
    }
    phoneLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  // --- Уроки «масаж» (1–10, 1 раз на день, по порядку, +10 massage_experience) ---
  int massageLessonsCompleted = 0;
  DateTime? massageLastWatchedDate;

  bool canWatchMassageLessonToday(DateTime gameDate) {
    if (massageLastWatchedDate == null) return true;
    return !_sameDay(massageLastWatchedDate!, gameDate);
  }

  bool isMassageLessonUnlocked(int lessonIndex1Based) {
    return lessonIndex1Based >= 1 &&
        lessonIndex1Based <= 10 &&
        lessonIndex1Based <= massageLessonsCompleted + 1;
  }

  void completeMassageLesson(int lessonIndex1Based, DateTime gameDate) {
    if (lessonIndex1Based < 1 || lessonIndex1Based > 10) return;
    changeMassageExperience(10);
    if (lessonIndex1Based > massageLessonsCompleted) {
      massageLessonsCompleted = lessonIndex1Based;
    }
    massageLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  /// Відкривається після всіх 10 уроків масажу. Повторно до 500 досвіду, 1 раз на день.
  bool get isEroMassageUnlocked => massageLessonsCompleted >= 10;

  DateTime? eroMassageLastWatchedDate;

  bool canWatchEroMassageToday(DateTime gameDate) {
    if (eroMassageLastWatchedDate == null) return true;
    return !_sameDay(eroMassageLastWatchedDate!, gameDate);
  }

  /// Після перегляду: +10 massage_experience (до макс 500), раз на день.
  void completeEroMassage(DateTime gameDate) {
    if (massage_experience >= maxMassage_experience) return;
    changeMassageExperience(10);
    eroMassageLastWatchedDate = DateTime(gameDate.year, gameDate.month, gameDate.day);
    notifyListeners();
  }

  /// Скидає стати гравця для нової гри
  void reset() {
    player.reset();
    programmingLessonsCompleted = 0;
    programmingLastWatchedDate = null;
    lockpickLessonsCompleted = 0;
    lockpickLastWatchedDate = null;
    stealthLessonsCompleted = 0;
    stealthLastWatchedDate = null;
    passwordLessonsCompleted = 0;
    passwordLastWatchedDate = null;
    phoneLessonsCompleted = 0;
    phoneLastWatchedDate = null;
    massageLessonsCompleted = 0;
    massageLastWatchedDate = null;
    eroMassageLastWatchedDate = null;
    notifyListeners();
  }
}