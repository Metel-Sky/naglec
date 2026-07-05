import '../juniper/juniper_npc.dart';
import '../../data/locations_room_data.dart';
import '../../services/game_time_controller.dart';
import '../../services/game_world_state.dart';

/// QUEST: sem_quest_001 — арка Juniper (знайомство, стосунки з Sem): подальший сюжет.
abstract final class SemQuest001 {
  SemQuest001._();

  static const String questId = 'sem_quest_001';

  /// Статус «Дівчина Sem» у профілі — лише після [GameWorldState.semJuniperDating].
  static bool isJuniperSemGirlfriendStatus(GameWorldState? world) =>
      world?.semJuniperDating == true;

  /// Рядок статусу Juniper для профілю, галереї та телефону.
  static String juniperProfileStatus({GameWorldState? world}) =>
      isJuniperSemGirlfriendStatus(world)
          ? kJuniperSemGirlfriendStatus
          : kJuniperDefaultStatus;

  static const int foundSomeoneButtonMinDays = 3;
  static const int collegeMeetMinDays = foundSomeoneButtonMinDays;
  static const int juniperAtSemMinDays = 7;

  /// «Поговорити про дівчат» з Sem — з 15-го дня гри (08.09.2025 при старті 25.08.2025).
  static const int girlsTalkUnlockMinGameDay = 15;

  /// Якщо стільки днів без follow-up — івент у коридорі будинку Sem.
  static const int autoIntroDaysWithoutTopicTalk = 14;

  static const String l10nGirlsTalkButton = 'sem_juniper_btn_talk_girls';
  static const String l10nGirlsHintButton = 'sem_juniper_btn_hint_girlfriend';
  static const String l10nGirlsTalkDialogue = 'sem_juniper_girls_talk_dialogue';
  static const String l10nGirlsSisterAskButton = 'sem_juniper_btn_ask_sister';
  static const String l10nGirlsSisterDialogue = 'sem_juniper_girls_sister_dialogue';
  static const String l10nGirlsSubBackButton = 'sem_juniper_girls_sub_btn_back';
  static const String l10nFoundSomeoneButton = 'sem_juniper_btn_found_someone';
  static const String l10nFoundSomeoneDialogue = 'sem_juniper_found_someone_dialogue';
  /// Зворотна сумісність зі старими ключами l10n.
  static const String l10nSemNewsButton = l10nFoundSomeoneButton;
  static const String l10nSemNewsDialogue = l10nFoundSomeoneDialogue;
  static const String l10nCorridorNoise = 'sem_juniper_corridor_noise';

  static int daysSinceDateKey(String? fromKey, String toKey) =>
      GameTimeController.daysSinceDateKey(fromKey, toKey);

  /// Номер ігрового дня від [GameWorldState.gameStartDateKey] (1 = перший день).
  static int gameDayNumber({
    required GameWorldState world,
    required String gameDateKey,
  }) =>
      GameTimeController.gameDayNumber(
        gameStartDateKey:
            world.gameStartDateKey ?? GameTimeController.defaultGameStartDateKey,
        currentDateKey: gameDateKey,
      );

  static bool isGirlsTalkUnlockedByGameDay({
    required GameWorldState world,
    required String gameDateKey,
  }) =>
      gameDayNumber(world: world, gameDateKey: gameDateKey) >=
      girlsTalkUnlockMinGameDay;

  static bool isJuniperVisibleInWorld(GameWorldState world) =>
      world.semJuniperMet;

  static bool canShowGirlsTalkButton({
    required GameWorldState world,
    required String gameDateKey,
    required bool semSummonedAtFacade,
  }) =>
      semSummonedAtFacade &&
      isGirlsTalkUnlockedByGameDay(world: world, gameDateKey: gameDateKey) &&
      (!world.semJuniperGirlsTalkDone || !world.semGirlsSisterTalkDone);

  static bool canShowFoundSomeoneButton({
    required GameWorldState world,
    required String gameDateKey,
    required bool semSummonedAtFacade,
  }) =>
      semSummonedAtFacade &&
      world.semJuniperGirlsTalkDone &&
      world.semJuniperCollegeMeetDone &&
      !world.semJuniperMet &&
      !world.semJuniperFollowUpDone &&
      daysSinceDateKey(world.semJuniperLastTopicTalkDateKey, gameDateKey) >=
          foundSomeoneButtonMinDays;

  static int daysSinceGirlsHint(GameWorldState world, String gameDateKey) =>
      daysSinceDateKey(world.semJuniperLastTopicTalkDateKey, gameDateKey);

  /// Juniper уже «у Sem» за календарем (7+ днів після натяку, Sem знайшов Juniper).
  static bool isJuniperAtSemDue({
    required GameWorldState world,
    required String gameDateKey,
  }) =>
      world.semJuniperGirlsTalkDone &&
      world.semJuniperCollegeMeetDone &&
      !world.semJuniperMet &&
      daysSinceGirlsHint(world, gameDateKey) >= juniperAtSemMinDays;

  static void syncArcTimersIfDue(GameWorldState world, String gameDateKey) {
    syncCollegeMeetIfDue(world, gameDateKey);
  }

  static bool canShowSemNewsButton({
    required GameWorldState world,
    required String gameDateKey,
    required bool semSummonedAtFacade,
  }) =>
      canShowFoundSomeoneButton(
        world: world,
        gameDateKey: gameDateKey,
        semSummonedAtFacade: semSummonedAtFacade,
      );

  static bool isCorridorAutoIntroDue({
    required GameWorldState world,
    required String gameDateKey,
  }) =>
      world.semJuniperGirlsTalkDone &&
      !world.semJuniperMet &&
      !world.semJuniperFollowUpDone &&
      daysSinceDateKey(world.semJuniperLastTopicTalkDateKey, gameDateKey) >=
          autoIntroDaysWithoutTopicTalk;

  static bool isInFriendHouseCorridor({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      zone == 'STREET' &&
      streetHouse == LocationsData.friendHouse &&
      insideRoom &&
      LocationsData.migrateLegacyRoomId(room) == LocationsData.friendCorridor;

  static bool isInSemRoom({
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      zone == 'STREET' &&
      streetHouse == LocationsData.friendHouse &&
      insideRoom &&
      LocationsData.migrateLegacyRoomId(room) == LocationsData.friendRoom;

  static bool shouldShowCorridorNoise({
    required GameWorldState world,
    required String gameDateKey,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) =>
      isInFriendHouseCorridor(
        zone: zone,
        streetHouse: streetHouse,
        insideRoom: insideRoom,
        room: room,
      ) &&
      isCorridorAutoIntroDue(world: world, gameDateKey: gameDateKey) &&
      !world.semJuniperCorridorNoiseShown;

  /// Натяк «пора шукати дівчину» — старт таймера знайомства з Juniper.
  static void markGirlsHintDone(GameWorldState world, String gameDateKey) {
    world.semJuniperGirlsTalkDone = true;
    world.semJuniperLastTopicTalkDateKey = gameDateKey;
  }

  static void markGirlsTalkDone(GameWorldState world, String gameDateKey) {
    markGirlsHintDone(world, gameDateKey);
  }

  static void markSisterTalkDone(GameWorldState world) {
    world.semGirlsSisterTalkDone = true;
  }

  /// Після [collegeMeetMinDays] від першої розмови — Sem познайомився з Juniper у коледжі.
  static void syncCollegeMeetIfDue(GameWorldState world, String gameDateKey) {
    if (world.semJuniperCollegeMeetDone || !world.semJuniperGirlsTalkDone) {
      return;
    }
    if (daysSinceDateKey(
          world.semJuniperLastTopicTalkDateKey,
          gameDateKey,
        ) >=
        collegeMeetMinDays) {
      world.semJuniperCollegeMeetDone = true;
    }
  }

  /// «Новини Sem» на фасаді: вони вже зустрічаються → статус «Дівчина Sem».
  static void markSemNewsDone(GameWorldState world, String gameDateKey) {
    world.semJuniperFollowUpDone = true;
    world.semJuniperLastTopicTalkDateKey = gameDateKey;
    markJuniperDatingStarted(world, gameDateKey);
  }

  static void markFollowUpDone(GameWorldState world, String gameDateKey) {
    markSemNewsDone(world, gameDateKey);
  }

  /// Знайомство в кімnаті Sem без попереднього питання на фасаді.
  static void markSkippedFacadeIntroDone(
    GameWorldState world,
    String gameDateKey,
  ) {
    world.semJuniperFollowUpDone = true;
    markJuniperMet(world);
    markJuniperDatingStarted(world, gameDateKey);
  }

  static void markCorridorNoiseShown(GameWorldState world) {
    world.semJuniperCorridorNoiseShown = true;
  }

  static void markJuniperMet(GameWorldState world) {
    world.semJuniperMet = true;
  }

  /// Початок стосунків із Sem — у профілі з’являється статус «Дівчина Sem».
  static void markJuniperDatingStarted(
    GameWorldState world,
    String gameDateKey,
  ) {
    if (!world.semJuniperDating) {
      world.semJuniperDatingStartDateKey = gameDateKey;
    }
    world.semJuniperDating = true;
  }

  /// Чіт: підготовка до сцени знайомства в кімнаті Sem (увімкнути → зайти в кімнату Sem).
  static void applyIntroDebugReady(GameWorldState world, String gameDateKey) {
    markGirlsHintDone(world, gameDateKey);
    world.semJuniperCollegeMeetDone = true;
    markSemNewsDone(world, gameDateKey);
    world.semJuniperMet = false;
    world.semJuniperCorridorNoiseShown = false;
    world.semJuniperEveningClipShownDateKey = null;
    world.semJuniperShowerSceneDateKey = null;
    world.semJuniperVideoStatsHourKey = null;
    world.semJuniperSemRoomSexCompleted = false;
    world.semJuniperSemRoomSexWitnessCount = 0;
    world.palivo = 0;
    world.semPalivoWitnessTalkDone = false;
    world.juniperPalivoApologyTalkDone = false;
  }

  /// Чіт: скинути арку sem_quest_001 (знайомство / стосунки з Juniper).
  static void resetIntroDebugArc(GameWorldState world) {
    world.semJuniperGirlsTalkDone = false;
    world.semGirlsSisterTalkDone = false;
    world.semJuniperLastTopicTalkDateKey = null;
    world.semJuniperCollegeMeetDone = false;
    world.semJuniperFollowUpDone = false;
    world.semJuniperMet = false;
    world.semJuniperCorridorNoiseShown = false;
    world.semJuniperDating = false;
    world.semJuniperDatingStartDateKey = null;
    world.semJuniperEveningClipShownDateKey = null;
    world.semJuniperShowerSceneDateKey = null;
    world.semJuniperVideoStatsHourKey = null;
    world.semJuniperSemRoomSexCompleted = false;
    world.semJuniperSemRoomSexWitnessCount = 0;
    world.palivo = 0;
    world.semPalivoWitnessTalkDone = false;
    world.juniperPalivoApologyTalkDone = false;
  }

  static bool isIntroDebugReady(GameWorldState world) =>
      world.semJuniperFollowUpDone &&
      world.semJuniperCollegeMeetDone &&
      !world.semJuniperMet;
}
