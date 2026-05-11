// ignore_for_file: public_member_api_docs

part of 'cherie_quests.dart';

/// QUEST: cherie_quest_006 — новий етап відносин (офіс ТРЦ після квесту 5, lizun == 2).
final class CherieQuest006Patch {
  const CherieQuest006Patch({
    required this.newsL10nKey,
    this.videoPath,
    this.videoMuted = false,
    this.fullScreen = true,
    this.closeWhenCompleted = false,
    this.loopVideo = true,
  });

  final String newsL10nKey;
  final String? videoPath;
  final bool videoMuted;
  final bool fullScreen;
  final bool closeWhenCompleted;
  final bool loopVideo;
}

abstract final class CherieQuest006L10n {
  static const step1 = 'cherie_quest_006_step1_news';
  static const step2 = 'cherie_quest_006_step2_news';
  static const step3 = 'cherie_quest_006_step3_news';
  static const step4 = 'cherie_quest_006_step4_news';
  static const btnOral = 'cherie_quest_006_btn_oral';
  static const btnHair = 'cherie_quest_006_btn_hair';
  static const btnFinish = 'cherie_quest_006_btn_finish';
  static const btnLeave = 'cherie_quest_004_btn_leave';
}

abstract final class CherieQuest006 {
  CherieQuest006._();

  static const String questId = 'cherie_quest_006';

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.cherieQuest006Step;
    return s >= 1 && s <= 4;
  }

  static bool isScriptedDialogActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isActiveMidFlow(world)) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    return currentZone == 'CITY' &&
        isInsideRoom &&
        r == LocationsData.cityMallGiftShopOffice;
  }

  static bool isLocationValidForActiveStep({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isActiveMidFlow(world)) return true;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    return currentZone == 'CITY' &&
        isInsideRoom &&
        r == LocationsData.cityMallGiftShopOffice;
  }

  static void abortAbandoned(GameWorldState world) {
    if (!isActiveMidFlow(world)) return;
    world.cherieQuest006Step = 0;
  }

  static void resetSession(GameWorldState world) {
    world.cherieQuest006Step = 0;
  }

  /// Після успішного «Піти» на кроці 3.
  static void markComplete(GameWorldState world) {
    world.cherieQuest006Complete = true;
    world.cherieRelationshipNewStage = true;
    world.cherieQuest006Step = 0;
  }

  static bool shouldResetOfficeSessionBecauseCherieLeft({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
  }) {
    if (!isActiveMidFlow(world)) return false;
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (r != LocationsData.cityMallGiftShopOffice) return false;
    if (cherie == null) return true;
    return npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice;
  }

  static bool canStartOfficeEntry({
    required NPCModel? cherie,
    required GameWorldState world,
    required int weekdayIndex,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required NPCService npcService,
    required CherieQuest001OfficePhase q1phase,
    required bool quest002ScriptedActive,
    required bool quest002MidFlow,
    required bool quest003ScriptedActive,
    required bool quest004MidFlow,
    required bool quest005MidFlow,
    required String? eventVideoPath,
  }) {
    if (cherie == null) return false;
    if (!world.cherieQuest005Complete) {
      return false;
    }
    if (world.cherieQuest005Lizun != 2) return false;
    if (world.cherieQuest006Complete) return false;
    if (world.cherieQuest006Step != 0) return false;
    if (!CherieEvents.isCherieQuest006ScheduleWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    )) {
      return false;
    }
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return false;
    if (q1phase != CherieQuest001OfficePhase.inactive) return false;
    if (quest002ScriptedActive) return false;
    if (quest002MidFlow) return false;
    if (quest003ScriptedActive) return false;
    if (quest004MidFlow) return false;
    if (quest005MidFlow) return false;
    if (eventVideoPath != null) return false;
    if (npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    return true;
  }

  static void startOfficePhase(GameWorldState world) {
    world.cherieQuest006Step = 1;
  }

  static CherieQuest006Patch patchForState({required GameWorldState world}) {
    switch (world.cherieQuest006Step) {
      case 1:
        return const CherieQuest006Patch(
          newsL10nKey: CherieQuest006L10n.step1,
          videoPath: CherieEvents.quest006OfficeTc2Webm,
        );
      case 2:
        return const CherieQuest006Patch(
          newsL10nKey: CherieQuest006L10n.step2,
          videoPath: CherieEvents.quest006WorkAnimContract1Webm,
        );
      case 3:
        return const CherieQuest006Patch(
          newsL10nKey: CherieQuest006L10n.step3,
          videoPath: CherieEvents.quest006WorkAnimContract2Webm,
        );
      case 4:
        return const CherieQuest006Patch(
          newsL10nKey: CherieQuest006L10n.step4,
          videoPath: CherieEvents.quest006WorkSexRiserEndWebm,
        );
      default:
        return const CherieQuest006Patch(
          newsL10nKey: CherieQuest006L10n.step1,
        );
    }
  }

  /// Нагорода після кроку 3 — «піти».
  static void applyFinaleRewards(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeCharisma,
    required void Function(double) changeEnergy,
    required void Function() clearPlayerArousal,
  }) {
    changeMoney(2500);
    addGameMinutes(60);
    changeEnergy(-20);
    cherie.addRelationship(35);
    changeCharisma(1);
    clearPlayerArousal();
    cherie.changeArousal(30);
    cherie.changeBehavior(10);
  }
}
