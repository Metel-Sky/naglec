import '../../models/npc_model.dart';

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
