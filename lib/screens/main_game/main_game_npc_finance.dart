part of '../main_game_screen.dart';

/// Діалоги та колбеки меню «Фінанси» ([NpcFinanceService]).
mixin MainGameNpcFinance on MainGameScreenStateBase {
  bool _npcFinanceAskMomMoney(NPCModel npc, int amount) {
    if (!mounted) return false;
    final t = sl<LocaleController>().t;
    final now = _timeController.dateTime;
    final ok = NpcFinanceService.applyMomAskMoney(
      w: _worldState,
      player: _playerStats,
      mom: npc,
      gameNow: now,
      amount: amount,
    );
    if (!ok) return false;
    setState(() {
      newsMessage = t('npc_finance_mom_gave').replaceAll('%s', '$amount');
    });
    _saveService.autosave();
    return true;
  }

  void _npcFinanceGiveMoney(NPCModel npc) {
    if (!mounted) return;
    final t = sl<LocaleController>().t;
    final now = _timeController.dateTime;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Center(
          child: Text(
            t('npc_finance_pick_amount'),
            textAlign: TextAlign.center,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: NpcFinanceService.canGive50(_worldState, npc.id, now) &&
                        _playerStats.money >= 50
                    ? () {
                        final ok = NpcFinanceService.applyGiveMoney(
                          _worldState,
                          npcId: npc.id,
                          npc: npc,
                          player: _playerStats,
                          gameNow: now,
                          amount: 50,
                        );
                        Navigator.pop(ctx);
                        if (ok) {
                          setState(() {
                            newsMessage =
                                t('npc_finance_you_gifted').replaceAll('%s', '50');
                          });
                          _saveService.autosave();
                        }
                      }
                    : null,
                child: Text(t('npc_finance_give_50')),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: NpcFinanceService.canGive100(_worldState, npc.id, now) &&
                        _playerStats.money >= 100
                    ? () {
                        final ok = NpcFinanceService.applyGiveMoney(
                          _worldState,
                          npcId: npc.id,
                          npc: npc,
                          player: _playerStats,
                          gameNow: now,
                          amount: 100,
                        );
                        Navigator.pop(ctx);
                        if (ok) {
                          setState(() {
                            newsMessage =
                                t('npc_finance_you_gifted').replaceAll('%s', '100');
                          });
                          _saveService.autosave();
                        }
                      }
                    : null,
                child: Text(t('npc_finance_give_100')),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: NpcFinanceService.canGive250(_worldState, npc.id, now) &&
                        _playerStats.money >= 250
                    ? () {
                        final ok = NpcFinanceService.applyGiveMoney(
                          _worldState,
                          npcId: npc.id,
                          npc: npc,
                          player: _playerStats,
                          gameNow: now,
                          amount: 250,
                        );
                        Navigator.pop(ctx);
                        if (ok) {
                          setState(() {
                            newsMessage =
                                t('npc_finance_you_gifted').replaceAll('%s', '250');
                          });
                          _saveService.autosave();
                        }
                      }
                    : null,
                child: Text(t('npc_finance_give_250')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('dialog_close')),
          ),
        ],
      ),
    );
  }

  void _npcFinanceAskLoan(NPCModel npc) {
    if (!mounted) return;
    final t = sl<LocaleController>().t;
    final now = _timeController.dateTime;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('npc_finance_ask_loan')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: NpcFinanceService.canBorrow50(_worldState, npc.id)
                  ? () {
                      if (npc.money < 50) {
                        Navigator.pop(ctx);
                        showDialog<void>(
                          context: context,
                          builder: (c2) => AlertDialog(
                            content: Text(t('npc_finance_npc_no_money')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c2),
                                child: Text(t('dialog_close')),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      final ok = NpcFinanceService.applyBorrowFromNpc(
                        _worldState,
                        npcId: npc.id,
                        npc: npc,
                        player: _playerStats,
                        gameNow: now,
                        slot50or100: 50,
                      );
                      Navigator.pop(ctx);
                      if (ok) {
                        setState(() {
                          newsMessage =
                              t('npc_finance_you_borrowed').replaceAll('%s', '50');
                        });
                        _saveService.autosave();
                      }
                    }
                  : null,
              child: Text(t('npc_finance_borrow_50')),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: NpcFinanceService.canBorrow100(_worldState, npc.id)
                  ? () {
                      if (npc.money < 100) {
                        Navigator.pop(ctx);
                        showDialog<void>(
                          context: context,
                          builder: (c2) => AlertDialog(
                            content: Text(t('npc_finance_npc_no_money')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c2),
                                child: Text(t('dialog_close')),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      final ok = NpcFinanceService.applyBorrowFromNpc(
                        _worldState,
                        npcId: npc.id,
                        npc: npc,
                        player: _playerStats,
                        gameNow: now,
                        slot50or100: 100,
                      );
                      Navigator.pop(ctx);
                      if (ok) {
                        setState(() {
                          newsMessage =
                              t('npc_finance_you_borrowed').replaceAll('%s', '100');
                        });
                        _saveService.autosave();
                      }
                    }
                  : null,
              child: Text(t('npc_finance_borrow_100')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('dialog_close')),
          ),
        ],
      ),
    );
  }

  void _npcFinanceGiveLoan(NPCModel npc) {
    if (!mounted) return;
    final t = sl<LocaleController>().t;
    final lendBlock = NpcFinanceService.lendToNpcBlockedMessageKey(npc);
    if (lendBlock != null) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(t(lendBlock)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t('dialog_close')),
            ),
          ],
        ),
      );
      return;
    }
    final now = _timeController.dateTime;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('npc_finance_give_loan')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _playerStats.money >= 50 &&
                      NpcFinanceService.canApplyLendAmount(_worldState, npc.id, 50)
                  ? () {
                      final ok = NpcFinanceService.applyLendToNpc(
                        _worldState,
                        npcId: npc.id,
                        npc: npc,
                        player: _playerStats,
                        gameNow: now,
                        amount: 50,
                      );
                      Navigator.pop(ctx);
                      if (ok) {
                        setState(() {
                          newsMessage =
                              t('npc_finance_you_lent').replaceAll('%s', '50');
                        });
                        _saveService.autosave();
                      }
                    }
                  : null,
              child: Text(t('npc_finance_lend_50')),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _playerStats.money >= 150 &&
                      NpcFinanceService.canApplyLendAmount(_worldState, npc.id, 150)
                  ? () {
                      final ok = NpcFinanceService.applyLendToNpc(
                        _worldState,
                        npcId: npc.id,
                        npc: npc,
                        player: _playerStats,
                        gameNow: now,
                        amount: 150,
                      );
                      Navigator.pop(ctx);
                      if (ok) {
                        setState(() {
                          newsMessage =
                              t('npc_finance_you_lent').replaceAll('%s', '150');
                        });
                        _saveService.autosave();
                      }
                    }
                  : null,
              child: Text(t('npc_finance_lend_150')),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _playerStats.money >= 250 &&
                      NpcFinanceService.canApplyLendAmount(_worldState, npc.id, 250)
                  ? () {
                      final ok = NpcFinanceService.applyLendToNpc(
                        _worldState,
                        npcId: npc.id,
                        npc: npc,
                        player: _playerStats,
                        gameNow: now,
                        amount: 250,
                      );
                      Navigator.pop(ctx);
                      if (ok) {
                        setState(() {
                          newsMessage =
                              t('npc_finance_you_lent').replaceAll('%s', '250');
                        });
                        _saveService.autosave();
                      }
                    }
                  : null,
              child: Text(t('npc_finance_lend_250')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('dialog_close')),
          ),
        ],
      ),
    );
  }

  void _npcFinanceRepayGgDebt(NPCModel npc) {
    if (!mounted) return;
    final t = sl<LocaleController>().t;
    final now = _timeController.dateTime;
    final has50 = NpcFinanceService.hasGgOwesNpcSlot50(_worldState, npc.id);
    final has100 = NpcFinanceService.hasGgOwesNpcSlot100(_worldState, npc.id);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('npc_finance_repay_to_npc')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (has50)
              ElevatedButton(
                onPressed: _playerStats.money >= 50
                    ? () {
                        final ok = NpcFinanceService.applyRepayGgOwesNpc(
                          _worldState,
                          npcId: npc.id,
                          npc: npc,
                          player: _playerStats,
                          gameNow: now,
                          slot50or100: 50,
                        );
                        Navigator.pop(ctx);
                        if (ok) {
                          setState(() {
                            newsMessage = t('npc_finance_repaid_loan');
                          });
                          _saveService.autosave();
                        } else {
                          showInsufficientMoneyDialog(context);
                        }
                      }
                    : null,
                child: Text(t('npc_finance_repay_slot_50')),
              ),
            if (has50 && has100) const SizedBox(height: 8),
            if (has100)
              ElevatedButton(
                onPressed: _playerStats.money >= 100
                    ? () {
                        final ok = NpcFinanceService.applyRepayGgOwesNpc(
                          _worldState,
                          npcId: npc.id,
                          npc: npc,
                          player: _playerStats,
                          gameNow: now,
                          slot50or100: 100,
                        );
                        Navigator.pop(ctx);
                        if (ok) {
                          setState(() {
                            newsMessage = t('npc_finance_repaid_loan');
                          });
                          _saveService.autosave();
                        } else {
                          showInsufficientMoneyDialog(context);
                        }
                      }
                    : null,
                child: Text(t('npc_finance_repay_slot_100')),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('dialog_close')),
          ),
        ],
      ),
    );
  }

  void _npcFinanceAskAboutDebt(NPCModel npc) {
    final ok = NpcFinanceService.applyNpcRepaysDebtWithCash(
      _worldState,
      npcId: npc.id,
      npc: npc,
      player: _playerStats,
    );
    setState(() {
      newsMessage = ok ? sl<LocaleController>().t('npc_finance_repaid_by_npc') : '';
    });
    if (ok) _saveService.autosave();
  }

  void _npcFinanceOfferAlternatives(NPCModel npc) {
    if (!mounted) return;
    final t = sl<LocaleController>().t;
    final now = _timeController.dateTime;
    final rollOk = NpcFinanceService.rollAlternativeSettlementAllowed(
      _worldState,
      npc.id,
      now,
    );
    if (!rollOk) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(t('npc_finance_alt_npc_refused')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t('dialog_close')),
            ),
          ],
        ),
      );
      return;
    }

    final debt = NpcFinanceService.npcOwesGg(_worldState, npc.id);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('npc_finance_offer_alt_settlement')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final kind in NpcFinanceAltSettlement.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: (!kind.isImplemented ||
                            debt < kind.debtMin ||
                            debt > kind.debtMax ||
                            npc.money < kind.debtMin)
                        ? null
                        : () {
                            final ok = NpcFinanceService.applyAlternativeSettlement(
                              _worldState,
                              npcId: npc.id,
                              npc: npc,
                              player: _playerStats,
                              gameNow: now,
                              kind: kind,
                            );
                            Navigator.pop(ctx);
                            if (ok) {
                              setState(() {
                                newsMessage = t('npc_finance_alt_done');
                              });
                              _saveService.autosave();
                            }
                          },
                    child: Text(
                      '${_npcFinanceAltLabel(t, kind)}${kind.isImplemented ? '' : ' (${t('npc_finance_soon')})'}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('dialog_close')),
          ),
        ],
      ),
    );
  }

  String _npcFinanceAltLabel(String Function(String) t, NpcFinanceAltSettlement k) {
    switch (k) {
      case NpcFinanceAltSettlement.showBreasts:
        return t('npc_finance_alt_show_breasts');
      case NpcFinanceAltSettlement.showButt:
        return t('npc_finance_alt_show_butt');
      case NpcFinanceAltSettlement.touchBreasts:
        return t('npc_finance_alt_touch_breasts');
      case NpcFinanceAltSettlement.touchButt:
        return t('npc_finance_alt_touch_butt');
      case NpcFinanceAltSettlement.handjob:
        return t('npc_finance_alt_handjob');
      case NpcFinanceAltSettlement.blowjob:
        return t('npc_finance_alt_blowjob');
      case NpcFinanceAltSettlement.bendOver:
        return t('npc_finance_alt_bend_over');
      case NpcFinanceAltSettlement.anal:
        return t('npc_finance_alt_anal');
      case NpcFinanceAltSettlement.threesome:
        return t('npc_finance_alt_threesome');
    }
  }
}
