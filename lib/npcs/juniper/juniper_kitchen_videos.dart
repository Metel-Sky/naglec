import 'dart:math';

/// Відео Juniper на кухні Sem — випадковий ролик при кожному вході.
abstract final class JuniperKitchenVideos {
  JuniperKitchenVideos._();

  static const List<String> videos = [
    'lib/assets/npcs/juniper/junip_kitchn.mp4',
    'lib/assets/npcs/juniper/junip_kitchn_1.mp4',
  ];

  static bool isKitchenAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('junip_kitchn');
  }

  static String randomVideoPath() {
    if (videos.isEmpty) return '';
    return videos[Random().nextInt(videos.length)];
  }
}
