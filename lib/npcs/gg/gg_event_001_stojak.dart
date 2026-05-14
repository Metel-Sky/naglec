// ignore_for_file: public_member_api_docs

import '../../models/npc_model.dart';
import '../../models/npc_secondary.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';

/// Івент **001 стояк**: ГГ з максимальним збудженням зустрічає жіночого NPC — короткий діалог, лише «Назад».
///
/// Для **мами та сестер** (`mom`, `elsa`, `piper`): прапор «бачила зі стояком» + скидання після
/// другої зустрічі без максимального збудження або після 6:00 ранку (ігровий день).
abstract final class GgEvent001Stojak {
  GgEvent001Stojak._();

  static const String sawVar = 'gg_event_001_stojak_saw';
  static const String noBulgeMeetVar = 'gg_event_001_stojak_no_bulge_meets';

  static const Set<String> familyNpcIds = {'mom', 'elsa', 'piper'};

  /// Жіночі NPC з повним меню (не другорядні).
  static bool isEligibleNpc(NPCModel npc) =>
      npc.gender == NpcGender.female && !isSecondaryNpc(npc);

  static bool isFullArousal(double arousal, double maxArousal) =>
      arousal >= maxArousal;

  static bool stojakDialogApplies(
    NPCModel npc,
    double playerArousal,
    double playerMaxArousal,
  ) =>
      isEligibleNpc(npc) &&
      isFullArousal(playerArousal, playerMaxArousal);

  /// Одноразово за «цикл» (поки [sawVar] ще false): нагороди NPC і [sawVar] = true.
  static void onStojakPanelFirstBuild(NPCModel npc) {
    if (!isEligibleNpc(npc)) return;
    if (npc.getVar(sawVar) == true) return;
    npc.setVar(sawVar, true);
    npc.changeArousal(10);
    npc.addRelationship(1.0);
    npc.changeBehavior(1);
  }

  static bool shouldRecordNeutralMeet(
    NPCModel npc,
    double playerArousal,
    double playerMaxArousal,
  ) {
    if (isFullArousal(playerArousal, playerMaxArousal)) return false;
    if (npc.getVar(sawVar) != true) return false;
    return true;
  }

  static int _intFromVar(NPCModel npc, String key) {
    final v = npc.variables[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  /// Друга зустріч без «стояка» після того, як бачила — скидає прапор і лічильник (лише мама/сестри).
  /// Інші жіночі NPC: одна зустріч без максимального збудження скидає [sawVar].
  static void onNeutralPanelOpen(
    NPCModel npc,
    double playerArousal,
    double playerMaxArousal,
  ) {
    if (npc.getVar(sawVar) != true) return;
    if (isFullArousal(playerArousal, playerMaxArousal)) return;

    if (familyNpcIds.contains(npc.id)) {
      final c = _intFromVar(npc, noBulgeMeetVar) + 1;
      npc.setVar(noBulgeMeetVar, c);
      if (c >= 2) {
        npc.setVar(sawVar, false);
        npc.setVar(noBulgeMeetVar, 0);
      }
    } else {
      npc.setVar(sawVar, false);
      npc.setVar(noBulgeMeetVar, 0);
    }
  }

  /// Після 6:00 ігрового дня — один раз на календарну дату скидаємо сімейні прапори.
  static void resetFamilyDailyIfNeeded(
    GameWorldState world,
    NPCService npcService,
    DateTime gameNow,
  ) {
    if (gameNow.hour < 6) return;
    final dayKey =
        '${gameNow.year}-${gameNow.month}-${gameNow.day}';
    if (world.ggEvent001StojakLastResetDayKey == dayKey) return;
    world.ggEvent001StojakLastResetDayKey = dayKey;
    for (final id in familyNpcIds) {
      final n = npcService.npcById(id);
      if (n == null) continue;
      n.setVar(sawVar, false);
      n.setVar(noBulgeMeetVar, 0);
    }
  }
}
