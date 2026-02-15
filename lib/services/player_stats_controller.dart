import 'package:flutter/material.dart';
import '../models/player_model.dart';

class PlayerStatsController with ChangeNotifier {
  final PlayerModel player = PlayerModel();

  // Геттери для сумісності зі старим кодом (Screen 1 & 2)
  int get money => player.money;
  double get arousal => player.arousal;
  int get vitality => player.vitality;
  int get lust => player.lust;
  int get physical_fitness => player.physical_fitness;
  int get fighting => player.fighting;
  int get college_success => player.college_success;
  int get massage_experience => player.massage_experience;

  // Статус для хедера
  String get energyStatus => "${player.energy.toInt()} / ${player.maxEnergy.toInt()}";
  String get arousalStatus => "${player.arousal.toInt()} / ${player.maxArousal.toInt()}";

  // Максимальні значення (заглушки для шкал)
  int get maxLust => 100;
  int get maxPhysical_fitness => 100;
  int get maxFighting => 100;
  int get maxCollege_success => 100;
  int get maxMassage_experience => 100;

  void changeEnergy(double amount) {
    player.energy = (player.energy + amount).clamp(0, player.maxEnergy);
    notifyListeners();
  }

  void changeArousal(double amount) {
    player.arousal = (player.arousal + amount).clamp(0, player.maxArousal);
    notifyListeners();
  }

  void changeMoney(int amount) {
    player.money = (player.money + amount).clamp(0, 999999);
    notifyListeners();
  }

  void changeVitality(int amount) {
    player.vitality = (player.vitality + amount).clamp(0, 999);
    notifyListeners();
  }

  void changeLust(int amount) {
    player.lust = (player.lust + amount).clamp(0, maxLust);
    notifyListeners();
  }

  void changePhysicalFitness(int amount) {
    player.physical_fitness = (player.physical_fitness + amount).clamp(0, maxPhysical_fitness);
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

  void changeInfluence(int amount) {
    player.influence = (player.influence + amount).clamp(0, 100);
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

  /// Скидає стати гравця для нової гри
  void reset() {
    player.reset();
    notifyListeners();
  }
}