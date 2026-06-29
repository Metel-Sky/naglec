import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../services/game_world_state.dart';
import '../services/service_locator.dart';
import '../npcs/gg/gg_hygiene.dart';
import 'left_panel_card_image.dart';

class StatsMainMenu extends StatelessWidget {
  final VoidCallback onBackpackTap;
  final VoidCallback onPersonTap;

  const StatsMainMenu({
    super.key,
    required this.onBackpackTap,
    required this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    final ggAvatarPath =
        GgHygiene.leftPanelAvatar(sl<GameWorldState>());
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onBackpackTap,
            child: Container(
              decoration: GameTheme.cardDecoration(radius: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: LeftPanelCardImage(
                  assetPath: 'lib/assets/left_panel/bag.png',
                  errorBuilder: (context, error, stackTrace) {
                    return LayoutBuilder(
                      builder: (context, c) {
                        final s = math.max(
                          20.0,
                          math.min(c.maxWidth, c.maxHeight) * 0.45,
                        );
                        return Center(
                          child: Icon(
                            Icons.backpack_outlined,
                            size: s,
                            color: Colors.white24,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onPersonTap,
            child: Container(
              decoration: GameTheme.cardDecoration(radius: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: LeftPanelCardImage(
                  assetPath: ggAvatarPath,
                  errorBuilder: (context, error, stackTrace) {
                    return LayoutBuilder(
                      builder: (context, c) {
                        final s = math.max(
                          20.0,
                          math.min(c.maxWidth, c.maxHeight) * 0.45,
                        );
                        return Center(
                          child: Icon(
                            Icons.person_outline,
                            size: s,
                            color: GameTheme.bgDark,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}