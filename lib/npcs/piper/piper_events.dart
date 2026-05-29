// ignore_for_file: public_member_api_docs

import 'dart:math';

import '../../data/locations_room_data.dart';
import '../../data/npc_interaction_types.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import 'piper_quests.dart';

/// EVENT: piper_event_001 — куріння в залі (вихідні, повторюваний).
/// EVENT: piper_event_002 — навчання в залі (вихідні, повторюваний).
/// EVENT: piper_event_003 — фітнес у залі (вихідні, повторюваний).
///
/// Спільний тригер: вхід у `hall` у слот 14–15 (сб–нд), Piper у залі → RNG **1–3**.
abstract final class PiperHallWeekendEvents {
  PiperHallWeekendEvents._();

  static const String event001Id = 'piper_event_001';
  static const String event002Id = 'piper_event_002';
  static const String event003Id = 'piper_event_003';

  static const int hallHourStart = 14;
  static const int hallHourEnd = 15;

  static const int variantSmokes = 1;
  static const int variantStudy = 2;
  static const int variantFitness = 3;

  static const String smokesVideo =
      'lib/assets/npcs/piper/video/piper_hall_smokes.webm';
  static const String studyVideo =
      'lib/assets/npcs/piper/video/piper_hall_study.webm';
  static const String fitnessVideo =
      'lib/assets/npcs/piper/video/piper_hall_fitness.webm';

  static const List<String> hallVideos = [
    smokesVideo,
    studyVideo,
    fitnessVideo,
  ];

  static const String branchSnitch = 'snitch';
  static const String branchBlackmail = 'blackmail';
  static const String branchPunish = 'punish';

  static bool isWeekend(int weekdayIndex) =>
      weekdayIndex == 5 || weekdayIndex == 6;

  static bool isHallWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    if (!isWeekend(weekdayIndex)) return false;
    return hour >= hallHourStart && hour <= hallHourEnd;
  }

  static bool isHallRoom({
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) == LocationsData.hall;
  }

  static bool isPiperInHall({
    required NPCService npcService,
    required int hour,
    required int weekdayIndex,
  }) {
    final piper = npcService.npcById('piper');
    if (piper == null) return false;
    return npcService.getCurrentLocationId(piper, hour, weekdayIndex) ==
        LocationsData.hall;
  }

  static bool isActiveScene({
    required GameWorldState world,
    required NPCService npcService,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int weekdayIndex,
    required int hour,
  }) {
    if (world.piperHallEventStep != 1) return false;
    if (!isHallWindow(weekdayIndex: weekdayIndex, hour: hour)) return false;
    if (!isHallRoom(
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return false;
    }
    return isPiperInHall(
      npcService: npcService,
      hour: hour,
      weekdayIndex: weekdayIndex,
    );
  }

  static bool canRollOnHallEnter({
    required GameWorldState world,
    required NPCService npcService,
    required int weekdayIndex,
    required int hour,
  }) {
    if (world.piperHallEventStep != 0) return false;
    if (!isHallWindow(weekdayIndex: weekdayIndex, hour: hour)) return false;
    return isPiperInHall(
      npcService: npcService,
      hour: hour,
      weekdayIndex: weekdayIndex,
    );
  }

  static int rollVariant([Random? rng]) {
    final r = rng ?? Random();
    return r.nextInt(3) + 1;
  }

  static String eventIdForVariant(int variant) {
    return switch (variant) {
      variantSmokes => event001Id,
      variantStudy => event002Id,
      variantFitness => event003Id,
      _ => event001Id,
    };
  }

  static String videoPathForVariant(int variant) {
    final index = variant.clamp(1, 3) - 1;
    return hallVideos[index];
  }

  static String introNewsL10nForVariant(int variant) {
    return switch (variant) {
      variantSmokes => 'piper_event_001_intro_news',
      variantStudy => 'piper_event_002_intro_news',
      variantFitness => 'piper_event_003_intro_news',
      _ => 'piper_event_001_intro_news',
    };
  }

  static String branchNewsL10n(String branch) {
    return switch (branch) {
      branchSnitch => 'piper_event_001_branch_snitch_news',
      branchBlackmail => 'piper_event_001_branch_blackmail_news',
      branchPunish => 'piper_event_001_branch_punish_news',
      _ => 'piper_event_001_intro_news',
    };
  }

  static bool hasSmokesBranchMenu(int variant) => variant == variantSmokes;

  static bool isScriptedDialogActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int weekdayIndex,
    required int hour,
    required NPCService npcService,
  }) {
    final s = world.piperHallEventStep;
    if (s != 1 && s != 2) return false;
    if (!isHallRoom(
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return false;
    }
    if (s == 2) return true;
    return isActiveScene(
      world: world,
      npcService: npcService,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      weekdayIndex: weekdayIndex,
      hour: hour,
    );
  }

  static void incrementCompletion(GameWorldState world, int variant) {
    switch (variant) {
      case variantSmokes:
        world.piperEvent001Completions++;
      case variantStudy:
        world.piperEvent002Completions++;
      case variantFitness:
        world.piperEvent003Completions++;
    }
  }

  static const smokesIntroPatch = PiperQuest001Patch(
    newsL10nKey: 'piper_event_001_intro_news',
  );
}

/// Івенти та взаємодії для Piper.
List<NpcInteractionSlot> get piperInteractionSlots => [
      NpcInteractionSlot(
        npcId: 'piper',
        location: '',
        hourStart: 0,
        hourEnd: 24,
        actions: defaultInteractionActions,
      ),
    ];
