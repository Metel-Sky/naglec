/// Усі **квести** NPC Cherie в одному файлі.
///
/// Кожен новий квест — окремий пронумерований блок із id `cherie_quest_NNN` (див. `.cursor/rules/event-numbering.mdc`).
library;

import '../../models/npc_model.dart';
import '../../data/locations_room_data.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import 'cherie_events.dart';

part 'cherie_quest004_impl.dart';
part 'cherie_quest005_impl.dart';
part 'cherie_quest006_impl.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Квест 1 — cherie_quest_001: пропозиція роботи аніматором (офіс ТРЦ, gift shop)
// ═══════════════════════════════════════════════════════════════════════════

/// Фаза офісної сцени квесту 1 (лише сесія, не зберігається).
enum CherieQuest001OfficePhase {
  inactive,
  /// Сила / масаж нижче порогу — лише «вибачте, помилився дверима».
  statsBlocked,
  /// Відео tc_1, перший обмін.
  step1Ask,
  /// Те саме відео без перезапуску, пропозиція про зміну.
  step2Decide,
}

/// Параметри відео для офісної сцени [CherieQuest001].
class CherieQuest001OfficeVideoSetup {
  const CherieQuest001OfficeVideoSetup({
    required this.path,
    this.muted = false,
    this.fullScreen = true,
    this.closeWhenCompleted = false,
    this.loop = true,
  });

  final String path;
  final bool muted;
  final bool fullScreen;
  final bool closeWhenCompleted;
  final bool loop;
}

/// Що застосувати при вході в офіс (якщо `CherieQuest001.tryBuildOfficeEntryPatch` повернув не null).
class CherieQuest001OfficeEntryPatch {
  const CherieQuest001OfficeEntryPatch({
    required this.phase,
    required this.selectedNpcId,
    required this.newsL10nKey,
    this.video,
  });

  final CherieQuest001OfficePhase phase;
  final String selectedNpcId;
  final String newsL10nKey;
  final CherieQuest001OfficeVideoSetup? video;
}

/// Ключі l10n для квесту 1 (рядки; текст у `strings_*.dart`).
abstract final class CherieQuest001L10n {
  static const statsBlockedHint = 'cherie_animator_quest_stats_blocked_hint';
  static const step1Dialogue = 'cherie_animator_quest_step1_dialogue';
  static const step2Dialogue = 'cherie_animator_quest_step2_dialogue';
  static const afterAgree = 'cherie_animator_quest_after_agree';
  static const askJob = 'cherie_animator_quest_ask_job';
  static const leave = 'cherie_animator_quest_leave';
  static const agree = 'cherie_animator_quest_agree';
  static const thinkLater = 'cherie_animator_quest_think_later';
  static const wrongDoor = 'cherie_animator_quest_wrong_door';
}

/// Логіка квесту **cherie_quest_001**.
abstract final class CherieQuest001 {
  CherieQuest001._();

  /// Стабільний id квесту (коментарі, збереження, умови наступних квестів).
  static const String questId = 'cherie_quest_001';

  static String get tc1Webm => CherieEvents.tc1Webm;

  /// Після «Погодитись» — зміна у вихідні в залі ТРЦ.
  static const String giftShopWorkAnimatorVar = 'gift_shop_work_animator';

  static const int minPhysicalFitnessForOfficeOffer = 300;
  static const int minMassageExperienceForOfficeOffer = 100;

  /// Скільки ігрових днів після згоди накопичити для наступного квесту (0…5).
  static const int nextQuestDayCounterMax = 5;

  /// Ключ «слоту» зміни аніматора: календар + [weekdayIndex] з часу (як у шапці).
  ///
  /// Потрібен, бо [GameTimeController.nextDayName] змінює день тижня без зміни [DateTime],
  /// і лише `y-m-d` брався б одна зміна на календарну добу.
  static String giftShopAnimatorShiftSlotKey(DateTime dt, int weekdayIndex) =>
      '${dt.year}-${dt.month}-${dt.day}-wd$weekdayIndex';

  static void tickNextQuestDayCounterIfNeeded({
    required GameWorldState world,
    required bool questOneAgreed,
    required DateTime now,
  }) {
    if (!questOneAgreed) return;
    if (world.cherieAnimatorNextQuestDayCounter >= nextQuestDayCounterMax) {
      return;
    }
    final todayKey = '${now.year}-${now.month}-${now.day}';
    if (world.cherieAnimatorNextQuestLastDateKey == todayKey) return;
    if (world.cherieAnimatorNextQuestLastDateKey != null) {
      world.cherieAnimatorNextQuestDayCounter =
          (world.cherieAnimatorNextQuestDayCounter + 1)
              .clamp(0, nextQuestDayCounterMax);
    }
    world.cherieAnimatorNextQuestLastDateKey = todayKey;
  }

  static void resetNextQuestDayTracking(GameWorldState world, DateTime now) {
    world.cherieAnimatorNextQuestDayCounter = 0;
    world.cherieAnimatorNextQuestLastDateKey =
        '${now.year}-${now.month}-${now.day}';
  }

  /// Після згоди в офісі: змінна NPC, доступ до зміни, лічильник днів для квесту 2.
  static void applyQuestOneAccepted({
    required NPCModel cherie,
    required GameWorldState world,
    required DateTime now,
  }) {
    cherie.setVar(giftShopWorkAnimatorVar, true);
    world.giftShopAnimatorJobOfferPending = true;
    resetNextQuestDayTracking(world, now);
  }

  /// Старт сцени при вході в офіс Cherie (null — нічого не робити).
  static CherieQuest001OfficeEntryPatch? tryBuildOfficeEntryPatch({
    required String enteredRoom,
    required String currentZone,
    required bool isInsideRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
    required int physicalFitness,
    required int massageExperience,
  }) {
    if (enteredRoom != LocationsData.cityMallGiftShopOffice) return null;
    if (currentZone != 'CITY' || !isInsideRoom) return null;
    if (cherie == null) return null;
    if (npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice) {
      return null;
    }
    if (cherie.getVar(giftShopWorkAnimatorVar) == true) return null;

    final statsOk = physicalFitness >= minPhysicalFitnessForOfficeOffer &&
        massageExperience >= minMassageExperienceForOfficeOffer;
    if (!statsOk) {
      return const CherieQuest001OfficeEntryPatch(
        phase: CherieQuest001OfficePhase.statsBlocked,
        selectedNpcId: 'cherie',
        newsL10nKey: CherieQuest001L10n.statsBlockedHint,
        video: null,
      );
    }

    return CherieQuest001OfficeEntryPatch(
      phase: CherieQuest001OfficePhase.step1Ask,
      selectedNpcId: 'cherie',
      newsL10nKey: CherieQuest001L10n.step1Dialogue,
      video: const CherieQuest001OfficeVideoSetup(
        path: CherieEvents.tc1Webm,
        muted: false,
        fullScreen: true,
        closeWhenCompleted: false,
        loop: true,
      ),
    );
  }

  /// Скинути офісну сесію квесту 1, якщо Cherie більше не в офісі під час активної фази.
  static bool shouldResetOfficeSessionBecauseCherieLeft({
    required CherieQuest001OfficePhase phase,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
  }) {
    if (phase == CherieQuest001OfficePhase.inactive) return false;
    if (currentZone != 'CITY' ||
        !isInsideRoom ||
        currentRoom != LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (cherie == null) return true;
    return npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Квест 2 — cherie_quest_002: допомога зі складом (офіс ТРЦ, вихідні)
// ═══════════════════════════════════════════════════════════════════════════

// ignore_for_file: public_member_api_docs

/// Контент офісної сцени квесту 2 (відео / картинка + ключ новини).
final class CherieQuest002OfficePatch {
  const CherieQuest002OfficePatch({
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

abstract final class CherieQuest002L10n {
  static const step1News = 'cherie_quest_002_step1_news';
  static const step2News = 'cherie_quest_002_step2_news';
  static const step3News = 'cherie_quest_002_step3_news';
  static const step4News = 'cherie_quest_002_step4_news';
  static const step4NewsWho = 'cherie_quest_002_step4_news_who';
  static const step5News = 'cherie_quest_002_step5_news';
  static const step6News = 'cherie_quest_002_step6_news';
  static const step7News = 'cherie_quest_002_step7_news';
  static const step8News = 'cherie_quest_002_step8_news';
  static const step9News = 'cherie_quest_002_step9_news';
  static const waitNextWeekend = 'cherie_quest_002_wait_next_weekend';
  static const btnContinue = 'cherie_quest_002_btn_continue';
  static const btnDeliverBoxes = 'cherie_quest_002_btn_deliver_boxes';
  static const btnFinish = 'cherie_quest_002_btn_finish';
  static const btnStep1Leave = 'cherie_quest_002_step1_btn_leave';
  static const btnFinishAnimatorShift = 'cherie_quest_002_btn_finish_animator_shift';
  static const btnGoWarehouse = 'cherie_quest_002_btn_go_warehouse';
  static const btnWhoAreYou = 'cherie_quest_002_btn_who_are_you';
  static const btnOfferHelp = 'cherie_quest_002_btn_offer_help';
  static const btnGoLeave = 'cherie_quest_002_btn_go_leave';
  static const btnFollowCherie = 'cherie_quest_002_btn_follow_cherie';
  static const btnMassageEllipsis = 'cherie_quest_002_btn_massage_ellipsis';
  static const btnOfferLegMassage = 'cherie_quest_002_btn_offer_leg_massage';
  static const btnFinishMassage = 'cherie_quest_002_btn_finish_massage';
}

/// Стан ГГ для гейтів старту квесту 2 (офіс / кнопка «Працювати аніматором»).
final class CherieQuest002StartPlayerGates {
  const CherieQuest002StartPlayerGates({
    required this.physicalFitness,
    required this.massageExperience,
    required this.hasAromaOilItem,
  });

  final int physicalFitness;
  final int massageExperience;
  final bool hasAromaOilItem;
}

/// Логіка квесту **cherie_quest_002**.
abstract final class CherieQuest002 {
  CherieQuest002._();

  static const String questId = 'cherie_quest_002';

  /// Прапорець для наступного квесту; стає true після «Закінчити» на кроці 8 (основна гілка).
  static const String npcVarComplete = 'cherie_quest_002_complete';

  /// Гілка «ноги» на кроці 9 відіграна (нагороди фіналу).
  static const String npcVarMassageLegsDone = 'cherie_quest_002_massage_legs_done';

  static const String phoneUnlockedVar = 'phone_unlocked';

  static const int rewardTipsStep9Fixed = 400;
  static const int rewardCharismaStep9 = 4;
  static const int rewardRelationshipStep9 = 25;

  /// Мінімум завершених змін аніматора, щоб стартував квест 2 (крок 1 з «Працювати аніматором»).
  static const int minAnimatorShiftsCompleted = 3;

  /// Старт квесту 2: сила, досвід масажу та предмет [aromaOilItemId] у рюкзаку.
  static const int minPhysicalFitnessForQuest002Start = 250;
  static const int minMassageExperienceForQuest002Start = 100;

  /// Той самий `id`, що `GameItems.massageAromaOil` / товар «олія» в ТРЦ.
  static const String aromaOilItemId = 'oil';

  /// Чит «квест 2 виконано»: підняти ГГ не нижче цих значень (+ олія в рюкзак).
  static const int cheatCompletionMinPhysicalFitness = 300;
  static const int cheatCompletionMinFighting = 30;
  static const int cheatCompletionMinMassageExperience = 100;

  /// Винагорода «перевезення + зміна + чайові» та витрата енергії (кроки 5 «Піти», 8 «Закінчити», 9 «Закінчити»).
  static const int energyRewardBlockCost = 50;
  static const int rewardMoneyTransport = 200;
  static const int rewardMoneyAnimatorShift = 300;

  static String get skladImagePath => 'lib/assets/npcs/cherie/sklad.png';

  static bool _questOneAgreed(NPCModel? cherie) =>
      cherie?.getVar(CherieQuest001.giftShopWorkAnimatorVar) == true;

  static bool _introSettled(GameWorldState world) =>
      world.cherieAnimatorIntroStep == 0;

  static bool _animatorExperienceOk(GameWorldState world) =>
      world.giftShopAnimatorShiftsCompleted >= minAnimatorShiftsCompleted;

  static bool passesQuest002PlayerGates(CherieQuest002StartPlayerGates p) {
    if (p.physicalFitness < minPhysicalFitnessForQuest002Start) return false;
    if (p.massageExperience < minMassageExperienceForQuest002Start) {
      return false;
    }
    if (!p.hasAromaOilItem) return false;
    return true;
  }

  static bool isComplete(NPCModel? cherie, GameWorldState world) {
    if (cherie?.getVar(npcVarComplete) == true) return true;
    return false;
  }

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.cherieQuest002Step;
    return s >= 1 && s <= 9;
  }

  /// Кроки 5–9: сцена в залі Home Cherie (Мажорщина), не в офісі ТРЦ.
  static bool isHomeHallPhase(int step) => step >= 5 && step <= 9;

  /// Офіс ТРЦ, кроки 1–4: єдине джерело правди разом із [tryBuildOfficePatchForCurrentStep]
  /// (світ + локація + розклад Cherie), без окремого незбереженого UI-прапорця.
  static bool shouldPresentOfficeQuest002Steps({
    required String currentRoom,
    required String currentZone,
    required bool isInsideRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
    required GameWorldState world,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    clearSundayBlockIfMonday(world, weekdayIndex);
    if (!_officeContextOk(
      enteredRoom: currentRoom,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      hour: hour,
      weekdayIndex: weekdayIndex,
      cherie: cherie,
      npcService: npcService,
    )) {
      return false;
    }
    if (isComplete(cherie, world)) return false;
    final step = world.cherieQuest002Step;
    if (step < 1 || step > 4) return false;
    return _gatesForStart(
      world: world,
      cherie: cherie,
      weekdayIndex: weekdayIndex,
      playerGates: playerGates,
    );
  }

  /// Офіс 1–4: чи показувати діалог і кнопки квесту (як раніше з незбереженим flow-прапорцем).
  ///
  /// Без перевірки «Cherie зараз у слоті офісу» — інакше після завантаження або зміни часу
  /// UI зникає, хоча крок у сейві ще 1–4. Старт/авто-патч лишаються суворими в
  /// [shouldPresentOfficeQuest002Steps] / [tryBuildOfficePatchForCurrentStep].
  static bool shouldShowOfficeQuest002PresentationUi({
    required String currentRoom,
    required String currentZone,
    required bool isInsideRoom,
    required int weekdayIndex,
    required NPCModel? cherie,
    required GameWorldState world,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    clearSundayBlockIfMonday(world, weekdayIndex);
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return false;
    if (isComplete(cherie, world)) return false;
    final step = world.cherieQuest002Step;
    if (step < 1 || step > 4) return false;
    return _gatesForStart(
      world: world,
      cherie: cherie,
      weekdayIndex: weekdayIndex,
      playerGates: playerGates,
    );
  }

  /// Діалог / дії квесту 002: **без** [_gatesForStart] під час активного кроку 1–9
  /// (інші умови гри не блокують UI сцени).
  static bool shouldPresentQuest002ScriptedUi({
    required GameWorldState world,
    required NPCModel? cherie,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int weekdayIndex,
  }) {
    clearSundayBlockIfMonday(world, weekdayIndex);
    if (!isActiveMidFlow(world)) return false;
    if (isComplete(cherie, world) && massageLegsEpilogueDone(cherie)) {
      return false;
    }
    if (shouldPresentHomeHallSteps(
      world: world,
      cherie: cherie,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return true;
    }
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    final s = world.cherieQuest002Step;
    if (s >= 1 && s <= 3) {
      return roomNorm == LocationsData.cityMallGiftShopOffice;
    }
    if (s == 4) {
      return roomNorm == LocationsData.cityMallGiftShopOffice ||
          roomNorm == LocationsData.cityMallGiftShopWarehouse;
    }
    return false;
  }

  /// Зал Cherie: UI квесту за [world.cherieQuest002Step].
  ///
  /// Позиція Cherie в залі на кроках 5–9: `cherie_quest002_location_pin.dart`.
  static bool shouldPresentHomeHallSteps({
    required GameWorldState world,
    required NPCModel? cherie,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'POOR_VILLAGE' ||
        !isInsideRoom ||
        roomNorm != LocationsData.poorVillageGiftShopOwnerHall) {
      return false;
    }
    if (!isHomeHallPhase(world.cherieQuest002Step)) return false;
    if (isComplete(cherie, world) && massageLegsEpilogueDone(cherie)) {
      return false;
    }
    return true;
  }

  static String dialogueL10nKeyForStep(GameWorldState world, int step) {
    if (step == 4 && world.cherieQuest002WarehouseWhoAsked) {
      return CherieQuest002L10n.step4NewsWho;
    }
    return switch (step) {
      1 => CherieQuest002L10n.step1News,
      2 => CherieQuest002L10n.step2News,
      3 => CherieQuest002L10n.step3News,
      4 => CherieQuest002L10n.step4News,
      5 => CherieQuest002L10n.step5News,
      6 => CherieQuest002L10n.step6News,
      7 => CherieQuest002L10n.step7News,
      8 => CherieQuest002L10n.step8News,
      9 => CherieQuest002L10n.step9News,
      _ => CherieQuest002L10n.step1News,
    };
  }

  /// Будні (0–4): зняти недільне блокування квесту 2 (після виходу зі сцени в суботу).
  /// Раніше скидалось лише в понеділок (0) — якщо гравець пропускав день, прапорець лишався назавжди.
  static void clearSundayBlockIfMonday(GameWorldState world, int weekdayIndex) {
    if (weekdayIndex < 5) {
      world.cherieQuest002SundayBlocked = false;
    }
  }

  /// Усі гейти квесту 2 окрім недільного блоку (для підказки гравцю).
  static bool passesQuest002GatesExceptSunday({
    required GameWorldState world,
    required NPCModel? cherie,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    if (isComplete(cherie, world)) return false;
    if (!_questOneAgreed(cherie)) return false;
    if (!_introSettled(world)) return false;
    if (!_animatorExperienceOk(world)) return false;
    if (!passesQuest002PlayerGates(playerGates)) return false;
    return true;
  }

  /// Неділя + прапорець після виходу зі сцени в суботу: квест 2 не стартує, а зміна все одно так (івент «як завжди»).
  static bool isOnlySundayBlockPreventingQuest002({
    required GameWorldState world,
    required NPCModel? cherie,
    required int weekdayIndex,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    if (world.cherieQuest002Step != 0) return false;
    if (weekdayIndex != 6 || !world.cherieQuest002SundayBlocked) return false;
    return passesQuest002GatesExceptSunday(
      world: world,
      cherie: cherie,
      playerGates: playerGates,
    );
  }

  static CherieQuest002OfficePatch patchForPresentationStep(
    int step,
    GameWorldState world,
  ) {
    final newsKey = dialogueL10nKeyForStep(world, step);
    switch (step) {
      case 1:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.tc1Webm,
        );
      case 2:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.animatorWorkVideoPath,
        );
      case 3:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.tc1Webm,
        );
      case 4:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          imagePath: skladImagePath,
        );
      case 5:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.quest002Box1Webm,
        );
      case 6:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.quest002Box2Webm,
        );
      case 7:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.quest002MassageWebm,
        );
      case 8:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.quest002Massage3Webm,
        );
      case 9:
        return CherieQuest002OfficePatch(
          newsL10nKey: newsKey,
          videoPath: CherieEvents.quest002Massage2Webm,
        );
      default:
        return CherieQuest002OfficePatch(
          newsL10nKey: CherieQuest002L10n.step1News,
          videoPath: CherieEvents.tc1Webm,
        );
    }
  }

  /// Лінійне «Далі» / одна головна кнопка: 1→2, 2→3, 3→4, 6→7, 7→8. Інші кроки — окремі обробники UI.
  static void advanceAfterLinearPrimary(GameWorldState world) {
    final s = world.cherieQuest002Step;
    if (s == 1) {
      world.cherieQuest002Step = 2;
    } else if (s == 2) {
      world.cherieQuest002Step = 3;
    } else if (s == 3) {
      world.cherieQuest002Step = 4;
    } else if (s == 6) {
      world.cherieQuest002Step = 7;
    } else if (s == 7) {
      world.cherieQuest002Step = 8;
    }
  }

  /// Квест 002 у профілі: позначено виконаним після кроку 8 «Закінчити» (основна гілка); далі — тижневий цикл гілки ніг.
  static void markQuest002MainArcComplete(NPCModel cherie, GameWorldState world) {
    cherie.setVar(npcVarComplete, true);
    cherie.setVar(phoneUnlockedVar, true);
    world.cherieQuest002MassageLegsCooldownMondays = 0;
    world.cherieQuest002MassageCooldownMondayTickKey = null;
    world.cherieQuest002MassageLegsReturnPending = false;
    world.cherieQuest002MassageFinishOnlyNextHallVisit = true;
  }

  /// Після «Закінчити» лише на тижні з однією кнопкою: без грошей, запуск лічильника тижнів.
  static void applyAfterStep8FinishOnlyHallVisit(GameWorldState world) {
    world.cherieQuest002MassageFinishOnlyNextHallVisit = false;
    world.cherieQuest002MassageLegsCooldownMondays = 2;
    world.cherieQuest002MassageCooldownMondayTickKey = null;
  }

  /// Один раз на ігровий понеділок: −1 тиждень до повернення кнопки «ноги».
  static void tickMassageLegsCooldownMonday({
    required GameWorldState world,
    required DateTime now,
    required int weekdayIndex,
  }) {
    if (weekdayIndex != 0) return;
    if (world.cherieQuest002MassageLegsCooldownMondays <= 0) return;
    final key = '${now.year}-${now.month}-${now.day}';
    if (world.cherieQuest002MassageCooldownMondayTickKey == key) return;
    world.cherieQuest002MassageCooldownMondayTickKey = key;
    world.cherieQuest002MassageLegsCooldownMondays =
        (world.cherieQuest002MassageLegsCooldownMondays - 1).clamp(0, 99);
    if (world.cherieQuest002MassageLegsCooldownMondays == 0) {
      world.cherieQuest002MassageLegsReturnPending = true;
    }
  }

  static void _clearMassageDeferWorldFields(GameWorldState world) {
    world.cherieQuest002MassageFinishOnlyNextHallVisit = false;
    world.cherieQuest002MassageLegsCooldownMondays = 0;
    world.cherieQuest002MassageCooldownMondayTickKey = null;
    world.cherieQuest002MassageLegsReturnPending = false;
  }

  static bool massageLegsEpilogueDone(NPCModel? cherie) =>
      cherie?.getVar(npcVarMassageLegsDone) == true;

  /// Після фіналу гілки ніг (крок 9): нагороди в UI + квест 002 у профілі як виконаний
  /// ([npcVarComplete]; телефон як після основної гілки кроку 8).
  static void markMassageLegsFinale(NPCModel cherie, GameWorldState world) {
    cherie.setVar(npcVarMassageLegsDone, true);
    cherie.setVar(npcVarComplete, true);
    cherie.setVar(phoneUnlockedVar, true);
    world.cherieQuest002Step = 0;
    world.cherieQuest002WarehouseWhoAsked = false;
    world.cherieQuest002EpilogueWeeksRemaining = 0;
    world.cherieQuest002EpilogueTickDateKey = null;
    _clearMassageDeferWorldFields(world);
  }

  /// Друга можливість кроку 8: гравець знову натискає «Закінчити» без гілки ніг.
  static void markMassageLegsWaived(NPCModel cherie, GameWorldState world) {
    cherie.setVar(npcVarMassageLegsDone, true);
    world.cherieQuest002Step = 0;
    _clearMassageDeferWorldFields(world);
  }

  /// Легасі / скидання після кроку 5 «Піти» без масажу.
  static void resetAfterPartialPayout(GameWorldState world) {
    world.cherieQuest002Step = 0;
    world.cherieQuest002WarehouseWhoAsked = false;
    world.cherieQuest002EpilogueWeeksRemaining = 0;
    world.cherieQuest002EpilogueTickDateKey = null;
    _clearMassageDeferWorldFields(world);
  }

  /// Гравець покинув сцену квесту (назад, інша кімната, Чері пішла з офісу): крок 0 і профіль — ніби не проходили.
  static void abortPlayerAbandoned(NPCModel? cherie, GameWorldState world) {
    if (!isActiveMidFlow(world)) return;
    world.cherieQuest002Step = 0;
    world.cherieQuest002WarehouseWhoAsked = false;
    world.cherieQuest002EpilogueWeeksRemaining = 0;
    world.cherieQuest002EpilogueTickDateKey = null;
    _clearMassageDeferWorldFields(world);
    if (cherie != null) {
      cherie.setVar(npcVarComplete, false);
      cherie.setVar(npcVarMassageLegsDone, false);
      cherie.setVar(phoneUnlockedVar, false);
    }
  }

  /// Чи треба відновити сцену кроку 8 у залі після основного проходження (finish-only або ноги).
  static bool shouldResumeMassageStep8InHall({
    required NPCModel? cherie,
    required GameWorldState world,
  }) {
    if (cherie == null) return false;
    if (cherie.getVar(npcVarComplete) != true) return false;
    if (massageLegsEpilogueDone(cherie)) return false;
    return world.cherieQuest002MassageFinishOnlyNextHallVisit ||
        world.cherieQuest002MassageLegsReturnPending;
  }

  static bool _officeContextOk({
    required String enteredRoom,
    required String currentZone,
    required bool isInsideRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
  }) {
    if (enteredRoom != LocationsData.cityMallGiftShopOffice) return false;
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (cherie == null) return false;
    if (!CherieEvents.isAnimatorShiftTimeWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    )) {
      return false;
    }
    return npcService.getCurrentLocationId(cherie, hour, weekdayIndex) ==
        LocationsData.cityMallGiftShopOffice;
  }

  static bool _gatesForStart({
    required GameWorldState world,
    required NPCModel? cherie,
    required int weekdayIndex,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    clearSundayBlockIfMonday(world, weekdayIndex);
    if (isComplete(cherie, world)) return false;
    if (!_questOneAgreed(cherie)) return false;
    if (!_introSettled(world)) return false;
    if (!_animatorExperienceOk(world)) return false;
    if (!passesQuest002PlayerGates(playerGates)) return false;
    if (weekdayIndex == 6 && world.cherieQuest002SundayBlocked) return false;
    return true;
  }

  /// Квест 2 крок 1: умови без перевірки офісу (для кнопки «Працювати аніматором»).
  static bool canStartQuest002FromAnimatorButton({
    required GameWorldState world,
    required NPCModel? cherie,
    required int weekdayIndex,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    if (world.cherieQuest002Step != 0) return false;
    return _gatesForStart(
      world: world,
      cherie: cherie,
      weekdayIndex: weekdayIndex,
      playerGates: playerGates,
    );
  }

  /// Чи зараз офісне вікно та Cherie в офісі (як для офісного патча).
  static bool isAnimatorOfficeWindowWithCherie({
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
  }) {
    return _officeContextOk(
      enteredRoom: currentRoom,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      hour: hour,
      weekdayIndex: weekdayIndex,
      cherie: cherie,
      npcService: npcService,
    );
  }

  /// Старт офісної сцени (null — не показувати квест 2 зараз).
  ///
  /// Офісна сцена лише для кроків 1–4; 5–9 — у залі Home Cherie після «Відвезти коробки».
  static CherieQuest002OfficePatch? tryBuildOfficePatchForCurrentStep({
    required String enteredRoom,
    required String currentZone,
    required bool isInsideRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
    required GameWorldState world,
    required CherieQuest002StartPlayerGates playerGates,
  }) {
    if (!shouldPresentOfficeQuest002Steps(
      currentRoom: enteredRoom,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      hour: hour,
      weekdayIndex: weekdayIndex,
      cherie: cherie,
      npcService: npcService,
      world: world,
      playerGates: playerGates,
    )) {
      return null;
    }
    final step = world.cherieQuest002Step;
    return patchForPresentationStep(step, world);
  }

  /// Гравець у офісі на кроці 1–4, але Cherie вже не тут — скинути сесію / прогрес (раніше залежало від UI-прапорця).
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
    if (currentZone != 'CITY' ||
        !isInsideRoom ||
        currentRoom != LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    final step = world.cherieQuest002Step;
    if (step < 1 || step > 4) return false;
    if (isComplete(cherie, world)) return false;
    if (cherie == null) return true;
    return npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Квест 3 — cherie_quest_003: масажист для Чері (офіс ТРЦ, вихідні 12–15)
// ═══════════════════════════════════════════════════════════════════════════

/// Контент офісної сцени квесту 3 (відео + ключ новини).
final class CherieQuest003OfficePatch {
  const CherieQuest003OfficePatch({
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

abstract final class CherieQuest003L10n {
  static const step1News = 'cherie_quest_003_step1_news';
  static const step2News = 'cherie_quest_003_step2_news';
  static const step3News = 'cherie_quest_003_step3_news';
  static const btnGoWork = 'cherie_quest_003_btn_go_work';
  static const btnFinishWork = 'cherie_quest_003_btn_finish_work';
  static const btnLeave = 'cherie_quest_003_btn_leave';
}

/// Логіка квесту **cherie_quest_003** (одноразовий).
abstract final class CherieQuest003 {
  CherieQuest003._();

  static const String questId = 'cherie_quest_003';

  /// Після фіналу: угода «масажист для Чері».
  static const String npcVarMassageTherapist = 'cherie_massage_therapist_for_cherie';

  static const int energyCostLeave = 40;
  static const int rewardMoneyBase = 200;
  static const int rewardCharisma = 1;
  static const int rewardRelationship = 10;
  static const int rewardArousal = 10;
  static const int rewardGameHours = 4;
  static const int tipsRandomMin = 100;
  static const int tipsRandomMax = 200;

  static bool isUnlocked(NPCModel? cherie) =>
      cherie?.getVar(npcVarMassageTherapist) == true;

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.cherieQuest003Step;
    return s >= 1 && s <= 3;
  }

  /// Під час активних кроків 1–3 переміщення не списують ігровий час (див. правило проєкту).
  static bool suppressTravelTime(GameWorldState world) =>
      isActiveMidFlow(world);

  static bool _officeWithCherie({
    required String enteredRoom,
    required String currentZone,
    required bool isInsideRoom,
    required int hour,
    required int weekdayIndex,
    required NPCModel? cherie,
    required NPCService npcService,
  }) {
    final roomNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return false;
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (cherie == null) return false;
    return npcService.getCurrentLocationId(cherie, hour, weekdayIndex) ==
        LocationsData.cityMallGiftShopOffice;
  }

  /// Старт з кнопки «Працювати аніматором» (вікно 12–15, квест 002 виконано).
  static bool canStartFromAnimatorWorkButton({
    required GameWorldState world,
    required NPCModel? cherie,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int hour,
    required int weekdayIndex,
    required NPCService npcService,
    required CherieQuest001OfficePhase cherieQuest001OfficePhase,
    required bool quest002ScriptedActive,
    required String? eventVideoPath,
    required bool giftShopAnimatorJobOfferPending,
    required String? giftShopAnimatorPendingFinishDateKey,
    required int giftShopAnimatorShiftsCompleted,
  }) {
    if (isUnlocked(cherie)) return false;
    if (!CherieQuest002.isComplete(cherie, world)) return false;
    if (world.cherieQuest003Step != 0) return false;
    if (!giftShopAnimatorJobOfferPending) return false;
    if (giftShopAnimatorPendingFinishDateKey != null) return false;
    if (giftShopAnimatorShiftsCompleted < 1) return false;
    if (!CherieEvents.isCherieQuest003OfferWindow(
      weekdayIndex: weekdayIndex,
      hour: hour,
    )) {
      return false;
    }
    if (cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return false;
    }
    if (quest002ScriptedActive) return false;
    if (eventVideoPath != null) return false;
    return _officeWithCherie(
      enteredRoom: currentRoom,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      hour: hour,
      weekdayIndex: weekdayIndex,
      cherie: cherie,
      npcService: npcService,
    );
  }

  static bool shouldPresentScriptedUi({
    required GameWorldState world,
    required NPCModel? cherie,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (isUnlocked(cherie)) return false;
    if (!isActiveMidFlow(world)) return false;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    return roomNorm == LocationsData.cityMallGiftShopOffice;
  }

  static bool isLocationValidForActiveStep({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isActiveMidFlow(world)) return true;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    return currentZone == 'CITY' &&
        isInsideRoom &&
        roomNorm == LocationsData.cityMallGiftShopOffice;
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
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' ||
        !isInsideRoom ||
        roomNorm != LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (cherie == null) return true;
    return npcService.getCurrentLocationId(cherie, hour, weekdayIndex) !=
        LocationsData.cityMallGiftShopOffice;
  }

  static void abortAbandoned(GameWorldState world) {
    if (!isActiveMidFlow(world)) return;
    world.cherieQuest003Step = 0;
  }

  static CherieQuest003OfficePatch patchForStep(int step) {
    switch (step) {
      case 1:
        return const CherieQuest003OfficePatch(
          newsL10nKey: CherieQuest003L10n.step1News,
          videoPath: CherieEvents.tc3Webm,
          closeWhenCompleted: false,
        );
      case 2:
        return const CherieQuest003OfficePatch(
          newsL10nKey: CherieQuest003L10n.step2News,
          videoPath: CherieEvents.animatorWorkVideoPath,
          closeWhenCompleted: false,
        );
      case 3:
        return const CherieQuest003OfficePatch(
          newsL10nKey: CherieQuest003L10n.step3News,
          videoPath: CherieEvents.animatorShiftEndVideoPath,
          closeWhenCompleted: false,
        );
      default:
        return const CherieQuest003OfficePatch(
          newsL10nKey: CherieQuest003L10n.step1News,
          videoPath: CherieEvents.tc3Webm,
        );
    }
  }

  static void applyFinaleRewards({
    required NPCModel cherie,
    required GameWorldState world,
    required void Function(int moneyDelta) changeMoney,
    required void Function(double energyDelta) changeEnergy,
    required void Function(int charismaDelta) changeCharisma,
    required void Function(double arousalDelta) changeArousal,
    required void Function(int minutes) addGameMinutes,
    required int tips,
  }) {
    world.cherieQuest003Step = 0;
    cherie.setVar(npcVarMassageTherapist, true);
    changeMoney(rewardMoneyBase + tips);
    changeEnergy(-energyCostLeave.toDouble());
    changeCharisma(rewardCharisma);
    cherie.addRelationship(rewardRelationship.toDouble());
    changeArousal(rewardArousal.toDouble());
    addGameMinutes(rewardGameHours * 60);
  }
}
