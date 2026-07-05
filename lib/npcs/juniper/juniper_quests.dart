import 'dart:math';

import 'package:intl/intl.dart';

import '../../data/locations_room_data.dart';
import '../../data/npc_sex_stats.dart';
import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/player_stats_controller.dart';
import '../sem/sem_juniper_evening_visits.dart';
import '../sem/sem_quests.dart';
import 'juniper_npc.dart';

/// QUEST: juniper_quest_001 — компромат Manuel + Juniper (4 відео, крок 1 — ванна Sem).
abstract final class JuniperQuest001 {
  JuniperQuest001._();

  static const String questId = 'juniper_quest_001';

  static const String korishFatherNpcId = 'korish_father';
  static const String npcVarKompromatCount = 'kompromat_count';

  /// Будні, обідня година (Manuel на роботі — сцена у ванній Sem).
  static const int step1TriggerHour = 12;

  /// Шанс 10% при вході у ванну Sem у слот 12:00.
  static const int step1TriggerChancePercent = 10;

  /// Мінімум повних «спалив у кімнаті Sem» (4 відео) перед kompromat.
  static const int minSemRoomWitnessCount = 2;

  /// 3 тижні вечірніх візитів — Juniper «живе» у Sem щодня.
  static const int minDaysJuniperAtSem =
      SemJuniperEveningVisits.weekLengthDays *
      SemJuniperEveningVisits.totalWeeks;

  static const String step1VideoPath =
      'lib/assets/npcs/juniper/junip_manuel_01.mp4';

  /// Крок 2: зал Sem, 5 днів після кроку 1, та сама година.
  static const int step2DaysAfterStep1Witness = 5;

  /// Шанс 20% при вході в зал Sem у слот години кроку 2.
  static const int step2TriggerChancePercent = 20;

  static const String step2VideoPath =
      'lib/assets/npcs/juniper/junip_manuel_zal_01.mp4';

  /// Після «Тікати» — гостева кімната (вітальня) Sem.
  static const String step2EscapeRoomId = LocationsData.friendLounge;

  static const double playerArousalOnKompromatVideo = 15;

  static const String step1ClosedDoorImagePath =
      'lib/assets/npcs/juniper/img/close_dor.png';

  static const List<String> allVideoPaths = [
    'lib/assets/npcs/juniper/junip_manuel_01.mp4',
    'lib/assets/npcs/juniper/junip_manuel_zal_01.mp4',
    'lib/assets/npcs/juniper/junip_manuel_02.mp4',
    'lib/assets/npcs/juniper/junip_manuel_03.mp4',
    'lib/assets/npcs/juniper/komprom_manuel.mp4',
  ];

  static const String l10nStep1Intro = 'juniper_quest_001_step1_intro';
  static const String l10nStep1RecordFail = 'juniper_quest_001_step1_record_fail';
  static const String l10nStep2Intro = 'juniper_quest_001_step2_intro';
  static const String l10nStep2AfterFlee = 'juniper_quest_001_step2_after_flee';
  static const String l10nBtnRecord = 'juniper_quest_001_btn_record';
  static const String l10nBtnFlee = 'juniper_quest_001_btn_flee';

  static bool isWeekday(int weekdayIndex) => weekdayIndex >= 0 && weekdayIndex <= 4;

  static bool isKompromatAssetPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('junip_manuel_') || lower.contains('komprom_manuel');
  }

  static bool ownsEventVideo(String? path) =>
      path != null && isKompromatAssetPath(path);

  /// Крок 1: відео у ванні Sem (перший шар StreetView, до «Зняти на відео»).
  static bool isStep1VideoSceneActive({
    required bool uiActive,
    required bool afterRecord,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      uiActive &&
      !afterRecord &&
      isInFriendBathroom(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  static String? step1StreetViewVideoPath({
    required bool uiActive,
    required bool afterRecord,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      isStep1VideoSceneActive(
        uiActive: uiActive,
        afterRecord: afterRecord,
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      )
          ? step1VideoPath
          : null;

  /// Juniper уже «оселилась» у Sem (3+ тижні стосунків, знайомство з ГG).
  static bool isJuniperLivingAtSemDaily({
    required GameWorldState world,
    required String gameDateKey,
  }) {
    if (!world.semJuniperDating || !world.semJuniperMet) return false;
    final start = world.semJuniperDatingStartDateKey;
    if (start == null || start.isEmpty) return false;
    return SemQuest001.daysSinceDateKey(start, gameDateKey) >= minDaysJuniperAtSem;
  }

  /// Усі передумови арки kompromat (крок 1 ще може не стартувати).
  static bool isKompromatArcUnlocked({
    required GameWorldState world,
    required String gameDateKey,
  }) =>
      isJuniperLivingAtSemDaily(world: world, gameDateKey: gameDateKey) &&
      world.semJuniperSemRoomSexWitnessCount >= minSemRoomWitnessCount &&
      world.semPalivoWitnessTalkDone &&
      world.juniperPalivoApologyTalkDone;

  static bool isInFriendBathroom({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      zone == 'STREET' &&
      streetHouse == LocationsData.friendHouse &&
      insideRoom &&
      LocationsData.migrateLegacyRoomId(room) == LocationsData.friendBathroom;

  static bool isInFriendParentsRoom({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      zone == 'STREET' &&
      streetHouse == LocationsData.friendHouse &&
      insideRoom &&
      LocationsData.migrateLegacyRoomId(room) ==
          LocationsData.friendParentsRoom;

  static bool isInFriendHall({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      zone == 'STREET' &&
      streetHouse == LocationsData.friendHouse &&
      insideRoom &&
      LocationsData.migrateLegacyRoomId(room) == LocationsData.friendHall;

  static bool isInFriendLounge({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      zone == 'STREET' &&
      streetHouse == LocationsData.friendHouse &&
      insideRoom &&
      LocationsData.migrateLegacyRoomId(room) == LocationsData.friendLounge;

  /// Крок 2: відео у залі Sem (перший шар StreetView).
  static bool isStep2VideoSceneActive({
    required bool uiActive,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      uiActive &&
      isInFriendHall(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  static String? kompromatStreetViewVideoPath({
    required bool step1UiActive,
    required bool step1AfterRecord,
    required bool step2UiActive,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
    required String? step1VideoPathActive,
    required String? step2VideoPathActive,
  }) {
    if (isStep2VideoSceneActive(
      uiActive: step2UiActive,
      zone: zone,
      streetHouse: streetHouse,
      insideRoom: insideRoom,
      room: room,
    )) {
      final p = step2VideoPathActive?.trim();
      return (p != null && p.isNotEmpty) ? p : step2VideoPath;
    }
    return step1StreetViewVideoPath(
      uiActive: step1UiActive,
      afterRecord: step1AfterRecord,
      zone: zone,
      streetHouse: streetHouse,
      insideRoom: insideRoom,
      room: room,
    );
  }

  /// День і година, коли ГG вперше побачив Manuel + Juniper (крок 1).
  static void recordStep1Witness({
    required GameWorldState world,
    required String gameDateKey,
    required int hour,
  }) {
    if (world.juniperManuelKompromatStep1WitnessDateKey != null) return;
    world.juniperManuelKompromatStep1WitnessDateKey = gameDateKey;
    world.juniperManuelKompromatStep1WitnessHour = hour;
  }

  static int step1WitnessHour(GameWorldState world) =>
      world.juniperManuelKompromatStep1WitnessHour ?? step1TriggerHour;

  static void applyKompromatVideoArousal(PlayerStatsController playerStats) {
    playerStats.changeArousal(playerArousalOnKompromatVideo);
  }

  static bool canTriggerStep1({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
  }) {
    if (world.juniperManuelKompromatStep1Done) return false;
    if (!isKompromatArcUnlocked(world: world, gameDateKey: gameDateKey)) {
      return false;
    }
    if (!isWeekday(weekdayIndex)) return false;
    if (hour != step1TriggerHour) return false;
    return true;
  }

  static bool rollStep1Trigger() =>
      Random().nextInt(100) < step1TriggerChancePercent;

  static NPCModel? _npcById(Iterable<NPCModel> npcs, String id) {
    for (final n in npcs) {
      if (n.id == id) return n;
    }
    return null;
  }

  static int kompromatCount(NPCModel npc) {
    final raw = npc.variables[npcVarKompromatCount];
    if (raw is int) return raw.clamp(0, 999);
    if (raw is num) return raw.toInt().clamp(0, 999);
    return 0;
  }

  static void incrementKompromatCount(NPCModel npc) {
    npc.setVar(npcVarKompromatCount, kompromatCount(npc) + 1);
  }

  /// Після «Зняти на відео»: +1 компромат Manuel і Juniper, крок 1 завершено.
  static void applyStep1RecordAttempt({
    required GameWorldState world,
    required Iterable<NPCModel> npcs,
    required String gameDateKey,
    required int hour,
  }) {
    world.juniperManuelKompromatStep1Done = true;
    world.juniperManuelKompromatStep1DoneDateKey = gameDateKey;
    recordStep1Witness(world: world, gameDateKey: gameDateKey, hour: hour);
    final juniper = _npcById(npcs, kJuniperNpcId);
    final manuel = _npcById(npcs, korishFatherNpcId);
    if (juniper != null) incrementKompromatCount(juniper);
    if (manuel != null) incrementKompromatCount(manuel);
  }

  /// Якорна дата для «+5 днів» кроку 2: спочатку день перегляду, інакше день завершення кроку 1.
  static String? step2TimingAnchorDateKey(GameWorldState world) =>
      world.juniperManuelKompromatStep1WitnessDateKey ??
      world.juniperManuelKompromatStep1DoneDateKey;

  /// Старі сейви / чит кроку 1 без witness — один раз підставляємо якір, щоб крок 2 міг стартувати.
  static void ensureStep2TimingAnchor({
    required GameWorldState world,
    required String gameDateKey,
  }) {
    if (!world.juniperManuelKompromatStep1Done) return;
    if (step2TimingAnchorDateKey(world) != null) return;
    world.juniperManuelKompromatStep1WitnessDateKey = _dateKeyDaysBefore(
      gameDateKey,
      step2DaysAfterStep1Witness,
    );
    world.juniperManuelKompromatStep1WitnessHour ??= step1TriggerHour;
  }

  static bool rollStep2Trigger() =>
      Random().nextInt(100) < step2TriggerChancePercent;

  /// Після «Тікати»: крок 2 завершено, Juniper sex +1, Alex arousal +15.
  static void applyStep2Flee({
    required GameWorldState world,
    required Iterable<NPCModel> npcs,
    required PlayerStatsController playerStats,
  }) {
    world.juniperManuelKompromatStep2Done = true;
    applyKompromatVideoArousal(playerStats);
    final juniper = _npcById(npcs, kJuniperNpcId);
    if (juniper != null) NpcSexStats.incrementSex(juniper);
  }

  // --- Чити (профіль Juniper, розділ квестів) ---

  static String _dateKeyDaysBefore(String dateKey, int days) {
    try {
      final parsed = DateFormat('dd.MM.yyyy').parse(dateKey);
      return DateFormat('dd.MM.yyyy')
          .format(parsed.subtract(Duration(days: days)));
    } catch (_) {
      return dateKey;
    }
  }

  static void applyCheatMet(GameWorldState world) {
    world.semJuniperMet = true;
  }

  static void resetCheatMet(GameWorldState world) {
    world.semJuniperMet = false;
  }

  static void applyCheatLivingAtSem(
    GameWorldState world,
    String gameDateKey,
  ) {
    world.semJuniperMet = true;
    world.semJuniperDating = true;
    world.semJuniperDatingStartDateKey =
        _dateKeyDaysBefore(gameDateKey, minDaysJuniperAtSem);
  }

  static void resetCheatLivingAtSem(GameWorldState world) {
    world.semJuniperDating = false;
    world.semJuniperDatingStartDateKey = null;
  }

  static void applyCheatSemRoomWitness(GameWorldState world) {
    world.semJuniperSemRoomSexWitnessCount = minSemRoomWitnessCount;
    world.semJuniperSemRoomSexCompleted = true;
    if (world.palivo < 1) world.palivo = 1;
  }

  static void resetCheatSemRoomWitness(GameWorldState world) {
    world.semJuniperSemRoomSexWitnessCount = 0;
    world.semJuniperSemRoomSexCompleted = false;
  }

  static void applyCheatSemPalivoTalk(GameWorldState world) {
    if (world.palivo < 1) world.palivo = 1;
    world.semPalivoWitnessTalkDone = true;
  }

  static void resetCheatSemPalivoTalk(GameWorldState world) {
    world.semPalivoWitnessTalkDone = false;
  }

  static void applyCheatJuniperPalivoTalk(GameWorldState world) {
    if (world.palivo < 1) world.palivo = 1;
    world.juniperPalivoApologyTalkDone = true;
  }

  static void resetCheatJuniperPalivoTalk(GameWorldState world) {
    world.juniperPalivoApologyTalkDone = false;
  }

  static void applyCheatKompromatStep1Done({
    required GameWorldState world,
    required Iterable<NPCModel> npcs,
    required String gameDateKey,
  }) {
    if (!world.juniperManuelKompromatStep1Done) {
      applyStep1RecordAttempt(
        world: world,
        npcs: npcs,
        gameDateKey: gameDateKey,
        hour: step1TriggerHour,
      );
    } else {
      ensureStep2TimingAnchor(world: world, gameDateKey: gameDateKey);
    }
  }

  static void resetCheatKompromatStep1Done(GameWorldState world) {
    world.juniperManuelKompromatStep1Done = false;
    world.juniperManuelKompromatStep1WitnessDateKey = null;
    world.juniperManuelKompromatStep1WitnessHour = null;
    world.juniperManuelKompromatStep1DoneDateKey = null;
  }

  static void applyCheatKompromatStep2Done({
    required GameWorldState world,
    required Iterable<NPCModel> npcs,
    required String gameDateKey,
  }) {
    if (!world.juniperManuelKompromatStep1Done) {
      applyCheatKompromatStep1Done(
        world: world,
        npcs: npcs,
        gameDateKey: gameDateKey,
      );
    }
    if (world.juniperManuelKompromatStep1WitnessDateKey == null) {
      world.juniperManuelKompromatStep1WitnessDateKey = _dateKeyDaysBefore(
        gameDateKey,
        step2DaysAfterStep1Witness,
      );
      world.juniperManuelKompromatStep1WitnessHour = step1TriggerHour;
    }
    world.juniperManuelKompromatStep2Done = true;
  }

  static void resetCheatKompromatStep2Done(GameWorldState world) {
    world.juniperManuelKompromatStep2Done = false;
  }

  /// Чит «Пропустити п'ять днів» — одразу дозволяє слот кроку 2 (без очікування).
  static void applyCheatSkipFiveDays({
    required GameWorldState world,
    required String gameDateKey,
  }) {
    world.juniperManuelKompromatStep2SkipFiveDaysCheat = true;
    if (!world.juniperManuelKompromatStep1Done) return;
    world.juniperManuelKompromatStep1WitnessDateKey = _dateKeyDaysBefore(
      gameDateKey,
      step2DaysAfterStep1Witness,
    );
    world.juniperManuelKompromatStep1WitnessHour ??= step1TriggerHour;
  }

  static void resetCheatSkipFiveDays(GameWorldState world) {
    world.juniperManuelKompromatStep2SkipFiveDaysCheat = false;
  }
}
