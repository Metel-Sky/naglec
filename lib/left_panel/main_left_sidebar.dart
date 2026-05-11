import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naglec/left_panel/stats_bottom_menu.dart';
import '../theme/game_theme.dart';
import '../services/player_stats_controller.dart';
import '../services/service_locator.dart';
import '../services/locale_controller.dart';
import 'stats_header_card.dart';
import 'stats_main_menu.dart';
import 'stats_girls_card.dart';

class MainLeftSidebar extends StatelessWidget {
  final PlayerStatsController playerStats;
  final VoidCallback onBackpackTap;
  final VoidCallback onPhoneTap;
  /// Відкрити екран збереження / завантаження.
  final VoidCallback onSaveTap;
  final VoidCallback onPersonTap;
  final VoidCallback? onNpcGalleryTap;
  final VoidCallback onRefresh;
  final VoidCallback onDebugMenuTap;
  /// Перед відкриттям налаштувань з нижнього меню (закрити галерею тощо).
  final VoidCallback? onBeforeSettingsNavigation;

  const MainLeftSidebar({
    super.key,
    required this.playerStats,
    required this.onBackpackTap,
    required this.onPhoneTap,
    required this.onSaveTap,
    required this.onPersonTap,
    this.onNpcGalleryTap,
    required this.onRefresh,
    required this.onDebugMenuTap,
    this.onBeforeSettingsNavigation,
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
                backgroundColor: Colors.redAccent.withValues(alpha: 0.7),
              ),
              onPressed: onDebugMenuTap,
              child: const Text("DEBUG: В МЕНЮ", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),

          // ОСНОВНА ПАНЕЛЬ
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              clipBehavior: Clip.hardEdge,
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

                  // Головне меню (Рюкзак, Стати ГГ)
                  Expanded(
                    flex: 30,
                    child: StatsMainMenu(
                      onBackpackTap: onBackpackTap,
                      onPersonTap: onPersonTap,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Нижнє меню (Налаштування, Телефон)
                  Expanded(
                    flex: 30,
                    child: StatsBottomMenu(
                      onBackpackTap: onBackpackTap,
                      onPhoneTap: onPhoneTap,
                      onRefresh: onRefresh,
                      onDebugMenuTap: onDebugMenuTap,
                      onBeforeSettingsNavigation: onBeforeSettingsNavigation,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Зберегти (ліворуч) + галерея NPC (праворуч)
                  Expanded(
                    flex: 23,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ListenableBuilder(
                            listenable: sl<LocaleController>(),
                            builder: (context, _) {
                              return Tooltip(
                                message: sl<LocaleController>().t('left_tooltip_save'),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onSaveTap,
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      decoration: GameTheme.cardDecoration(radius: 15),
                                      child: Center(
                                        child: LayoutBuilder(
                                          builder: (_, constraints) {
                                            final byWidth = constraints.maxWidth * 0.55;
                                            final capped = math.min(
                                              byWidth,
                                              constraints.maxHeight * 0.72,
                                            );
                                            final size = math.max(18.0, capped);
                                            return Icon(
                                              Icons.save_alt_rounded,
                                              size: size,
                                              color: GameTheme.bgDark,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatsGirlsCard(onTap: onNpcGalleryTap),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}