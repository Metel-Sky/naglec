import '../../models/npc_model.dart';
import '../../services/game_world_state.dart';

/// Івенти та збережений прогрес для Sem (кориш).
///
/// Сценарії біля дверей дому (фасад вул. Шевченка), кнопки в [MainGameScreenState].

/// [NPCModel.id] Sem у даних гри.
const String kSemNpcId = 'sem';

/// Ключі [NPCModel.variables] для сценаріїв Sem.
abstract final class SemEventVars {
  /// Івент «Розмова про батьків» завершено (`true` після «Піти» з діалогу біля дверей).
  static const String talkedAboutParents = 'semTalkedAboutParents';

  /// Гравець запросив Sem подивитись порно (кнопка біля дверей).
  static const String invitedToWatchPorn = 'semInvitedToWatchPorn';
}

// --- Івент «Розмова про батьків» (фасад дому Sem) --------------------------------

/// Тексти в [strings_uk] / [strings_ru] / [strings_en] за цими ключами.
abstract final class SemParentsTalkEvent {
  SemParentsTalkEvent._();

  static const String l10nDialogueKey = 'friend_house_sem_parents_dialogue';
  static const String l10nAfterStreetKey = 'friend_house_sem_parents_after_street';
  static const String l10nAskButtonKey = 'friend_house_sem_ask_parents';

  /// Хвилини часу при відкритті діалогу (кнопка «Запитати про батьків»).
  static const int minutesOnOpenDialogue = 5;

  static bool _isSem(NPCModel npc) => npc.id == kSemNpcId;

  /// Чи вже пройдено івент (кнопка «Запитати…» більше не показується).
  static bool isComplete(NPCModel sem) =>
      _isSem(sem) && sem.getVar(SemEventVars.talkedAboutParents) == true;

  /// Чи показувати кнопку запиту (Sem і івент ще не завершено).
  static bool canShowAskButton(NPCModel sem) => _isSem(sem) && !isComplete(sem);

  /// Позначити івент виконаним (викликати перед збереженням гри).
  static void markComplete(NPCModel sem) {
    if (!_isSem(sem)) return;
    sem.setVar(SemEventVars.talkedAboutParents, true);
  }
}

/// Sem з [npcs] або `null`, якщо немає запису з [kSemNpcId].
NPCModel? findSemNpc(Iterable<NPCModel> npcs) {
  for (final n in npcs) {
    if (n.id == kSemNpcId) return n;
  }
  return null;
}

/// Підменю «Поговорити» з Sem (у кімнаті або біля дверей).
abstract final class SemTalkMenu {
  SemTalkMenu._();

  static const String l10nBtnNews = 'sem_talk_btn_news';
  static const String l10nBtnGirls = 'sem_talk_btn_girls';
  static const String l10nBtnParents = 'sem_talk_btn_parents';
  static const String l10nNewsFallback = 'friend_house_sem_talk_dialogue';
  static const String l10nGirlsDone = 'sem_talk_girls_done';
  static const String l10nParentsDone = 'sem_talk_parents_done';
}

/// Розмова з Sem після першого «палива» (palivo ≥ 1): розповісти про Juniper у кімнаті.
abstract final class SemPalivoGirlsTalk {
  SemPalivoGirlsTalk._();

  static const String l10nBtnWitness = 'sem_palivo_btn_tell_juniper_witness';
  static const String l10nDialogue = 'sem_palivo_girls_witness_dialogue';

  static bool canShowButton(GameWorldState world) =>
      world.palivo >= 1 && !world.semPalivoWitnessTalkDone;

  static void markDone(GameWorldState world) {
    world.semPalivoWitnessTalkDone = true;
  }
}
