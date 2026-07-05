import 'dart:math';

import '../../data/locations_room_data.dart';
import '../../services/game_world_state.dart';
import '../sem/sem_juniper_evening_visits.dart';

/// Відео Juniper у душі (3 набори × 3 ролики) — sem_quest_001, вечірні візити.
abstract final class JuniperShowerVideos {
  JuniperShowerVideos._();

  static const List<List<String>> showerSets = [
    [
      'lib/assets/npcs/juniper/junip_shower_1_01.mp4',
      'lib/assets/npcs/juniper/junip_shower_1_02.mp4',
      'lib/assets/npcs/juniper/junip_shower_1_03.mp4',
    ],
    [
      'lib/assets/npcs/juniper/junip_shower_2_01.mp4',
      'lib/assets/npcs/juniper/junip_shower_2_02.mp4',
      'lib/assets/npcs/juniper/junip_shower_2_03.mp4',
    ],
    [
      'lib/assets/npcs/juniper/junip_shower_3_01.mp4',
      'lib/assets/npcs/juniper/junip_shower_3_02.mp4',
      'lib/assets/npcs/juniper/junip_shower_3_03.mp4',
    ],
  ];

  static const double playerArousalPerVideo = 10;

  static bool isShowerAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('junip_shower_');
  }

  static int randomSetIndex() {
    if (showerSets.isEmpty) return 0;
    return Random().nextInt(showerSets.length);
  }

  static String videoPath({
    required int setIndex,
    required int tier,
  }) {
    final clampedSet = setIndex.clamp(0, showerSets.length - 1);
    final videos = showerSets[clampedSet];
    final clampedTier = tier.clamp(1, videos.length);
    return videos[clampedTier - 1];
  }

  /// Juniper у душі Sem за розкладом вечірніх візитів.
  static bool isJuniperInShowerAt({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
  }) {
    if (!SemJuniperEveningVisits.isActive(
      world,
      gameDateKey,
      weekdayIndex,
      hour,
    )) {
      return false;
    }
    return SemJuniperEveningVisits.locationAtHour(
          gameDateKey: gameDateKey,
          weekdayIndex: weekdayIndex,
          hour: hour,
          world: world,
        ) ==
        LocationsData.friendBathroom;
  }

  static bool isInFriendBathroom(String roomId) =>
      LocationsData.migrateLegacyRoomId(roomId) ==
      LocationsData.friendBathroom;
}
