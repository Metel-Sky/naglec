import 'dart:math';

import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import '../services/npc_service.dart';
import 'room_npc_scene_template.dart';

/// Шар NPC у кімнаті: фон-відео, растр знизу, активний NPC для тапу.
final class NpcRoomSceneLayers {
  const NpcRoomSceneLayers({
    this.specialBackground,
    this.npcRasterOverlay,
    this.activeNpc,
  });

  static const empty = NpcRoomSceneLayers();

  final String? specialBackground;
  final String? npcRasterOverlay;
  final NPCModel? activeNpc;
}

/// Єдина точка: хто показаний у кімнаті + картинка обраного NPC з лівої смуги.
abstract final class NpcRoomSceneResolver {
  NpcRoomSceneResolver._();

  /// Чи дозволено спецмедіа NPC (напр. відео мами), коли в смузі обрано іншого.
  static bool selectionAllows(String? selectedNpcIdInRoom, String npcId) =>
      selectedNpcIdInRoom == null || selectedNpcIdInRoom == npcId;

  /// [baseLayers] — спецмедіа до фіналізації (HomeView: кухня/душ мами). Інакше — pick з розкладу.
  /// [candidates] — якщо задано, pick з цього списку замість [NPCService.getCandidatesInRoom].
  static NpcRoomSceneLayers resolve({
    required NPCService npcService,
    required String roomId,
    required int hour,
    required int weekday,
    required DateTime dateTime,
    String? selectedNpcIdInRoom,
    bool suppressRoomNpcRaster = false,
    NpcRoomSceneLayers? baseLayers,
    List<({NPCModel npc, SchedulePoint point})>? candidates,
    int? pickSeed,
  }) {
    if (suppressRoomNpcRaster) return NpcRoomSceneLayers.empty;

    final current = baseLayers ??
        _fromSchedule(
          npcService: npcService,
          roomId: roomId,
          hour: hour,
          weekday: weekday,
          dateTime: dateTime,
          candidates: candidates,
          pickSeed: pickSeed,
          selectedNpcIdInRoom: selectedNpcIdInRoom,
        );

    return _applySelected(
      npcService: npcService,
      roomId: roomId,
      hour: hour,
      weekday: weekday,
      selectedNpcIdInRoom: selectedNpcIdInRoom,
      current: current,
    );
  }

  static NpcRoomSceneLayers fromCandidate(
    ({NPCModel npc, SchedulePoint point}) chosen,
  ) {
    final sp = chosen.point.spritePath.trim();
    if (sp.isNotEmpty && NpcRoomScenePicker.isVideoAssetPath(sp)) {
      return NpcRoomSceneLayers(
        specialBackground: sp,
        activeNpc: chosen.npc,
      );
    }
    return NpcRoomSceneLayers(
      npcRasterOverlay:
          NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point),
      activeNpc: chosen.npc,
    );
  }

  static NpcRoomSceneLayers _fromSchedule({
    required NPCService npcService,
    required String roomId,
    required int hour,
    required int weekday,
    required DateTime dateTime,
    List<({NPCModel npc, SchedulePoint point})>? candidates,
    int? pickSeed,
    String? selectedNpcIdInRoom,
  }) {
    final list =
        candidates ?? npcService.getCandidatesInRoom(roomId, hour, weekday);
    if (list.isEmpty) return NpcRoomSceneLayers.empty;
    if (list.length == 1) return fromCandidate(list.first);

    final selected = selectedNpcIdInRoom?.trim();
    if (selected != null && selected.isNotEmpty) {
      for (final c in list) {
        if (c.npc.id == selected) return fromCandidate(c);
      }
    }

    final chosen = list[
        Random(pickSeed ?? NpcRoomScenePicker.hourlySeed(dateTime, hour, roomId))
            .nextInt(list.length)];
    return fromCandidate(chosen);
  }

  static NpcRoomSceneLayers _applySelected({
    required NPCService npcService,
    required String roomId,
    required int hour,
    required int weekday,
    required String? selectedNpcIdInRoom,
    required NpcRoomSceneLayers current,
  }) {
    final selected = selectedNpcIdInRoom?.trim();
    if (selected == null || selected.isEmpty) return current;

    if (current.activeNpc?.id == selected) {
      if (current.specialBackground != null || current.npcRasterOverlay != null) {
        return current;
      }
    }

    final norm = LocationsData.migrateLegacyRoomId(roomId);
    final npc = npcService.npcById(selected);
    if (npc == null ||
        npcService.getCurrentLocationId(npc, hour, weekday) != norm) {
      return current;
    }

    for (final c in npcService.getCandidatesInRoom(roomId, hour, weekday)) {
      if (c.npc.id != selected) continue;
      return fromCandidate(c);
    }

    final av = npc.avatarPath?.trim();
    return NpcRoomSceneLayers(
      npcRasterOverlay: (av != null && av.isNotEmpty) ? av : null,
      activeNpc: npc,
    );
  }
}
