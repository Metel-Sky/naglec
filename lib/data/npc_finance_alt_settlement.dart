/// Варіанти розрахунку боргу NPC перед ГГ (підменю «інші варіанти»).
///
/// Для кожного NPC плануються відео: `lib/assets/npcs/<npcId>/finance_alt_XX.webm`
/// де XX = 01…09 (мінімум 10 відео на персонажа в майбутньому контенті).
enum NpcFinanceAltSettlement {
  showBreasts(50, 100),
  showButt(101, 200),
  touchBreasts(201, 300),
  touchButt(301, 400),
  handjob(401, 500),
  blowjob(501, 600),
  bendOver(601, 750),
  anal(751, 900),
  threesome(901, 1100);

  const NpcFinanceAltSettlement(this.debtMin, this.debtMax);
  final int debtMin;
  final int debtMax;

  /// Плейсхолдер під майбутні асети (01-based індекс як у імені файлу).
  String videoAssetPath(String npcId) {
    final idx = index + 1;
    final xx = idx.toString().padLeft(2, '0');
    return 'lib/assets/npcs/$npcId/finance_alt_$xx.webm';
  }

  /// Кнопки 8–9 поки неактивні в геймплеї.
  bool get isImplemented =>
      this != NpcFinanceAltSettlement.anal &&
      this != NpcFinanceAltSettlement.threesome;
}
