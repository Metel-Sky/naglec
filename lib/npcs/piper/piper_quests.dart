// ignore_for_file: public_member_api_docs

import 'dart:math';

import '../../data/locations_room_data.dart';
import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/npc_service.dart';
import '../mom/mom_quest001.dart';

final class PiperQuest001Patch {
  const PiperQuest001Patch({
    required this.newsL10nKey,
    this.videoPath,
    this.imagePath,
  });

  final String newsL10nKey;
  final String? videoPath;
  final String? imagePath;
}

/// QUEST: piper_quest_001 — «погані оцінки» (перший прохід + хвіст 7C TBD).
///
/// Нумерація кроків (Notion `001_piper_погані_оцінки`):
/// 1 — бібліотека; 2 — просьба; 3 — дзвінок; 4 — сварка; 5 — покарання;
/// 6 — фінал проходу; 7A/7B/7C — unlock ГG (окремі прапори, не [piperQuest001Step]).
abstract final class PiperQuest001 {
  PiperQuest001._();

  static const String questId = 'piper_quest_001';

  /// Крок 1 (бібліотека): **без відео** — аватарки Piper + Emily у [CollegeView].
  ///
  /// Крок 2 (Piper просить не здавати): лише fullscreen-відео в кімнаті Piper.
  static const String quest001Step2Video =
      'lib/assets/npcs/piper/video/piper_prosit_ne_zdavat_ee.mp4';

  /// Крок 3 (кухня, дзвінок мами): відео розмови мами по телефону.
  static const String quest001TeacherCallVideo =
      'lib/assets/npcs/mom/video/mom_phone.mp4';

  /// Крок 4 (коридор, сварка): **без відео** — опційно «Підслухати» (лише текст).
  ///
  /// Крок 5 (покарання): рівень 1–2 — текст; рівень 3 — відео (мама або ГG).
  static const String quest001GgPunishVideo1 =
      'lib/assets/npcs/piper/video/gg_punish_piper_1.webm';
  static const String quest001GgPunishVideo2 =
      'lib/assets/npcs/piper/video/gg_punish_piper_2.webm';
  static const String quest001GgPunishVideo3 =
      'lib/assets/npcs/piper/video/gg_punish_piper_3.webm';

  /// Добровільне покарання ГG у `piper_room` (після 7B, під час кризи з двійкою).
  static const String ggVoluntaryPunishVideo =
      'lib/assets/npcs/piper/video/spank_001.mp4';

  static const List<String> quest001GgPunishmentVideos = [
    quest001GgPunishVideo1,
    quest001GgPunishVideo2,
    quest001GgPunishVideo3,
  ];

  static const String punishmentBranchGgPunisher = 'gg_punisher';

  /// Після кроку 7A мама більше не в ланцюжку кризи — лише Пайпер і ГG.
  static bool isMomExcludedFromQuestChain(GameWorldState world) =>
      world.piperGgPunishmentGranted;

  /// У поточній кризі карає ГG (лише якщо криза почалась після 7A+7B).
  static bool ggPunishesInsteadOfMom(GameWorldState world) =>
      world.piperGgPunishmentThisCrisis;

  static bool isGgPunishmentTimingReached(
    GameWorldState world,
    DateTime gameDate,
    int hour,
  ) {
    if (!world.piperGradeCrisisActive || world.piperCrisisResolved) {
      return false;
    }
    if (hour < 18 || hour > 21) return false;
    final dk = dayKey(gameDate);
    final byCounter = world.piperWorkdaysSinceBadGrade >= teacherCallWorkdays;
    final byKey =
        world.teacherCallDayKey != null && world.teacherCallDayKey == dk;
    return byCounter || byKey;
  }

  /// Замість кроків 3–4: час покарання настав, мама вже не в ланцюжку.
  static bool canScheduleGgPunishmentSkippingMomChain({
    required GameWorldState world,
    required DateTime gameDate,
    required int hour,
  }) {
    if (!isMomExcludedFromQuestChain(world)) return false;
    if (!ggPunishesInsteadOfMom(world)) return false;
    if (world.piperPunishmentPending || world.piperQuest001Step >= 5) {
      return false;
    }
    if (world.piperQuest001Step == 2) return false;
    return isGgPunishmentTimingReached(world, gameDate, hour);
  }

  static void markGgPunishmentPendingSkippingMomChain(GameWorldState world) {
    if (!isMomExcludedFromQuestChain(world)) return;
    if (!world.piperGradeCrisisActive || world.piperCrisisResolved) return;
    if (world.piperQuest001Step >= 5) return;
    world.piperPunishmentPending = true;
    world.piperMomTalkingAboutGrades = false;
    world.teacherCalledMom = true;
    world.teacherDealHookOpen = false;
  }

  static void clearMomChainStateForGgPunisher(GameWorldState world) {
    world.piperMomTalkingAboutGrades = false;
    world.teacherDealHookOpen = false;
    if (world.piperQuest001Step == 3 || world.piperQuest001Step == 4) {
      world.piperQuest001Step = 0;
      world.piperQuest001Step3CallOverheard = false;
      world.piperQuest001Step3VideoSeen = false;
      world.piperQuest001Step4ScoldingOverheard = false;
      world.piperQuest001Step4EarliestDayKey = null;
    }
  }

  static const String quest001Punishment1Video =
      'lib/assets/npcs/piper/video/spanked_piper_1.mp4';
  static const String quest001Punishment2Video =
      'lib/assets/npcs/piper/video/spanked_piper_2.mp4';
  static const String quest001Punishment3Video =
      'lib/assets/npcs/piper/video/spanked_piper_3.mp4';

  static const List<String> quest001PunishmentVideos = [
    quest001Punishment1Video,
    quest001Punishment2Video,
    quest001Punishment3Video,
  ];

  /// Перше відео-покарання — з 1-ї кризи (Notion MVP: spanked_piper_1/2/3).
  static const int firstPunishmentVideoCrisisN = 1;

  /// Крок 7C (колишні 6A/6B/6C): меню наказу — TBD.
  static const int coverPaymentAmount = 20;
  static const int teacherCallWorkdays = 4;
  static const double badGradeChance = 0.08;

  /// Вечірній слот кроків 3–4 (дзвінок викладачки / сварка мами).
  static bool isQuest001EveningHour(int hour) => hour >= 18 && hour <= 21;

  /// Коридор удома = сітка кімнат (не всередині окремої кімнати).
  static bool isStep4CorridorScene({
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (currentZone != 'HOME' || isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) ==
        LocationsData.corridor;
  }

  static DateTime? _parseDayKey(String? key) {
    if (key == null || key.isEmpty) return null;
    final parts = key.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static bool isGameDayOnOrAfter(DateTime gameDate, String earliestDayKey) {
    final earliest = _parseDayKey(earliestDayKey);
    if (earliest == null) return true;
    final today = DateTime(gameDate.year, gameDate.month, gameDate.day);
    return !today.isBefore(earliest);
  }

  /// Після здачі / дзвінка викладачки: той самий вечір (≥18) або наступний день.
  static void markStep4AvailableAfterMomKnows(
    GameWorldState world,
    DateTime gameDate,
    int hour,
  ) {
    if (isQuest001EveningHour(hour)) {
      world.piperQuest001Step4EarliestDayKey = dayKey(gameDate);
    } else {
      final next = gameDate.add(const Duration(days: 1));
      world.piperQuest001Step4EarliestDayKey = dayKey(next);
    }
  }

  static void ensureStep4EarliestDayKey(GameWorldState world, DateTime gameDate) {
    if (!world.piperMomTalkingAboutGrades) return;
    world.piperQuest001Step4EarliestDayKey ??= dayKey(gameDate);
  }

  static const String subjectMath = 'math';
  static const String subjectEnglish = 'english';
  static const String subjectHistory = 'history';

  static String dayKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  static bool isWeekday(int weekdayIndex) => weekdayIndex >= 0 && weekdayIndex <= 4;

  static bool isWeekend(int weekdayIndex) =>
      weekdayIndex == 5 || weekdayIndex == 6;

  static bool isActiveMidFlow(GameWorldState world) {
    final s = world.piperQuest001Step;
    return s >= 1 && s <= 6;
  }

  static bool blocksStandardPiperInteractions(GameWorldState world) =>
      isActiveMidFlow(world) || world.piperGradeCrisisActive;

  static String weekKey(DateTime gameDate) =>
      MomQuest001.gameWeekMondayKey(gameDate);

  static String? auditoriumForSubject(String subject) {
    switch (subject) {
      case subjectMath:
        return LocationsData.auditorium2;
      case subjectEnglish:
        return LocationsData.auditorium1;
      case subjectHistory:
        return LocationsData.auditorium3;
      default:
        return null;
    }
  }

  static String subjectL10nKey(String subject) {
    switch (subject) {
      case subjectMath:
        return 'piper_quest_001_subject_math';
      case subjectEnglish:
        return 'piper_quest_001_subject_english';
      case subjectHistory:
        return 'piper_quest_001_subject_history';
      default:
        return 'piper_quest_001_subject_math';
    }
  }

  static String teacherNameL10nKey(String teacherId) {
    switch (teacherId) {
      case 'lisa':
        return 'piper_quest_001_teacher_lisa';
      case 'amia':
        return 'piper_quest_001_teacher_amia';
      case 'nicole':
        return 'piper_quest_001_teacher_nicole';
      default:
        return 'piper_quest_001_teacher_lisa';
    }
  }

  static void applyRelationshipDelta(NPCModel npc, double delta) {
    npc.addTrust(delta / 5);
  }

  static void rollBadGradeSubject(Random rng, GameWorldState world) {
    final pick = rng.nextInt(3);
    switch (pick) {
      case 0:
        world.piperBadGradeSubject = subjectMath;
        world.piperBadGradeTeacherId = 'lisa';
      case 1:
        world.piperBadGradeSubject = subjectEnglish;
        world.piperBadGradeTeacherId = 'amia';
      default:
        world.piperBadGradeSubject = subjectHistory;
        world.piperBadGradeTeacherId = 'nicole';
    }
  }

  static String computeTeacherCallDayKey(DateTime badGradeDate) {
    var d = badGradeDate;
    var counted = 0;
    while (counted < teacherCallWorkdays) {
      d = d.add(const Duration(days: 1));
      if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) {
        counted++;
      }
    }
    return dayKey(d);
  }

  static void startBadGradeCrisis({
    required GameWorldState world,
    required DateTime gameDate,
    required Random rng,
  }) {
    rollBadGradeSubject(rng, world);
    world.piperBadGradeToday = true;
    world.piperBadGradesCount++;
    world.piperGradeCrisisActive = true;
    world.piperGradeSecretKnown = false;
    world.piperHelpRequested = false;
    world.piperCrisisResolved = false;
    world.piperSnitchedToMom = false;
    world.piperMomTalkingAboutGrades = false;
    world.teacherCallPending = true;
    world.teacherCalledMom = false;
    world.piperBadGradeDayKey = dayKey(gameDate);
    world.piperWorkdaysSinceBadGrade = 0;
    world.teacherCallDayKey = computeTeacherCallDayKey(gameDate);
    world.piperApproachSlot1Done = false;
    world.piperApproachSlot2Done = false;
    world.piperPunishmentPending = false;
    world.piperUnderPunishment = false;
    world.piperGgPunishmentThisCrisis =
        world.piperGgPunishmentGranted && world.piperGgPunishmentAnnouncedToPiper;
    world.piperGgVoluntaryPunishDoneThisCrisis = false;
    world.piperQuest001Step = 0;
    world.piperQuest001Step2VideoSeen = false;
    world.piperQuest001Step2GgDealSubmenu = false;
    world.piperQuest001Step3VideoSeen = false;
    world.piperQuest001Step5VideoSeen = false;
    world.piperQuest001Step3CallOverheard = false;
    world.piperQuest001Step4ScoldingOverheard = false;
    world.piperQuest001Step4EarliestDayKey = null;
    world.piperQuest001SnitchAckPending = false;
    world.piperQuest001GgPunishTalkPhase = 0;
    world.piperBadGradeWeekKey = weekKey(gameDate);
  }

  static void resetApproachSlotsForNewDay(GameWorldState world) {
    world.piperApproachSlot1Done = false;
    world.piperApproachSlot2Done = false;
  }

  static void syncWorkdayCounterOnNewDay({
    required GameWorldState world,
    required int weekdayIndex,
    required String currentDayKey,
  }) {
    if (!world.piperGradeCrisisActive ||
        world.piperCrisisResolved ||
        world.piperBadGradeDayKey == null) {
      return;
    }
    if (currentDayKey == world.piperBadGradeDayKey) return;
    if (!isWeekday(weekdayIndex)) return;
    world.piperWorkdaysSinceBadGrade++;
  }

  static void maybeRollDailyBadGrade({
    required GameWorldState world,
    required DateTime gameDate,
    required int weekdayIndex,
    required int hour,
    required NPCModel? piper,
  }) {
    if (piper == null || piper.id != 'piper') return;
    if (!isWeekday(weekdayIndex)) return;
    if (hour < 10) return;
    final dk = dayKey(gameDate);
    if (world.piperBadGradeLastRollDayKey == dk) return;
    world.piperBadGradeLastRollDayKey = dk;

    if (world.piperGradeCrisisActive && !world.piperCrisisResolved) return;

    final wk = weekKey(gameDate);
    if (world.piperBadGradeWeekKey == wk) return;

    final rng = Random(dk.hashCode ^ questId.hashCode);
    if (rng.nextDouble() >= badGradeChance) return;

    startBadGradeCrisis(world: world, gameDate: gameDate, rng: rng);
  }

  static bool isLibraryScheduleHour(int hour) => hour >= 10 && hour <= 18;

  /// Крок 1: автоподія в **бібліотеці** коледжу при активній кризі (ще не підслухано).
  static bool canAutoStartStep1LibraryScene({
    required GameWorldState world,
    required int weekdayIndex,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!world.piperGradeCrisisActive ||
        world.piperCrisisResolved ||
        world.piperGradeSecretKnown) {
      return false;
    }
    if (world.piperQuest001Step >= 2) return false;
    if (!isWeekday(weekdayIndex) || !isLibraryScheduleHour(hour)) return false;
    if (currentZone != 'COLLEGE' || !isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) ==
        LocationsData.canteen;
  }

  static bool isPiperAtHome({
    required NPCService npcService,
    required NPCModel piper,
    required int hour,
    required int weekdayIndex,
  }) {
    final loc = npcService.getCurrentLocationId(piper, hour, weekdayIndex);
    return loc == LocationsData.piperRoom ||
        loc == LocationsData.corridor ||
        loc == LocationsData.kitchen ||
        loc == LocationsData.hall ||
        loc == LocationsData.bathroom;
  }

  static bool isApproachSlotActive({
    required int weekdayIndex,
    required int hour,
    required bool slot1Done,
    required bool slot2Done,
  }) {
    if (isWeekday(weekdayIndex)) {
      return hour >= 18 && hour <= 21 && !slot1Done;
    }
    if (isWeekend(weekdayIndex)) {
      if (hour >= 10 && hour < 14 && !slot1Done) return true;
      if (hour >= 14 && hour <= 20 && !slot2Done) return true;
    }
    return false;
  }

  static bool marksApproachSlotDone({
    required int weekdayIndex,
    required int hour,
  }) {
    if (isWeekday(weekdayIndex)) return hour >= 18 && hour <= 21;
    if (hour >= 10 && hour < 14) return true;
    if (hour >= 14 && hour <= 20) return true;
    return false;
  }

  static void markApproachSlotDone(GameWorldState world, int weekdayIndex, int hour) {
    if (isWeekday(weekdayIndex)) {
      world.piperApproachSlot1Done = true;
      return;
    }
    if (hour >= 10 && hour < 14) {
      world.piperApproachSlot1Done = true;
    } else if (hour >= 14 && hour <= 20) {
      world.piperApproachSlot2Done = true;
    }
  }

  static bool isStep2ApproachRoom(String currentRoom) {
    final room = LocationsData.migrateLegacyRoomId(currentRoom);
    return room == LocationsData.piperRoom || room == LocationsData.roomGg;
  }

  static bool canStartStep2Approach({
    required GameWorldState world,
    required NPCService npcService,
    required NPCModel? piper,
    required int weekdayIndex,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!world.piperGradeCrisisActive ||
        world.piperCrisisResolved ||
        world.piperSnitchedToMom) {
      return false;
    }
    if (!isMomExcludedFromQuestChain(world) &&
        world.piperMomTalkingAboutGrades) {
      return false;
    }
    if (world.piperQuest001Step >= 2) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (!isStep2ApproachRoom(currentRoom)) return false;
    if (piper == null || piper.id != 'piper') return false;
    if (!isPiperAtHome(
      npcService: npcService,
      piper: piper,
      hour: hour,
      weekdayIndex: weekdayIndex,
    )) {
      return false;
    }
    return isApproachSlotActive(
      weekdayIndex: weekdayIndex,
      hour: hour,
      slot1Done: world.piperApproachSlot1Done,
      slot2Done: world.piperApproachSlot2Done,
    );
  }

  static bool canStartStep3TeacherCall({
    required GameWorldState world,
    required DateTime gameDate,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (isMomExcludedFromQuestChain(world)) return false;
    if (!world.piperCrisisResolved ||
        world.teacherCalledMom ||
        world.piperMomTalkingAboutGrades ||
        world.piperSnitchedToMom) {
      return false;
    }
    if (!world.piperGradeCrisisActive) return false;
    if (hour < 18 || hour > 21) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    final room = LocationsData.migrateLegacyRoomId(currentRoom);
    if (room != LocationsData.kitchen && room != LocationsData.hall) {
      return false;
    }
    final dk = dayKey(gameDate);
    final byCounter = world.piperWorkdaysSinceBadGrade >= teacherCallWorkdays;
    final byKey =
        world.teacherCallDayKey != null && world.teacherCallDayKey == dk;
    return byCounter || byKey;
  }

  static bool canStartStep4MomScolds({
    required GameWorldState world,
    required DateTime gameDate,
    required int hour,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (isMomExcludedFromQuestChain(world)) return false;
    if (!world.piperGradeCrisisActive || world.piperCrisisResolved) {
      return false;
    }
    if (!world.piperMomTalkingAboutGrades) return false;
    if (world.piperQuest001Step >= 4) return false;
    if (!isStep4CorridorScene(
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return false;
    }
    if (!isQuest001EveningHour(hour)) return false;
    ensureStep4EarliestDayKey(world, gameDate);
    final earliest = world.piperQuest001Step4EarliestDayKey;
    if (earliest != null && !isGameDayOnOrAfter(gameDate, earliest)) {
      return false;
    }
    return true;
  }

  static bool canStartStep5Punishment({
    required GameWorldState world,
  }) {
    return world.piperPunishmentPending && world.piperQuest001Step < 5;
  }

  /// Крок 7A: домовленість з мамою на кухні (`piper_punishment_crisis_n ≥ 5`, мама «винна»).
  static bool canRequestGgCommandPiperOnKitchen({
    required GameWorldState world,
    required NPCService npcService,
    required NPCModel? mom,
    required int hour,
    required int weekdayIndex,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (world.piperGgPunishmentGranted) return false;
    if (world.piperPunishmentCrisisN < 5) return false;
    if (world.momOwesGgCount <= 0) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.kitchen) {
      return false;
    }
    if (mom == null || mom.id != 'mom') return false;
    return npcService.getCurrentLocationId(mom, hour, weekdayIndex) ==
        LocationsData.kitchen;
  }

  static void applyGgCommandsPiperInsteadOfMom(GameWorldState world) {
    world.piperGgPunishmentGranted = true;
    world.piperPunishmentBranch = punishmentBranchGgPunisher;
    clearMomChainStateForGgPunisher(world);
    if (world.momOwesGgCount > 0) {
      world.momOwesGgCount--;
    }
  }

  /// Крок 7B: сказати Пайпер у `piper_room` (діє з наступної кризи).
  static bool canTellPiperAboutGgPunishmentInRoom({
    required GameWorldState world,
    required NPCService npcService,
    required NPCModel? piper,
    required int hour,
    required int weekdayIndex,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!world.piperGgPunishmentGranted) return false;
    if (world.piperGgPunishmentAnnouncedToPiper) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (!isStep5PunishmentRoom(currentRoom)) return false;
    if (piper == null || piper.id != 'piper') return false;
    return npcService.getCurrentLocationId(piper, hour, weekdayIndex) ==
        LocationsData.piperRoom;
  }

  static void applyGgPunishmentAnnouncedToPiper(GameWorldState world) {
    world.piperGgPunishmentAnnouncedToPiper = true;
  }

  /// ГG уже сказав Пайпер про накази + активна криза з двійкою; Пайпер у своїй кімнаті.
  static bool canGgVoluntaryPunishPiperInRoom({
    required GameWorldState world,
    required NPCService npcService,
    required NPCModel? piper,
    required int hour,
    required int weekdayIndex,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!world.piperGgPunishmentAnnouncedToPiper) return false;
    if (!world.piperGradeCrisisActive || world.piperCrisisResolved) {
      return false;
    }
    if (world.piperGgVoluntaryPunishDoneThisCrisis) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (!isStep5PunishmentRoom(currentRoom)) return false;
    if (piper == null || piper.id != 'piper') return false;
    return npcService.getCurrentLocationId(piper, hour, weekdayIndex) ==
        LocationsData.piperRoom;
  }

  static bool canShowGgVoluntaryPunishButton({
    required GameWorldState world,
    required NPCService npcService,
    required NPCModel? piper,
    required int hour,
    required int weekdayIndex,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!canGgVoluntaryPunishPiperInRoom(
      world: world,
      npcService: npcService,
      piper: piper,
      hour: hour,
      weekdayIndex: weekdayIndex,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return false;
    }
    return !isScriptedDialogActive(
      world: world,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      weekdayIndex: weekdayIndex,
      hour: hour,
    );
  }

  /// Крок 2 після 7A: інший набір кнопок (домовитись / \$20 / покарати / піти).
  static bool usesGgPunisherStep2Buttons(GameWorldState world) =>
      isMomExcludedFromQuestChain(world);

  static bool canGgPunishPiperDuringStep2Approach(GameWorldState world) =>
      usesGgPunisherStep2Buttons(world) &&
      world.piperGradeCrisisActive &&
      !world.piperCrisisResolved &&
      !world.piperGgVoluntaryPunishDoneThisCrisis;

  static const String debtTypeGgCoverNoPunish = 'gg_cover_no_punish';
  static const String debtTypeGgDealBreasts = 'gg_deal_breasts';
  static const String debtTypeGgDealAss = 'gg_deal_ass';

  static void resetStep2GgDealSubmenu(GameWorldState world) {
    world.piperQuest001Step2GgDealSubmenu = false;
  }

  static void markGgVoluntaryPunishDoneThisCrisis(GameWorldState world) {
    world.piperGgVoluntaryPunishDoneThisCrisis = true;
  }

  /// Нагорода за «Покарати Пайпер» (spank_001): хтивість +3, відносини +5, поведінка +3, збудження +5, вплив +3.
  static void applyGgVoluntaryPunishStatRewards(NPCModel? piper) {
    if (piper == null || piper.id != 'piper') return;
    piper.changeLust(3);
    piper.addRelationship(5);
    piper.changeBehavior(3);
    piper.changeArousal(5);
    piper.changeInfluence(3);
  }

  static bool isGgPunishmentSceneActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!ggPunishesInsteadOfMom(world)) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return isStep5PunishmentRoom(currentRoom);
  }

  static bool canSnitchToMomOnKitchen({
    required GameWorldState world,
    required NPCService npcService,
    required NPCModel? mom,
    required int hour,
    required int weekdayIndex,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (isMomExcludedFromQuestChain(world)) return false;
    if (!world.piperGradeCrisisActive ||
        world.piperCrisisResolved ||
        world.piperMomTalkingAboutGrades ||
        world.piperSnitchedToMom) {
      return false;
    }
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.kitchen) {
      return false;
    }
    if (mom == null || mom.id != 'mom') return false;
    return npcService.getCurrentLocationId(mom, hour, weekdayIndex) ==
        LocationsData.kitchen;
  }

  static bool isScriptedDialogActive({
    required GameWorldState world,
    required String currentZone,
    required bool isInsideRoom,
    required String currentRoom,
    required int weekdayIndex,
    required int hour,
  }) {
    final s = world.piperQuest001Step;
    if (s <= 0) return false;
    if (s == 1) {
      if (currentZone != 'COLLEGE' || !isInsideRoom) return false;
      return LocationsData.migrateLegacyRoomId(currentRoom) ==
          LocationsData.canteen;
    }
    if (s == 2) {
      if (currentZone != 'HOME' || !isInsideRoom) return false;
      return isStep2ApproachRoom(currentRoom);
    }
    if (s == 3) {
      if (isMomExcludedFromQuestChain(world)) return false;
      final r = LocationsData.migrateLegacyRoomId(currentRoom);
      return currentZone == 'HOME' &&
          isInsideRoom &&
          (r == LocationsData.kitchen || r == LocationsData.hall);
    }
    if (s == 4) {
      if (isMomExcludedFromQuestChain(world)) return false;
      return isStep4CorridorScene(
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
      );
    }
    if (s == 5) {
      if (currentZone != 'HOME' || !isInsideRoom) return false;
      if (ggPunishesInsteadOfMom(world)) {
        return isGgPunishmentSceneActive(
          world: world,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        );
      }
      return true;
    }
    if (s == 6) {
      return currentZone == 'HOME' && isInsideRoom;
    }
    return false;
  }

  static const step3IntroPatch = PiperQuest001Patch(
    newsL10nKey: 'piper_quest_001_step03_intro_news',
    videoPath: quest001TeacherCallVideo,
  );

  static const step4IntroPatch = PiperQuest001Patch(
    newsL10nKey: 'piper_quest_001_step04_intro_news',
  );

  static PiperQuest001Patch patchForStep2Phase({required bool videoSeen}) =>
      patchForStep(2);

  static PiperQuest001Patch patchForStep3Phase({required bool callOverheard}) {
    return callOverheard ? patchForStep(3) : step3IntroPatch;
  }

  static PiperQuest001Patch patchForStep4Phase({required bool scoldingOverheard}) {
    return scoldingOverheard ? patchForStep(4) : step4IntroPatch;
  }

  static PiperQuest001Patch patchForStep(int step) {
    switch (step) {
      case 1:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step01_news',
        );
      case 2:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step02_news',
        );
      case 3:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step03_news',
          videoPath: quest001TeacherCallVideo,
        );
      case 4:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step04_news',
        );
      case 5:
        return patchForPunishmentCrisis(1);
      case 6:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step06_news',
        );
      default:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step02_news',
        );
    }
  }

  static String? punishmentVideoForCrisis(int crisisN) {
    if (crisisN < firstPunishmentVideoCrisisN) return null;
    final index =
        (crisisN - firstPunishmentVideoCrisisN).clamp(0, quest001PunishmentVideos.length - 1);
    return quest001PunishmentVideos[index];
  }

  static bool isStep5PunishmentRoom(String currentRoom) =>
      LocationsData.migrateLegacyRoomId(currentRoom) == LocationsData.piperRoom;

  static int punishmentLevelFromCrisisN(int crisisN) {
    if (crisisN <= 1) return 1;
    if (crisisN == 2) return 2;
    return 3;
  }

  static int nextPunishmentLevel(GameWorldState world) =>
      punishmentLevelFromCrisisN(world.piperPunishmentCrisisN + 1);

  static String? momPunishmentVideoForCrisisN(int crisisN) {
    if (crisisN < firstPunishmentVideoCrisisN) return null;
    final index =
        (crisisN - firstPunishmentVideoCrisisN).clamp(0, quest001PunishmentVideos.length - 1);
    return quest001PunishmentVideos[index];
  }

  static String? ggPunishmentVideoForCrisisN(int crisisN) {
    if (crisisN < 3) return null;
    final index = (crisisN - 3).clamp(0, quest001GgPunishmentVideos.length - 1);
    return quest001GgPunishmentVideos[index];
  }

  static PiperQuest001Patch patchForStep5(GameWorldState world, int crisisN) {
    if (ggPunishesInsteadOfMom(world)) {
      return patchForGgPunishmentLevel(
        punishmentLevelFromCrisisN(crisisN),
      );
    }
    return patchForMomPunishmentLevel(
      punishmentLevelFromCrisisN(crisisN),
    );
  }

  static PiperQuest001Patch patchForMomPunishmentLevel(int level) {
    switch (level) {
      case 1:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_crisis1_news',
          videoPath: momPunishmentVideoForCrisisN(1),
        );
      case 2:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_crisis2_news',
          videoPath: momPunishmentVideoForCrisisN(2),
        );
      default:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_crisis3_news',
          videoPath: momPunishmentVideoForCrisisN(level),
        );
    }
  }

  static PiperQuest001Patch patchForGgPunishmentLevel(int level) {
    switch (level) {
      case 1:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_gg_level1_news',
        );
      case 2:
        return const PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_gg_level2_news',
        );
      default:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_gg_level3_news',
          videoPath: ggPunishmentVideoForCrisisN(level),
        );
    }
  }

  /// @deprecated Використовуй [patchForStep5]. Лишено для читів за номером кризи.
  static PiperQuest001Patch patchForPunishmentCrisis(int crisisN) {
    switch (crisisN) {
      case 1:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_crisis1_news',
          videoPath: momPunishmentVideoForCrisisN(1),
        );
      case 2:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_crisis2_news',
          videoPath: momPunishmentVideoForCrisisN(2),
        );
      default:
        return PiperQuest001Patch(
          newsL10nKey: 'piper_quest_001_step05_crisis3_news',
          videoPath: punishmentVideoForCrisis(crisisN),
        );
    }
  }

  static void closeCrisisPass(GameWorldState world) {
    world.piperQuest001Step = 6;
    world.piperGradeCrisisActive = false;
    world.piperBadGradeToday = false;
    world.teacherCallPending = false;
    world.piperPunishmentPending = false;
    world.piperUnderPunishment = false;
    world.piperNoPhone = false;
    world.piperHelpRequested = false;
    world.piperGgPunishmentThisCrisis = false;
    world.piperCrisisResolved = true;
  }

  /// Завершити крок 6 і повернутись до фонового режиму до наступної кризи.
  static void finishCrisisPass(GameWorldState world) {
    if (world.piperQuest001Step != 6) return;
    world.piperQuest001Step = 0;
    world.piperQuest001PassesCompleted++;
  }

  /// Чит: активна криза з поганою оцінкою сьогодні.
  static bool isCheatCrisisActive(GameWorldState world) =>
      world.piperGradeCrisisActive && !world.piperCrisisResolved;

  static bool isCheatPunishmentActive(GameWorldState world, int crisisN) =>
      world.piperQuest001Step == 5 &&
      world.piperUnderPunishment &&
      world.piperPunishmentCrisisN == crisisN;

  static bool isCheatGgPunishmentActive(GameWorldState world) =>
      world.piperQuest001Step == 5 &&
      world.piperUnderPunishment &&
      world.piperGgPunishmentThisCrisis;

  static void clearCheatPunishmentScene(GameWorldState world) {
    if (world.piperQuest001Step != 5) return;
    world.piperQuest001Step = 0;
    world.piperUnderPunishment = false;
    world.piperPunishmentPending = false;
    world.piperNoPhone = false;
    world.piperPunishmentCrisisN = 0;
  }

  /// Чит: показати покарання кризи 1 / 2 / 3 (крок 5).
  static void applyCheatPunishment({
    required GameWorldState world,
    required int crisisN,
  }) {
    clearCheatPunishmentScene(world);
    final n = crisisN.clamp(1, 3);
    world.piperMomTalkingAboutGrades = true;
    world.piperGradeCrisisActive = true;
    world.piperCrisisResolved = false;
    world.piperPunishmentCrisisN = n;
    world.piperQuest001Step = 5;
    world.piperUnderPunishment = true;
    world.piperPunishmentPending = false;
    world.piperNoPhone = n <= 2;
    world.piperQuest001Step5VideoSeen = false;
  }

  static void resetCheatPunishment(GameWorldState world, int crisisN) {
    if (isCheatPunishmentActive(world, crisisN)) {
      clearCheatPunishmentScene(world);
    }
  }

  /// Чит: покарання від ГG (крок 5, GG-гілка, криза 3+).
  static void applyCheatGgPunishment({required GameWorldState world}) {
    applyCheatPunishment(world: world, crisisN: 3);
    world.piperGgPunishmentGranted = true;
    world.piperGgPunishmentAnnouncedToPiper = true;
    world.piperGgPunishmentThisCrisis = true;
    world.piperPunishmentBranch = punishmentBranchGgPunisher;
    world.piperMomTalkingAboutGrades = false;
  }

  static void resetCheatGgPunishment(GameWorldState world) {
    if (isCheatGgPunishmentActive(world)) {
      clearCheatPunishmentScene(world);
    }
  }

  static void applyCheatActiveCrisis({
    required GameWorldState world,
    required DateTime gameDate,
  }) {
    clearCheatPunishmentScene(world);
    final rng = Random(gameDate.hashCode);
    startBadGradeCrisis(world: world, gameDate: gameDate, rng: rng);
    world.piperBadGradeToday = true;
  }

  static void resetCheat(GameWorldState world) {
    world.piperQuest001Step = 0;
    world.piperQuest001Step2VideoSeen = false;
    world.piperQuest001Step2GgDealSubmenu = false;
    world.piperQuest001Step3VideoSeen = false;
    world.piperQuest001Step5VideoSeen = false;
    world.piperQuest001Step3CallOverheard = false;
    world.piperQuest001Step4ScoldingOverheard = false;
    world.piperQuest001Step4EarliestDayKey = null;
    world.piperQuest001SnitchAckPending = false;
    world.piperQuest001GgPunishTalkPhase = 0;
    world.piperGgPunishmentGranted = false;
    world.piperGgPunishmentAnnouncedToPiper = false;
    world.piperGgPunishmentThisCrisis = false;
    world.piperGgVoluntaryPunishDoneThisCrisis = false;
    world.piperPunishmentBranch = '';
    world.piperBadGradesCount = 0;
    world.piperGradeCrisisActive = false;
    world.piperGradeSecretKnown = false;
    world.piperHelpRequested = false;
    world.piperCrisisResolved = false;
    world.piperSnitchedToMom = false;
    world.piperMomTalkingAboutGrades = false;
    world.teacherCallPending = false;
    world.teacherCalledMom = false;
    world.piperBadGradeDayKey = null;
    world.piperWorkdaysSinceBadGrade = 0;
    world.teacherCallDayKey = null;
    world.piperApproachSlot1Done = false;
    world.piperApproachSlot2Done = false;
    world.piperBadGradeSubject = '';
    world.piperBadGradeTeacherId = '';
    world.piperBadGradeToday = false;
    world.piperBadGradeWeekKey = null;
    world.piperBadGradeLastRollDayKey = null;
    world.piperPunishmentPending = false;
    world.piperPunishmentCrisisN = 0;
    world.piperUnderPunishment = false;
    world.teacherDealHookOpen = false;
    world.piperNoPhone = false;
    world.piperDebtType = '';
    world.piperQuest001PassesCompleted = 0;
  }
}
