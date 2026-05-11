import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/player_stats_controller.dart';

/// Міні-квест «спалився»: після [GameWorldState.spyOnSemParentsDone] — розмова з Danielle в кімнаті.
abstract final class DanielleSpyCaughtQuest {
  DanielleSpyCaughtQuest._();

  static const String npcId = 'danielle';

  static const String imagePath =
      'lib/assets/npcs/danielle/razgovor_kogda_spalila.png';

  static const int repeatSpyThreshold = 3;
  static const int repeatCounterMax = 10;
  static const int repeatThreatDialogueFromCount = 3;
  static const String defaultDialogueKey = 'danielle_spy_caught_dialogue';
  static const String repeatDialogueKey = 'danielle_spy_caught_repeat_dialogue';

  static bool isPending(GameWorldState world) {
    if (!world.spyOnSemParentsDone) return false;
    // Перша розмова — одразу після першого повного підглядання.
    if (!world.danielleSpyCaughtConfrontationDone) return true;
    // Далі розмова знову з’являється лише коли накопичено 3+ повтори.
    return world.danielleSpyCaughtConfrontationCount >= repeatSpyThreshold;
  }

  static String dialogueL10nKey(GameWorldState world) {
    if (world.danielleSpyCaughtConfrontationDone) {
      return repeatDialogueKey;
    }
    return defaultDialogueKey;
  }

  static void applyCompletionRewards(
    GameWorldState world,
    PlayerStatsController stats,
    Iterable<NPCModel> npcs,
  ) {
    if (!world.danielleSpyCaughtConfrontationDone) {
      world.danielleSpyCaughtConfrontationDone = true;
      stats.changeCharisma(1);
      stats.changeArousal(15);
      for (final n in npcs) {
        if (n.id != npcId) continue;
        n.addRelationship(5);
        n.changeBehavior(3);
        n.changeLust(2);
        break;
      }
    }
    // Після розмови запускаємо новий цикл накопичення повторів.
    world.danielleSpyCaughtConfrontationCount = 0;
    // Дозволяємо повторний запуск spyOnSemParents після розмови.
    world.spyOnSemParentsDone = false;
    world.spyOnSemParentsSpottedByDanielle = false;
    world.spyOnSemParentsParentsRoomPeekDone = false;
    world.spyOnSemParentsPlayerArousalDeltaApplied = null;
  }
}
