import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';
import '../sem/sem_events.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import '../../services/player_stats_controller.dart';

/// Фази UI квесту **spyOnSemParents**: двері → три кроки з відео (усі з діалогом і кнопками).
enum DanielleSpyParentsPhase {
  /// Картинка дверей; «Підглядати» лише при стелсі ≥ [peek2MinStealth], інакше лише «Піти».
  door,
  watchVideo1,
  watchVideo2,
  watchVideo3,
}

/// Квест **spyOnSemParents**: підглядання біля кімнати батьків (картинка + діалог).
abstract final class DanielleSpyParentsQuest {
  DanielleSpyParentsQuest._();

  static const String imagePath =
      'lib/assets/location/houses/open_dor.jpg';

  /// Відео 1 — після «Підглядати» / початковий рівень.
  static const String peekVideoPath =
      'lib/assets/npcs/danielle/daniela_1_minet_perents.webm';

  static const String peekVideoPath2 =
      'lib/assets/npcs/danielle/daniela_2_sex_perents.webm';

  static const String peekVideoPath3 =
      'lib/assets/npcs/danielle/daniela_anal_perents.webm';

  static String peekVideoPathForTier(int tier) {
    switch (tier) {
      case 2:
        return peekVideoPath2;
      case 3:
        return peekVideoPath3;
      case 1:
      default:
        return peekVideoPath;
    }
  }

  /// Ключі l10n для тексту після відповідного ролика (tier 1..3).
  static String afterPeekDialogueKeyForTier(int tier) {
    switch (tier) {
      case 2:
        return 'danielle_spy_parents_after_peek_2_dialogue';
      case 3:
        return 'danielle_spy_parents_after_peek_3_dialogue';
      case 1:
      default:
        return 'danielle_spy_parents_after_peek_dialogue';
    }
  }

  /// Година ігрового часу **після** [GameNavigationController.handleRoomEntry]
  /// (враховує +5 хв при вході в кімнату). 20–22: у будні Danielle і Manuel
  /// разом у [friendParentsRoom] за розкладом (раніше о 20 Danielle була на кухні — тригер ніколи не спрацьовував).
  static const int triggerHour = 20;
  static const int triggerHourEnd = 22;

  static const int minStealth = 30;

  /// Стелс ≥ цього значення — кнопка «Підглядати» запускає відео 1.
  static const int peek2MinStealth = 40;

  /// Стелс ≥ цього значення — з відео 1 доступне «Дивитись далі» (відео 2).
  static const int peek3MinStealth = 50;

  static NPCModel? _npcById(Iterable<NPCModel> npcs, String id) {
    for (final n in npcs) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// Умови без перевірки поточної кімнати (після успішного входу в [friendParentsRoom]).
  static bool canTrigger({
    required GameWorldState world,
    required NPCService npcService,
    required PlayerStatsController playerStats,
    required int hourAfterEntry,
    required int weekdayIndex,
  }) {
    if (world.spyOnSemParentsDone) return false;
    if (playerStats.player.stealth_mode < minStealth) return false;
    if (hourAfterEntry < triggerHour || hourAfterEntry > triggerHourEnd) {
      return false;
    }
    // Сцена розрахована на будні, коли обидва батьки мають бути вдома ввечері.
    if (weekdayIndex > 4) return false;

    final sem = findSemNpc(npcService.allNPCs);
    if (sem == null || !SemParentsTalkEvent.isComplete(sem)) return false;

    final danielle = _npcById(npcService.allNPCs, 'danielle');
    final manuel = _npcById(npcService.allNPCs, 'korish_father');
    if (danielle == null || manuel == null) return false;

    final dLoc =
        npcService.getCurrentLocationId(danielle, hourAfterEntry, weekdayIndex);
    final mLoc =
        npcService.getCurrentLocationId(manuel, hourAfterEntry, weekdayIndex);
    if (dLoc != LocationsData.friendParentsRoom ||
        mLoc != LocationsData.friendParentsRoom) {
      return false;
    }
    return true;
  }

  static const String danielleNpcId = 'danielle';

  /// Після повного проходження квесту (3-тє відео або еквівалент з читів).
  static void applyDanielleCompletionStatBonuses(Iterable<NPCModel> npcs) {
    final danielle = _npcById(npcs, danielleNpcId);
    if (danielle == null) return;
    danielle.changeLust(15);
    danielle.addRelationship(20);
    danielle.changeBehavior(10);
  }

  /// Симетричний відкат [applyDanielleCompletionStatBonuses].
  static void revertDanielleCompletionStatBonuses(Iterable<NPCModel> npcs) {
    final danielle = _npcById(npcs, danielleNpcId);
    if (danielle == null) return;
    danielle.changeLust(-15);
    danielle.addRelationship(-20);
    danielle.changeBehavior(-10);
  }

  /// Нагороди після 3-го відео / читу «завершити»: прапорці peek, ГГ, Danielle.
  static void applySpyOnSemParentsTier3Rewards(
    GameWorldState world,
    PlayerStatsController playerStats,
    Iterable<NPCModel> npcs,
  ) {
    final p = playerStats.player;
    final delta = p.maxArousal - p.arousal;
    world.spyOnSemParentsPlayerArousalDeltaApplied = delta;
    playerStats.changeArousal(delta);
    playerStats.changeStealthMode(2);
    world.spyOnSemParentsParentsRoomPeekDone = true;
    world.spyOnSemParentsSpottedByDanielle = true;
    applyDanielleCompletionStatBonuses(npcs);
  }
}
