part of '../../screens/main_game_screen.dart';

/// Екранний флоу мами: **mom_quest_001** (пляж), **mom_event_002** (басейн).
mixin MomGameFlow on MainGameScreenStateBase {
  bool _isMomQuest001ScriptedDialogActive() {
    return MomQuest001.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  void _resetMomQuest001PresentationSession() {
    _momQuest001PresentationSyncedStep = null;
    _momQuest001VideoPath = null;
    _ui.setEventImagePath(null);
  }

  void _abortMomQuest001ProgressAndUi() {
    MomQuest001.abortAbandoned(_worldState);
    _resetMomQuest001PresentationSession();
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.migrateLegacyRoomId(currentRoom));
  }

  void _teleportMomQuest001HomeCorridor() {
    _nav.setZoneAndRoom('HOME', LocationsData.corridor);
    _nav.setIsInsideRoom(true);
    _worldState.currentZone = 'HOME';
    _worldState.currentRoom = LocationsData.corridor;
    _worldState.isInsideRoom = true;
    currentZone = 'HOME';
    currentRoom = LocationsData.corridor;
    isInsideRoom = true;
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.corridor);
  }

  void _applyMomQuest001Patch(MomQuest001Patch p) {
    _ui.clearEventSubState();
    newsMessage = sl<LocaleController>().t(p.newsL10nKey);
    _momQuest001VideoPath = null;
    if (p.imagePath != null) _ui.setEventImagePath(p.imagePath);
    if (p.videoPath != null) {
      final h = _launchInRoomVideo(
        videoPath: p.videoPath!,
        previousPlaybackTick: _momQuest001VideoTick,
        loop: p.loopVideo,
      );
      _momQuest001VideoTick = h.playbackTick;
      _momQuest001VideoPath = h.videoPath;
      _momQuest001VideoLoop = h.loop;
    }
    _momQuest001PresentationSyncedStep = _worldState.momQuest001Step;
  }

  void _maybeAbortMomQuest001WrongLocation() {
    if (!MomQuest001.isActiveMidFlow(_worldState)) return;
    if (MomQuest001.isLocationValidMidFlow(
      world: _worldState,
      currentZone: currentZone,
    )) {
      return;
    }
    _abortMomQuest001ProgressAndUi();
    _saveService.autosave();
  }

  void _tryStartMomQuest001HallIfNeeded(String enteredRoom) {
    final norm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (norm != LocationsData.hall) return;
    if (currentZone != 'HOME' || !isInsideRoom) return;
    final dt = _timeController.dateTime;
    final hour = dt.hour;
    final dayFromCalendar = MomQuest001.weekdayIndexFromDateTime(dt);
    final npcService = sl<NPCService>();
    final mom = npcService.npcById('mom');

    if (_worldState.momQuest001Step == 1 &&
        _momQuest001PresentationSyncedStep == 1) {
      return;
    }

    if (MomQuest001.canStartStep1Weekday(
      world: _worldState,
      mom: mom,
      weekdayIndex: dayFromCalendar,
      hour: hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      _worldState.momQuest001Step = 1;
      _selectedNpcIdInRoom = 'mom';
      _momQuest001PresentationSyncedStep = null;
      _applyMomQuest001Patch(MomQuest001.patchForPresentationStep(1));
      return;
    }

    if (MomQuest001.isWeekendDateTime(dt) &&
        MomQuest001.isHallWeekendWindow(hour) &&
        _worldState.momQuest001InvitationAccepted &&
        _worldState.momQuest001Step == 0 &&
        mom != null) {
      final weekKey =
          MomQuest001.gameWeekMondayKey(_timeController.dateTime);
      if (_worldState.momQuest001LastBeachTripWeekKey == weekKey) {
        newsMessage =
            sl<LocaleController>().t('mom_quest_001_beach_weekly_limit');
        return;
      }
      final tier = MomQuest001.effectiveWeekendTier(
        beach: _worldState.momQuest001Beach,
        invitationAccepted: _worldState.momQuest001InvitationAccepted,
        relationship: mom.relationship,
      );
      if (tier >= 1) {
        final entry = MomQuest001.hallWeekendEntryStepForTier(tier);
        if (entry > 0) {
          _worldState.momQuest001Step = entry;
          _selectedNpcIdInRoom = 'mom';
          _momQuest001PresentationSyncedStep = null;
          _applyMomQuest001Patch(MomQuest001.patchForPresentationStep(entry));
        }
      }
    }
  }

  void _maybeResumeMomQuest001AfterLoad() {
    if (!MomQuest001.isActiveMidFlow(_worldState)) return;
    if (!MomQuest001.isLocationValidMidFlow(
      world: _worldState,
      currentZone: currentZone,
    )) {
      return;
    }
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.hall) return;
    final s = _worldState.momQuest001Step;
    if (_momQuest001PresentationSyncedStep == s) return;
    _selectedNpcIdInRoom = 'mom';
    _applyMomQuest001Patch(MomQuest001.patchForPresentationStep(s));
  }

  void _momQuest001GoToStep(int nextStep) {
    _worldState.momQuest001Step = nextStep;
    _applyMomQuest001Patch(MomQuest001.patchForPresentationStep(nextStep));
  }

  void _momQuest001ApplyStep1Agree() {
    if (_worldState.momQuest001Step != 1) return;
    _worldState.momQuest001InvitationAccepted = true;
    _worldState.momQuest001Step = 0;
    _resetMomQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(LocationsData.hall);
  }

  void _momQuest001ApplyStep1Refuse() {
    if (_worldState.momQuest001Step != 1) return;
    _worldState.momQuest001Step = 0;
    _resetMomQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(LocationsData.hall);
  }

  void _momQuest001ApplyHallImageBack() {
    final s = _worldState.momQuest001Step;
    if (s != 2 && s != 6 && s != 11 && s != 16 && s != 21) return;
    _worldState.momQuest001Step = 0;
    _resetMomQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(LocationsData.hall);
  }

  void _momQuest001ApplyTierHome({
    required int beachAfter,
    required bool firstTierStyleRewards,
    required bool markCompleteIfFirstFinale,
  }) {
    final mom = sl<NPCService>().npcById('mom');
    if (mom == null) return;
    if (firstTierStyleRewards) {
      MomQuest001.applyStep5Rewards(mom);
    } else {
      MomQuest001.applyLaterTripRewards(mom);
    }
    _worldState.momQuest001Beach = beachAfter.clamp(0, 4);
    _worldState.momQuest001Step = 0;
    _worldState.momQuest001LastBeachTripWeekKey =
        MomQuest001.gameWeekMondayKey(_timeController.dateTime);
    if (markCompleteIfFirstFinale && !MomQuest001.isComplete(mom)) {
      mom.setVar(MomQuest001.npcVarComplete, true);
    }
    _resetMomQuest001PresentationSession();
    _teleportMomQuest001HomeCorridor();
  }

  Widget? _momQuest001PriorityActionPanelIfAny() {
    if (!_isMomQuest001ScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;
    final s = _worldState.momQuest001Step;

    Widget column(List<Widget> children) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );

    if (s == 1) {
      return column([
        _navBtn(t('mom_quest_001_btn_agree').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyStep1Agree();
          });
          _saveService.autosave();
        }),
        const SizedBox(height: 8),
        _navBtn(t('mom_quest_001_btn_refuse').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyStep1Refuse();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 2) {
      return column([
        _navBtn(t('mom_quest_001_btn_ride_beach').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(3));
          _saveService.autosave();
        }),
        const SizedBox(height: 8),
        _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyHallImageBack();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 3) {
      return column([
        _navBtn(t('mom_quest_001_btn_locker').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(4));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 4) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_beach').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(5));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 5) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_home').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyTierHome(
              beachAfter: 1,
              firstTierStyleRewards: true,
              markCompleteIfFirstFinale: false,
            );
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 6 || s == 11 || s == 16 || s == 21) {
      return column([
        _navBtn(t('mom_quest_001_btn_propose_beach').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(s + 1));
          _saveService.autosave();
        }),
        const SizedBox(height: 8),
        _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyHallImageBack();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 7 || s == 12 || s == 17 || s == 22) {
      return column([
        _navBtn(t('mom_quest_001_btn_ride').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(s + 1));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 8 || s == 13 || s == 18 || s == 23) {
      return column([
        _navBtn(t('mom_quest_001_btn_locker').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(s + 1));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 9 || s == 14 || s == 19) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_beach').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(s + 1));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 10) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_home').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyTierHome(
              beachAfter: 2,
              firstTierStyleRewards: false,
              markCompleteIfFirstFinale: false,
            );
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 15) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_home').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyTierHome(
              beachAfter: 3,
              firstTierStyleRewards: false,
              markCompleteIfFirstFinale: false,
            );
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 20) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_home').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyTierHome(
              beachAfter: 4,
              firstTierStyleRewards: false,
              markCompleteIfFirstFinale: false,
            );
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 24) {
      return column([
        _navBtn(t('mom_quest_001_btn_continue_fun').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(25));
          _saveService.autosave();
        }),
        const SizedBox(height: 8),
        _navBtn(t('mom_quest_001_btn_skip_to_finale').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(27));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 25) {
      return column([
        _navBtn(t('mom_quest_001_btn_finish').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(26));
          _saveService.autosave();
        }),
        const SizedBox(height: 8),
        _navBtn(t('mom_quest_001_btn_skip_to_finale').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(27));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 26) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_beach').toUpperCase(), () {
          setState(() => _momQuest001GoToStep(27));
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 27) {
      return column([
        _navBtn(t('mom_quest_001_btn_go_home').toUpperCase(), () {
          setState(() {
            _momQuest001ApplyTierHome(
              beachAfter: 4,
              firstTierStyleRewards: false,
              markCompleteIfFirstFinale: true,
            );
          });
          _saveService.autosave();
        }),
      ]);
    }

    return null;
  }

  bool _isMomEvent002ScriptedDialogActive() {
    if (!MomEvent002Pool.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return false;
    }
    return currentZone == 'HOME';
  }

  void _resetMomEvent002PresentationSession() {
    _momEvent002PresentationSyncedStep = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
  }

  void _abortMomEvent002ProgressAndUi() {
    MomEvent002Pool.abortAbandoned(_worldState);
    _resetMomEvent002PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
  }

  void _applyMomEvent002Patch(MomEvent002Patch p) {
    _ui.clearEventSubState();
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (p.imagePath != null) {
      _ui.setEventImagePath(p.imagePath);
    } else {
      _ui.setEventImagePath(null);
    }
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _momEvent002PresentationSyncedStep = _worldState.momEvent002Step;
  }

  void _syncMomEvent002KitchenRecheckIfNeeded() {
    if (!_worldState.momEvent002PendingKitchenRecheck) return;
    _worldState.momEvent002PendingKitchenRecheck = false;
    _momEvent002PresentationSyncedStep = null;
    _resetMomEvent002PresentationSession();
    if (currentZone != 'HOME' || !isInsideRoom) return;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.kitchen) {
      return;
    }
    _tryStartMomEvent002KitchenIfNeeded(LocationsData.kitchen);
  }

  void _maybeAbortMomEvent002WrongLocation() {
    final s = _worldState.momEvent002Step;
    if (s == 1 || s == 2) {
      if (MomEvent002Pool.isLocationValidForActiveStep(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
      )) {
        return;
      }
      if (s == 2 && _worldState.momPoolEventActive) {
        _worldState.momEvent002Step = 0;
        _resetMomEvent002PresentationSession();
        newsMessage = LocationsData.getLocationDisplayName(LocationsData.yard);
        return;
      }
      _abortMomEvent002ProgressAndUi();
      return;
    }
    if (s == 3 &&
        !MomEvent002Pool.isLocationValidForActiveStep(
          world: _worldState,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        )) {
      _worldState.momEvent002Step = 0;
      _resetMomEvent002PresentationSession();
      newsMessage = LocationsData.getLocationDisplayName(
        LocationsData.migrateLegacyRoomId(currentRoom),
      );
    }
  }

  void _tryStartMomEvent002KitchenIfNeeded(String enteredRoom) {
    final norm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (norm != LocationsData.kitchen) return;
    if (currentZone != 'HOME' || !isInsideRoom) return;

    if (MomEvent002Pool.canStartKitchenPayment(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      _startMomEvent002PaymentStep();
      return;
    }

    final dt = _timeController.dateTime;
    final hour = dt.hour;
    final weekday = _timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final mom = npcService.npcById('mom');

    if (_worldState.momEvent002Step == 1 &&
        _momEvent002PresentationSyncedStep == 1) {
      return;
    }

    if (!MomEvent002Pool.canStartKitchenOffer(
      world: _worldState,
      mom: mom,
      npcService: npcService,
      weekdayIndex: weekday,
      hour: hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      gameDate: dt,
    )) {
      return;
    }

    _worldState.momEvent002Step = 1;
    _selectedNpcIdInRoom = 'mom';
    _momEvent002PresentationSyncedStep = null;
    _applyMomEvent002Patch(MomEvent002Pool.patchForPresentationStep(1));
  }

  void _maybeResumeMomEvent002AfterLoad(String enteredRoom) {
    final norm = LocationsData.migrateLegacyRoomId(enteredRoom);
    final s = _worldState.momEvent002Step;
    if (s == 1 || s == 2 || s == 3) {
      if (!MomEvent002Pool.isLocationValidForActiveStep(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
      )) {
        return;
      }
      if (_momEvent002PresentationSyncedStep == s) return;
      if (s == 3) {
        _startMomEvent002PaymentStep();
      } else {
        _selectedNpcIdInRoom = s == 2 ? null : 'mom';
        _applyMomEvent002Patch(MomEvent002Pool.patchForPresentationStep(s));
      }
      return;
    }
    if (norm == LocationsData.kitchen &&
        MomEvent002Pool.canStartKitchenPayment(
          world: _worldState,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        )) {
      _startMomEvent002PaymentStep();
    }
  }

  void _startMomEvent002PaymentStep() {
    final mom = sl<NPCService>().npcById('mom');
    if (mom == null) return;
    final variant = MomEvent002Pool.payVariant(mom: mom, world: _worldState);
    _worldState.momEvent002Step = 3;
    _selectedNpcIdInRoom = 'mom';
    _momEvent002PresentationSyncedStep = null;
    _applyMomEvent002Patch(MomEvent002Pool.patchForPaymentStep(variant));
  }

  /// Після входу на кухню: навігація може перезаписати діалог назвою кімнати
  /// (addMinutes → _onTimeChanged стартує оплату раніше за setNewsMessage).
  void _ensureMomEvent002KitchenPaymentUiCoherent() {
    final norm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'HOME' || !isInsideRoom || norm != LocationsData.kitchen) {
      return;
    }
    if (MomEvent002Pool.canStartKitchenPayment(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      _startMomEvent002PaymentStep();
      return;
    }
    if (_worldState.momEvent002Step != 3) return;
    final mom = sl<NPCService>().npcById('mom');
    if (mom == null) return;
    final variant = MomEvent002Pool.payVariant(mom: mom, world: _worldState);
    _selectedNpcIdInRoom = 'mom';
    _applyMomEvent002Patch(MomEvent002Pool.patchForPaymentStep(variant));
  }

  void _momEvent002ApplyStep1Agree() {
    if (_worldState.momEvent002Step != 1) return;
    final dt = _timeController.dateTime;
    final weekday = _timeController.weekdayIndex;
    _worldState.momPoolEventActive = true;
    _worldState.momPoolEventSlotWeekday = weekday;
    _worldState.momPoolEventSlotWeekKey = MomEvent002Pool.weekKey(dt);
    _worldState.momEvent002Step = 0;
    _resetMomEvent002PresentationSession();
    newsMessage = sl<LocaleController>().t('mom_event_002_after_agree_news');
  }

  void _momEvent002ApplyStep1Refuse() {
    if (_worldState.momEvent002Step != 1) return;
    _worldState.momEvent002Step = 0;
    _resetMomEvent002PresentationSession();
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.kitchen);
  }

  void _momEvent002StartCleaning() {
    if (!MomEvent002Pool.canShowYardCleanButton(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _worldState.momEvent002Step = 2;
    _applyMomEvent002Patch(MomEvent002Pool.patchForPresentationStep(2));
  }

  void _momEvent002FinishCleaning() {
    if (_worldState.momEvent002Step != 2) return;
    _worldState.momPoolCleanPendingPay = true;
    _worldState.momPoolEventActive = false;
    _worldState.momEvent002Step = 0;
    _resetMomEvent002PresentationSession();
    newsMessage = sl<LocaleController>().t('mom_event_002_after_clean_news');
  }

  void _momEvent002ClosePaymentSlot({required String resultL10nKey}) {
    final dt = _timeController.dateTime;
    final weekday = _worldState.momPoolEventSlotWeekday >= 0
        ? _worldState.momPoolEventSlotWeekday
        : _timeController.weekdayIndex;
    final weekKey = _worldState.momPoolEventSlotWeekKey ??
        MomEvent002Pool.weekKey(dt);
    MomEvent002Pool.closeCurrentSlot(
      world: _worldState,
      weekdayIndex: weekday,
      weekKey: weekKey,
    );
    _resetMomEvent002PresentationSession();
    newsMessage = sl<LocaleController>().t(resultL10nKey);
  }

  void _momEvent002ApplyAutoCashPayment() {
    if (_worldState.momEvent002Step != 3) return;
    final mom = sl<NPCService>().npcById('mom');
    if (mom == null) return;
    MomEvent002Pool.applyCashPayment(
      mom: mom,
      world: _worldState,
      changePlayerMoney: _playerStats.changeMoney,
    );
    _momEvent002ClosePaymentSlot(
      resultL10nKey: MomEvent002Pool.resultPaidL10nKey,
    );
  }

  void _momEvent002ApplyChoiceCashPayment() {
    if (_worldState.momEvent002Step != 3) return;
    final mom = sl<NPCService>().npcById('mom');
    if (mom == null) return;
    if (mom.money < MomEvent002Pool.paymentAmount) {
      MomEvent002Pool.applyDebt(_worldState);
      _momEvent002ClosePaymentSlot(
        resultL10nKey: MomEvent002Pool.resultDebtL10nKey,
      );
      return;
    }
    MomEvent002Pool.applyCashPayment(
      mom: mom,
      world: _worldState,
      changePlayerMoney: _playerStats.changeMoney,
    );
    _momEvent002ClosePaymentSlot(
      resultL10nKey: MomEvent002Pool.resultPaidL10nKey,
    );
  }

  void _momEvent002ApplyDebtPayment() {
    if (_worldState.momEvent002Step != 3) return;
    MomEvent002Pool.applyDebt(_worldState);
    _momEvent002ClosePaymentSlot(
      resultL10nKey: MomEvent002Pool.resultDebtL10nKey,
    );
  }

  Widget? _momEvent002PriorityActionPanelIfAny() {
    final t = sl<LocaleController>().t;

    Widget column(List<Widget> children) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );

    if (MomEvent002Pool.canShowYardCleanButton(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return column([
        _navBtn(t('mom_event_002_btn_clean_pool').toUpperCase(), () {
          setState(() {
            _momEvent002StartCleaning();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (!_isMomEvent002ScriptedDialogActive()) return null;
    final s = _worldState.momEvent002Step;

    if (s == 1) {
      return column([
        _navBtn(t('mom_event_002_btn_agree').toUpperCase(), () {
          setState(() {
            _momEvent002ApplyStep1Agree();
          });
          _saveService.autosave();
        }),
        const SizedBox(height: 8),
        _navBtn(t('mom_event_002_btn_not_now').toUpperCase(), () {
          setState(() {
            _momEvent002ApplyStep1Refuse();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 2) {
      return column([
        _navBtn(t('mom_event_002_btn_finish').toUpperCase(), () {
          setState(() {
            _momEvent002FinishCleaning();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 3) {
      final mom = sl<NPCService>().npcById('mom');
      if (mom == null) return null;
      final variant =
          MomEvent002Pool.payVariant(mom: mom, world: _worldState);
      if (variant == MomEvent002PayVariant.choice) {
        return column([
          _navBtn(t('mom_event_002_btn_pay_50').toUpperCase(), () {
            setState(() {
              _momEvent002ApplyChoiceCashPayment();
            });
            _saveService.autosave();
          }),
          const SizedBox(height: 8),
          _navBtn(t('mom_event_002_btn_you_owe').toUpperCase(), () {
            setState(() {
              _momEvent002ApplyDebtPayment();
            });
            _saveService.autosave();
          }),
        ]);
      }
      if (variant == MomEvent002PayVariant.autoCash) {
        return column([
          _navBtn(t('mom_event_002_btn_leave').toUpperCase(), () {
            setState(() {
              _momEvent002ApplyAutoCashPayment();
            });
            _saveService.autosave();
          }),
        ]);
      }
      return column([
        _navBtn(t('mom_event_002_btn_leave').toUpperCase(), () {
          setState(() {
            _momEvent002ApplyDebtPayment();
          });
          _saveService.autosave();
        }),
      ]);
    }

    return null;
  }

  bool _canMomDeliverGroceriesToMom() {
    final npcService = sl<NPCService>();
    return MomGroceryDebt.canDeliverGroceriesToMom(
      npcService: npcService,
      mom: npcService.npcById('mom'),
      hour: _timeController.dateTime.hour,
      weekdayIndex: _timeController.weekdayIndex,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      groceryItemCount: _inventory.count(MomGroceryDebt.groceryItemId),
    );
  }

  void _momApplyGroceryDelivery() {
    if (!_canMomDeliverGroceriesToMom()) return;
    MomGroceryDebt.applyDelivery(world: _worldState);
    _inventory.removeItem(MomGroceryDebt.groceryItemId);
    newsMessage = sl<LocaleController>().t('mom_grocery_debt_news');
    _saveService.autosave();
  }
}
