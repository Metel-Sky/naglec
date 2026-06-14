import 'dart:math';

import '../data/npc_economy_config.dart';
import '../data/npc_finance_alt_settlement.dart';
import '../data/npc_finance_state.dart';
import '../data/npc_finance_time.dart';
import '../models/npc_model.dart';
import '../models/npc_secondary.dart';
import 'game_world_state.dart';
import 'npc_service.dart';
import 'player_stats_controller.dart';

/// Логіка меню «Фінанси» та боргів (без віджетів).
abstract final class NpcFinanceService {
  static NpcFinanceRecord _get(GameWorldState w, String npcId) =>
      NpcFinanceRecord.fromJson(w.npcFinanceByNpcId[npcId]);

  static void _put(GameWorldState w, String npcId, NpcFinanceRecord r) {
    w.npcFinanceByNpcId[npcId] = r.toJson();
  }

  static int npcOwesGg(GameWorldState w, String npcId) =>
      _get(w, npcId).npcOwesGgTotal;

  static int ggOwesNpc(GameWorldState w, String npcId) =>
      _get(w, npcId).ggOwesNpcTotal;

  static bool hasGgOwesNpcSlot50(GameWorldState w, String npcId) =>
      _get(w, npcId).ggOwesNpcSlot50 > 0;

  static bool hasGgOwesNpcSlot100(GameWorldState w, String npcId) =>
      _get(w, npcId).ggOwesNpcSlot100 > 0;

  static bool showAskAboutDebtButton(GameWorldState w, String npcId) {
    return npcOwesGg(w, npcId) > 0;
  }

  static bool showOfferAlternativesButton({
    required GameWorldState w,
    required String npcId,
    required NpcGender gender,
    required DateTime gameNow,
  }) {
    if (gender == NpcGender.male) return false;
    final r = _get(w, npcId);
    if (r.npcOwesGgTotal <= 0 || r.npcDebtFirstIssueDateIso == null) {
      return false;
    }
    final first = NpcFinanceRecord.parseIsoDate(r.npcDebtFirstIssueDateIso);
    if (first == null) return false;
    final days = npcFinanceCalendarDaysBetween(first, gameNow);
    return days >= 7;
  }

  static bool canUseMomAskMoney(GameWorldState w, DateTime gameNow) {
    final k = npcFinanceGameDayKey(gameNow);
    final r = _get(w, 'mom');
    return r.momAskMoneyGameDayKey != k;
  }

  static void syncGiveMoneyLimits(GameWorldState w, String npcId, DateTime gameNow) {
    final r = _get(w, npcId);
    r.syncGiveMoneyDay(npcFinanceGameDayKey(gameNow));
    _put(w, npcId, r);
  }

  static bool canGive50(GameWorldState w, String npcId, DateTime gameNow) {
    syncGiveMoneyLimits(w, npcId, gameNow);
    return _get(w, npcId).give50Count < 3;
  }

  static bool canGive100(GameWorldState w, String npcId, DateTime gameNow) {
    syncGiveMoneyLimits(w, npcId, gameNow);
    return _get(w, npcId).give100Count < 1;
  }

  static bool canGive250(GameWorldState w, String npcId, DateTime gameNow) {
    syncGiveMoneyLimits(w, npcId, gameNow);
    return _get(w, npcId).give250Count < 1;
  }

  static bool canBorrow50(GameWorldState w, String npcId) =>
      _get(w, npcId).ggOwesNpcSlot50 == 0;

  static bool canBorrow100(GameWorldState w, String npcId) =>
      _get(w, npcId).ggOwesNpcSlot100 == 0;

  /// Чому позика зараз недоступна; `null` — можна відкривати діалог суми.
  /// Працюючі NPC ([NpcEconomyConfig.isEmployed]) — лише при відносинах **понад** 500.
  static String? lendToNpcBlockedMessageKey(NPCModel npc) {
    if (isSecondaryNpc(npc)) return 'npc_finance_lend_need_npc_broke';
    if (npc.money > 0) return 'npc_finance_lend_need_npc_broke';
    if (NpcEconomyConfig.isEmployed(npc.id) && npc.relationship <= 500) {
      return 'npc_finance_lend_employed_need_relations';
    }
    return null;
  }

  static bool canLendToNpc(NPCModel npc) =>
      lendToNpcBlockedMessageKey(npc) == null;

  /// Чи не перевищить нова позика ліміт [kNpcOwesGgMaxUsd] боргу NPC перед ГГ.
  static bool canApplyLendAmount(GameWorldState w, String npcId, int amount) {
    final r = _get(w, npcId);
    return r.npcOwesGgTotal + amount <= kNpcOwesGgMaxUsd;
  }

  /// Мама: +50 або +100 ГГ, −15 відносини, раз на добу.
  static bool applyMomAskMoney({
    required GameWorldState w,
    required PlayerStatsController player,
    required NPCModel mom,
    required DateTime gameNow,
    required int amount,
  }) {
    if (mom.id != 'mom') return false;
    if (amount != 50 && amount != 100) return false;
    if (mom.money < amount) return false;
    final k = npcFinanceGameDayKey(gameNow);
    final r = _get(w, 'mom');
    if (r.momAskMoneyGameDayKey == k) return false;
    mom.changeMoney(-amount);
    player.changeMoney(amount);
    mom.addRelationship(-15);
    r.momAskMoneyGameDayKey = k;
    _put(w, 'mom', r);
    return true;
  }

  static bool applyGiveMoney(
    GameWorldState w, {
    required String npcId,
    required NPCModel npc,
    required PlayerStatsController player,
    required DateTime gameNow,
    required int amount,
  }) {
    syncGiveMoneyLimits(w, npcId, gameNow);
    final r = _get(w, npcId);
    if (amount == 50) {
      if (r.give50Count >= 3) return false;
      if (player.money < 50) return false;
      player.changeMoney(-50);
      npc.changeMoney(50);
      npc.addRelationship(5);
      r.give50Count++;
    } else if (amount == 100) {
      if (r.give100Count >= 1) return false;
      if (player.money < 100) return false;
      player.changeMoney(-100);
      npc.changeMoney(100);
      npc.addRelationship(10);
      npc.changeBehavior(1);
      r.give100Count++;
    } else if (amount == 250) {
      if (r.give250Count >= 1) return false;
      if (player.money < 250) return false;
      player.changeMoney(-250);
      npc.changeMoney(250);
      npc.changeLust(5);
      npc.addRelationship(25);
      npc.changeBehavior(4);
      npc.changeArousal(5);
      r.give250Count++;
    } else {
      return false;
    }
    _put(w, npcId, r);
    return true;
  }

  static bool applyBorrowFromNpc(
    GameWorldState w, {
    required String npcId,
    required NPCModel npc,
    required PlayerStatsController player,
    required DateTime gameNow,
    required int slot50or100,
  }) {
    final r = _get(w, npcId);
    final issue = NpcFinanceRecord.dateIso(gameNow);
    if (slot50or100 == 50) {
      if (r.ggOwesNpcSlot50 != 0) return false;
      if (npc.money < 50) return false;
      npc.changeMoney(-50);
      player.changeMoney(50);
      r.ggOwesNpcSlot50 = 50;
      r.ggOwesNpcSlot50IssueIso = issue;
      r.ggOwes50LateRelApplied = false;
      npc.addRelationship(-10);
    } else if (slot50or100 == 100) {
      if (r.ggOwesNpcSlot100 != 0) return false;
      if (npc.money < 100) return false;
      npc.changeMoney(-100);
      player.changeMoney(100);
      r.ggOwesNpcSlot100 = 100;
      r.ggOwesNpcSlot100IssueIso = issue;
      r.ggOwes100LateRelApplied = false;
      npc.addRelationship(-10);
    } else {
      return false;
    }
    _put(w, npcId, r);
    return true;
  }

  static bool applyRepayGgOwesNpc(
    GameWorldState w, {
    required String npcId,
    required NPCModel npc,
    required PlayerStatsController player,
    required DateTime gameNow,
    required int slot50or100,
  }) {
    final r = _get(w, npcId);
    final owed = slot50or100 == 50 ? r.ggOwesNpcSlot50 : r.ggOwesNpcSlot100;
    if (owed == 0) return false;
    if (player.money < owed) return false;

    final issueIso =
        slot50or100 == 50 ? r.ggOwesNpcSlot50IssueIso : r.ggOwesNpcSlot100IssueIso;
    final issue = NpcFinanceRecord.parseIsoDate(issueIso);
    final days = issue != null ? npcFinanceCalendarDaysBetween(issue, gameNow) : 999;

    player.changeMoney(-owed);
    npc.changeMoney(owed);

    if (days <= 5) {
      npc.addRelationship(5);
      npc.changeBehavior(1);
    }

    if (slot50or100 == 50) {
      r.ggOwesNpcSlot50 = 0;
      r.ggOwesNpcSlot50IssueIso = null;
    } else {
      r.ggOwesNpcSlot100 = 0;
      r.ggOwesNpcSlot100IssueIso = null;
    }
    _put(w, npcId, r);
    return true;
  }

  static bool applyLendToNpc(
    GameWorldState w, {
    required String npcId,
    required NPCModel npc,
    required PlayerStatsController player,
    required DateTime gameNow,
    required int amount,
  }) {
    if (!canLendToNpc(npc)) return false;
    if (amount != 50 && amount != 150 && amount != 250) return false;
    if (player.money < amount) return false;
    if (!canApplyLendAmount(w, npcId, amount)) return false;

    final r = _get(w, npcId);
    final todayIso = NpcFinanceRecord.dateIso(gameNow);
    player.changeMoney(-amount);
    npc.changeMoney(amount);

    if (r.npcOwesGgTotal <= 0) {
      r.npcDebtFirstIssueDateIso = todayIso;
    }
    r.npcOwesGgTotal += amount;
    r.npcOwesGgPenaltyBase += amount;

    if (amount == 50) {
      npc.addRelationship(10);
      npc.changeBehavior(2);
      npc.changeArousal(5);
    } else if (amount == 150) {
      npc.addRelationship(20);
      npc.changeBehavior(4);
      npc.changeArousal(15);
    } else {
      npc.addRelationship(25);
      npc.changeBehavior(5);
      npc.changeArousal(25);
    }

    _put(w, npcId, r);
    return true;
  }

  /// Повне погашення боргу NPC перед ГГ готівкою → на рахунок ГГ.
  static bool applyNpcRepaysDebtWithCash(
    GameWorldState w, {
    required String npcId,
    required NPCModel npc,
    required PlayerStatsController player,
  }) {
    final r = _get(w, npcId);
    final debt = r.npcOwesGgTotal;
    if (debt <= 0) return false;
    if (npc.money < debt) return false;
    npc.changeMoney(-debt);
    player.changeMoney(debt);
    _clearNpcOwesGg(r);
    _put(w, npcId, r);
    return true;
  }

  static void _clearNpcOwesGg(NpcFinanceRecord r) {
    r.npcOwesGgTotal = 0;
    r.npcOwesGgPenaltyBase = 0;
    r.npcDebtFirstIssueDateIso = null;
    r.lastPenaltyPeriodIndex = -1;
  }

  /// Чоловіки: автоматично, коли на руках достатньо готівки.
  static void tryMaleAutoRepay(
    GameWorldState w,
    NPCModel npc,
    PlayerStatsController player,
  ) {
    if (npc.gender != NpcGender.male) return;
    applyNpcRepaysDebtWithCash(w, npcId: npc.id, npc: npc, player: player);
  }

  /// Нарахування штрафів +10% кожні 3 доби після 6-ї доби від видачі.
  static void applyDebtPenaltiesForNpc(
    GameWorldState w,
    String npcId,
    DateTime gameNow,
  ) {
    final r = _get(w, npcId);
    if (r.npcOwesGgTotal <= 0 || r.npcDebtFirstIssueDateIso == null) return;
    final first = NpcFinanceRecord.parseIsoDate(r.npcDebtFirstIssueDateIso);
    if (first == null) return;
    final days = npcFinanceCalendarDaysBetween(first, gameNow);
    if (days < 6) return;
    final period = (days - 6) ~/ 3;
    if (period <= r.lastPenaltyPeriodIndex) return;
    if (r.npcOwesGgPenaltyBase <= 0) return;

    final add = (r.npcOwesGgPenaltyBase * 0.10).round();
    if (add > 0) {
      r.npcOwesGgTotal += add;
      if (r.npcOwesGgTotal > kNpcOwesGgMaxUsd) {
        r.npcOwesGgTotal = kNpcOwesGgMaxUsd;
      }
    }
    r.lastPenaltyPeriodIndex = period;
    _put(w, npcId, r);
  }

  static void tickGgOwesNpcLateRelationship(
    GameWorldState w,
    NPCModel npc,
    DateTime gameNow,
  ) {
    final id = npc.id;
    final r = _get(w, id);
    if (r.ggOwesNpcSlot50 > 0 &&
        r.ggOwesNpcSlot50IssueIso != null &&
        !r.ggOwes50LateRelApplied) {
      final issue = NpcFinanceRecord.parseIsoDate(r.ggOwesNpcSlot50IssueIso);
      if (issue != null && npcFinanceCalendarDaysBetween(issue, gameNow) >= 6) {
        npc.addRelationship(-50.0);
        r.ggOwes50LateRelApplied = true;
      }
    }
    if (r.ggOwesNpcSlot100 > 0 &&
        r.ggOwesNpcSlot100IssueIso != null &&
        !r.ggOwes100LateRelApplied) {
      final issue = NpcFinanceRecord.parseIsoDate(r.ggOwesNpcSlot100IssueIso);
      if (issue != null && npcFinanceCalendarDaysBetween(issue, gameNow) >= 6) {
        npc.addRelationship(-100.0);
        r.ggOwes100LateRelApplied = true;
      }
    }
    _put(w, id, r);
  }

  /// Один рандом на добу перед відкриттям підменю альтернатив.
  static bool rollAlternativeSettlementAllowed(
    GameWorldState w,
    String npcId,
    DateTime gameNow,
  ) {
    final dayKey = npcFinanceGameDayKey(gameNow);
    final r = _get(w, npcId);
    if (r.altSettlementAttemptGameDayKey == dayKey) {
      return r.altSettlementAcceptedToday;
    }
    final debt = r.npcOwesGgTotal;
    final p = debt > 500 ? 0.5 : 0.15;
    final ok = Random().nextDouble() < p;
    r.altSettlementAttemptGameDayKey = dayKey;
    r.altSettlementAcceptedToday = ok;
    _put(w, npcId, r);
    return ok;
  }

  /// Зниження боргу без надходження грошей на ГГ.
  static bool applyAlternativeSettlement(
    GameWorldState w, {
    required String npcId,
    required NPCModel npc,
    required PlayerStatsController player,
    required DateTime gameNow,
    required NpcFinanceAltSettlement kind,
  }) {
    if (!kind.isImplemented) return false;
    final r = _get(w, npcId);
    final debt = r.npcOwesGgTotal;
    if (debt <= 0) return false;
    if (debt < kind.debtMin || debt > kind.debtMax) return false;
    if (npc.money < kind.debtMin) return false;

    final debtReduction = debt < kind.debtMax ? debt : kind.debtMax;
    final cashTake = npc.money < debtReduction ? npc.money : debtReduction;
    npc.changeMoney(-cashTake);

    final newDebt = debt - debtReduction;
    if (newDebt <= 0) {
      _clearNpcOwesGg(r);
    } else {
      r.npcOwesGgTotal = newDebt;
      r.npcOwesGgPenaltyBase =
          (r.npcOwesGgPenaltyBase - debtReduction).clamp(0, 999999);
    }

    _applyAltStats(npc, player, kind);
    _put(w, npcId, r);
    return true;
  }

  static void _applyAltStats(
    NPCModel npc,
    PlayerStatsController player,
    NpcFinanceAltSettlement k,
  ) {
    void zeroGgArousal() {
      player.changeArousal(-player.arousal);
    }

    switch (k) {
      case NpcFinanceAltSettlement.showBreasts:
        npc.addRelationship(5);
        npc.changeBehavior(1);
        npc.changeLust(1);
        npc.changeArousal(5);
        break;
      case NpcFinanceAltSettlement.showButt:
        npc.addRelationship(7);
        npc.changeBehavior(2);
        npc.changeLust(1);
        npc.changeArousal(5);
        break;
      case NpcFinanceAltSettlement.touchBreasts:
        npc.addRelationship(7);
        npc.changeBehavior(2);
        npc.changeLust(1);
        npc.changeArousal(10);
        player.changeArousal(10);
        break;
      case NpcFinanceAltSettlement.touchButt:
        npc.addRelationship(10);
        npc.changeBehavior(2);
        npc.changeLust(2);
        npc.changeArousal(15);
        player.changeArousal(10);
        break;
      case NpcFinanceAltSettlement.handjob:
        npc.addRelationship(15);
        npc.changeBehavior(3);
        npc.changeLust(5);
        zeroGgArousal();
        npc.changeArousal(20);
        break;
      case NpcFinanceAltSettlement.blowjob:
        npc.changeBehavior(4);
        npc.changeLust(5);
        zeroGgArousal();
        npc.changeArousal(30);
        break;
      case NpcFinanceAltSettlement.bendOver:
        if (npc.relationship < 450) {
          npc.addRelationship(-25);
        } else {
          npc.addRelationship(25);
        }
        npc.changeBehavior(4);
        npc.changeLust(5);
        zeroGgArousal();
        npc.changeArousal(30);
        break;
      case NpcFinanceAltSettlement.anal:
      case NpcFinanceAltSettlement.threesome:
        break;
    }
  }

  /// Викликати при зміні ігрового дня (після 06:00).
  static void onGameDayAdvanced(
    GameWorldState w,
    NPCService npcService,
    PlayerStatsController player,
    DateTime gameNow,
  ) {
    for (final npc in npcService.allNPCs) {
      if (isSecondaryNpc(npc)) continue;
      final id = npc.id;
      applyDebtPenaltiesForNpc(w, id, gameNow);
      tickGgOwesNpcLateRelationship(w, npc, gameNow);
      tryMaleAutoRepay(w, npc, player);
    }
  }
}
