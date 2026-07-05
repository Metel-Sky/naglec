/// Шляхи відео мами — in-room патерн, не EventInteractionOverlay.
abstract final class MomVideos {
  MomVideos._();

  static const prefix = 'lib/assets/npcs/mom/video/';

  static bool ownsEventVideo(String? path) =>
      path != null && path.startsWith(prefix);
}
