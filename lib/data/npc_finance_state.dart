/// Максимальний борг NPC перед ГГ (доларів) — далі позика не наростає.
const int kNpcOwesGgMaxUsd = 3000;

/// Збережений стан фінансових операцій з одним NPC (не другорядний).
class NpcFinanceRecord {
  /// Остання ігрова доба, коли мама дала гроші (раз на добу).
  String? momAskMoneyGameDayKey;

  /// Ліміти «дати гроші» — одна доба.
  String? giveMoneyGameDayKey;
  int give50Count;
  int give100Count;
  int give250Count;

  /// ГГ позичив у NPC: залишок 0 або 50.
  int ggOwesNpcSlot50;
  /// ISO дата видачі (календарний день старту відліку).
  String? ggOwesNpcSlot50IssueIso;
  /// Чи вже застосовано штраф до відносин за прострочення (50$).
  bool ggOwes50LateRelApplied;

  /// ГГ позичив у NPC: залишок 0 або 100.
  int ggOwesNpcSlot100;
  String? ggOwesNpcSlot100IssueIso;
  bool ggOwes100LateRelApplied;

  /// NPC винен ГГ (позики ГГ → NPC), сума з штрафами.
  int npcOwesGgTotal;
  /// База для +10%: об’єднана «початкова» сума боргу без нарахованих штрафів.
  int npcOwesGgPenaltyBase;
  /// Перший день видачі позики в поточному ланцюгу (ISO yyyy-MM-dd).
  String? npcDebtFirstIssueDateIso;
  /// Останній період штрафу (щоб нараховувати кожні 3 доби після 6-ї).
  int lastPenaltyPeriodIndex;

  /// Спроба «інші варіанти» — раз на ігрову добу.
  String? altSettlementAttemptGameDayKey;
  /// Успішна згода NPC на альтернативи в цю добу (після рандому).
  bool altSettlementAcceptedToday;

  NpcFinanceRecord({
    this.momAskMoneyGameDayKey,
    this.giveMoneyGameDayKey,
    this.give50Count = 0,
    this.give100Count = 0,
    this.give250Count = 0,
    this.ggOwesNpcSlot50 = 0,
    this.ggOwesNpcSlot50IssueIso,
    this.ggOwes50LateRelApplied = false,
    this.ggOwesNpcSlot100 = 0,
    this.ggOwesNpcSlot100IssueIso,
    this.ggOwes100LateRelApplied = false,
    this.npcOwesGgTotal = 0,
    this.npcOwesGgPenaltyBase = 0,
    this.npcDebtFirstIssueDateIso,
    this.lastPenaltyPeriodIndex = -1,
    this.altSettlementAttemptGameDayKey,
    this.altSettlementAcceptedToday = false,
  });

  factory NpcFinanceRecord.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return NpcFinanceRecord();
    final totalRaw = (json['npcOwesGgTotal'] as num?)?.toInt() ?? 0;
    final baseRaw = (json['npcOwesGgPenaltyBase'] as num?)?.toInt() ?? 0;
    return NpcFinanceRecord(
      momAskMoneyGameDayKey: json['momAskMoneyGameDayKey'] as String?,
      giveMoneyGameDayKey: json['giveMoneyGameDayKey'] as String?,
      give50Count: (json['give50Count'] as num?)?.toInt() ?? 0,
      give100Count: (json['give100Count'] as num?)?.toInt() ?? 0,
      give250Count: (json['give250Count'] as num?)?.toInt() ?? 0,
      ggOwesNpcSlot50: (json['ggOwesNpcSlot50'] as num?)?.toInt() ?? 0,
      ggOwesNpcSlot50IssueIso: json['ggOwesNpcSlot50IssueIso'] as String?,
      ggOwes50LateRelApplied: json['ggOwes50LateRelApplied'] == true,
      ggOwesNpcSlot100: (json['ggOwesNpcSlot100'] as num?)?.toInt() ?? 0,
      ggOwesNpcSlot100IssueIso: json['ggOwesNpcSlot100IssueIso'] as String?,
      ggOwes100LateRelApplied: json['ggOwes100LateRelApplied'] == true,
      npcOwesGgTotal: totalRaw.clamp(0, kNpcOwesGgMaxUsd),
      npcOwesGgPenaltyBase: baseRaw.clamp(0, kNpcOwesGgMaxUsd),
      npcDebtFirstIssueDateIso: json['npcDebtFirstIssueDateIso'] as String?,
      lastPenaltyPeriodIndex: (json['lastPenaltyPeriodIndex'] as num?)?.toInt() ?? -1,
      altSettlementAttemptGameDayKey:
          json['altSettlementAttemptGameDayKey'] as String?,
      altSettlementAcceptedToday: json['altSettlementAcceptedToday'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'momAskMoneyGameDayKey': momAskMoneyGameDayKey,
        'giveMoneyGameDayKey': giveMoneyGameDayKey,
        'give50Count': give50Count,
        'give100Count': give100Count,
        'give250Count': give250Count,
        'ggOwesNpcSlot50': ggOwesNpcSlot50,
        'ggOwesNpcSlot50IssueIso': ggOwesNpcSlot50IssueIso,
        'ggOwes50LateRelApplied': ggOwes50LateRelApplied,
        'ggOwesNpcSlot100': ggOwesNpcSlot100,
        'ggOwesNpcSlot100IssueIso': ggOwesNpcSlot100IssueIso,
        'ggOwes100LateRelApplied': ggOwes100LateRelApplied,
        'npcOwesGgTotal': npcOwesGgTotal,
        'npcOwesGgPenaltyBase': npcOwesGgPenaltyBase,
        'npcDebtFirstIssueDateIso': npcDebtFirstIssueDateIso,
        'lastPenaltyPeriodIndex': lastPenaltyPeriodIndex,
        'altSettlementAttemptGameDayKey': altSettlementAttemptGameDayKey,
        'altSettlementAcceptedToday': altSettlementAcceptedToday,
      };

  /// Скільки ГГ винен цьому NPC (сума двох слотів).
  int get ggOwesNpcTotal => ggOwesNpcSlot50 + ggOwesNpcSlot100;

  void syncGiveMoneyDay(String gameDayKey) {
    if (giveMoneyGameDayKey != gameDayKey) {
      giveMoneyGameDayKey = gameDayKey;
      give50Count = 0;
      give100Count = 0;
      give250Count = 0;
    }
  }

  static String dateIso(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static DateTime? parseIsoDate(String? iso) {
    if (iso == null || iso.length < 10) return null;
    return DateTime.tryParse(iso.substring(0, 10));
  }
}
