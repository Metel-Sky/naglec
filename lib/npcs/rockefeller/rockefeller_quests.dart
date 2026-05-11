import '../../services/game_world_state.dart';

/// Усі квести NPC Rockefeller в одному файлі.
abstract final class RockefellerQuests {
  RockefellerQuests._();

  // Квест 1 — rockefeller_quest_001: реклама Nike (офісний старт).
  /// QUEST: rockefeller_quest_001
  static const String nikeQuestId = 'rockefeller_quest_001';

  /// Етапи офісного діалогу.
  /// 0 — не активний; 1 — старт; 2 — вибір; 3 — підтвердження.
  static const int officeStepInactive = 0;
  static const int officeStepIntro = 1;
  static const int officeStepOffer = 2;
  static const int officeStepAccepted = 3;

  static bool isWeekday(int weekdayIndex) =>
      weekdayIndex >= 0 && weekdayIndex <= 4;

  /// Ігровий час 9:00–17:59 — вікно для «Запитати про роботу» без cherie_quest_005.
  static bool isAskJobWindowHour(int hour) => hour >= 9 && hour < 18;

  /// Показувати «Запитати про роботу», якщо cherie_quest_005 ще не виконано:
  /// один раз на ігрову добу ([gameDateDdMmYyyy] як [GameTimeController.onlyDate]), лише 9–18.
  static bool canShowAskJobWhileCherie005Incomplete({
    required GameWorldState world,
    required String gameDateDdMmYyyy,
    required int hour,
  }) {
    if (world.cherieQuest005Complete) return false;
    if (!isAskJobWindowHour(hour)) return false;
    return world.rockefellerCherie005IncompleteAskLastDateKey !=
        gameDateDdMmYyyy;
  }

  /// Старт офісної гілки: будні, офіс (виклик з екрану), Чері 005 виконано,
  /// ще не почали «роботу в рекламі», квест не завершено.
  static bool canStartOfficeQuest({
    required GameWorldState world,
    required int weekdayIndex,
  }) {
    return world.cherieQuest005Complete &&
        !world.rockefellerNikeWorkStarted &&
        !world.rockefellerNikeAdCompleted &&
        world.rockefellerNikeOfficeStep == officeStepInactive &&
        isWeekday(weekdayIndex);
  }

  static bool canShowShootingButton({
    required GameWorldState world,
    required int weekdayIndex,
    required int hour,
  }) {
    return world.rockefellerNikeWorkStarted &&
        !world.rockefellerNikeAdCompleted &&
        !world.rockefellerNikeShootingInProgress &&
        !world.rockefellerNikeFinalReviewInProgress &&
        isWeekday(weekdayIndex) &&
        hour >= 9 &&
        hour <= 13;
  }

  static bool isReviewUnlocked(GameWorldState world) =>
      world.rockefellerNikeShootingDays >= 5;
}
