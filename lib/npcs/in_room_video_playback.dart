import '../npcs/juniper/juniper_quest_001_kompromat.dart';
import '../npcs/juniper/juniper_quest_003.dart';
import '../npcs/juniper/juniper_sem_room_sex_videos.dart';
import '../npcs/juniper/juniper_shower_videos.dart';
import '../npcs/mom/mom_videos.dart';
import '../npcs/sem/sem_juniper_room_intro.dart';

/// Спільна логіка «відео в кімнаті» — перший шар view зони, не EventInteractionOverlay.
/// Запуск сцени: [InRoomVideoSceneLauncher] у `lib/widgets/in_room_video_scene_launcher.dart`.
/// Див. `.cursor/rules/in-room-video-playback.mdc`.
abstract final class InRoomVideoPlayback {
  InRoomVideoPlayback._();

  /// Чи шлях належить in-room сцені (не показувати через EventInteractionOverlay).
  static bool ownsKnownEventVideoPath(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    return SemJuniperRoomIntro.ownsEventVideo(path) ||
        JuniperShowerVideos.isShowerAssetPath(path) ||
        JuniperSemRoomSexVideos.isSexAssetPath(path) ||
        JuniperManuelKompromatInRoomScene.ownsEventVideo(path) ||
        JuniperQuest003.ownsEventVideo(path) ||
        MomVideos.ownsEventVideo(path);
  }

  /// Чи показувати основний view зони ([StreetView], [HomeView], …), а не overlay.
  ///
  /// Коли [hasActiveInRoomVideo] — overlay не повинен ховати view, інакше відео не стартує.
  static bool usesZoneRoomContentLayer({
    required bool hasActiveInRoomVideo,
    required String? overlayEventVideoPath,
    required String? eventVideoPendingButton,
    required String? eventImagePath,
    required bool allowEventImageOverlay,
  }) {
    // In-room відео (kompromat, душ, intro…) — завжди через StreetView/HomeView,
    // навіть якщо лишився _eventVideoPath / eventImagePath від іншого флоу.
    if (hasActiveInRoomVideo) return true;
    if (overlayEventVideoPath != null || eventVideoPendingButton != null) {
      return false;
    }
    return eventImagePath == null || allowEventImageOverlay;
  }

  /// Debug: переконатися, що відео сцени піде через view зони, а не overlay.
  static void assertVideoUsesZoneRoomLayer({
    required bool hasActiveInRoomVideo,
    required String? videoPath,
    required String? overlayEventVideoPath,
    required String? eventVideoPendingButton,
    required String? eventImagePath,
    required bool allowEventImageOverlay,
  }) {
    assert(hasActiveInRoomVideo, 'in-room video scene must be active');
    assert(
      videoPath != null && videoPath.trim().isNotEmpty,
      'in-room video path must be set',
    );
    assert(
      usesZoneRoomContentLayer(
        hasActiveInRoomVideo: hasActiveInRoomVideo,
        overlayEventVideoPath: overlayEventVideoPath,
        eventVideoPendingButton: eventVideoPendingButton,
        eventImagePath: eventImagePath,
        allowEventImageOverlay: allowEventImageOverlay,
      ),
      'EventInteractionOverlay blocks StreetView — video will not play',
    );
  }
}
