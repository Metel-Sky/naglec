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
    player.money += amount;
    notifyListeners();
  }

  void updateUI() => notifyListeners();
}