import 'package:flutter/material.dart';

import '../npcs/in_room_video_playback.dart';
import 'room_npc_scene_template.dart';
import 'video_scene_widget.dart';

/// Результат [InRoomVideoSceneLauncher.launch] — шлях і tick для [VideoSceneWidget].
final class InRoomVideoSceneHandle {
  const InRoomVideoSceneHandle({
    required this.videoPath,
    required this.playbackTick,
    this.loop = true,
  });

  final String videoPath;
  final int playbackTick;
  final bool loop;
}

/// Єдина точка запуску in-room відео (перший шар view зони, не overlay).
/// Див. `.cursor/rules/in-room-video-playback.mdc`.
abstract final class InRoomVideoSceneLauncher {
  InRoomVideoSceneLauncher._();

  static String normalizePath(String videoPath) {
    final path = videoPath.trim();
    assert(path.isNotEmpty, 'in-room video path must not be empty');
    return path;
  }

  /// Запустити сцену: скинути overlay-блокери, перевірити шар, повернути handle.
  static InRoomVideoSceneHandle launch({
    required String videoPath,
    required int previousPlaybackTick,
    required void Function() clearOverlayBlockers,
    required String? overlayEventVideoPath,
    required String? eventVideoPendingButton,
    required String? eventImagePath,
    required bool allowEventImageOverlay,
    bool loop = true,
  }) {
    clearOverlayBlockers();
    final path = normalizePath(videoPath);
    final tick = previousPlaybackTick + 1;
    InRoomVideoPlayback.assertVideoUsesZoneRoomLayer(
      hasActiveInRoomVideo: true,
      videoPath: path,
      overlayEventVideoPath: overlayEventVideoPath,
      eventVideoPendingButton: eventVideoPendingButton,
      eventImagePath: eventImagePath,
      allowEventImageOverlay: allowEventImageOverlay,
    );
    return InRoomVideoSceneHandle(
      videoPath: path,
      playbackTick: tick,
      loop: loop,
    );
  }

  /// Перший шар у [StreetView] / [HomeView] — [VideoSceneWidget].
  static Widget buildZoneLayer({
    required String videoPath,
    required int playbackTick,
    required String keyPrefix,
    String? fallbackImagePath,
    bool loop = true,
  }) {
    final path = videoPath.trim();
    if (path.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(RoomNpcSceneTemplate.defaultClipRadius),
      child: KeyedSubtree(
        key: ValueKey('${keyPrefix}_${path}_$playbackTick'),
        child: VideoSceneWidget(
          videoPath: path,
          loop: loop,
          fallbackImagePath: fallbackImagePath,
        ),
      ),
    );
  }
}
