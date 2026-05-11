// ignore_for_file: public_member_api_docs

import '../../data/locations_room_data.dart';
import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import 'cherie_events.dart';
import 'cherie_quests.dart';

final class CherieMassageFunEventPatch {
  const CherieMassageFunEventPatch({
    required this.newsL10nKey,
    this.videoPath,
    this.videoMuted = false,
    this.fullScreen = true,
    this.loopVideo = true,
  });

  final String newsL10nKey;
  final String? videoPath;
  final bool videoMuted;
  final bool fullScreen;
  final bool loopVideo;
}

/// EVENT: cherie_event_004 — «розваги після массажу» (івент, не квест).
///
/// Пн / Ср / Пт, магазин подарунків 10–18, після cherie_quest_005 та cherie_quest_006.
abstract final class CherieMassageFunEvent {
  CherieMassageFunEvent._();

  static const String eventId = 'cherie_event_004';

  /// Скільки разів завершено івент (крок 6 «Піти» або крок 8 «Піти»), щоб на кроці 6 з’явилась «продовжити».
  static const int minCompletionsForBonusPath = 7;

  static bool suppressTravelTime(GameWorldState world) =>
      world.cherieMassageFunEventStep > 0;

  static bool prerequisitesMet(GameWorldState world) =>
      world.cherieQuest005Complete && world.cherieQuest006Complete;

  static bool isScheduleWindow({
    required int weekdayIndex,
    required int hour,
  }) {
    return CherieEvents.isCherieQuest004ScheduleWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    );
  }

  static bool noBlockingCherieQuest(GameWorldState world) {
    return !CherieQuest002.isActiveMidFlow(world) &&
        !CherieQuest003.isActiveMidFlow(world) &&
        !CherieQuest004.isActiveMidFlow(world) &&
        !CherieQuest005.isActiveMidFlow(world) &&
        !CherieQuest006.isActiveMidFlow(world);
  }

  static bool canStartOfficeEntry({
    required GameWorldState world,
    required int weekdayIndex,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required NPCModel? cherie,
    required NPCService npcService,
    required bool cherieAnimatorIntroInactive,
    required bool cherieQuest001OfficePhaseInactive,
  }) {
    if (world.cherieMassageFunEventStep != 0) return false;
    if (!cherieAnimatorIntroInactive) return false;
    if (!cherieQuest001OfficePhaseInactive) return false;
    if (!prerequisitesMet(world)) return false;
    if (!noBlockingCherieQuest(world)) return false;
    if (!isScheduleWindow(weekdayIndex: weekdayIndex, hour: hour)) {
      return false;
    }
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' ||
        !isInsideRoom ||
        r != LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (cherie == null) return false;
    if (npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    return true;
  }

  static bool isScriptedDialogActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    final s = world.cherieMassageFunEventStep;
    if (s <= 0) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (s == 1) {
      return currentZone == 'CITY' &&
          isInsideRoom &&
          r == LocationsData.cityMallGiftShopOffice;
    }
    return currentZone == 'POOR_VILLAGE' &&
        isInsideRoom &&
        r == LocationsData.poorVillageGiftShopOwnerRoom1;
  }

  static bool isLocationValidForActiveStep({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    return isScriptedDialogActive(
      world: world,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  static CherieMassageFunEventPatch patchForPresentationStep(int step) {
    switch (step) {
      case 1:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step1_news',
          videoPath: CherieEvents.tc1Webm,
        );
      case 2:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step2_news',
          videoPath: CherieEvents.quest004Massage7Webm,
        );
      case 3:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step3_news',
          videoPath: CherieEvents.quest004Massage8Webm,
        );
      case 4:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step4_news',
          videoPath: CherieEvents.quest004Massage9Webm,
        );
      case 5:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step5_news',
          videoPath: CherieEvents.massageFunAfter1Webm,
        );
      case 6:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step6_news',
          videoPath: CherieEvents.massageFunAfter2Webm,
        );
      case 7:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step7_news',
          videoPath: CherieEvents.massageFunFuckWebm,
        );
      case 8:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step8_news',
          videoPath: CherieEvents.massageFunFuck2EndWebm,
        );
      default:
        return const CherieMassageFunEventPatch(
          newsL10nKey: 'cherie_massage_fun_step1_news',
          videoPath: CherieEvents.tc1Webm,
        );
    }
  }

  /// Ранній вихід з кроку 2 або 3 («закінчити»).
  static void applyEarlyFinishFromStep2Or3({
    required NPCModel cherie,
    required int fromStep,
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    changeEnergy(-40);
    changeMoney(100);
    addGameMinutes(120);
    changeMassageExperience(1);
    cherie.addRelationship(5);
    changeCharisma(1);
    changeArousal(25);
    if (fromStep == 2) {
      cherie.changeArousal(10);
      cherie.changeBehavior(10);
    } else {
      cherie.changeArousal(20);
      cherie.changeBehavior(15);
    }
  }
}

