import 'dart:math';

import '../data/npc_economy_config.dart';
import '../models/npc_model.dart';
import '../models/npc_secondary.dart';
import 'game_world_state.dart';
import 'npc_service.dart';
import 'npc_trc_impulse_buy.dart';

/// Щоденна економіка NPC: зарплати / витрати / пасивний дохід / імпульсні покупки в ТРЦ.
///
/// Раз на місяць (1-го числа) — лотерея: один випадковий NPC +$1000, інший (інший id) −$500.
///
/// Викликати при зміні ігрового календарного дня ([syncWithGameClock]).
class NpcEconomyService {
  NpcEconomyService._();

  static const int _monthlyLotteryWinAmount = 1000;
  static const int _monthlyLotteryLossAmount = 500;

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Ключ календарного місяця для лотереї (`yyyy-MM`).
  static String _monthKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  /// Індекс «тижня року» для стабільного рандому зарплати за тиждень (0…).
  static int _weekIndexWithinYear(DateTime d) {
    final jan1 = DateTime(d.year, 1, 1);
    final days = d.difference(jan1).inDays;
    return days ~/ 7;
  }

  /// Ключ тижня для імпульсної покупки в ТРЦ (`yyyy_weekIndex` від 1 січня).
  static String _trcImpulseWeekKey(DateTime d) => '${d.year}_${_weekIndexWithinYear(d)}';

  static void _clampMoney(NPCModel npc) {
    npc.money = NpcEconomyConfig.clampNpcMoney(npc.id, npc.money);
  }

  /// Працюючі: понеділок — зарплата; п’ятниця — витрати (комуналка тощо).
  /// Діапазони трохи зсунуті в плюс проти старого балансу, щоб за кілька тижнів не
  /// провалюватись у мінус усім NPC одночасно.
  static void _applyEmployedDay(NPCModel npc, DateTime dayDate) {
    final week = _weekIndexWithinYear(dayDate);
    final rngSalary =
        Random(Object.hash(npc.id, dayDate.year, week, 'weekly_salary'));
    final rngBill =
        Random(Object.hash(npc.id, dayDate.year, week, 'friday_bills'));

    if (dayDate.weekday == DateTime.monday) {
      // було 150–750; піднята підлога + середнє ~+$15/тиждень
      final salary = 180 + rngSalary.nextInt(571);
      npc.money += salary;
    }
    if (dayDate.weekday == DateTime.friday) {
      // було 100–750; м’якший верх і нижня межа ~−$15–20 до середнього чека
      final bill = 95 + rngBill.nextInt(626);
      npc.money -= bill;
    }
    _clampMoney(npc);
  }

  /// Непрацюючі: щодня пасивний дохід **+10…+25**; пн/ср/пт додатково витрати **−3…−15**.
  /// Раз на календарний тиждень (від 1 січня) — **лише одна** імпульсна покупка в ТРЦ за **$200–$800**
  /// (за фактичною ціною товару), якщо на рахунку ≥ $200; день тижня не фіксований.
  static void _applyPassiveDay(
    NPCModel npc,
    DateTime dayDate,
    GameWorldState world,
  ) {
    final key = _dateKey(dayDate);

    final rngDaily =
        Random(Object.hash(npc.id, key, 'passive_daily'));
    final rngExpense =
        Random(Object.hash(npc.id, key, 'passive_expense'));

    npc.money += 10 + rngDaily.nextInt(16);

    if (dayDate.weekday == DateTime.monday ||
        dayDate.weekday == DateTime.wednesday ||
        dayDate.weekday == DateTime.friday) {
      npc.money -= 3 + rngExpense.nextInt(13);
    }

    _clampMoney(npc);

    final weekKey = _trcImpulseWeekKey(dayDate);
    if (world.npcTrcImpulseYearWeekByNpcId[npc.id] == weekKey) {
      return;
    }
    if (npc.money < NpcTrcImpulseBuy.minPrice) {
      return;
    }

    final noonThatDay = DateTime(dayDate.year, dayDate.month, dayDate.day, 12);
    final maxAff = npc.money.clamp(
      NpcTrcImpulseBuy.minPrice,
      NpcTrcImpulseBuy.maxPrice,
    );
    final product = NpcTrcImpulseBuy.pickAndApply(
      npc: npc,
      gameNow: noonThatDay,
      sequence: 0,
      maxAffordable: maxAff,
    );
    if (product != null) {
      world.npcTrcImpulseYearWeekByNpcId[npc.id] = weekKey;
    }
    _clampMoney(npc);
  }

  static void _applyDayForNpc(
    NPCModel npc,
    DateTime dayDate,
    GameWorldState world,
  ) {
    if (isSecondaryNpc(npc)) return;

    if (NpcEconomyConfig.isEmployed(npc.id)) {
      _applyEmployedDay(npc, dayDate);
    } else {
      _applyPassiveDay(npc, dayDate, world);
    }
  }

  /// Другорядні NPC не беруть участі (у них немає економіки грошей).
  static void _applyMonthlyLotteryIfNeeded(
    NPCService npcService,
    GameWorldState world,
    DateTime dayDate,
  ) {
    if (dayDate.day != 1) return;
    final mk = _monthKey(dayDate);
    if (world.lastNpcLotteryMonthKey == mk) return;

    final pool = npcService.allNPCs.where((n) => !isSecondaryNpc(n)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (pool.isEmpty) {
      world.lastNpcLotteryMonthKey = mk;
      return;
    }

    final rng = Random(Object.hash(dayDate.year, dayDate.month, 'npc_monthly_lottery'));
    final winIndex = rng.nextInt(pool.length);
    pool[winIndex].changeMoney(_monthlyLotteryWinAmount);

    if (pool.length >= 2) {
      var loseIndex = rng.nextInt(pool.length - 1);
      if (loseIndex >= winIndex) loseIndex++;
      pool[loseIndex].changeMoney(-_monthlyLotteryLossAmount);
    }

    world.lastNpcLotteryMonthKey = mk;
  }

  /// Обробляє всі календарні дні від останнього збереженого до [gameNow] включно.
  static void syncWithGameClock(
    NPCService npcService,
    GameWorldState world,
    DateTime gameNow,
  ) {
    for (final npc in npcService.allNPCs) {
      if (isSecondaryNpc(npc)) {
        npc.money = 0;
      }
    }

    final today = DateTime(gameNow.year, gameNow.month, gameNow.day);
    final todayKey = _dateKey(today);

    final lastKey = world.lastNpcEconomyProcessedDateKey;
    if (lastKey == null) {
      _applyMonthlyLotteryIfNeeded(npcService, world, today);
      for (final npc in npcService.allNPCs) {
        _applyDayForNpc(npc, today, world);
      }
      npcService.ensureNpcItemsFresh();
      world.lastNpcEconomyProcessedDateKey = todayKey;
      return;
    }

    if (lastKey == todayKey) {
      _applyMonthlyLotteryIfNeeded(npcService, world, today);
      npcService.ensureNpcItemsFresh();
      return;
    }

    final lastDate = DateTime.tryParse(lastKey);
    if (lastDate == null) {
      world.lastNpcEconomyProcessedDateKey = null;
      syncWithGameClock(npcService, world, gameNow);
      return;
    }

    final lastNorm = DateTime(lastDate.year, lastDate.month, lastDate.day);
    if (today.isBefore(lastNorm)) {
      world.lastNpcEconomyProcessedDateKey = todayKey;
      npcService.ensureNpcItemsFresh();
      return;
    }

    var d = lastNorm.add(const Duration(days: 1));
    while (!d.isAfter(today)) {
      _applyMonthlyLotteryIfNeeded(npcService, world, d);
      for (final npc in npcService.allNPCs) {
        _applyDayForNpc(npc, d, world);
      }
      d = d.add(const Duration(days: 1));
    }

    npcService.ensureNpcItemsFresh();
    world.lastNpcEconomyProcessedDateKey = todayKey;
  }
}
