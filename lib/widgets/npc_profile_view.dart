import 'package:flutter/material.dart';
import '../cheats/npc_quest_cheats.dart';
import '../data/npc_profile_display.dart';
import '../data/npc_profile_quests_registry.dart';
import '../data/npc_sex_stats.dart';
import '../npcs/cherie/cherie_quests.dart';
import '../models/npc_model.dart';
import '../models/npc_secondary.dart';
import '../services/game_time_controller.dart';
import '../services/game_world_state.dart';
import '../services/locale_controller.dart';
import '../services/npc_finance_service.dart';
import '../services/npc_service.dart';
import '../services/player_stats_controller.dart';
import '../services/save_service.dart';
import '../services/settings_controller.dart';
import '../services/service_locator.dart';
import '../theme/game_theme.dart';
import '../utils/npc_portrait_paths.dart';
import 'npc_profile_owes_alex_row.dart';
import 'npc_stat_edit_rows.dart';

/// Профіль NPC у стилі аркуша персонажа: властивості, біографія, чекпоінти, компромат.
class NpcProfileView extends StatelessWidget {
  final NPCModel npc;
  /// Якщо разом із [npcService] задано — велике фото враховує поточний розклад (офіціантка в кафе тощо).
  final GameTimeController? timeController;
  final NPCService? npcService;
  /// Для розділу «Квести»: статуси з [GameWorldState] та [npc].
  final GameWorldState? gameWorld;

  const NpcProfileView({
    super.key,
    required this.npc,
    this.timeController,
    this.npcService,
    this.gameWorld,
  });

  @override
  Widget build(BuildContext context) {
    npcService?.ensureNpcItemsFresh();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхній ряд: фото пропорційно 175*250 зліва, заголовок і властивості справа
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Фото NPC у верхньому лівому куті (пропорція 70:100, висота 250)
                SizedBox(
                  width: 175,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _ProfilePortraitPhoto(
                      npc: npc,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NpcProfileDisplay.cardTitleLine(npc, world: gameWorld),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _NpcProfileStatsPanel(npc: npc, gameWorld: gameWorld),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (gameWorld != null) ...[
              _collapsibleSection(
                context,
                title: sl<LocaleController>().t('profile_quests_section'),
                children: [
                  _NpcProfileQuestsList(
                    npc: npc,
                    world: gameWorld!,
                    npcService: npcService,
                  ),
                ],
              ),
            ],

            if (npc.biographyType != null && npc.biographyType!.isNotEmpty) ...[
              _sectionLabel('Біографія та Характер', highlight: true),
              const SizedBox(height: 8),
              Text(
                npc.biographyType!,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
            ],

            if (NpcProfileDisplay.appearanceParagraph(npc) != null) ...[
              _sectionLabel('Зовнішність', highlight: true),
              const SizedBox(height: 8),
              Text(
                NpcProfileDisplay.appearanceParagraph(npc)!,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
            ],

            _collapsibleSection(
              context,
              title: 'Особисті речі',
              children: npc.items.isNotEmpty
                  ? <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in npc.items) _npcItemIcon(item.imagePath),
                          ],
                        ),
                      ),
                    ]
                  : const <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          '—',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ],
            ),

            // Чекпоінти
            if (npc.checkpoints != null && npc.checkpoints!.isNotEmpty)
              _collapsibleSection(
                context,
                title: 'Чекпоінти',
                children: npc.checkpoints!
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: SizedBox(
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                s,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.35),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

            // Компромат (Proofs)
            _collapsibleSection(
              context,
              title: 'Компромат (Proofs)',
              children: npc.proofs != null && npc.proofs!.isNotEmpty
                  ? npc.proofs!
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ))
                      .toList()
                  : [const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('—', style: TextStyle(color: Colors.white54, fontSize: 14)))],
            ),

            _collapsibleSection(
              context,
              title: sl<LocaleController>().t('profile_npc_sex_section'),
              children: [
                _NpcProfileSexStatsList(npc: npc),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: highlight ? Colors.amber.shade900.withValues(alpha: 0.35) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: highlight ? Colors.amber.shade200 : Colors.white,
        ),
      ),
    );
  }

  Widget _collapsibleSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        childrenPadding: const EdgeInsets.only(left: 0, bottom: 0, top: 0),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            textAlign: TextAlign.left,
          ),
        ),
        children: children,
      ),
    );
  }

  Widget _npcItemIcon(String? path) {
    const size = 60.0;
    if (path == null || path.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.inventory_2_outlined, color: Colors.white54, size: 18),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.white12,
          child: const Icon(Icons.broken_image, color: Colors.white54, size: 18),
        ),
      ),
    );
  }
}

/// Стати в шапці картки NPC: read-only або ± при увімкнених читах.
class _NpcProfileOwesAlexBlock extends StatelessWidget {
  const _NpcProfileOwesAlexBlock({
    required this.gameWorld,
    required this.npc,
  });

  final GameWorldState? gameWorld;
  final NPCModel npc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: NpcProfileOwesAlexRow(
        gameWorld: gameWorld,
        npc: npc,
      ),
    );
  }
}

/// Стати в шапці картки NPC: read-only або ± при увімкнених читах.
class _NpcProfileStatsPanel extends StatefulWidget {
  const _NpcProfileStatsPanel({
    required this.npc,
    required this.gameWorld,
  });

  final NPCModel npc;
  final GameWorldState? gameWorld;

  @override
  State<_NpcProfileStatsPanel> createState() => _NpcProfileStatsPanelState();
}

class _NpcProfileStatsPanelState extends State<_NpcProfileStatsPanel> {
  static const double _statsBlockWidthReduction = 200;

  void _applyStatChange(VoidCallback action) {
    action();
    sl<SaveService>().autosave();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final npc = widget.npc;
    final gameWorld = widget.gameWorld;
    final t = sl<LocaleController>().t;

    return ListenableBuilder(
      listenable: sl<SettingsController>(),
      builder: (context, _) {
        final cheatsOn = sl<SettingsController>().cheatsEnabled;

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final blockWidth = maxW.isFinite
                ? (maxW - _statsBlockWidthReduction).clamp(0.0, maxW)
                : null;

            final statsBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            if (isSecondaryNpc(npc)) ...[
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Категорія: другорядний персонаж. Стати не ведуться.',
                  style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.35),
                ),
              ),
            ] else if (isRelationshipInfluenceOnlyNpc(npc)) ...[
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Категорія: чоловічий персонаж. У статах лише відносини та вплив ГГ.',
                  style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.35),
                ),
              ),
              if (cheatsOn) ...[
                NpcStatEditRow(
                  label: 'Відносини',
                  value: '${npc.relationship.round()} / 1000',
                  tier: NpcStatTierLabels.relationship(npc.relationship.round()),
                  onMinus: () => _applyStatChange(() {
                    npc.changeTrust(-2);
                    npc.changeLove(-2);
                  }),
                  onPlus: () => _applyStatChange(() {
                    npc.changeTrust(2);
                    npc.changeLove(2);
                  }),
                ),
                NpcStatEditRow(
                  label: 'Гроші',
                  value: '\$${npc.money}',
                  onMinus: () => _applyStatChange(() => npc.changeMoney(-100)),
                  onPlus: () => _applyStatChange(() => npc.changeMoney(100)),
                ),
                NpcStatEditRow(
                  label: 'Вплив ГГ',
                  value: '${npc.influenceFromGg} / 100',
                  onMinus: () => _applyStatChange(() => npc.changeInfluence(-1)),
                  onPlus: () => _applyStatChange(() => npc.changeInfluence(1)),
                ),
              ] else ...[
                NpcStatReadOnlyRow(
                  label: 'Відносини',
                  value: '${npc.relationship.toInt()} / 1000',
                ),
                NpcStatReadOnlyRow(label: 'Гроші', value: '\$${npc.money}'),
                NpcStatReadOnlyRow(
                  label: 'Вплив ГГ',
                  value: '${npc.influenceFromGg} / 100',
                ),
              ],
              _NpcProfileOwesAlexBlock(gameWorld: gameWorld, npc: npc),
              NpcStatReadOnlyRow(
                label: t('npc_card_debt_gg_owes_npc'),
                value: gameWorld != null
                    ? '\$${NpcFinanceService.ggOwesNpc(gameWorld, npc.id)}'
                    : '\$0',
              ),
            ] else if (cheatsOn) ...[
              NpcStatEditRow(
                label: 'Хтивість',
                value: '${npc.lust.round()} / 1000',
                tier: NpcStatTierLabels.lust(npc.lust.round()),
                onMinus: () => _applyStatChange(() => npc.changeLust(-25)),
                onPlus: () => _applyStatChange(() => npc.changeLust(25)),
              ),
              NpcStatEditRow(
                label: 'Відносини',
                value: '${npc.relationship.round()} / 1000',
                tier: NpcStatTierLabels.relationship(npc.relationship.round()),
                onMinus: () => _applyStatChange(() {
                  npc.changeTrust(-2);
                  npc.changeLove(-2);
                }),
                onPlus: () => _applyStatChange(() {
                  npc.changeTrust(2);
                  npc.changeLove(2);
                }),
              ),
              NpcStatEditRow(
                label: 'Поведінка',
                value: '${npc.behavior.round()} / 1000',
                tier: NpcStatTierLabels.behavior(npc.behavior.round()),
                onMinus: () => _applyStatChange(() => npc.changeBehavior(-25)),
                onPlus: () => _applyStatChange(() => npc.changeBehavior(25)),
              ),
              NpcStatEditRow(
                label: 'Збудження',
                value: '${npc.arousal} / 100',
                onMinus: () => _applyStatChange(() => npc.changeArousal(-10)),
                onPlus: () => _applyStatChange(() => npc.changeArousal(10)),
              ),
              NpcStatEditRow(
                label: 'Гроші',
                value: '\$${npc.money}',
                onMinus: () => _applyStatChange(() => npc.changeMoney(-100)),
                onPlus: () => _applyStatChange(() => npc.changeMoney(100)),
              ),
              NpcStatEditRow(
                label: 'Вплив ГГ',
                value: '${npc.influenceFromGg} / 100',
                onMinus: () => _applyStatChange(() => npc.changeInfluence(-1)),
                onPlus: () => _applyStatChange(() => npc.changeInfluence(1)),
              ),
              _NpcProfileOwesAlexBlock(gameWorld: gameWorld, npc: npc),
              NpcStatReadOnlyRow(
                label: t('npc_card_debt_gg_owes_npc'),
                value: gameWorld != null
                    ? '\$${NpcFinanceService.ggOwesNpc(gameWorld, npc.id)}'
                    : '\$0',
              ),
            ] else ...[
              NpcStatReadOnlyRow(
                label: 'Хтивість',
                value: '${npc.lust.toInt()} / 1000',
              ),
              NpcStatReadOnlyRow(
                label: 'Відносини',
                value: '${npc.relationship.toInt()} / 1000',
              ),
              NpcStatReadOnlyRow(
                label: 'Поведінка',
                value: '${npc.behavior.toInt()} / 1000',
              ),
              NpcStatReadOnlyRow(
                label: 'Збудження',
                value: '${npc.arousal} / 100',
              ),
              NpcStatReadOnlyRow(label: 'Гроші', value: '\$${npc.money}'),
              NpcStatReadOnlyRow(
                label: 'Вплив ГГ',
                value: '${npc.influenceFromGg} / 100',
              ),
              _NpcProfileOwesAlexBlock(gameWorld: gameWorld, npc: npc),
              NpcStatReadOnlyRow(
                label: t('npc_card_debt_gg_owes_npc'),
                value: gameWorld != null
                    ? '\$${NpcFinanceService.ggOwesNpc(gameWorld, npc.id)}'
                    : '\$0',
              ),
            ],
              ],
            );

            if (blockWidth != null) {
              return SizedBox(width: blockWidth, child: statsBlock);
            }
            return statsBlock;
          },
        );
      },
    );
  }
}

class _NpcProfileQuestsList extends StatefulWidget {
  const _NpcProfileQuestsList({
    required this.npc,
    required this.world,
    this.npcService,
  });

  final NPCModel npc;
  final GameWorldState world;
  final NPCService? npcService;

  @override
  State<_NpcProfileQuestsList> createState() => _NpcProfileQuestsListState();
}

class _NpcProfileQuestsListState extends State<_NpcProfileQuestsList> {
  static const String _kCherieAnimatorCounterKey =
      'profile_cherie_animator_shifts_count';
  static const String _kCherieMasseurCounterKey =
      'profile_cherie_masseur_counter';
  static const String _kCherieQuest005ActorKey =
      'profile_cherie_quest005_actor';
  static const String _kCherieQuest005LizunKey =
      'profile_cherie_quest005_lizun';
  static const String _kMomOwesGgCounterKey = 'profile_mom_owes_gg_label';

  void _nudgeGiftShopAnimatorShifts(int delta) {
    final v = widget.world.giftShopAnimatorShiftsCompleted + delta;
    widget.world.giftShopAnimatorShiftsCompleted = v < 0 ? 0 : v;
    sl<SaveService>().autosave();
    setState(() {});
  }

  Widget _cherieAnimatorShiftsStepper(
    String Function(String) t, {
    required bool questOneDone,
  }) {
    final n = widget.world.giftShopAnimatorShiftsCompleted;
    final active = questOneDone;
    final lineStyle = TextStyle(
      color: active ? Colors.white54 : Colors.white30,
      fontSize: 12,
      height: 1.35,
    );
    final digitColor = active ? Colors.white : Colors.white38;
    final iconAccent = Colors.white70;
    final iconDisabled = Colors.white24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '${t('profile_cherie_animator_shifts_label')} — ',
            style: lineStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: active && n > 0
              ? () => _nudgeGiftShopAnimatorShifts(-1)
              : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: active && n > 0 ? iconAccent : iconDisabled,
            size: 22,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '$n',
            style: TextStyle(
              color: digitColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: active ? () => _nudgeGiftShopAnimatorShifts(1) : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: active ? iconAccent : iconDisabled,
            size: 22,
          ),
        ),
      ],
    );
  }

  void _nudgeMomOwesGgCount(int delta) {
    final next = (widget.world.momOwesGgCount + delta).clamp(0, 9999);
    widget.world.momOwesGgCount = next;
    sl<SaveService>().autosave();
    setState(() {});
  }

  Widget _momOwesGgStepper(
    String Function(String) t, {
    required bool active,
  }) {
    final n = widget.world.momOwesGgCount;
    final lineStyle = TextStyle(
      color: active ? Colors.white54 : Colors.white30,
      fontSize: 12,
      height: 1.35,
    );
    final digitColor = active ? Colors.white : Colors.white38;
    final iconAccent = Colors.white70;
    final iconDisabled = Colors.white24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '${t(_kMomOwesGgCounterKey)} — ',
            style: lineStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: active && n > 0 ? () => _nudgeMomOwesGgCount(-1) : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: active && n > 0 ? iconAccent : iconDisabled,
            size: 22,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '$n',
            style: TextStyle(
              color: digitColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: active ? () => _nudgeMomOwesGgCount(1) : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: active ? iconAccent : iconDisabled,
            size: 22,
          ),
        ),
      ],
    );
  }

  void _nudgeCherieMasseurCounter(int delta) {
    if (widget.npc.id != 'cherie') return;
    final next = CherieQuest004.readMasseur(widget.npc) + delta;
    widget.npc.setVar(
      CherieQuest004.npcVarMasseur,
      next < 0 ? 0 : next,
    );
    sl<SaveService>().autosave();
    setState(() {});
  }

  Widget _cherieMasseurStepper(
    String Function(String) t, {
    required bool massageTherapistUnlocked,
  }) {
    final n = CherieQuest004.readMasseur(widget.npc);
    final active = massageTherapistUnlocked;
    final lineStyle = TextStyle(
      color: active ? Colors.white54 : Colors.white30,
      fontSize: 12,
      height: 1.35,
    );
    final digitColor = active ? Colors.white : Colors.white38;
    final iconAccent = Colors.white70;
    final iconDisabled = Colors.white24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '${t('profile_cherie_masseur_label')} — ',
            style: lineStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: active && n > 0
              ? () => _nudgeCherieMasseurCounter(-1)
              : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: active && n > 0 ? iconAccent : iconDisabled,
            size: 22,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '$n',
            style: TextStyle(
              color: digitColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: active ? () => _nudgeCherieMasseurCounter(1) : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: active ? iconAccent : iconDisabled,
            size: 22,
          ),
        ),
      ],
    );
  }

  void _nudgeCherieQuest005Actor(int delta) {
    final next = (widget.world.cherieQuest005Actor + delta).clamp(0, 99);
    widget.world.cherieQuest005Actor = next;
    widget.world.cherieQuest005Complete =
        widget.world.cherieQuest005Actor >=
            CherieQuest005.completeActorThreshold;
    sl<SaveService>().autosave();
    setState(() {});
  }

  void _nudgeCherieQuest005Lizun(int delta) {
    final next = (widget.world.cherieQuest005Lizun + delta).clamp(0, 3);
    widget.world.cherieQuest005Lizun = next;
    sl<SaveService>().autosave();
    setState(() {});
  }

  Widget _cherieQuest005StepperSegment(
    String Function(String) t, {
    required String labelKey,
    required int value,
    required int min,
    required int max,
    required bool active,
    required void Function(int delta) onDelta,
  }) {
    final lineStyle = TextStyle(
      color: active ? Colors.white54 : Colors.white30,
      fontSize: 12,
      height: 1.35,
    );
    final digitColor = active ? Colors.white : Colors.white38;
    final iconAccent = Colors.white70;
    final iconDisabled = Colors.white24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            t(labelKey),
            style: lineStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: active && value > min
              ? () => onDelta(-1)
              : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: active && value > min ? iconAccent : iconDisabled,
            size: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            '$value',
            style: TextStyle(
              color: digitColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: active && value < max ? () => onDelta(1) : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: active && value < max ? iconAccent : iconDisabled,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _cherieQuest005CountersRow(
    String Function(String) t, {
    required bool active,
  }) {
    final actor = widget.world.cherieQuest005Actor;
    final lizun = widget.world.cherieQuest005Lizun;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _cherieQuest005StepperSegment(
            t,
            labelKey: 'profile_cherie_quest005_actor_label',
            value: actor,
            min: 0,
            max: 99,
            active: active,
            onDelta: _nudgeCherieQuest005Actor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _cherieQuest005StepperSegment(
            t,
            labelKey: 'profile_cherie_quest005_lizun_label',
            value: lizun,
            min: 0,
            max: 3,
            active: active,
            onDelta: _nudgeCherieQuest005Lizun,
          ),
        ),
      ],
    );
  }

  Widget _questGroupExpansion(
    BuildContext context,
    NpcProfileQuestGroup group,
    String Function(String) t,
    bool cheatsOn,
    PlayerStatsController stats,
    NPCService npcSvc,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        childrenPadding: const EdgeInsets.only(left: 4, bottom: 4, top: 0),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            t(group.titleKey),
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        children: group.lines
            .map(
              (q) => _buildQuestLineTile(
                q,
                t,
                cheatsOn,
                stats,
                npcSvc,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildQuestLineTile(
    NpcProfileQuestLine q,
    String Function(String) t,
    bool cheatsOn,
    PlayerStatsController stats,
    NPCService npcSvc,
  ) {
    final done = q.isDone(widget.world, widget.npc);
    final canToggle = cheatsOn && q.cheatId != null;
    final statusLabel = done
        ? t(q.statusDoneKey ?? 'quest_status_done')
        : t(q.statusPendingKey ?? 'quest_status_pending');
    final statusStyle = TextStyle(
      color: done ? GameTheme.textGreen : Colors.orange.shade200,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final counterKey = q.counterLineKey;
    final counterFn = q.counterValue;
    final secondaryCounterKey = q.secondaryCounterLineKey;
    final secondaryCounterFn = q.secondaryCounterValue;
    final isCherieQuest005DualCounters = counterKey == _kCherieQuest005ActorKey &&
        secondaryCounterKey == _kCherieQuest005LizunKey;
    final counterText = counterKey != null &&
            counterFn != null &&
            counterKey != _kCherieAnimatorCounterKey &&
            counterKey != _kCherieMasseurCounterKey &&
            counterKey != _kMomOwesGgCounterKey &&
            !isCherieQuest005DualCounters
        ? t(counterKey).replaceAll('%s', () {
            final raw = counterFn(widget.world, widget.npc);
            return '$raw';
          }())
        : '';
    final secondaryCounterText = secondaryCounterKey != null &&
            secondaryCounterFn != null &&
            !isCherieQuest005DualCounters
        ? t(secondaryCounterKey).replaceAll('%s', () {
            final raw = secondaryCounterFn(widget.world, widget.npc);
            return '$raw';
          }())
        : '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: q.compactSwitch
          ? const VisualDensity(horizontal: 0, vertical: -3)
          : VisualDensity.standard,
      title: Text(
        t(q.titleKey),
        style: TextStyle(
          color: Colors.white70,
          fontSize: q.compactSwitch ? 13 : 14,
          height: 1.35,
        ),
      ),
      subtitle: counterKey != null && counterFn != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: statusStyle,
                ),
                const SizedBox(height: 4),
                if (counterKey == _kCherieAnimatorCounterKey)
                  _cherieAnimatorShiftsStepper(
                    t,
                    questOneDone: done,
                  )
                else if (counterKey == _kCherieMasseurCounterKey)
                  _cherieMasseurStepper(
                    t,
                    massageTherapistUnlocked: CherieQuest003.isUnlocked(widget.npc),
                  )
                else if (counterKey == _kMomOwesGgCounterKey)
                  _momOwesGgStepper(t, active: cheatsOn)
                else if (isCherieQuest005DualCounters)
                  _cherieQuest005CountersRow(
                    t,
                    active: cheatsOn ||
                        CherieQuest004.isLingerieContractDone(widget.npc),
                  )
                else ...[
                  if (counterText.isNotEmpty)
                    Text(
                      counterText,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  if (secondaryCounterText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryCounterText,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ],
            )
          : Text(
              statusLabel,
              style: statusStyle,
            ),
      trailing: Transform.scale(
        scale: q.compactSwitch ? 0.78 : 0.92,
        alignment: Alignment.centerRight,
        child: Switch(
          value: done,
          activeThumbColor: GameTheme.textGreen,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: canToggle
              ? (v) {
                  NpcQuestCheats.setQuestCompleted(
                    q.cheatId!,
                    v,
                    widget.world,
                    stats,
                    npcSvc,
                    widget.npc,
                  );
                  sl<SaveService>().autosave();
                  setState(() {});
                }
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = sl<LocaleController>();
    final t = loc.t;
    final groups = npcProfileQuestGroupsFor(widget.npc.id);
    final lines = groups == null ? npcProfileQuestLinesFor(widget.npc.id) : const <NpcProfileQuestLine>[];
    if (groups == null && lines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Text(
          '—',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    final settings = sl<SettingsController>();
    final stats = sl<PlayerStatsController>();
    final npcSvc = widget.npcService ?? sl<NPCService>();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final cheatsOn = settings.cheatsEnabled;
        if (groups != null && groups.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: groups
                .map(
                  (g) => _questGroupExpansion(
                    context,
                    g,
                    t,
                    cheatsOn,
                    stats,
                    npcSvc,
                  ),
                )
                .toList(),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: lines
              .map(
                (q) => _buildQuestLineTile(
                  q,
                  t,
                  cheatsOn,
                  stats,
                  npcSvc,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _NpcProfileSexStatsList extends StatelessWidget {
  const _NpcProfileSexStatsList({required this.npc});

  final NPCModel npc;

  @override
  Widget build(BuildContext context) {
    final t = sl<LocaleController>().t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final varKey in NpcSexStats.orderedVarKeys)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '${t(NpcSexStats.labelL10nKeys[varKey]!)}: ${NpcSexStats.read(npc, varKey)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}

Widget _profilePhotoPlaceholder() {
  return Container(
    width: 175,
    height: 250,
    color: Colors.white12,
    child: const Icon(Icons.person, color: Colors.white38, size: 36),
  );
}

class _ProfilePortraitPhoto extends StatelessWidget {
  const _ProfilePortraitPhoto({
    required this.npc,
  });

  final NPCModel npc;

  @override
  Widget build(BuildContext context) {
    // У картці NPC завжди показуємо той самий портрет, що і в галереї персонажів.
    final paths = npcGalleryPortraitCandidates(npc);
    if (paths.isEmpty) return _profilePhotoPlaceholder();
    return _ChainedProfileImage(paths: paths);
  }
}

class _ChainedProfileImage extends StatelessWidget {
  const _ChainedProfileImage({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      paths.first,
      width: 175,
      height: 250,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        if (paths.length <= 1) return _profilePhotoPlaceholder();
        return _ChainedProfileImage(paths: paths.sublist(1));
      },
    );
  }
}
