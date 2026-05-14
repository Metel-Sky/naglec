part of '../../screens/main_game_screen.dart';

/// Екранний флоу мами: **mom_quest_001** (пляж).
mixin MomGameFlow on MainGameScreenStateBase {
  bool _isMomQuest001ScriptedDialogActive() {
    if (!MomQuest001.isActiveMidFlow(_worldState)) return false;
    return currentZone == 'HOME';
  }

  void _resetMomQuest001PresentationSession() {
    _momQuest001PresentationSyncedStep = null;
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
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (p.imagePath != null) {
      _ui.setEventImagePath(p.imagePath);
    }
    if (p.videoPath != null) {
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = false;
      _eventVideoFullScreen = p.fullScreen;
      _eventVideoCloseWhenCompleted = p.closeWhenCompleted;
      _eventVideoLoop = p.loopVideo;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
    } else {
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoFullScreen = false;
      _eventVideoLoop = false;
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
}
