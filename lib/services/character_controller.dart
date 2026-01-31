import 'package:flutter/material.dart';
import '../models/character_model.dart';

class CharacterController extends ChangeNotifier {
  final Character _player = Character();

  Character get player => _player;

  void updateEnergy(int amount) {
    _player.energy = (_player.energy + amount).clamp(0, _player.maxEnergy);
    notifyListeners();
  }

  void addMoney(int amount) {
    _player.money += amount;
    notifyListeners();
  }

  void updateStat(String statName, int value) {
    switch (statName) {
      case 'intellect': _player.intellect += value; break;
      case 'charisma': _player.charisma += value; break;
      case 'strength': _player.strength += value; break;
    }
    notifyListeners();
  }
}