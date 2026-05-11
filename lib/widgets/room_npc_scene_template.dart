import 'dart:math';

import 'package:flutter/material.dart';

import '../models/npc_model.dart';
import '../services/npc_service.dart';
import 'video_scene_widget.dart';

/// Шаблон відображення кімнати з NPC як у **коледжі**:
/// - фон — картинка/відео кімнати на весь блок (`BoxFit.cover` для растру);
/// - NPC — **оверлей знизу по центру**, висота **[npcOverlayHeightFraction]** від висоти віджета,
///   `BoxFit.contain` (як Amia/Lisa/Den у [CollegeView]).
///
/// Для сцен, де саме медіа NPC має бути повноекранним (кухня мами з відео тощо), не використовуйте цей шаблон —
/// залишайте окрему логіку.
class RoomNpcSceneTemplate {
  RoomNpcSceneTemplate._();

  /// Частка висоти блоку під силует NPC (збігається з коледжем / автосалоном).
  static const double npcOverlayHeightFraction = 0.9;

  static const double defaultClipRadius = 15;

  /// Якщо в даних локації немає картинки кімнати.
  static const String fallbackRoomImagePath =
      'lib/assets/location/home_gg/rooms/kitchen.jpg';

  /// Фон локації: відео або зображення на весь простір (`BoxFit.cover`).
  static Widget layerBackground(String path) {
    if (path.endsWith('.mp4') || path.endsWith('.webm')) {
      return VideoSceneWidget(videoPath: path);
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white24, size: 50),
        ),
      ),
    );
  }

  /// `ClipRRect` + `LayoutBuilder` + `Stack`: фон кімнати + опційно растровий NPC знизу (90%).
  ///
  /// [npcRasterAssetPath] — лише растр (png/jpg/webp); відео тут не показуємо.
  /// [npcRasterFallbackPath] — якщо основний асет не знайдено (наприклад macOS), показуємо цей растр.
  static Widget clippedRoomWithNpcOverlay({
    required String roomBackgroundPath,
    String? npcRasterAssetPath,
    String? npcRasterFallbackPath,
    required VoidCallback onTap,
    double borderRadius = defaultClipRadius,
  }) {
    final displayPath = _effectiveNpcRasterPath(npcRasterAssetPath, npcRasterFallbackPath);
    final fbTrim = npcRasterFallbackPath?.trim();
    final errorFallback = (fbTrim != null &&
            fbTrim.isNotEmpty &&
            displayPath != null &&
            fbTrim != displayPath)
        ? fbTrim
        : null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxH = constraints.maxHeight;
            final maxW = constraints.maxWidth;
            final overlayHeight = maxH.isFinite
                ? maxH * npcOverlayHeightFraction
                : (maxW.isFinite ? maxW * npcOverlayHeightFraction : 400.0);

            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: layerBackground(roomBackgroundPath),
                ),
                if (displayPath != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: overlayHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onTap,
                      child: _NpcOverlayRaster(
                        primaryPath: displayPath,
                        fallbackPath: errorFallback,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String? _effectiveNpcRasterPath(String? primary, String? fallback) {
    final p = primary?.trim();
    if (p != null && p.isNotEmpty && !p.toLowerCase().endsWith('.mp4') && !p.toLowerCase().endsWith('.webm')) {
      return p;
    }
    final f = fallback?.trim();
    if (f != null && f.isNotEmpty && !f.toLowerCase().endsWith('.mp4') && !f.toLowerCase().endsWith('.webm')) {
      return f;
    }
    return null;
  }
}

/// Растр NPC поверх фону: [primaryPath], при помилці — [fallbackPath].
class _NpcOverlayRaster extends StatelessWidget {
  const _NpcOverlayRaster({
    required this.primaryPath,
    this.fallbackPath,
  });

  final String primaryPath;
  final String? fallbackPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      primaryPath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) {
        final fb = fallbackPath?.trim();
        if (fb != null && fb.isNotEmpty) {
          return Image.asset(
            fb,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => const _NpcOverlayPlaceholder(),
          );
        }
        return const _NpcOverlayPlaceholder();
      },
    );
  }
}

class _NpcOverlayPlaceholder extends StatelessWidget {
  const _NpcOverlayPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.person, color: Colors.white24, size: 56),
    );
  }
}

/// Вибір NPC для сцени (кілька кандидатів — seed по годині; обраний у смузі — [selectedNpcIdInRoom]).
class NpcRoomScenePicker {
  NpcRoomScenePicker._();

  static int hourlySeed(DateTime dt, int hour, String location) {
    final dayPart = dt.year * 10000 + dt.month * 100 + dt.day;
    return (dayPart * 24 + hour) * 31 + location.hashCode;
  }

  /// Повертає пару (npc, point) для відображення в [roomId] або null.
  static ({NPCModel npc, SchedulePoint point})? pickDisplayedNpc({
    required NPCService npcService,
    required String roomId,
    required int hour,
    required int weekday,
    required DateTime dateTime,
    String? selectedNpcIdInRoom,
  }) {
    final candidates = npcService.getCandidatesInRoom(roomId, hour, weekday);
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;
    if (selectedNpcIdInRoom != null) {
      for (final c in candidates) {
        if (c.npc.id == selectedNpcIdInRoom) return c;
      }
    }
    final i = Random(hourlySeed(dateTime, hour, roomId))
        .nextInt(candidates.length);
    return candidates[i];
  }

  static bool isRasterAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  static bool isVideoAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.webm');
  }

  /// Шлях до растру для оверлею: непорожній растровий [SchedulePoint.spritePath]
  /// (наприклад інший одяг у локації) має пріоритет над [NPCModel.avatarPath];
  /// інакше — аватар або sprite; відео — null.
  static String? npcRasterOverlayPath(NPCModel npc, SchedulePoint point) {
    final sp = point.spritePath.trim();
    if (sp.isNotEmpty && isRasterAssetPath(sp)) {
      return sp;
    }
    final av = npc.avatarPath;
    final path = (av != null && av.isNotEmpty) ? av : sp;
    if (path.isEmpty) return null;
    if (isVideoAssetPath(path)) return null;
    return path;
  }

  static String roomBackgroundPath(String? roomImagePath) =>
      (roomImagePath != null && roomImagePath.isNotEmpty)
          ? roomImagePath
          : RoomNpcSceneTemplate.fallbackRoomImagePath;
}
