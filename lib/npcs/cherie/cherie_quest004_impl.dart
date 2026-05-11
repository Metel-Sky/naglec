// ignore_for_file: public_member_api_docs

part of 'cherie_quests.dart';

/// Сцена квесту **cherie_quest_004** (офіс або дім Чері).
final class CherieQuest004Patch {
  const CherieQuest004Patch({
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

abstract final class CherieQuest004L10n {
  static const step1 = 'cherie_quest_004_step1_news';
  static const step3Bedroom = 'cherie_quest_004_step3_bedroom_news';
  static const step4 = 'cherie_quest_004_step4_news';
  static const step5 = 'cherie_quest_004_step5_news';
  static const step6TurnAngry = 'cherie_quest_004_step6_turn_angry_news';
  static const step6TurnMassage5 = 'cherie_quest_004_step6_turn_massage5_news';
  static const step7Angry = 'cherie_quest_004_step7_angry_news';
  static const step7Ok = 'cherie_quest_004_step7_ok_news';
  static const step8 = 'cherie_quest_004_step8_news';
  static const step8GropeRebuff = 'cherie_quest_004_step8_grope_rebuff_news';
  static const step9 = 'cherie_quest_004_step9_news';
  static const step9PetRebuff = 'cherie_quest_004_step9_pet_rebuff_news';
  static const step10 = 'cherie_quest_004_step10_news';
  static const step11Contract = 'cherie_quest_004_step11_contract_news';

  static const btnRide = 'cherie_quest_004_btn_ride';
  static const btnEllipsis = 'cherie_quest_004_btn_ellipsis';
  static const btnFinish = 'cherie_quest_004_btn_finish';
  static const btnOfferLegs = 'cherie_quest_004_btn_offer_legs';
  static const btnOfferTurn = 'cherie_quest_004_btn_offer_turn';
  static const btnRemovePanties = 'cherie_quest_004_btn_remove_panties';
  static const btnGropeChest = 'cherie_quest_004_btn_grope_chest';
  static const btnPetKitty = 'cherie_quest_004_btn_pet_kitty';
  static const btnLeave = 'cherie_quest_004_btn_leave';
}

/// Гілки [GameWorldState.cherieQuest004Branch]: 1 — відбій «лапати»; 2 — відбій «пестити».
abstract final class CherieQuest004Branch {
  CherieQuest004Branch._();

  static const int gropeRebuff = 1;
  static const int petRebuff = 2;
}

/// Логіка **cherie_quest_004** (масажист, багаторазовий до контракту білизни).
abstract final class CherieQuest004 {
  CherieQuest004._();

  static const String questId = 'cherie_quest_004';
  static const String npcVarMasseur = 'cherie_quest_004_masseur';
  static const String npcVarLingerieContract = 'cherie_quest_004_lingerie_masseur';

  static int readMasseur(NPCModel? c) {
    if (c == null) return 0;
    final v = c.variables[npcVarMasseur];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  static void addMasseur(NPCModel c, int d) {
    final n = (readMasseur(c) + d).clamp(0, 999);
    c.setVar(npcVarMasseur, n);
  }

  static bool isLingerieContractDone(NPCModel? c) =>
      c?.getVar(npcVarLingerieContract) == true;

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.cherieQuest004Step;
    return s >= 1 && s <= 11;
  }

  static bool suppressTravelTime(GameWorldState world) {
    final s = world.cherieQuest004Step;
    return s >= 3 && s <= 11;
  }

  static bool isBedroomPhase(GameWorldState world) {
    final s = world.cherieQuest004Step;
    return s >= 3 && s <= 10;
  }

  static bool isContractHallPhase(GameWorldState world) =>
      world.cherieQuest004Step == 11;

  static bool isOfficePhase(GameWorldState world) =>
      world.cherieQuest004Step == 1;

  static bool isLocationValidForActiveStep({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    final s = world.cherieQuest004Step;
    if (s < 1 || s > 11) return true;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    if (s == 1) {
      return currentZone == 'CITY' &&
          isInsideRoom &&
          r == LocationsData.cityMallGiftShopOffice;
    }
    if (s >= 3 && s <= 10) {
      return currentZone == 'POOR_VILLAGE' &&
          isInsideRoom &&
          r == LocationsData.poorVillageGiftShopOwnerRoom1;
    }
    return currentZone == 'POOR_VILLAGE' &&
        isInsideRoom &&
        r == LocationsData.poorVillageGiftShopOwnerHall;
  }

  static void abortAbandoned(GameWorldState world) {
    if (!isActiveMidFlow(world)) return;
    world.cherieQuest004Step = 0;
    world.cherieQuest004Branch = 0;
    world.cherieQuest004LegsMassagePhase = false;
  }

  /// Офіс 1–2: Чері пішла зі слоту офісу — скинути сесію квесту 4.
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

  /// Старт з офісу (тап «офіс Чері» у магазині), якщо вікно Пн/Ср/Пт 10–18 і квест 003 виконано.
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
    required String? eventVideoPath,
  }) {
    if (cherie == null) return false;
    if (!CherieQuest003.isUnlocked(cherie)) return false;
    if (isLingerieContractDone(cherie)) return false;
    if (!CherieEvents.isCherieQuest004ScheduleWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    )) {
      return false;
    }
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return false;
    if (world.cherieQuest004Step != 0) return false;
    if (q1phase != CherieQuest001OfficePhase.inactive) return false;
    if (quest002ScriptedActive) return false;
    if (quest002MidFlow) return false;
    if (quest003ScriptedActive) return false;
    if (eventVideoPath != null) return false;
    if (npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    return true;
  }

  static void startOfficePhase(GameWorldState world, NPCModel cherie) {
    world.cherieQuest004Branch = 0;
    world.cherieQuest004LegsMassagePhase = false;
    if (!cherie.variables.containsKey(npcVarMasseur)) {
      cherie.setVar(npcVarMasseur, 0);
    }
    world.cherieQuest004Step = 1;
  }

  /// Після «Їхати»: при masseur ≥ 7 — одразу massage_7; у `GameWorldState` це step 8 (не 7).
  static int stepAfterRide(NPCModel cherie) =>
      readMasseur(cherie) >= 7 ? 8 : 3;

  static CherieQuest004Patch patchForState({
    required GameWorldState world,
    required NPCModel? cherie,
  }) {
    final s = world.cherieQuest004Step;
    final m = readMasseur(cherie);
    final br = world.cherieQuest004Branch;

    switch (s) {
      case 1:
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step1,
          videoPath: CherieEvents.tc1Webm,
        );
      case 3:
        return CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step3Bedroom,
          videoPath:
              m <= 6 ? CherieEvents.quest002MassageWebm : null,
        );
      case 4:
        if (!world.cherieQuest004LegsMassagePhase) {
          return const CherieQuest004Patch(
            newsL10nKey: CherieQuest004L10n.step4,
            videoPath: CherieEvents.quest002Massage3Webm,
          );
        }
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step5,
          videoPath: CherieEvents.quest004Massage4Webm,
        );
      case 6:
        // masseur ≤ 3: лише massage_4 + «закінчити»; ≥ 4: одразу massage_5 + трусики/закінчити.
        if (m >= 4) {
          return const CherieQuest004Patch(
            newsL10nKey: CherieQuest004L10n.step6TurnMassage5,
            videoPath: CherieEvents.quest004Massage5Webm,
          );
        }
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step6TurnAngry,
          videoPath: CherieEvents.quest004Massage4Webm,
        );
      case 7:
        // Після «Зняти трусики»: 4 ≤ masseur < 6 — грубий текст; ≥ 6 — м’якший; відео завжди massage_6.
        if (m >= 6) {
          return const CherieQuest004Patch(
            newsL10nKey: CherieQuest004L10n.step7Ok,
            videoPath: CherieEvents.quest004Massage6Webm,
          );
        }
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step7Angry,
          videoPath: CherieEvents.quest004Massage6Webm,
        );
      case 8:
        if (br == CherieQuest004Branch.gropeRebuff) {
          return const CherieQuest004Patch(
            newsL10nKey: CherieQuest004L10n.step8GropeRebuff,
            videoPath: CherieEvents.quest004MassageNoWebm,
          );
        }
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step8,
          videoPath: CherieEvents.quest004Massage7Webm,
        );
      case 9:
        if (br == CherieQuest004Branch.petRebuff) {
          return const CherieQuest004Patch(
            newsL10nKey: CherieQuest004L10n.step9PetRebuff,
            videoPath: CherieEvents.quest004MassageNo1Webm,
          );
        }
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step9,
          videoPath: CherieEvents.quest004Massage8Webm,
        );
      case 10:
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step10,
          videoPath: CherieEvents.quest004Massage9Webm,
        );
      case 11:
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step11Contract,
          videoPath: CherieEvents.quest004HomeContractTalkWebm,
        );
      default:
        return const CherieQuest004Patch(
          newsL10nKey: CherieQuest004L10n.step1,
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

  static bool shouldPresentContractHallScriptedUi({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isContractHallPhase(world)) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    return currentZone == 'POOR_VILLAGE' &&
        isInsideRoom &&
        r == LocationsData.poorVillageGiftShopOwnerHall;
  }

  static void resetSession(GameWorldState world) {
    world.cherieQuest004Step = 0;
    world.cherieQuest004Branch = 0;
    world.cherieQuest004LegsMassagePhase = false;
  }

  // --- Нагороди ---

  static void _baseMassageReward(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(double) changeEnergy,
    required int money,
    required int minutes,
    required int relationship,
  }) {
    changeEnergy(-40);
    changeMoney(money);
    if (minutes > 0) addGameMinutes(minutes);
    changeMassageExperience(1);
    cherie.addRelationship(relationship.toDouble());
  }

  /// Після massage_3: «закінчити» без ніг (+100$, без +2 год, без masseur).
  static void applyRewardStep4Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) changeMassageExperience,
    required void Function(double) changeEnergy,
  }) {
    changeEnergy(-40);
    changeMoney(100);
    changeMassageExperience(1);
    cherie.addRelationship(5);
  }

  /// Після massage_4 (ноги): «закінчити» (+100$, +2 год, без masseur).
  static void applyRewardStep5Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(double) changeEnergy,
  }) {
    _baseMassageReward(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeEnergy: changeEnergy,
      money: 100,
      minutes: 120,
      relationship: 5,
    );
  }

  /// Після «перевернутися», masseur ≤ 3 (massage_4, лише «закінчити»).
  static void applyRewardStep6TurnLt3Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeEnergy,
  }) {
    _baseMassageReward(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeEnergy: changeEnergy,
      money: 100,
      minutes: 120,
      relationship: 10,
    );
    changeCharisma(1);
    addMasseur(cherie, 1);
  }

  /// Після massage_5 (masseur ≥ 4): «закінчити» без зняття трусиків або після кроку 7.
  static void applyRewardStep6TurnGte3AfterMassage5Finish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeEnergy,
  }) {
    _baseMassageReward(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeEnergy: changeEnergy,
      money: 100,
      minutes: 120,
      relationship: 5,
    );
    changeCharisma(1);
    addMasseur(cherie, 1);
  }

  static void applyRewardStep7PantiesFinish(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeEnergy,
  }) {
    applyRewardStep6TurnGte3AfterMassage5Finish(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeEnergy: changeEnergy,
    );
  }

  static void applyRewardMassageSessionWithArousal(
    NPCModel cherie, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
    required int masseurDelta,
  }) {
    _baseMassageReward(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeEnergy: changeEnergy,
      money: 100,
      minutes: 120,
      relationship: 5,
    );
    changeCharisma(1);
    changeArousal(25);
    if (masseurDelta != 0) addMasseur(cherie, masseurDelta);
  }

  /// Фінал контракту білизни (після «Піти» на кроці 11).
  static void applyContractFinale(
    NPCModel cherie,
    GameWorldState world, {
    required void Function(int) changeMoney,
    required void Function(int) addGameMinutes,
    required void Function(int) changeMassageExperience,
    required void Function(int) changeCharisma,
    required void Function(double) changeArousal,
    required void Function(double) changeEnergy,
  }) {
    applyRewardMassageSessionWithArousal(
      cherie,
      changeMoney: changeMoney,
      addGameMinutes: addGameMinutes,
      changeMassageExperience: changeMassageExperience,
      changeCharisma: changeCharisma,
      changeArousal: changeArousal,
      changeEnergy: changeEnergy,
      masseurDelta: 1,
    );
    cherie.setVar(npcVarLingerieContract, true);
    resetSession(world);
  }
}
