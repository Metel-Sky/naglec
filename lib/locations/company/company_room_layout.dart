import 'package:flutter/material.dart';

import '../../widgets/room_npc_scene_template.dart';

/// Одна кнопка-«вікно» на правій панелі: зображення + опційний підпис, заокруглені кути.
class CompanyWindowButton extends StatelessWidget {
  final String? imagePath;
  final String label;
  final VoidCallback? onTap;

  const CompanyWindowButton({
    super.key,
    this.imagePath,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 2),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
            )
          else
            Container(color: Colors.grey[800]),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

/// Макет вікна компанії: одне велике вікно (фон) на весь екран, поверх нього справа — 2 маленькі вікна (30% ширини), що перекривають частину великого.
class CompanyRoomLayout extends StatelessWidget {
  /// Шлях до фонового зображення (велике вікно).
  final String backgroundImagePath;
  /// Підпис на великому фоні (ліва частина, не перекриває праві вікна), наприклад «Хол».
  final String? mainBackgroundLabel;
  /// Верхнє маленьке вікно справа.
  final Widget topWindow;
  /// Нижнє маленьке вікно справа (перекриває частину великого).
  final Widget bottomWindow;
  /// Опційно: силует NPC знизу (між фоном і вікнами справа), як у [RoomNpcSceneTemplate].
  final Widget? npcBottomOverlay;
  /// Тап по великому фону (не по правих кнопках-вікнах) — наприклад, щоб відкрити NPC на повноекранному кадрі.
  final VoidCallback? onMainBackgroundTap;

  const CompanyRoomLayout({
    super.key,
    required this.backgroundImagePath,
    this.mainBackgroundLabel,
    required this.topWindow,
    required this.bottomWindow,
    this.npcBottomOverlay,
    this.onMainBackgroundTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final rightPanelWidth = w * 0.30;
          const padding = 12.0;
          final windowHeight = h * 0.40;
          final remainingHeight = h - 2 * windowHeight;
          final gap = remainingHeight / 3;

          Widget background = Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[900],
              child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
            ),
          );
          final bgTap = onMainBackgroundTap;
          if (bgTap != null) {
            background = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: bgTap,
              child: background,
            );
          }

          final label = mainBackgroundLabel?.trim();
          return Stack(
            fit: StackFit.expand,
            children: [
              background,
              if (label != null && label.isNotEmpty)
                Positioned(
                  left: padding,
                  right: rightPanelWidth + padding * 2,
                  top: gap,
                  bottom: gap,
                  child: IgnorePointer(
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (npcBottomOverlay != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: h * RoomNpcSceneTemplate.npcOverlayHeightFraction,
                  child: ClipRect(
                    child: npcBottomOverlay!,
                  ),
                ),
              Positioned(
                right: padding,
                top: gap,
                width: rightPanelWidth,
                height: windowHeight,
                child: topWindow,
              ),
              Positioned(
                right: padding,
                top: gap + windowHeight + gap,
                width: rightPanelWidth,
                height: windowHeight,
                child: bottomWindow,
              ),
            ],
          );
        },
      ),
    );
  }
}
