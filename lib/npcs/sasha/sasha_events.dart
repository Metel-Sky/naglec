import '../../models/npc_model.dart';
import '../../data/npc_finance_state.dart';
import '../../services/game_world_state.dart';
import '../../services/inventory_controller.dart';
import '../../services/player_stats_controller.dart';

/// Фази івенту `comunicate_sasha_in_zal` (Sasha в залі біля ТБ).
enum ComunicateSashaInHallPhase {
  /// 1) Вступний діалог + кнопки «Підійти до Саши» / «Піти»
  intro,

  /// 2) Старт відео + діалог Саші
  videoAndTalk,

  /// 3) Вибір дії: гроші / Ред Бул (енергетик) / «Послать і піти»
  moneyChoice,
}

/// Івент №2 Саші: ранковий пробіг біля вулиці.
/// Зберігаємо кроки в [NPCModel.variables], щоб прогрес переживав сейв/лоад.
enum SashaMorningRunPhase {
  /// 1) Старт зустрічі: відео run_1, кнопки «Підійти» / «залишити в спокої»
  intro,

  /// 2) Підійти: відео run_2, діалог, кнопка «ну і вали»
  video2,

  /// 3) Після «ну і вали»: відео run_2, діалог з умовою боргу, кнопки гроші/послати
  payOffer,

  /// 3б) Після «дати гроші»: вибір 10 / 20 / 50 / назад
  moneyAmountChoice,

  /// 4) Після оплати: відео run_2, фінальний діалог, кнопка «піти»
  afterPaid,
}

/// Події Sasha (кастомні UI/відео в main_game).
abstract final class SashaEvents {
  SashaEvents._();

  // --- Media ---

  static const String comunicateSashaInHallVideoPath =
      'lib/assets/npcs/sasha/sash_video/piano.webm';

  /// Вступ у залі (ліва панель), фаза intro.
  static const String comunicateHallStep1Intro = '''
Большой зал дружной семьи, здесь обычно кто-то тусит. Особенно Саша любит смотреть большую плазму, которой нет в её спальне.
Саша занимается музыкой...
''';

  /// Діалог правої панелі у фазі відео (після «Підійти…» або автозапуску о 19:00).
  static const String comunicateHallStep2Talk = '''
Привет, Саша! Как дела? – подошел я к девушке.

Нормально! Не видишь я музыкой занимаюсь? – недовольно вздохнула она, будто увидела надоедливую муху.

Ты что, песни пишешь?

Да! В отличии от тебя у меня есть цель, к которой я стремлюсь! А ты тупо бродишь туда сюда свои 16 лет.

Мне 18 так-то!

Мне пох – так-то!
''';

  /// Фаза грошей / енергетика / «послати».
  static const String comunicateHallStep3Talk = '''
Хотя постой, мелкий! - остановила меня Саша.
Что еще?
У тебя пару баксов есть? Как будет верну! - вытянула вперед руку и пару раз сжала в кулак.
''';

  // --- NPC vars ---

  /// Скільки всього грошей гравець вже “дав” Саші в цьому івенті.
  ///
  /// Використовується для бонусу +10 відношення за кожні $100,
  /// але не далі ніж до $500.
  static const String moneyGivenTotalVar = 'sashaMoneyGivenTotal';

  // ======================================================================
  // EVENT: sasha_event_002 (sasha_morning_run)
  // ======================================================================

  /// Slug івенту (для людини/логів).
  static const String morningRunSlug = 'sasha_morning_run';

  /// Консистентний id з нумерацією NPC-івентів (див. .cursor/rules/event-numbering.mdc).
  static const String morningRunEventId = 'sasha_event_002';

  static const String morningRunLastDateKeyVar = 'sashaMorningRunLastDateKey';
  static const String morningRunStepVar = 'sashaMorningRunStep';
  static const String morningRunTimesCompletedVar = 'sashaMorningRunTimesCompleted';
  static const String morningRunDebtBucksVar = 'sashaDebtBucks';

  // --- Media ---
  static const String morningRunVideoRun1Path =
      'lib/assets/npcs/sasha/sash_video/run_1.webm';
  static const String morningRunVideoRun2Path =
      'lib/assets/npcs/sasha/sash_video/run_2.webm';

  static String dateKey(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  static int stepForPhase(SashaMorningRunPhase phase) => switch (phase) {
        SashaMorningRunPhase.intro => 1,
        SashaMorningRunPhase.video2 => 2,
        SashaMorningRunPhase.payOffer => 3,
        SashaMorningRunPhase.moneyAmountChoice => 31,
        SashaMorningRunPhase.afterPaid => 4,
      };

  static SashaMorningRunPhase phaseFromStep(int? step) {
    final s = step ?? 0;
    if (s == 31) return SashaMorningRunPhase.moneyAmountChoice;
    return switch (s) {
      1 => SashaMorningRunPhase.intro,
      2 => SashaMorningRunPhase.video2,
      3 => SashaMorningRunPhase.payOffer,
      4 => SashaMorningRunPhase.afterPaid,
      _ => SashaMorningRunPhase.intro,
    };
  }

  static bool isMorningRunAlreadyStartedToday(NPCModel sasha, String dateKey) {
    final raw = sasha.variables[morningRunLastDateKeyVar];
    return raw is String && raw == dateKey;
  }

  static int _readIntVar(NPCModel sasha, String key) {
    final raw = sasha.variables[key];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0;
  }

  /// Після «дати гроші» ($10 / $20): готівка Саші +10 відносин.
  static bool applyMorningRunGiveCash({
    required NPCModel sasha,
    required PlayerStatsController player,
    required int amount,
  }) {
    if (amount <= 0 || player.money < amount) return false;
    player.changeMoney(-amount);
    sasha.changeMoney(amount);
    sasha.addRelationship(10.0);
    return true;
  }

  /// $50 у борг: гроші з ГГ → Саші, +50 до боргу NPC перед ГГ (і event-var).
  static bool applyMorningRunGiveAsDebt({
    required GameWorldState world,
    required NPCModel sasha,
    required PlayerStatsController player,
    required DateTime gameNow,
  }) {
    const amount = 50;
    if (player.money < amount) return false;

    player.changeMoney(-amount);
    sasha.changeMoney(amount);

    final prevDebt = _readIntVar(sasha, morningRunDebtBucksVar);
    sasha.setVar(morningRunDebtBucksVar, prevDebt + amount);

    final r = NpcFinanceRecord.fromJson(world.npcFinanceByNpcId['sasha']);
    final todayIso = NpcFinanceRecord.dateIso(gameNow);
    if (r.npcOwesGgTotal <= 0 && r.npcDebtFirstIssueDateIso == null) {
      r.npcDebtFirstIssueDateIso = todayIso;
    }
    r.npcOwesGgTotal = (r.npcOwesGgTotal + amount).clamp(0, kNpcOwesGgMaxUsd);
    r.npcOwesGgPenaltyBase =
        (r.npcOwesGgPenaltyBase + amount).clamp(0, kNpcOwesGgMaxUsd);
    world.npcFinanceByNpcId['sasha'] = r.toJson();

    sasha.addRelationship(10.0);
    return true;
  }

  static void incrementMorningRunTimesCompleted(NPCModel sasha) {
    final prev = _readIntVar(sasha, morningRunTimesCompletedVar);
    sasha.setVar(morningRunTimesCompletedVar, prev + 1);
  }

  // --- Dialogues ---
  static const String morningRunStep1Talk = '''
Соседка Саша аппетитно двигала попкой, проходя мимо меня по улице в одежде для пробежки; я заворожённо и медленно шёл следом.
— Малой, челюсть подбери с асфальта, — обернулась она ко мне. — Я на пробежке, так что исчезни!
''';

  static const String morningRunStep2Talk = '''
— Чего хотел? — сощурилась от яркого солнца девушка. — Не видишь, что мешаешь?
— Просто хотел узнать, где бегаешь?
— На стадионе! Всё, отвянь, я пошла.
''';

  static const String morningRunStep3Talk = '''
— Эй, постой! — остановила меня Саша.
— Что тебе?
— У тебя десять баксов в долг есть? Как будет — верну обязательно! — она протянула вперёд руку и пару раз сжала её в кулак.
''';

  static const String morningRunAfterPaidTalk = '''
— Отработаешь на плантациях! — пошутил я.
— Ага, а ты ещё и шутник.
''';

  static int _clampSteps(int steps) => steps.clamp(0, 5);

  static int _stepsFromTotal(int totalDollars) =>
      _clampSteps((totalDollars ~/ 100));

  /// Застосувати ефекти варіанта 1: «Дать грошей і піти».
  ///
  /// Base: lust +0.3, relationship -0.5, behavior +0.2
  /// Додатково: +10 relationship за кожні $100, але сумарно не більше до $500.
  static void applyGiveMoney({
    required NPCModel sasha,
    required int dollarsGiven,
  }) {
    sasha.changeLust(0.3);
    sasha.addRelationship(-0.5);
    sasha.changeBehavior(0.2);

    final prevRaw = sasha.variables[moneyGivenTotalVar];
    final int prevTotal = prevRaw is int
        ? prevRaw
        : (prevRaw is num ? prevRaw.toInt() : 0);

    final int newTotal = prevTotal + dollarsGiven;
    sasha.setVar(moneyGivenTotalVar, newTotal);

    final prevSteps = _stepsFromTotal(prevTotal);
    final newSteps = _stepsFromTotal(newTotal);
    final int deltaSteps = (newSteps - prevSteps).clamp(0, 5);

    if (deltaSteps > 0) {
      sasha.addRelationship((deltaSteps * 10).toDouble());
    }
  }

  /// Є в рюкзаку енергетик «Ред Бул»: [InventoryController] `energy` (ТРЦ) або `energy_drink`.
  static bool hasRedBullStyleEnergy(InventoryController inventory) =>
      inventory.count('energy_drink') > 0 || inventory.count('energy') > 0;

  /// Знімає одну штуку: спочатку `energy_drink`, інакше `energy`.
  static void consumeOneRedBullStyleEnergy(InventoryController inventory) {
    if (inventory.count('energy_drink') > 0) {
      inventory.removeItem('energy_drink');
    } else if (inventory.count('energy') > 0) {
      inventory.removeItem('energy');
    }
  }

  /// Застосувати ефекти варіанта 2: дати Саші Ред Бул (енергетик) і піти.
  ///
  /// Base: lust -0.0 (тобто 0), relationship +1, behavior +0.2
  /// Також відновлює енергію ГГ (як use `energy` / `energy_drink` у рюкзаку: +20% maxEnergy).
  static void applyEnergyDrink({
    required NPCModel sasha,
    required PlayerStatsController playerStats,
  }) {
    // lust -0.0 -> 0
    sasha.addRelationship(1.0);
    sasha.changeBehavior(0.2);

    playerStats.changeEnergy(playerStats.player.maxEnergy * 0.2);
  }

  /// Застосувати ефекти варіанта 3: «Послать і піти».
  static void applySendAway({required NPCModel sasha}) {
    sasha.changeLust(-0.2);
    sasha.addRelationship(-1.5);
    sasha.changeBehavior(0.5);
  }
}

