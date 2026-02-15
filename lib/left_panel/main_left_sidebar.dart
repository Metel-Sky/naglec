import 'package:flutter/material.dart';
import 'package:naglec/left_panel/stats_bottom_menu.dart';
import '../theme/game_theme.dart';
import '../services/player_stats_controller.dart';
import 'stats_header_card.dart';
import 'stats_main_menu.dart';
import 'stats_girls_card.dart';

// 1. ДОДАЙ ЦЕЙ ІМПОРТ (перевір чи правильний шлях до файлу)


class MainLeftSidebar extends StatelessWidget {
  final PlayerStatsController playerStats;
  final VoidCallback onBackpackTap;
  final VoidCallback onPhoneTap;
  final VoidCallback onPersonTap;
  final VoidCallback onRefresh;
  final VoidCallback onDebugMenuTap;

  const MainLeftSidebar({
    super.key,
    required this.playerStats,
    required this.onBackpackTap,
    required this.onPhoneTap,
    required this.onPersonTap,
    required this.onRefresh,
    required this.onDebugMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 300),
      child: Column(
        children: [
          // КНОПКА ДЕБАГУ
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.7),
              ),
              onPressed: onDebugMenuTap,
              child: const Text("DEBUG: В МЕНЮ", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),

          // ОСНОВНА ПАНЕЛЬ
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: GameTheme.bgDark,
              ),
              child: Column(
                children: [
                  // Хедер зі статами
                  Expanded(
                    flex: 23,
                    child: StatsHeaderCard(
                      stats: playerStats,
                      onStatsChanged: onRefresh,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Головне меню (Рюкзак, Телефон)
                  Expanded(
                    flex: 30,
                    child: StatsMainMenu(
                      onBackpackTap: onBackpackTap,
                      onPhoneTap: onPhoneTap,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. ВИПРАВЛЕНО: ТЕПЕР ПЕРЕДАЄМО ВСІ 4 ПАРАМЕТРИ
                  Expanded(
                    flex: 30,
                    child: StatsBottomMenu(
                      onBackpackTap: onBackpackTap,
                      onPersonTap: onPersonTap,
                      onRefresh: onRefresh, // Додано
                      onDebugMenuTap: onDebugMenuTap, // Додано
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Картка дівчат
                  const Expanded(
                    flex: 23,
                    child: StatsGirlsCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}