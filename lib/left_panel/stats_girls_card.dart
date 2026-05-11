import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import 'left_panel_card_image.dart';

/// Нижній блок лівої панелі. Зовні — іконка; при натисканні відкривається меню з карточками NPC у головному вікні.
class StatsGirlsCard extends StatelessWidget {
  final VoidCallback? onTap;

  const StatsGirlsCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      decoration: GameTheme.cardDecoration(radius: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: LeftPanelCardImage(
          assetPath: 'lib/assets/left_panel/girls.png',
          errorBuilder: (context, error, stackTrace) {
            return LayoutBuilder(
              builder: (context, c) {
                final s = math.max(
                  20.0,
                  math.min(c.maxWidth, c.maxHeight) * 0.45,
                );
                return Center(
                  child: Icon(
                    Icons.people_alt,
                    size: s,
                    color: Colors.black87,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: child,
      ),
    );
  }
}