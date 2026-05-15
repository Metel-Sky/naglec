// ignore_for_file: public_member_api_docs

import '../../models/npc_model.dart';
import '../../models/npc_secondary.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';

/// Івент **001 стояк**: ГГ з максимальним збудженням зустрічає жіночого NPC — короткий діалог, лише «Назад».
///
/// Прапор «бачила зі стояком» ([sawVar]) скидається **лише о 6:00** ігрового дня (раз на дату).
abstract final class GgEvent001Stojak {
  GgEvent001Stojak._();

  static const String sawVar = 'gg_event_001_stojak_saw';

  /// Мама й сестри — окремий облік у ТЗ; скидання разом з усіма жінками о 6:00.
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

  /// Після 6:00 — один раз на календарну дату скидаємо [sawVar] у всіх жіночих NPC івенту.
  static void resetDailyAtSixIfNeeded(
    GameWorldState world,
    NPCService npcService,
    DateTime gameNow,
  ) {
    if (gameNow.hour < 6) return;
    final dayKey = '${gameNow.year}-${gameNow.month}-${gameNow.day}';
    if (world.ggEvent001StojakLastResetDayKey == dayKey) return;
    world.ggEvent001StojakLastResetDayKey = dayKey;
    for (final npc in npcService.allNPCs) {
      if (!isEligibleNpc(npc)) continue;
      npc.setVar(sawVar, false);
    }
  }
}
