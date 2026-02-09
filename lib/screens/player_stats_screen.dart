import 'package:flutter/material.dart';
import 'package:naglec/services/player_stats_controller.dart';
import '../theme/game_theme.dart';

// Перейменовано на PlayerStatsView для відповідності коду
class PlayerStatsView extends StatelessWidget {
  final PlayerStatsController playerStats;

  const PlayerStatsView({super.key, required this.playerStats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ліва частина: Аватар
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'lib/assets/home_gg.jpg', // Шлях до аватара
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Права частина: Статистика
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow("Збудження", "${playerStats.arousal.toInt()}"),
                    _buildStatRow("Бадьорість", "${playerStats.vitality}", color: Colors.greenAccent),
                    const SizedBox(height: 20),
                    _buildStatRow("Хтивість", "${playerStats.lust} / ${playerStats.maxLust}"),
                    _buildStatRow("Фіз. форма", "${playerStats.physical_fitness} / ${playerStats.maxPhysical_fitness}"),
                    _buildStatRow("Бій", "${playerStats.fighting} / ${playerStats.maxFighting}"),
                    const SizedBox(height: 20),
                    _buildStatRow("Досвід масажу", "${playerStats.massage_experience} / ${playerStats.maxMassage_experience}"),
                    _buildStatRow("Успішність", "${playerStats.college_success} / ${playerStats.maxCollege_success}"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Опис персонажа
          Container(
            padding: const EdgeInsets.all(12),
            decoration: GameTheme.cardDecoration(),
            child: const Text(
              "Я майже звичайний хлопець, але у мене є бонуси, природа нагородила мене значним членом і неабияким розумом!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? Colors.white)),
        ],
      ),
    );
  }
}
