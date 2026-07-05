import '../../data/locations_room_data.dart';
import '../../services/game_world_state.dart';
import 'sem_juniper_evening_visits.dart';
import 'sem_quests.dart';

/// QUEST: sem_quest_001 — єдина сцена знайомства Alex ↔ Juniper у кімнаті Sem.
/// Відео [videoPath] і [l10nDialogue] використовуються **лише** тут.
abstract final class SemJuniperRoomIntro {
  SemJuniperRoomIntro._();

  static const String videoPath =
      'lib/assets/npcs/juniper/junip_sem_room_znakomstvo.mp4';

  static const String l10nDialogue = 'sem_juniper_room_intro_dialogue';
  static const String l10nSkippedDialogue =
      'sem_juniper_room_intro_skipped_dialogue';
  static const String l10nLeaveButton = 'sem_juniper_intro_leave';

  static bool ownsEventVideo(String? path) => path == videoPath;

  static bool isInSemRoom({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      SemQuest001.isInSemRoom(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  /// Сцена активна лише в кімnаті Sem під час intro UI.
  static bool isSceneActive({
    required bool introUiActive,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      introUiActive &&
      isInSemRoom(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  /// Після «Ну що, знайшов когось?» на фасаді — intro при вході в кімнату Sem.
  static bool canAutoStartNormal({
    required GameWorldState world,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (world.semJuniperMet) return false;
    if (!world.semJuniperFollowUpDone) return false;
    return isInSemRoom(
      zone: zone,
      streetHouse: streetHouse,
      insideRoom: insideRoom,
      room: room,
    );
  }

  /// 7+ днів без питання на фасаді — intro у день, коли Juniper у кімнаті Sem.
  static bool canAutoStartSkipped({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (world.semJuniperMet) return false;
    if (world.semJuniperFollowUpDone) return false;
    if (LocationsData.migrateLegacyRoomId(room) != LocationsData.friendRoom) {
      return false;
    }
    if (SemJuniperEveningVisits.locationAtHour(
          gameDateKey: gameDateKey,
          weekdayIndex: weekdayIndex,
          hour: hour,
          world: world,
        ) !=
        LocationsData.friendRoom) {
      return false;
    }
    return SemJuniperEarlyVisits.isActiveInRoom(
      world: world,
      gameDateKey: gameDateKey,
      weekdayIndex: weekdayIndex,
      hour: hour,
      zone: zone,
      streetHouse: streetHouse,
      insideRoom: insideRoom,
      room: room,
    );
  }

  /// Перший візит у кімнату Sem після follow-up або після шуму в коридорі.
  static bool canAutoStart({
    required GameWorldState world,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (world.semJuniperMet) return false;
    if (!isInSemRoom(
      zone: zone,
      streetHouse: streetHouse,
      insideRoom: insideRoom,
      room: room,
    )) {
      return false;
    }
    return world.semJuniperFollowUpDone || world.semJuniperCorridorNoiseShown;
  }

  static void markComplete(
    GameWorldState world,
    String gameDateKey, {
    required bool skippedFacadePath,
  }) {
    if (skippedFacadePath) {
      SemQuest001.markSkippedFacadeIntroDone(world, gameDateKey);
    } else {
      SemQuest001.markJuniperMet(world);
    }
  }
}
