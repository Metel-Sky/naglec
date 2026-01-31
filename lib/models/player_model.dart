class PlayerModel {
  double energy;
  double maxEnergy;
  double arousal;
  double maxArousal;
  int money;

  int lust;
  int maxLust;
  int vitality;
  int maxVitality;
  int physical_fitness;
  int maxPhysical_fitness;
  int fighting;
  int maxFighting;
  int massage_experience;
  int maxMassage_experience;
  int lockpicking;
  int maxLockpicking;
  int programming;
  int maxProgramming;
  int hacking;
  int maxHacking;
  int stealth_mode;
  int maxStealth_mode;
  int influence;
  int maxInfluence;
  int college_success;
  int maxCollege_success;

  PlayerModel({
    this.energy = 100.0,
    this.maxEnergy = 100.0,
    this.arousal = 0.0,
    this.maxArousal = 100.0,
    this.money = 2000,
    this.lust = 0,
    this.maxLust = 1000,
    this.vitality = 100,
    this.maxVitality = 100,
    this.physical_fitness = 0,
    this.maxPhysical_fitness = 1000,
    this.fighting = 0,
    this.maxFighting = 1000,
    this.massage_experience = 0,
    this.maxMassage_experience = 1000,
    this.lockpicking = 0,
    this.maxLockpicking = 300,
    this.programming = 0,
    this.maxProgramming = 300,
    this.hacking = 0,
    this.maxHacking = 300,
    this.stealth_mode = 0,
    this.maxStealth_mode = 300,
    this.influence = 0,
    this.maxInfluence = 1000,
    this.college_success = 0,
    this.maxCollege_success = 1000,
  });
}
