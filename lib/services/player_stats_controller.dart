import '../models/player_model.dart';

class PlayerStatsController {
  final PlayerModel player = PlayerModel();

  // Getters to access data from the model
  double get energy => player.energy;
  double get maxEnergy => player.maxEnergy;
  double get arousal => player.arousal;
  double get maxArousal => player.maxArousal;
  int get money => player.money;

  int get lust => player.lust;
  int get maxLust => player.maxLust;
  int get vitality => player.vitality;
  int get maxVitality => player.maxVitality;
  int get physical_fitness => player.physical_fitness;
  int get maxPhysical_fitness => player.maxPhysical_fitness;
  int get fighting => player.fighting;
  int get maxFighting => player.maxFighting;
  int get massage_experience => player.massage_experience;
  int get maxMassage_experience => player.maxMassage_experience;
  int get lockpicking => player.lockpicking;
  int get maxLockpicking => player.maxLockpicking;
  int get programming => player.programming;
  int get maxProgramming => player.maxProgramming;
  int get hacking => player.hacking;
  int get maxHacking => player.maxHacking;
  int get stealth_mode => player.stealth_mode;
  int get maxStealth_mode => player.maxStealth_mode;
  int get influence => player.influence;
  int get maxInfluence => player.maxInfluence;
  int get college_success => player.college_success;
  int get maxCollege_success => player.maxCollege_success;

  // Status strings
  String get energyStatus => energy <= 25 ? "Знесилений" : energy <= 50 ? "Втомлений" : energy <= 75 ? "Нормальний" : "Бадьорий";
  String get arousalStatus => arousal <= 33 ? "Спокійний" : arousal <= 66 ? "Тісно в штанях" : "Стоїть колом";

  // Methods to change player stats
  void changeEnergy(double amount) {
    player.energy = (player.energy + amount).clamp(0, player.maxEnergy);
  }

  void changeArousal(double amount) {
    player.arousal = (player.arousal + amount).clamp(0, player.maxArousal);
  }

  void changeMoney(int amount) {
    player.money = (player.money + amount).clamp(0, 9999999);
  }

  void changeLust(int amount) {
    player.lust = (player.lust + amount).clamp(0, player.maxLust);
  }

  void changeVitality(int amount) {
    player.vitality = (player.vitality + amount).clamp(0, player.maxVitality);
  }

  void changePhysicalFitness(int amount) {
    player.physical_fitness = (player.physical_fitness + amount).clamp(0, player.maxPhysical_fitness);
  }

  void changeFighting(int amount) {
    player.fighting = (player.fighting + amount).clamp(0, player.maxFighting);
  }

  void changeMassageExperience(int amount) {
    player.massage_experience = (player.massage_experience + amount).clamp(0, player.maxMassage_experience);
  }

  void changeLockpicking(int amount) {
    player.lockpicking = (player.lockpicking + amount).clamp(0, player.maxLockpicking);
  }

  void changeProgramming(int amount) {
    player.programming = (player.programming + amount).clamp(0, player.maxProgramming);
  }

  void changeHacking(int amount) {
    player.hacking = (player.hacking + amount).clamp(0, player.maxHacking);
  }

  void changeStealthMode(int amount) {
    player.stealth_mode = (player.stealth_mode + amount).clamp(0, player.maxStealth_mode);
  }

  void changeInfluence(int amount) {
    player.influence = (player.influence + amount).clamp(0, player.maxInfluence);
  }

  void changeCollegeSuccess(int amount) {
    player.college_success = (player.college_success + amount).clamp(0, player.maxCollege_success);
  }
}
