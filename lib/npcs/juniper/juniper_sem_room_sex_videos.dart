import '../../data/locations_room_data.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import '../../services/player_stats_controller.dart';
import '../../services/save_service.dart';
import '../../services/service_locator.dart';
import 'juniper_npc.dart';
import 'juniper_quest_003.dart';

/// Відео Juniper у кімнаті Sem (4 ролики) — суб 12:00, нд 16:00; у день catch quest 003 — 18:00.
abstract final class JuniperSemRoomSexVideos {
  JuniperSemRoomSexVideos._();

  static const int saturdayWeekdayIndex = 5;
  static const int sundayWeekdayIndex = 6;
  static const int saturdayHour = 12;
  static const int sundayHour = 16;

  static const List<String> videos = [
    'lib/assets/npcs/juniper/junip_sem_room_sex_01.mp4',
    'lib/assets/npcs/juniper/junip_sem_room_sex_02.mp4',
    'lib/assets/npcs/juniper/junip_sem_room_sex_03.mp4',
    'lib/assets/npcs/juniper/junip_sem_room_sex_04_palivo.mp4',
  ];

  static const int tierCount = 4;

  static const double playerArousalOnComplete = 30;
  static const int juniperLustOnComplete = 10;
  static const int juniperArousalOnComplete = 15;
  static const int juniperBehaviorOnComplete = 15;

  static const String l10nWatchMore = 'juniper_sem_room_sex_watch_more';

  static bool isSexAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('junip_sem_room_sex_');
  }

  static String videoPath({required int tier}) {
    if (videos.isEmpty) return '';
    final clampedTier = tier.clamp(1, videos.length);
    return videos[clampedTier - 1];
  }

  static bool isScheduledHour(int weekdayIndex, int hour) =>
      (weekdayIndex == saturdayWeekdayIndex && hour == saturdayHour) ||
      (weekdayIndex == sundayWeekdayIndex && hour == sundayHour);

  static bool isInSemRoom(String roomId) =>
      LocationsData.migrateLegacyRoomId(roomId) == LocationsData.friendRoom;

  /// Juniper у кімнаті Sem за розкладом або quest 003 catch-день о 18:00.
  static bool isSceneActiveAt({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
  }) {
    if (!world.semJuniperDating) return false;
    if (isScheduledHour(weekdayIndex, hour)) return true;
    return JuniperQuest003.isSemRoomSexOfferActive(
      world: world,
      gameDateKey: gameDateKey,
    );
  }

  static bool isActiveInRoom({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (streetHouse != LocationsData.friendHouse ||
        zone != 'STREET' ||
        !insideRoom) {
      return false;
    }
    if (!isInSemRoom(room)) return false;
    return isSceneActiveAt(
      world: world,
      gameDateKey: gameDateKey,
      weekdayIndex: weekdayIndex,
      hour: hour,
    );
  }

  /// Нагороди після перегляду всіх 4 роликів; [palivo] = 1 (перше з чотирьох).
  static void applyCompletionRewards({
    required GameWorldState world,
    required PlayerStatsController playerStats,
  }) {
    world.semJuniperSemRoomSexWitnessCount =
        world.semJuniperSemRoomSexWitnessCount + 1;

    if (world.semJuniperSemRoomSexCompleted) {
      sl<SaveService>().autosave();
      return;
    }

    world.semJuniperSemRoomSexCompleted = true;
    if (world.palivo < 1) world.palivo = 1;

    playerStats.changeArousal(playerArousalOnComplete);

    final npc = sl<NPCService>().npcById(kJuniperNpcId);
    if (npc != null) {
      npc.changeLust(juniperLustOnComplete);
      npc.changeArousal(juniperArousalOnComplete);
      npc.changeBehavior(juniperBehaviorOnComplete);
    }

    sl<SaveService>().autosave();
  }
}
