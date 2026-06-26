import 'package:flutter/material.dart';

import '../models/npc_model.dart';
import '../models/npc_secondary.dart';
import '../npcs/gg/gg_event_001_stojak.dart';
import '../services/game_time_controller.dart';
import '../services/locale_controller.dart';
import '../services/player_stats_controller.dart';
import '../services/save_service.dart';
import '../services/service_locator.dart';
import '../theme/game_theme.dart';

const TextStyle _npcButtonTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.4,
);

/// Кнопки взаємодії з NPC (Поговорити, Комплімент, Пожартувати тощо).
/// Показує список дій, повернутих [NPCModel.getAvailableActions].
///
/// Для NPC з економікою додається «Фінанси» → підменю. Логіку фінансових кнопок
/// підключають через [onFinanceGiveMoney], [onFinanceGiveLoan] тощо (або дописують окремо).
class NpcInteractionButtons extends StatefulWidget {
  final NPCModel npc;
  final String location;
  final int hour;
  final VoidCallback onUpdate;
  final VoidCallback? onBack;

  /// Викликається після виконання кожної дії (label + npc для івент-відео тощо).
  final void Function(String actionLabel, NPCModel npc)? onActionExecuted;

  /// Логіка фінансового підменю — за потреби передати з батька; якщо null, тап без ефекту.
  final VoidCallback? onFinanceGiveMoney;
  final VoidCallback? onFinanceGiveLoan;
  final bool Function(int amount)? onFinanceAskMomMoney;

  /// Коли NPC має несплачений борг перед ГГ — повне погашення готівкою.
  final VoidCallback? onFinanceAskAboutDebt;

  /// Жіночі NPC: альтернативний розрахунок після 7 днів боргу.
  final VoidCallback? onFinanceOfferAlternatives;

  /// Погасити борг ГГ перед NPC (позика 50/100).
  final VoidCallback? onFinanceRepayGgDebt;

  /// Piper quest: «Розповісти про оцінки» у підменю «Поговорити» з мамою (null — не показувати).
  final VoidCallback? onTalkPiperSnitch;

  /// Piper quest: крок 7A — попросити маму дозволити наказувати Пайпер (кухня).
  final VoidCallback? onTalkGgCommandPiper;

  /// Piper quest: крок 7B — сказати Пайпер про покарання в `piper_room`.
  final VoidCallback? onTalkTellPiperAboutPunishment;

  /// Кошик їжі з ТРЦ: ввечері на кухні — «Мама, я купив до дому продукти».
  final VoidCallback? onMomDeliverGroceries;

  const NpcInteractionButtons({
    super.key,
    required this.npc,
    required this.location,
    required this.hour,
    required this.onUpdate,
    this.onBack,
    this.onActionExecuted,
    this.onFinanceGiveMoney,
    this.onFinanceGiveLoan,
    this.onFinanceAskMomMoney,
    this.onFinanceAskAboutDebt,
    this.onFinanceOfferAlternatives,
    this.onFinanceRepayGgDebt,
    this.onTalkPiperSnitch,
    this.onTalkGgCommandPiper,
    this.onTalkTellPiperAboutPunishment,
    this.onMomDeliverGroceries,
  });

  @override
  State<NpcInteractionButtons> createState() => _NpcInteractionButtonsState();
}

class _NpcInteractionButtonsState extends State<NpcInteractionButtons> {
  static const String _talkLabel = 'Поговорити';
  static const String _askHowAreYouLabel = 'Запитати як справи';
  static const String _complimentLabel = 'Комплімент';
  static const String _jokeLabel = 'Пожартувати';
  static const String _giftLabel = 'Подарувати';
  static const Map<String, int> _talkDailyLimits = {
    _talkLabel: 5,
    _complimentLabel: 4,
    _jokeLabel: 3,
    _giftLabel: 1,
  };
  static const Map<String, String> _talkDailyCounterIds = {
    _talkLabel: 'ask_how_are_you',
    _complimentLabel: 'compliment',
    _jokeLabel: 'joke',
    _giftLabel: 'gift',
  };

  bool _financeMode = false;
  bool _talkMode = false;
  bool _momAskMoneyMode = false;

  void _applyGgEvent001StojakSideEffects() {
    final stats = sl<PlayerStatsController>();
    final a = stats.arousal;
    final m = stats.player.maxArousal;
    if (!GgEvent001Stojak.stojakDialogApplies(widget.npc, a, m)) return;
    GgEvent001Stojak.onStojakPanelFirstBuild(widget.npc);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onUpdate();
      sl<SaveService>().autosave();
    });
  }

  @override
  void initState() {
    super.initState();
    _applyGgEvent001StojakSideEffects();
  }

  @override
  void didUpdateWidget(covariant NpcInteractionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.npc.id != widget.npc.id) {
      _applyGgEvent001StojakSideEffects();
    }
  }

  bool get _financeAvailable => !isSecondaryNpc(widget.npc);

  Widget _elevated(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: GameTheme.actionButtonStyle().copyWith(
          textStyle: WidgetStateProperty.all(_npcButtonTextStyle),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: _npcButtonTextStyle,
        ),
      ),
    );
  }

  Widget _backToActionsButton(BuildContext context) {
    final t = sl<LocaleController>().t;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: GameTheme.actionButtonStyle(
          color: GameTheme.textBlack,
        ).copyWith(textStyle: WidgetStateProperty.all(_npcButtonTextStyle)),
        onPressed: () => setState(() {
          _financeMode = false;
          _momAskMoneyMode = false;
        }),
        child: Text(
          t('npc_finance_back_actions').toUpperCase(),
          textAlign: TextAlign.center,
          style: _npcButtonTextStyle,
        ),
      ),
    );
  }

  Widget _backToFinanceButton(BuildContext context) {
    final t = sl<LocaleController>().t;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: GameTheme.actionButtonStyle(
          color: GameTheme.textBlack,
        ).copyWith(textStyle: WidgetStateProperty.all(_npcButtonTextStyle)),
        onPressed: () => setState(() => _momAskMoneyMode = false),
        child: Text(
          t('npc_finance_back_actions').toUpperCase(),
          textAlign: TextAlign.center,
          style: _npcButtonTextStyle,
        ),
      ),
    );
  }

  Widget _menuMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: GameTheme.textBlack,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _backToMainActionsButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: GameTheme.actionButtonStyle(
          color: GameTheme.textBlack,
        ).copyWith(textStyle: WidgetStateProperty.all(_npcButtonTextStyle)),
        onPressed: () => setState(() => _talkMode = false),
        child: const Text(
          'НАЗАД',
          textAlign: TextAlign.center,
          style: _npcButtonTextStyle,
        ),
      ),
    );
  }

  Widget _stojakLeaveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: GameTheme.actionButtonStyle(
          color: GameTheme.textBlack,
        ).copyWith(textStyle: WidgetStateProperty.all(_npcButtonTextStyle)),
        onPressed: widget.onBack,
        child: Text(
          sl<LocaleController>().t('gg_event_001_stojak_btn_leave').toUpperCase(),
          textAlign: TextAlign.center,
          style: _npcButtonTextStyle,
        ),
      ),
    );
  }

  Widget _closePanelButton() {
    return ElevatedButton(
      style: GameTheme.actionButtonStyle(
        color: GameTheme.textBlack,
      ).copyWith(textStyle: WidgetStateProperty.all(_npcButtonTextStyle)),
      onPressed: widget.onBack,
      child: const Text(
        'НАЗАД',
        textAlign: TextAlign.center,
        style: _npcButtonTextStyle,
      ),
    );
  }

  void _executeAction(NPCAction action) {
    action.onExecute();
    widget.npc.setVar('phone_unlocked', true);
    widget.onUpdate();
    widget.onActionExecuted?.call(action.label, widget.npc);
  }

  String get _gameDayKey {
    final dt = sl<GameTimeController>().dateTime;
    return '${dt.year}-${dt.month}-${dt.day}';
  }

  String _talkCounterKey(String actionLabel) {
    final id = _talkDailyCounterIds[actionLabel] ?? actionLabel;
    return 'talk_menu_${id}_$_gameDayKey';
  }

  int _talkUsedToday(String actionLabel) {
    final raw = widget.npc.variables[_talkCounterKey(actionLabel)];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0;
  }

  bool _talkActionAvailable(String actionLabel) {
    final limit = _talkDailyLimits[actionLabel];
    return limit == null || _talkUsedToday(actionLabel) < limit;
  }

  void _executeLimitedTalkAction(NPCAction action) {
    final limit = _talkDailyLimits[action.label];
    if (limit != null) {
      final used = _talkUsedToday(action.label);
      if (used >= limit) return;
      widget.npc.setVar(_talkCounterKey(action.label), used + 1);
    }
    _executeAction(action);
  }

  void _askMomMoney(int amount) {
    final ok = widget.onFinanceAskMomMoney?.call(amount) ?? false;
    if (ok && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = sl<LocaleController>().t;
    final stats = sl<PlayerStatsController>();
    final playerArousal = stats.arousal;
    final playerMaxArousal = stats.player.maxArousal;
    if (GgEvent001Stojak.stojakDialogApplies(
      widget.npc,
      playerArousal,
      playerMaxArousal,
    )) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onBack != null) _stojakLeaveButton(),
        ],
      );
    }

    if (_financeMode && _financeAvailable) {
      final isMom = widget.npc.id == 'mom';
      if (_momAskMoneyMode && isMom) {
        final momCanGive50 = widget.npc.money >= 50;
        final momCanGive100 = widget.npc.money >= 100;
        final momAskRows = <Widget>[
          if (!momCanGive50) _menuMessage(t('npc_finance_mom_no_money')),
          if (momCanGive50)
            _elevated(t('npc_finance_mom_ask_50'), () => _askMomMoney(50)),
          if (momCanGive100)
            _elevated(t('npc_finance_mom_ask_100'), () => _askMomMoney(100)),
          _backToFinanceButton(context),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: momAskRows,
        );
      }

      // Мама: попросити грошей → дати → дати в борг → назад.
      // Інші NPC: дати → дати в борг → … → назад.
      final financeRows = <Widget>[
        if (isMom && widget.onFinanceAskMomMoney != null)
          _elevated(
            t('npc_finance_ask_money_mom'),
            () => setState(() => _momAskMoneyMode = true),
          ),
        _elevated(
          t('npc_finance_give_money'),
          () => widget.onFinanceGiveMoney?.call(),
        ),
        _elevated(
          t('npc_finance_give_loan'),
          () => widget.onFinanceGiveLoan?.call(),
        ),
        if (widget.onFinanceRepayGgDebt != null)
          _elevated(
            t('npc_finance_repay_to_npc'),
            widget.onFinanceRepayGgDebt!,
          ),
        if (widget.onFinanceAskAboutDebt != null)
          _elevated(
            t('npc_finance_ask_about_debt'),
            widget.onFinanceAskAboutDebt!,
          ),
        if (widget.onFinanceOfferAlternatives != null)
          _elevated(
            t('npc_finance_offer_alt_settlement'),
            widget.onFinanceOfferAlternatives!,
          ),
        _backToActionsButton(context),
      ];
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: financeRows,
      );
    }

    final actions = widget.npc.getAvailableActions(
      location: widget.location,
      hour: widget.hour,
      onUpdate: widget.onUpdate,
    );

    if (_talkMode) {
      final actionByLabel = <String, NPCAction>{
        for (final action in actions) action.label: action,
      };
      final talkAction = actionByLabel[_talkLabel];
      final talkRows = <Widget>[
        if (widget.onTalkTellPiperAboutPunishment != null)
          _elevated(
            t('piper_quest_001_btn_tell_piper_punishment'),
            () {
              widget.onTalkTellPiperAboutPunishment!();
            },
          ),
        if (widget.onTalkPiperSnitch != null)
          _elevated(
            t('piper_quest_001_btn_snitch_mom'),
            () {
              widget.onTalkPiperSnitch!();
              setState(() => _talkMode = false);
            },
          ),
        if (widget.onTalkGgCommandPiper != null)
          _elevated(
            t('piper_quest_001_btn_step7a_command_piper'),
            () {
              widget.onTalkGgCommandPiper!();
            },
          ),
        if (talkAction != null && _talkActionAvailable(_talkLabel))
          _elevated(
            _askHowAreYouLabel,
            () => _executeLimitedTalkAction(talkAction),
          ),
        for (final label in [_complimentLabel, _jokeLabel, _giftLabel])
          if (actionByLabel[label] != null && _talkActionAvailable(label))
            _elevated(
              label,
              () => _executeLimitedTalkAction(actionByLabel[label]!),
            ),
        _backToMainActionsButton(),
      ];

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: talkRows,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onMomDeliverGroceries != null)
          _elevated(
            t('mom_grocery_debt_btn'),
            widget.onMomDeliverGroceries!,
          ),
        if (widget.onMomDeliverGroceries != null) const SizedBox(height: 8),
        for (final action in actions.where(
          (action) =>
              action.label != _complimentLabel &&
              action.label != _jokeLabel &&
              action.label != _giftLabel,
        )) ...[
          ElevatedButton(
            style: GameTheme.actionButtonStyle().copyWith(
              textStyle: WidgetStateProperty.all(_npcButtonTextStyle),
            ),
            onPressed: () {
              if (action.label == _talkLabel) {
                setState(() => _talkMode = true);
                return;
              }
              _executeAction(action);
            },
            child: Text(
              action.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: _npcButtonTextStyle,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_financeAvailable) ...[
          ElevatedButton(
            style: GameTheme.actionButtonStyle().copyWith(
              textStyle: WidgetStateProperty.all(_npcButtonTextStyle),
            ),
            onPressed: () => setState(() => _financeMode = true),
            child: Text(
              t('npc_finance_button').toUpperCase(),
              textAlign: TextAlign.center,
              style: _npcButtonTextStyle,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.onBack != null) _closePanelButton(),
      ],
    );
  }
}
