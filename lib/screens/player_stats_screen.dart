import 'package:flutter/material.dart';
import '../services/player_stats_controller.dart';

class PlayerStatsView extends StatelessWidget {
  final PlayerStatsController playerStats;

  const PlayerStatsView({super.key, required this.playerStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            "ХАРАКТЕРИСТИКИ ПЕРСОНАЖА",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Аватар
                Container(
                  width: 150,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('lib/assets/home_gg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Статистика
                Expanded(
                  child: ListView(
                    children: [
                      _buildStatLine("Енергія:", playerStats.vitality / 100),
                      _buildStatLine("Збудження:", playerStats.arousal / 100),
                      _buildStatLine("Хтивість:", playerStats.lust / playerStats.maxLust),
                      _buildStatLine("Фіз. форма:", playerStats.physical_fitness / playerStats.maxPhysical_fitness),
                      _buildStatLine("Бій:", playerStats.fighting / playerStats.maxFighting),
                      _buildStatLine("Успішність:", playerStats.college_success / playerStats.maxCollege_success),
                      _buildStatLine("Масаж:", playerStats.massage_experience / playerStats.maxMassage_experience),
                      _buildStatLine("Програмування:", 0.4), // Заглушка
                      _buildStatLine("Хакерство:", 0.2),      // Заглушка
                      _buildStatLine("Взлом замків:", 0.2),
                      _buildStatLine("Стелс режим:", 0.2),
                      _buildStatLine("Вплив:", 0.2),

                    ],
                  ),
                ),
              ],
            ),
          ),
          // Опис внизу

        ],
      ),
    );
  }

  Widget _buildStatLine(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Назва зліва - забирає весь вільний простір
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
          const SizedBox(width: 50),

          // Фіксований блок для шкали (приблизно 40% ширини центрального вікна)
          SizedBox(
            width: 280, // Фіксована ширина для всіх шкал
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: percent,
                        minHeight: 18,
                        backgroundColor: const Color(0xFF2D353C), // Чистий темний колір без опасіті
                        color: Colors.green, // Яскравий суцільний колір
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // Відсотки поверх шкали
                      Text(
                        "${(percent * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white, // Чорний текст краще читається на світло-зеленому
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}