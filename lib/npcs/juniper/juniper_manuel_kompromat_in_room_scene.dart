import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';
import '../../services/player_stats_controller.dart';
import '../sem/sem_quests.dart';
import 'juniper_quests.dart';

/// In-room відео kompromat Manuel + Juniper (крок 1 — ванна, крок 2 — зал Sem).
/// Запуск: [InRoomVideoSceneLauncher.launch] / `_launchInRoomVideo` на екрані.
/// Показ: [InRoomVideoSceneLauncher.buildZoneLayer] у [StreetView].
abstract final class JuniperManuelKompromatInRoomScene {
  JuniperManuelKompromatInRoomScene._();

  static const String step1VideoPath = JuniperQuest001.step1VideoPath;
  static const String step2VideoPath = JuniperQuest001.step2VideoPath;

  static bool ownsEventVideo(String? path) =>
      JuniperQuest001.ownsEventVideo(path);

  static bool isStep1VideoPhase(JuniperManuelKompromatPhase phase) =>
      phase == JuniperManuelKompromatPhase.step1Video;

  static bool isStep2VideoPhase(JuniperManuelKompromatPhase phase) =>
      phase == JuniperManuelKompromatPhase.step2Video;

  static bool isStep2AfterFleePhase(JuniperManuelKompromatPhase phase) =>
      phase == JuniperManuelKompromatPhase.step2AfterFlee;

  static bool isStep1UiPhase(JuniperManuelKompromatPhase phase) =>
      phase == JuniperManuelKompromatPhase.step1Video ||
      phase == JuniperManuelKompromatPhase.step1AfterRecord;

  static bool isAfterRecordPhase(JuniperManuelKompromatPhase phase) =>
      phase == JuniperManuelKompromatPhase.step1AfterRecord;

  /// Крок 1: фаза + ванна Sem (відео / «зачинені двері» + діалог).
  static bool isStep1UiCoherent({
    required JuniperManuelKompromatPhase phase,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      isStep1UiPhase(phase) &&
      JuniperQuest001.isInFriendBathroom(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  /// Крок 2 (відео): фаза + зал Sem (відео + діалог + «Тікати»).
  static bool isStep2UiCoherent({
    required JuniperManuelKompromatPhase phase,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      isStep2VideoPhase(phase) &&
      JuniperQuest001.isInFriendHall(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  /// Після «Тікати»: діалог у гостевій кімнаті Sem (без відео).
  static bool isStep2AfterFleeUiCoherent({
    required JuniperManuelKompromatPhase phase,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      isStep2AfterFleePhase(phase) &&
      JuniperQuest001.isInFriendLounge(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );

  static bool isPhaseCoherentWithLocation({
    required JuniperManuelKompromatPhase phase,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    switch (phase) {
      case JuniperManuelKompromatPhase.inactive:
        return true;
      case JuniperManuelKompromatPhase.step1Video:
      case JuniperManuelKompromatPhase.step1AfterRecord:
        return JuniperQuest001.isInFriendBathroom(
          zone: zone,
          streetHouse: streetHouse,
          insideRoom: insideRoom,
          room: room,
        );
      case JuniperManuelKompromatPhase.step2Video:
        return JuniperQuest001.isInFriendHall(
          zone: zone,
          streetHouse: streetHouse,
          insideRoom: insideRoom,
          room: room,
        );
      case JuniperManuelKompromatPhase.step2AfterFlee:
        return JuniperQuest001.isInFriendLounge(
          zone: zone,
          streetHouse: streetHouse,
          insideRoom: insideRoom,
          room: room,
        );
    }
  }

  /// Чи [message] — текст одного з кроків kompromat (для скидання поза сценою).
  static bool isKompromatDialogMessage(
    String message,
    String Function(String key) translate,
  ) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return false;
    return trimmed == translate(JuniperQuest001.l10nStep1Intro).trim() ||
        trimmed == translate(JuniperQuest001.l10nStep1RecordFail).trim() ||
        trimmed == translate(JuniperQuest001.l10nStep2Intro).trim() ||
        trimmed == translate(JuniperQuest001.l10nStep2AfterFlee).trim();
  }

  /// L10n-ключ діалогу для поточної фази (лише якщо фаза активна).
  static String? dialogueL10nKeyForPhase(JuniperManuelKompromatPhase phase) {
    switch (phase) {
      case JuniperManuelKompromatPhase.step1Video:
        return JuniperQuest001.l10nStep1Intro;
      case JuniperManuelKompromatPhase.step1AfterRecord:
        return JuniperQuest001.l10nStep1RecordFail;
      case JuniperManuelKompromatPhase.step2Video:
        return JuniperQuest001.l10nStep2Intro;
      case JuniperManuelKompromatPhase.step2AfterFlee:
        return JuniperQuest001.l10nStep2AfterFlee;
      case JuniperManuelKompromatPhase.inactive:
        return null;
    }
  }

  static bool isActivePhase(JuniperManuelKompromatPhase phase) =>
      phase != JuniperManuelKompromatPhase.inactive;

  static String videoPathForPhase(JuniperManuelKompromatPhase phase) {
    switch (phase) {
      case JuniperManuelKompromatPhase.step1Video:
        return step1VideoPath;
      case JuniperManuelKompromatPhase.step2Video:
        return step2VideoPath;
      case JuniperManuelKompromatPhase.inactive:
      case JuniperManuelKompromatPhase.step1AfterRecord:
      case JuniperManuelKompromatPhase.step2AfterFlee:
        return '';
    }
  }

  static bool isVideoSceneActive({
    required JuniperManuelKompromatPhase phase,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (phase == JuniperManuelKompromatPhase.step1Video) {
      return JuniperQuest001.isInFriendBathroom(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );
    }
    if (phase == JuniperManuelKompromatPhase.step2Video) {
      return JuniperQuest001.isInFriendHall(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      );
    }
    return false;
  }

  /// Шлях для [StreetView] / [InRoomVideoSceneLauncher.buildZoneLayer].
  static String? streetViewVideoPath({
    required JuniperManuelKompromatPhase phase,
    required String? videoPathActive,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (!isVideoSceneActive(
      phase: phase,
      zone: zone,
      streetHouse: streetHouse,
      insideRoom: insideRoom,
      room: room,
    )) {
      return null;
    }
    final active = videoPathActive?.trim();
    if (active != null && active.isNotEmpty) return active;
    final fallback = videoPathForPhase(phase).trim();
    return fallback.isEmpty ? null : fallback;
  }

  static bool isTriggerHour({
    required int hour,
    required int minute,
    required GameWorldState world,
  }) {
    final witnessHour = JuniperQuest001.step1WitnessHour(world);
    if (hour == witnessHour) return true;
    // Вхід у кімнату +5 хв: клік о :56–:59 → після addMinutes наступна година, але той самий слот.
    if (hour == (witnessHour + 1) % 24 && minute < 10) return true;
    return false;
  }

  static bool canTriggerStep2({
    required GameWorldState world,
    required String gameDateKey,
    required int hour,
    required int minute,
  }) {
    if (world.juniperManuelKompromatStep2Done) return false;
    if (!world.juniperManuelKompromatStep1Done) return false;
    JuniperQuest001.ensureStep2TimingAnchor(
      world: world,
      gameDateKey: gameDateKey,
    );
    final anchorDate = JuniperQuest001.step2TimingAnchorDateKey(world);
    if (anchorDate == null || anchorDate.isEmpty) return false;
    if (!world.juniperManuelKompromatStep2SkipFiveDaysCheat &&
        SemQuest001.daysSinceDateKey(anchorDate, gameDateKey) <
            JuniperQuest001.step2DaysAfterStep1Witness) {
      return false;
    }
    return isTriggerHour(hour: hour, minute: minute, world: world);
  }

  static bool rollStep2Trigger() => JuniperQuest001.rollStep2Trigger();

  static void applyStep2Flee({
    required GameWorldState world,
    required Iterable<NPCModel> npcs,
    required PlayerStatsController playerStats,
  }) {
    JuniperQuest001.applyStep2Flee(
      world: world,
      npcs: npcs,
      playerStats: playerStats,
    );
  }
}

/// Фаза in-room сцени kompromat на екрані гри.
enum JuniperManuelKompromatPhase {
  inactive,
  step1Video,
  step1AfterRecord,
  step2Video,
  step2AfterFlee,
}
