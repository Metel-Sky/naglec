import '../../data/npc_finance_time.dart';
import '../../services/game_world_state.dart';

/// Гігієна ГГ: без миття 3+ ігрових дні — «смердить», NPC відмовляються спілкуватись.
abstract final class GgHygiene {
  GgHygiene._();

  static const int stinkyAfterDays = 3;

  static const String avatarNormalLeftPanel = 'lib/assets/left_panel/gg.png';
  static const String avatarNormalStats = 'lib/assets/gg/pers.png';
  static const String avatarStinky = 'lib/assets/gg/gg_stinky.png';

  static bool isStinky(GameWorldState world) =>
      world.ggDaysSinceWash >= stinkyAfterDays;

  static String leftPanelAvatar(GameWorldState world) =>
      isStinky(world) ? avatarStinky : avatarNormalLeftPanel;

  static String statsAvatar(GameWorldState world) =>
      isStinky(world) ? avatarStinky : avatarNormalStats;

  /// +1 день без миття на кожен новий ігровий день (раз на `yyyy-M-d`).
  static void syncDayTick(GameWorldState world, DateTime gameNow) {
    final dayKey = npcFinanceGameDayKey(gameNow);
    if (world.ggHygieneLastTickGameDayKey == null) {
      world.ggHygieneLastTickGameDayKey = dayKey;
      return;
    }
    if (world.ggHygieneLastTickGameDayKey == dayKey) return;
    world.ggHygieneLastTickGameDayKey = dayKey;
    world.ggDaysSinceWash++;
  }

  static void wash(GameWorldState world, DateTime gameNow) {
    world.ggDaysSinceWash = 0;
    world.ggHygieneLastTickGameDayKey = npcFinanceGameDayKey(gameNow);
  }
}
