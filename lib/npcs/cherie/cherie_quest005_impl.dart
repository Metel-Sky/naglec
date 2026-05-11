// ignore_for_file: public_member_api_docs

part of 'cherie_quests.dart';

/// QUEST: cherie_quest_005 — шлях у рекламу (офіс ТРЦ після контракту з квесту 4).
final class CherieQuest005Patch {
  const CherieQuest005Patch({
    required this.newsL10nKey,
    this.videoPath,
    this.imagePath,
    this.videoMuted = false,
    this.fullScreen = true,
    this.closeWhenCompleted = false,
    this.loopVideo = true,
  });

  final String newsL10nKey;
  final String? videoPath;
  final String? imagePath;
  final bool videoMuted;
  final bool fullScreen;
  final bool closeWhenCompleted;
  final bool loopVideo;
}

abstract final class CherieQuest005L10n {
  static const step1 = 'cherie_quest_005_step1_news';
  static const step2 = 'cherie_quest_005_step2_news';
  static const step3 = 'cherie_quest_005_step3_news';
  static const step4 = 'cherie_quest_005_step4_news';
  static const step41 = 'cherie_quest_005_step4_1_news';
  static const step42 = 'cherie_quest_005_step4_2_news';
  static const step5v1 = 'cherie_quest_005_step5_variant1_news';
  static const step6 = 'cherie_quest_005_step6_news';
  static const step7 = 'cherie_quest_005_step7_news';
  static const step8 = 'cherie_quest_005_step8_news';
  static const step9 = 'cherie_quest_005_step9_news';
  static const step10 = 'cherie_quest_005_step10_news';
  static const step11 = 'cherie_quest_005_step11_news';

  static const btnRide = 'cherie_quest_004_btn_ride';
  static const btnGropeChest = 'cherie_quest_004_btn_grope_chest';
  static const btnPetKitty = 'cherie_quest_004_btn_pet_kitty';
  static const btnFinish = 'cherie_quest_004_btn_finish';
  static const btnLick = 'cherie_quest_005_btn_lick';
  static const btnLeave = 'cherie_quest_004_btn_leave';
  static const btnEllipsis = 'cherie_quest_004_btn_ellipsis';
  static const btnAgree = 'cherie_quest_005_btn_agree';
  static const btnDecline = 'cherie_quest_005_btn_decline';
  static const btnExitPool = 'cherie_quest_005_btn_exit_pool';
}

abstract final class CherieQuest005 {
  CherieQuest005._();

  static const String questId = 'cherie_quest_005';

  /// Поріг [GameWorldState.cherieQuest005Actor]: лінія 005 вважається завершеною (Q006 тощо).
  static const int completeActorThreshold = 10;

  static const int energyCostReward = 40;

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.cherieQuest005Step;
    return s >= 1 && s <= 13;
  }

  /// Увесь активний квест — без списання часу на переходи між зонами.
  static bool suppressTravelTime(GameWorldState world) =>
      isActiveMidFlow(world);

  static bool isOfficePhase(GameWorldState world) =>
      world.cherieQuest005Step == 1;

  static bool isBedroomPhase(GameWorldState world) {
    final s = world.cherieQuest005Step;
    return s >= 2 && s <= 13;
  }

  static bool isScriptedDialogActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isActiveMidFlow(world)) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (isOfficePhase(world)) {
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
    if (!isActiveMidFlow(world)) return true;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (isOfficePhase(world)) {
      return currentZone == 'CITY' &&
          isInsideRoom &&
          r == LocationsData.cityMallGiftShopOffice;
    }
    return currentZone == 'POOR_VILLAGE' &&
        isInsideRoom &&
        r == LocationsData.poorVillageGiftShopOwnerRoom1;
  }

  static void abortAbandoned(GameWorldState world) {
    if (!isActiveMidFlow(world)) return;
    world.cherieQuest005Step = 0;
    world.cherieQuest005Step42PantsPick = 0;
  }

  static void resetSession(GameWorldState world) {
    world.cherieQuest005Step = 0;
    world.cherieQuest005Step42PantsPick = 0;
  }

  /// Крок 4.2: шлях до jpg за збереженим індексом (0..2).
  static String step42PantsImagePath(int pick) {
    switch (pick.clamp(0, 2)) {
      case 0:
        return CherieEvents.quest005Pants1StoyakJpg;
      case 1:
        return CherieEvents.quest005PantsJpg;
      default:
        return CherieEvents.quest005PantsRekJpg;
    }
  }

  /// Бонус збудження Чері при показі відповідної картинки (застосовується одразу при вході на крок 6).
  static int step42CherieArousalDeltaForPick(int pick) {
    switch (pick.clamp(0, 2)) {
      case 0:
        return 10;
      case 1:
        return 15;
      default:
        return 20;
    }
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
    if (!isOfficePhase(world)) return false;
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
    required String? eventVideoPath,
  }) {
    if (cherie == null) return false;
    if (world.cherieQuest005Actor >= completeActorThreshold) return false;
    if (!CherieQuest004.isLingerieContractDone(cherie)) return false;
    if (!CherieEvents.isCherieQuest005ScheduleWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    )) {
      return false;
    }
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return false;
    if (world.cherieQuest005Step != 0) return false;
    if (q1phase != CherieQuest001OfficePhase.inactive) return false;
    if (quest002ScriptedActive) return false;
    if (quest002MidFlow) return false;
    if (quest003ScriptedActive) return false;
    if (quest004MidFlow) return false;
    if (eventVideoPath != null) return false;
    if (npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    return true;
  }

  static void startOfficePhase(GameWorldState world) {
    world.cherieQuest005Step = 1;
    world.cherieQuest005Actor =
        world.cherieQuest005Actor.clamp(0, 99);
    world.cherieQuest005Lizun =
        world.cherieQuest005Lizun.clamp(0, 3);
  }

  /// Після «…» на кроці 6: гілка за [actor] / [lizun].
  static int stepAfterPantsEllipsis(GameWorldState world) {
    final a = world.cherieQuest005Actor;
    final l = world.cherieQuest005Lizun;
    if (a == 0 || l == 2) return 7;
    if (a == 1) return 8;
    if (a == 2) return 10;
    return 7;
  }

  static CherieQuest005Patch patchForState({required GameWorldState world}) {
    final s = world.cherieQuest005Step;
    switch (s) {
      case 1:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step1,
          videoPath: CherieEvents.tc1Webm,
        );
      case 2:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step2,
          videoPath: CherieEvents.quest004Massage7Webm,
        );
      case 3:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step3,
          videoPath: CherieEvents.quest004Massage8Webm,
        );
      case 4:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step4,
          videoPath: CherieEvents.quest004Massage9Webm,
        );
      case 5:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step41,
          videoPath: CherieEvents.quest005LickWebm,
        );
      case 6:
        return CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step42,
          imagePath: step42PantsImagePath(world.cherieQuest005Step42PantsPick),
          fullScreen: true,
        );
      case 7:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step5v1,
          videoPath: CherieEvents.quest005PantsStoyakWatchWebm,
        );
      case 8:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step6,
          videoPath: CherieEvents.quest004HomeContractTalkWebm,
        );
      case 9:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step7,
          imagePath: CherieEvents.quest005PantsRekJpg,
        );
      case 10:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step8,
          videoPath: CherieEvents.quest005SwimmingWebm,
        );
      case 11:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step9,
          imagePath: CherieEvents.quest005AfterSwimmingJpg,
        );
      case 12:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step10,
          videoPath: CherieEvents.quest005LickWebm,
        );
      case 13:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step11,
          imagePath: CherieEvents.quest005AfterSwimmingJpg,
        );
      default:
        return const CherieQuest005Patch(
          newsL10nKey: CherieQuest005L10n.step1,
        );
    }
  }

  static bool shouldPresentOfficeScriptedUi({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isOfficePhase(world)) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    return currentZone == 'CITY' &&
        isInsideRoom &&
        r == LocationsData.cityMallGiftShopOffice;
  }

  static bool shouldPresentBedroomScriptedUi({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isBedroomPhase(world)) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    return currentZone == 'POOR_VILLAGE' &&
        isInsideRoom &&
        r == LocationsData.poorVillageGiftShopOwnerRoom1;
  }

  // --- Нагороди (енергія −40 кожного разу) ---

  static void _baseAfterMassage(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
    required int money,
    required int relationship,
    required double arousal,
    int cherieArousalDelta = 0,
    bool resetCherieArousalToZero = false,
    num cherieBehaviorDelta = 0,
  }) {
    changeEnergy(-energyCostReward.toDouble());
    changeMoney(money);
    addGameMinutes(120);
    changeMassageExperience(1);
    cherie.addRelationship(relationship.toDouble());
    changeCharisma(1);
    changeArousal(arousal);
    if (resetCherieArousalToZero) {
      cherie.arousal = 0;
    } else if (cherieArousalDelta != 0) {
      cherie.changeArousal(cherieArousalDelta);
    }
    if (cherieBehaviorDelta != 0) {
      cherie.changeBehavior(cherieBehaviorDelta);
    }
  }

  /// Крок 2 — «закінчити».
  static void applyRewardStep2Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 100,
      relationship: 5,
      arousal: 25,
      cherieArousalDelta: 10,
      cherieBehaviorDelta: 10,
    );
  }

  /// Крок 3 — «закінчити».
  static void applyRewardStep3Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 100,
      relationship: 5,
      arousal: 25,
      cherieArousalDelta: 20,
      cherieBehaviorDelta: 15,
    );
  }

  /// Крок 4 — «піти» при lizun == 1 (ранній вихід на Майорщину, без трусів / лизуня).
  static void applyRewardStep4LeaveEarly(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 100,
      relationship: 10,
      arousal: 25,
    );
  }

  /// Крок 4.1 — «піти» після лизуня (з кроку 4).
  static void applyRewardStep41Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 175,
      relationship: 10,
      arousal: 25,
      resetCherieArousalToZero: true,
      cherieBehaviorDelta: 10,
    );
  }

  /// Варіант 1 після кроку 7 — «піти».
  static void applyRewardVariant1Leave(
    NPCModel cherie,
    GameWorldState world, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 150,
      relationship: 5,
      arousal: 25,
      cherieArousalDelta: 25,
      cherieBehaviorDelta: 15,
    );
    world.cherieQuest005Actor =
        (world.cherieQuest005Actor + 1).clamp(0, 99);
  }

  /// Крок 9 — фотосесія, «піти».
  static void applyRewardPhotoSessionLeave(
    NPCModel cherie,
    GameWorldState world, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 1100,
      relationship: 5,
      arousal: 25,
      cherieArousalDelta: 30,
      cherieBehaviorDelta: 15,
    );
    world.cherieQuest005Actor =
        (world.cherieQuest005Actor + 1).clamp(0, 99);
  }

  /// Крок 12 — погодився на контракт у басейні.
  static void applyRewardPoolAgreeLeave(
    NPCModel cherie,
    GameWorldState world, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 2500,
      relationship: 25,
      arousal: 30,
      resetCherieArousalToZero: true,
      cherieBehaviorDelta: 5,
    );
    world.cherieQuest005Actor =
        (world.cherieQuest005Actor + 1).clamp(0, 99);
    world.cherieQuest005Lizun = 1;
  }

  /// Крок 13 — «послати нахєр».
  static void applyRewardPoolDeclineLeave(
    NPCModel cherie,
    GameWorldState world, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    _baseAfterMassage(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      money: 100,
      relationship: 5,
      arousal: 25,
      cherieArousalDelta: 50,
      cherieBehaviorDelta: 25,
    );
    world.cherieQuest005Actor =
        (world.cherieQuest005Actor + 1).clamp(0, 99);
    world.cherieQuest005Lizun = 2;
  }
}
