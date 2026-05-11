import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../theme/game_theme.dart';
import 'left_panel_card_image.dart';

class StatsBottomMenu extends StatelessWidget {
  final VoidCallback onBackpackTap;
  final VoidCallback onPhoneTap;
  final VoidCallback onRefresh;
  final VoidCallback onDebugMenuTap;
  /// Перед переходом у налаштування (наприклад, закрити галерею персонажів).
  final VoidCallback? onBeforeSettingsNavigation;

  const StatsBottomMenu({
    super.key,
    required this.onBackpackTap,
    required this.onPhoneTap,
    required this.onRefresh,
    required this.onDebugMenuTap,
    this.onBeforeSettingsNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildIconButton(
            icon: Icons.settings_outlined,
            onTap: () async {
              onBeforeSettingsNavigation?.call();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              onRefresh();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onPhoneTap,
            child: Container(
              decoration: GameTheme.cardDecoration(radius: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: LeftPanelCardImage(
                  assetPath: 'lib/assets/left_panel/iphone.png',
                  padding: const EdgeInsets.only(top: 4, left: 6, right: 6, bottom: 6),
                  errorBuilder: (context, error, stackTrace) {
                    return LayoutBuilder(
                      builder: (context, c) {
                        final s = math.max(
                          20.0,
                          math.min(c.maxWidth, c.maxHeight) * 0.45,
                        );
                        return Center(
                          child: Icon(
                            Icons.phone_iphone,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: LeftPanelCardImage(
            assetPath: 'lib/assets/left_panel/setting.png',
            errorBuilder: (context, error, stackTrace) {
              return LayoutBuilder(
                builder: (context, c) {
                  final s = math.max(
                    20.0,
                    math.min(c.maxWidth, c.maxHeight) * 0.45,
                  );
                  return Center(child: Icon(icon, size: s, color: GameTheme.bgDark));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
