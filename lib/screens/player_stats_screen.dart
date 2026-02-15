import 'package:flutter/material.dart';
import 'package:naglec/services/player_stats_controller.dart';
import '../theme/game_theme.dart';

// Перейменовано на PlayerStatsView для відповідності коду
class PlayerStatsView extends StatelessWidget {
  final PlayerStatsController playerStats;

  const PlayerStatsView({super.key, required this.playerStats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Верхній блок (аватар + стати) заповнює весь доступний простір
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ліва частина: Аватар
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 350,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'lib/assets/pers.png', // Шлях до аватара
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Права частина: Статистика з кнопками +/-
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Основні ресурси
                        _buildStatRowWithButtons("Гроші", "${playerStats.player.money} ₴", color: Colors.amber,
                            onMinus: () => playerStats.changeMoney(-10), onPlus: () => playerStats.changeMoney(10)),
                        _buildStatRowWithButtons("Енергія", "${playerStats.player.energy.toInt()} / ${playerStats.player.maxEnergy.toInt()}", color: Colors.blueAccent,
                            onMinus: () => playerStats.changeEnergy(-10), onPlus: () => playerStats.changeEnergy(10)),
                        _buildStatRowWithButtons("Збудження", "${playerStats.player.arousal.toInt()} / ${playerStats.player.maxArousal.toInt()}", color: Colors.pinkAccent,
                            onMinus: () => playerStats.changeArousal(-10), onPlus: () => playerStats.changeArousal(10)),
                        _buildStatRowWithButtons("Бадьорість", "${playerStats.player.vitality}", color: Colors.greenAccent,
                            onMinus: () => playerStats.changeVitality(-10), onPlus: () => playerStats.changeVitality(10)),
                        const SizedBox(height: 6),

                        // Фізичні характеристики
                        _buildStatRowWithButtons("Хтивість", "${playerStats.player.lust} / ${playerStats.maxLust}",
                            onMinus: () => playerStats.changeLust(-10), onPlus: () => playerStats.changeLust(10)),
                        _buildStatRowWithButtons("Фіз. форма", "${playerStats.player.physical_fitness} / ${playerStats.maxPhysical_fitness}",
                            onMinus: () => playerStats.changePhysicalFitness(-10), onPlus: () => playerStats.changePhysicalFitness(10)),
                        _buildStatRowWithButtons("Бій", "${playerStats.player.fighting} / ${playerStats.maxFighting}",
                            onMinus: () => playerStats.changeFighting(-10), onPlus: () => playerStats.changeFighting(10)),
                        const SizedBox(height: 6),

                        // Навички
                        _buildStatRowWithButtons("Програмування", "${playerStats.player.programming} / 100",
                            onMinus: () => playerStats.changeProgramming(-10), onPlus: () => playerStats.changeProgramming(10)),
                        _buildStatRowWithButtons("Хакінг", "${playerStats.player.hacking} / 100",
                            onMinus: () => playerStats.changeHacking(-10), onPlus: () => playerStats.changeHacking(10)),
                        _buildStatRowWithButtons("Злам замків", "${playerStats.player.lockpicking} / 100",
                            onMinus: () => playerStats.changeLockpicking(-10), onPlus: () => playerStats.changeLockpicking(10)),
                        _buildStatRowWithButtons("Стелс", "${playerStats.player.stealth_mode} / 100",
                            onMinus: () => playerStats.changeStealthMode(-10), onPlus: () => playerStats.changeStealthMode(10)),
                        const SizedBox(height: 6),

                        // Соціальні та інші
                        _buildStatRowWithButtons("Вплив", "${playerStats.player.influence} / 100",
                            onMinus: () => playerStats.changeInfluence(-10), onPlus: () => playerStats.changeInfluence(10)),
                        _buildStatRowWithButtons("Досвід масажу", "${playerStats.player.massage_experience} / ${playerStats.maxMassage_experience}",
                            onMinus: () => playerStats.changeMassageExperience(-10), onPlus: () => playerStats.changeMassageExperience(10)),
                        _buildStatRowWithButtons("Успішність", "${playerStats.player.college_success} / ${playerStats.maxCollege_success}",
                            onMinus: () => playerStats.changeCollegeSuccess(-10), onPlus: () => playerStats.changeCollegeSuccess(10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Опис персонажа – завжди притиснутий донизу блоку
          Container(
            padding: const EdgeInsets.all(10),
            decoration: GameTheme.cardDecoration(),
            child: const Text(
              "Я майже звичайний хлопець, але у мене є бонуси, природа нагородила мене значним членом і неабияким розумом!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.blueGrey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text("$label:", style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ),
          const SizedBox(width: 15),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        ],
      ),
    );
  }

  static const double _buttonColumnWidth = 44.0;
  static const double _gapBetweenColumns = 20.0;

  Widget _buildStatRowWithButtons(String label, String value, {Color? color, required VoidCallback onMinus, required VoidCallback onPlus}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text("$label:", style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ),
          const SizedBox(width: _gapBetweenColumns),
          SizedBox(
            width: _buttonColumnWidth,
            child: _miniBtn("-", onMinus),
          ),
          const SizedBox(width: _gapBetweenColumns),
          Expanded(
            child: Center(
              child: Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: _gapBetweenColumns),
          SizedBox(
            width: _buttonColumnWidth,
            child: _miniBtn("+", onPlus),
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
