import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../services/player_stats_controller.dart';
import 'stats_header_card.dart';
import 'stats_main_menu.dart';
import 'stats_bottom_menu.dart';
import 'stats_girls_card.dart';

class MainLeftSidebar extends StatelessWidget {
  final PlayerStatsController playerStats;
  final VoidCallback onBackpackTap;
  final VoidCallback onPersonTap;
  final VoidCallback onRefresh;

  const MainLeftSidebar({
    super.key,
    required this.playerStats,
    required this.onBackpackTap,
    required this.onPersonTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 300),
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

            // Головне меню (Рюкзак)
            Expanded(
              flex: 30,
              child: StatsMainMenu(
                onBackpackTap: onBackpackTap,
              ),
            ),
            const SizedBox(height: 10),

            // Нижнє меню (Персонаж/Стати)
            Expanded(
              flex: 30,
              child: StatsBottomMenu(
                onBackpackTap: onBackpackTap,
                onPersonTap: onPersonTap,
              ),
            ),
            const SizedBox(height: 10),

            // Картка дівчат
            const Expanded(
                flex: 23,
                child: StatsGirlsCard()
            ),
          ],
        ),
      ),
    );
  }
}