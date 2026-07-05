import '../../services/game_time_controller.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import '../../services/player_stats_controller.dart';
import '../../services/save_service.dart';
import '../../services/service_locator.dart';
import 'juniper_npc.dart';
import 'juniper_shower_videos.dart';

/// Бонуси за перегляд відео Juniper у кімнаті — не частіше **1 раз на ігрову годину**.
abstract final class JuniperVideoRewards {
  JuniperVideoRewards._();

  static bool isJuniperAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/npcs/juniper/') || lower.contains('junip_');
  }

  static String statsHourKey(String gameDateKey, int hour) =>
      '${gameDateKey}_$hour';

  static bool _tryConsumeStatsHour(GameWorldState world) {
    final time = sl<GameTimeController>();
    final key = statsHourKey(time.onlyDate, time.dateTime.hour);
    if (world.semJuniperVideoStatsHourKey == key) return false;
    world.semJuniperVideoStatsHourKey = key;
    return true;
  }

  /// +1 хтивість, +1 поведінка Juniper (фонові кліпи у кімнаті).
  static void tryGrantRoomVideoStats() {
    if (!_tryConsumeStatsHour(sl<GameWorldState>())) return;
    final npc = sl<NPCService>().npcById(kJuniperNpcId);
    if (npc == null) return;
    npc.changeLust(1);
    npc.changeBehavior(1);
    sl<SaveService>().autosave();
  }

  /// +10 збудженості Alex (сцена душу).
  static void tryGrantShowerArousal(PlayerStatsController stats) {
    if (!_tryConsumeStatsHour(sl<GameWorldState>())) return;
    stats.changeArousal(JuniperShowerVideos.playerArousalPerVideo);
    sl<SaveService>().autosave();
  }
}
