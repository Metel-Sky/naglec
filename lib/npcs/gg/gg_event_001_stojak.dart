// ignore_for_file: public_member_api_docs

import '../../models/npc_model.dart';
import '../../models/npc_secondary.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';

/// Івент **001 стояк**: ГГ з максимальним збудженням і жіночим NPC — один рядок у діалозі, лише «Піти».
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

  /// Обраний у смузі NPC або перша жінка в кімнаті (якщо нікого не обрано).
  static NPCModel? npcForStojakInRoom({
    required Iterable<NPCModel> activeNpcs,
    required String? selectedNpcIdInRoom,
  }) {
    final list = activeNpcs.toList();
    if (list.isEmpty) return null;
    if (selectedNpcIdInRoom != null) {
      for (final n in list) {
        if (n.id == selectedNpcIdInRoom) return n;
      }
    }
    for (final n in list) {
      if (isEligibleNpc(n)) return n;
    }
    return null;
  }

  static bool stojakAppliesInRoom({
    required Iterable<NPCModel> activeNpcs,
    required String? selectedNpcIdInRoom,
    required double playerArousal,
    required double playerMaxArousal,
  }) {
    final npc = npcForStojakInRoom(
      activeNpcs: activeNpcs,
      selectedNpcIdInRoom: selectedNpcIdInRoom,
    );
    if (npc == null) return false;
    return stojakDialogApplies(npc, playerArousal, playerMaxArousal);
  }

  /// Сценарний квест/івент на 100% збудженості (пріоритетніше generic stojak).
  static bool isSpecificFullArousalQuestContext({
    required String zone,
    required String room,
    required int hour,
    required Iterable<NPCModel> activeNpcs,
    required GameWorldState world,
  }) {
    // TODO: mom kitchen stojak quest (7–20) — окремий діалог і кнопки.
    return false;
  }

  /// Generic stojak — коли 100% збудженість + жінка в кімнаті, але немає сценарного квесту.
  static bool shouldShowGenericStojakFallback({
    required Iterable<NPCModel> activeNpcs,
    required String? selectedNpcIdInRoom,
    required double playerArousal,
    required double playerMaxArousal,
    required String zone,
    required String room,
    required int hour,
    required GameWorldState world,
  }) {
    if (!stojakAppliesInRoom(
      activeNpcs: activeNpcs,
      selectedNpcIdInRoom: selectedNpcIdInRoom,
      playerArousal: playerArousal,
      playerMaxArousal: playerMaxArousal,
    )) {
      return false;
    }
    return !isSpecificFullArousalQuestContext(
      zone: zone,
      room: room,
      hour: hour,
      activeNpcs: activeNpcs,
      world: world,
    );
  }

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
