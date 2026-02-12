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

                // Права частина: Статистика
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Основні ресурси
                        _buildStatRow("Гроші", "${playerStats.player.money} ₴", color: Colors.amber),
                        _buildStatRow("Енергія", "${playerStats.player.energy.toInt()} / ${playerStats.player.maxEnergy.toInt()}", color: Colors.blueAccent),
                        _buildStatRow("Збудження", "${playerStats.player.arousal.toInt()} / ${playerStats.player.maxArousal.toInt()}", color: Colors.pinkAccent),
                        _buildStatRow("Бадьорість", "${playerStats.player.vitality}", color: Colors.greenAccent),
                        const SizedBox(height: 6),

                        // Фізичні характеристики
                        _buildStatRow("Хтивість", "${playerStats.player.lust} / ${playerStats.maxLust}"),
                        _buildStatRow("Фіз. форма", "${playerStats.player.physical_fitness} / ${playerStats.maxPhysical_fitness}"),
                        _buildStatRow("Бій", "${playerStats.player.fighting} / ${playerStats.maxFighting}"),
                        const SizedBox(height: 6),

                        // Навички
                        _buildStatRow("Програмування", "${playerStats.player.programming} / 100"),
                        _buildStatRow("Хакінг", "${playerStats.player.hacking} / 100"),
                        _buildStatRow("Злам замків", "${playerStats.player.lockpicking} / 100"),
                        _buildStatRow("Стелс", "${playerStats.player.stealth_mode} / 100"),
                        const SizedBox(height: 6),

                        // Соціальні та інші
                        _buildStatRow("Вплив", "${playerStats.player.influence} / 100"),
                        _buildStatRow("Досвід масажу", "${playerStats.player.massage_experience} / ${playerStats.maxMassage_experience}"),
                        _buildStatRow("Успішність", "${playerStats.player.college_success} / ${playerStats.maxCollege_success}"),
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
}
