import 'dart:math';

import 'package:flutter/material.dart';

import '../models/npc_model.dart';
import '../data/locations_room_data.dart';
import '../services/npc_service.dart';
import 'video_scene_widget.dart';

/// Шаблон відображення кімнати з NPC як у **коледжі**:
/// - фон — картинка/відео кімнати на весь блок (`BoxFit.cover` для растру);
/// - NPC — **оверлей знизу по центру на передньому плані** (Stack після фону),
///   висота **[npcOverlayHeightFraction]** від висоти віджета, `BoxFit.contain` (як Amia/Lisa/Den у [CollegeView]).
/// Для офісів БЦ використовуйте [clippedRoomWithNpcOverlay], а не окремий Container лише з фоном.
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
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4') || lower.endsWith('.webm')) {
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
    bool flipHorizontally = false,
    double npcOverlayScale = 1.0,
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
            final overlayHeight = (maxH.isFinite
                ? maxH * npcOverlayHeightFraction
                : (maxW.isFinite ? maxW * npcOverlayHeightFraction : 400.0)) *
                npcOverlayScale;

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
                        flipHorizontally: flipHorizontally,
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

  /// Два NPC знизу: лівий і правий оверлеї (Riley + Lana у спальні тощо).
  static Widget clippedRoomWithDualNpcOverlay({
    required String roomBackgroundPath,
    required String leftNpcRasterAssetPath,
    String? leftNpcRasterFallbackPath,
    required String rightNpcRasterAssetPath,
    String? rightNpcRasterFallbackPath,
    required VoidCallback onTapLeft,
    required VoidCallback onTapRight,
    bool leftFlipHorizontally = false,
    bool rightFlipHorizontally = false,
    double borderRadius = defaultClipRadius,
  }) {
    final leftPath =
        _effectiveNpcRasterPath(leftNpcRasterAssetPath, leftNpcRasterFallbackPath);
    final rightPath =
        _effectiveNpcRasterPath(rightNpcRasterAssetPath, rightNpcRasterFallbackPath);
    final leftFb = _errorFallbackPath(leftNpcRasterAssetPath, leftNpcRasterFallbackPath);
    final rightFb = _errorFallbackPath(rightNpcRasterAssetPath, rightNpcRasterFallbackPath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final maxW = constraints.maxWidth;
          final overlayHeight = maxH.isFinite
              ? maxH * npcOverlayHeightFraction
              : (maxW.isFinite ? maxW * npcOverlayHeightFraction : 400.0);
          final halfWidth = maxW.isFinite ? maxW * 0.5 : 200.0;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: layerBackground(roomBackgroundPath)),
              if (leftPath != null)
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: halfWidth,
                  height: overlayHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onTapLeft,
                    child: _NpcOverlayRaster(
                      primaryPath: leftPath,
                      fallbackPath: leftFb,
                      alignment: Alignment.bottomCenter,
                      flipHorizontally: leftFlipHorizontally,
                    ),
                  ),
                ),
              if (rightPath != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: halfWidth,
                  height: overlayHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onTapRight,
                    child: _NpcOverlayRaster(
                      primaryPath: rightPath,
                      fallbackPath: rightFb,
                      alignment: Alignment.bottomCenter,
                      flipHorizontally: rightFlipHorizontally,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String? _errorFallbackPath(String? primary, String? fallback) {
    final displayPath = _effectiveNpcRasterPath(primary, fallback);
    final fbTrim = fallback?.trim();
    if (fbTrim != null &&
        fbTrim.isNotEmpty &&
        displayPath != null &&
        fbTrim != displayPath) {
      return fbTrim;
    }
    return null;
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
    this.alignment = Alignment.bottomCenter,
    this.flipHorizontally = false,
  });

  final String primaryPath;
  final String? fallbackPath;
  final Alignment alignment;
  final bool flipHorizontally;

  Widget _wrapFlip(Widget child) {
    if (!flipHorizontally) return child;
    return Transform.flip(flipX: true, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return _wrapFlip(
      Image.asset(
        primaryPath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) {
          final fb = fallbackPath?.trim();
          if (fb != null && fb.isNotEmpty) {
            return _wrapFlip(
              Image.asset(
                fb,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                alignment: alignment,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const _NpcOverlayPlaceholder(),
              ),
            );
          }
          return const _NpcOverlayPlaceholder();
        },
      ),
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

  /// Масштаб оверлею NPC у конкретній кімнаті (1.0 = стандарт; Oleksandr у офісі — 1.08).
  static double npcOverlayScaleFor({
    required String roomId,
    String? npcId,
  }) {
    if (roomId == LocationsData.cityBcLogisticsBossOffice &&
        npcId == 'oleksandr') {
      return 1.08;
    }
    return 1.0;
  }

  /// Riley + Lana у спальні квартири 2 (елітний ЖК): Lana зліва, Riley справа.
  static ({({NPCModel npc, SchedulePoint point}) left, ({NPCModel npc, SchedulePoint point}) right})?
      rileyLanaBedroomPair(
    List<({NPCModel npc, SchedulePoint point})> candidates,
  ) {
    ({NPCModel npc, SchedulePoint point})? riley;
    ({NPCModel npc, SchedulePoint point})? lana;
    for (final c in candidates) {
      if (c.npc.id == 'riley') riley = c;
      if (c.npc.id == 'lana') lana = c;
    }
    if (riley == null || lana == null) return null;
    return (left: lana, right: riley);
  }

  /// Zazie + Geisha у спальні кв. 2 (Бандери 2): Zazie зліва, Geisha справа.
  static ({({NPCModel npc, SchedulePoint point}) left, ({NPCModel npc, SchedulePoint point}) right})?
      zazieGeishaBedroomPair(
    List<({NPCModel npc, SchedulePoint point})> candidates,
  ) {
    ({NPCModel npc, SchedulePoint point})? zazie;
    ({NPCModel npc, SchedulePoint point})? geisha;
    for (final c in candidates) {
      if (c.npc.id == 'zazie') zazie = c;
      if (c.npc.id == 'geisha') geisha = c;
    }
    if (zazie == null || geisha == null) return null;
    return (left: zazie, right: geisha);
  }
}
