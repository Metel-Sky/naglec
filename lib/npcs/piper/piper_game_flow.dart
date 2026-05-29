part of '../../screens/main_game_screen.dart';

mixin PiperGameFlow on MainGameScreenStateBase, MomGameFlow {
  int? _piperQuest001PresentationSyncedStep;
  String? _piperQuest001LastApproachDayKey;

  bool _isPiperQuest001SnitchAckScene() {
    if (!_worldState.piperQuest001SnitchAckPending) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) ==
        LocationsData.kitchen;
  }

  bool _isPiperQuest001SnitchOfferScene() {
    if (_isPiperQuest001SnitchAckScene()) return false;
    if (MomEvent002Pool.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return false;
    }
    final npcService = sl<NPCService>();
    return PiperQuest001.canSnitchToMomOnKitchen(
      world: _worldState,
      npcService: npcService,
      mom: npcService.npcById('mom'),
      hour: _timeController.dateTime.hour,
      weekdayIndex: _timeController.weekdayIndex,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  bool _isPiperQuest001ScriptedDialogActive() {
    if (_isPiperQuest001SnitchAckScene()) return true;
    if (!PiperQuest001.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      weekdayIndex: _timeController.weekdayIndex,
      hour: _timeController.dateTime.hour,
    )) {
      return false;
    }
    return true;
  }

  void _resetPiperQuest001PresentationSession() {
    _piperQuest001PresentationSyncedStep = null;
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

  void _applyPiperQuest001Patch(PiperQuest001Patch p) {
    _ui.clearEventSubState();
    final loc = sl<LocaleController>();
    newsMessage = _resolvePiperQuest001News(p.newsL10nKey, loc);
    if (p.imagePath != null) {
      _ui.setEventImagePath(p.imagePath);
    } else {
      _ui.setEventImagePath(null);
    }
    if (p.videoPath != null) {
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = false;
      _eventVideoLoop = false;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
    } else {
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
    }
    _piperQuest001PresentationSyncedStep = _worldState.piperQuest001Step;
  }

  String _resolvePiperQuest001News(String key, LocaleController loc) {
    final subject = loc.t(
      PiperQuest001.subjectL10nKey(_worldState.piperBadGradeSubject),
    );
    final teacher = loc.t(
      PiperQuest001.teacherNameL10nKey(_worldState.piperBadGradeTeacherId),
    );
    return loc
        .t(key)
        .replaceAll('{subject}', subject)
        .replaceAll('{teacher}', teacher);
  }

  void _syncPiperQuest001DailyIfNeeded() {
    final dt = _timeController.dateTime;
    final dk = PiperQuest001.dayKey(dt);
    if (_piperQuest001LastApproachDayKey != dk) {
      _piperQuest001LastApproachDayKey = dk;
      PiperQuest001.resetApproachSlotsForNewDay(_worldState);
      PiperQuest001.syncWorkdayCounterOnNewDay(
        world: _worldState,
        weekdayIndex: _timeController.weekdayIndex,
        currentDayKey: dk,
      );
    }
    final npcService = sl<NPCService>();
    PiperQuest001.maybeRollDailyBadGrade(
      world: _worldState,
      gameDate: dt,
      weekdayIndex: _timeController.weekdayIndex,
      hour: dt.hour,
      piper: npcService.npcById('piper'),
    );
    _tryStartPiperQuest001Step1IfNeeded(currentRoom);
  }

  bool _isPiperQuest001LibraryEavesdropScene() {
    if (_worldState.piperQuest001Step != 1) return false;
    if (currentZone != 'COLLEGE' || !isInsideRoom) return false;
    return LocationsData.migrateLegacyRoomId(currentRoom) ==
        LocationsData.canteen;
  }

  bool _isPiperQuest001Step2ApproachScene() {
    if (_worldState.piperQuest001Step != 2) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return PiperQuest001.isStep2ApproachRoom(currentRoom);
  }

  bool _isPiperQuest001Step3TeacherCallScene() {
    if (_worldState.piperQuest001Step != 3) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    final r = LocationsData.migrateLegacyRoomId(currentRoom);
    return r == LocationsData.kitchen || r == LocationsData.hall;
  }

  void _onPiperQuest001Step2VideoCompleted() {
    if (!mounted || _worldState.piperQuest001Step != 2) return;
    _worldState.piperQuest001Step2VideoSeen = true;
    setState(() {
      _clearPiperQuest001Step2VideoIfShowing();
    });
  }

  void _clearPiperQuest001Step2VideoIfShowing() {
    if (_eventVideoPath != PiperQuest001.quest001Step2Video) return;
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoMuted = false;
  }

  bool _shouldShowPiperQuest001Step2Video() {
    return _worldState.piperQuest001Step == 2 &&
        !_worldState.piperQuest001Step2VideoSeen &&
        _isPiperQuest001Step2ApproachScene();
  }

  void _syncPiperQuest001Step2VideoPresentation() {
    if (_shouldShowPiperQuest001Step2Video()) {
      if (_eventVideoPath == PiperQuest001.quest001Step2Video) return;
      _eventVideoPath = PiperQuest001.quest001Step2Video;
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoLoop = false;
      _eventVideoOnComplete = _onPiperQuest001Step2VideoCompleted;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      return;
    }
    _clearPiperQuest001Step2VideoIfShowing();
  }

  void _applyPiperQuest001Step2Patch() {
    _applyPiperQuest001Patch(PiperQuest001.patchForStep(2));
    _syncPiperQuest001Step2VideoPresentation();
  }

  void _applyPiperQuest001Step3Patch() {
    _applyPiperQuest001Patch(
      PiperQuest001.patchForStep3Phase(
        callOverheard: _worldState.piperQuest001Step3CallOverheard,
      ),
    );
  }

  void _applyPiperQuest001Step4Patch() {
    _applyPiperQuest001Patch(
      PiperQuest001.patchForStep4Phase(
        scoldingOverheard: _worldState.piperQuest001Step4ScoldingOverheard,
      ),
    );
  }

  bool _isPiperQuest001Step4CorridorScene() {
    if (_worldState.piperQuest001Step != 4) return false;
    return PiperQuest001.isStep4CorridorScene(
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  /// Після входу в коридор: навігація може перезаписати діалог назвою кімнати.
  void _ensurePiperQuest001Step4CorridorUiCoherent() {
    if (!_isPiperQuest001Step4CorridorScene()) return;
    _applyPiperQuest001Step4Patch();
  }

  /// Після входу на кухню/у зал: навігація може перезаписати діалог назвою кімнати.
  void _ensurePiperQuest001Step3TeacherCallUiCoherent() {
    if (!_isPiperQuest001Step3TeacherCallScene()) return;
    _applyPiperQuest001Step3Patch();
  }

  /// Крок 2: відео лише в [piper_room]; поза нею — закрити оверлей, step=2 лишається.
  void _ensurePiperQuest001Step2ApproachUiCoherent() {
    if (_worldState.piperQuest001Step != 2) {
      _clearPiperQuest001Step2VideoIfShowing();
      return;
    }
    if (_isPiperQuest001Step2ApproachScene()) {
      final loc = sl<LocaleController>();
      final expectedNews =
          _resolvePiperQuest001News('piper_quest_001_step02_news', loc);
      if (newsMessage != expectedNews) {
        newsMessage = expectedNews;
      }
    }
    _syncPiperQuest001Step2VideoPresentation();
  }

  /// Крок 5: відновити діалог/відео покарання після навігації.
  void _ensurePiperQuest001Step5PunishmentUiCoherent() {
    if (_worldState.piperQuest001Step != 5) return;
    if (currentZone != 'HOME' || !isInsideRoom) return;
    if (_worldState.piperGgPunishmentThisCrisis &&
        !PiperQuest001.isGgPunishmentSceneActive(
          world: _worldState,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        )) {
      return;
    }
    _applyPiperQuest001Step5Patch();
  }

  bool _isPiperQuest001Step5Scene() {
    if (_worldState.piperQuest001Step != 5) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (_worldState.piperGgPunishmentThisCrisis) {
      return PiperQuest001.isGgPunishmentSceneActive(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
      );
    }
    return true;
  }

  void _clearPiperQuest001Step5VideoIfShowing() {
    final paths = {
      ...PiperQuest001.quest001PunishmentVideos,
      ...PiperQuest001.quest001GgPunishmentVideos,
    };
    if (_eventVideoPath == null || !paths.contains(_eventVideoPath)) return;
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoMuted = false;
  }

  void _syncPiperQuest001Step5VideoPresentation(PiperQuest001Patch patch) {
    final video = patch.videoPath;
    if (video == null) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (_worldState.piperGgPunishmentThisCrisis &&
        !PiperQuest001.isStep5PunishmentRoom(currentRoom)) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (!_worldState.piperGgPunishmentThisCrisis &&
        PiperQuest001.punishmentLevelFromCrisisN(
              _worldState.piperPunishmentCrisisN,
            ) >=
            3 &&
        !PiperQuest001.isStep5PunishmentRoom(currentRoom)) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (_eventVideoPath == video) return;
    _eventVideoPath = video;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = false;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
  }

  void _applyPiperQuest001Step5Patch() {
    _ui.clearEventSubState();
    final patch = PiperQuest001.patchForStep5(
      _worldState,
      _worldState.piperPunishmentCrisisN,
    );
    final loc = sl<LocaleController>();
    newsMessage = _resolvePiperQuest001News(patch.newsL10nKey, loc);
    if (patch.imagePath != null) {
      _ui.setEventImagePath(patch.imagePath);
    } else {
      _ui.setEventImagePath(null);
    }
    _syncPiperQuest001Step5VideoPresentation(patch);
    _piperQuest001PresentationSyncedStep = 5;
  }

  void _tryStartPiperQuest001Step1IfNeeded(String enteredRoom) {
    if (_worldState.piperQuest001Step >= 2) return;
    final inLibraryEavesdrop = _worldState.piperQuest001Step == 1 &&
        currentZone == 'COLLEGE' &&
        isInsideRoom &&
        LocationsData.migrateLegacyRoomId(enteredRoom) ==
            LocationsData.canteen;
    final canStart = PiperQuest001.canAutoStartStep1LibraryScene(
      world: _worldState,
      weekdayIndex: _timeController.weekdayIndex,
      hour: _timeController.dateTime.hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: enteredRoom,
    );
    if (!canStart && !inLibraryEavesdrop) return;
    if (_worldState.piperQuest001Step != 1) {
      _worldState.piperQuest001Step = 1;
      _piperQuest001PresentationSyncedStep = null;
    }
    _applyPiperQuest001Patch(PiperQuest001.patchForStep(1));
  }

  /// Після входу в бібліотеку: навігація може перезаписати діалог назвою кімнати
  /// (addMinutes → _onTimeChanged стартує крок 1 раніше за setNewsMessage).
  void _ensurePiperQuest001LibraryDialogUiCoherent() {
    if (currentZone != 'COLLEGE' || !isInsideRoom) return;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.canteen) {
      return;
    }
    if (_worldState.piperQuest001Step == 1) {
      _applyPiperQuest001Patch(PiperQuest001.patchForStep(1));
      return;
    }
    _tryStartPiperQuest001Step1IfNeeded(currentRoom);
  }

  void _tryStartPiperQuest001Step2IfNeeded() {
    if (_worldState.piperQuest001Step >= 2) return;
    final npcService = sl<NPCService>();
    final hour = _timeController.dateTime.hour;
    final weekday = _timeController.weekdayIndex;
    if (!PiperQuest001.canStartStep2Approach(
      world: _worldState,
      npcService: npcService,
      piper: npcService.npcById('piper'),
      weekdayIndex: weekday,
      hour: hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    PiperQuest001.markApproachSlotDone(_worldState, weekday, hour);
    _worldState.piperQuest001Step = 2;
    _worldState.piperHelpRequested = true;
    _worldState.piperQuest001Step2VideoSeen = false;
    _selectedNpcIdInRoom = 'piper';
    _piperQuest001PresentationSyncedStep = null;
    _applyPiperQuest001Step2Patch();
  }

  void _tryStartPiperQuest001Step3IfNeeded() {
    if (_worldState.piperQuest001Step >= 3) return;
    if (!PiperQuest001.canStartStep3TeacherCall(
      world: _worldState,
      gameDate: _timeController.dateTime,
      hour: _timeController.dateTime.hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _worldState.piperQuest001Step = 3;
    _worldState.piperQuest001Step3CallOverheard = false;
    _worldState.teacherCalledMom = true;
    _worldState.piperMomTalkingAboutGrades = true;
    _worldState.teacherDealHookOpen = true;
    PiperQuest001.markStep4AvailableAfterMomKnows(
      _worldState,
      _timeController.dateTime,
      _timeController.dateTime.hour,
    );
    _piperQuest001PresentationSyncedStep = null;
    _applyPiperQuest001Patch(PiperQuest001.step3IntroPatch);
  }

  void _tryStartPiperQuest001Step4IfNeeded() {
    if (_worldState.piperQuest001Step >= 4) return;
    final dt = _timeController.dateTime;
    if (!PiperQuest001.canStartStep4MomScolds(
      world: _worldState,
      gameDate: dt,
      hour: dt.hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _worldState.piperQuest001Step = 4;
    _worldState.piperQuest001Step4ScoldingOverheard = false;
    _worldState.piperPunishmentPending = true;
    _piperQuest001PresentationSyncedStep = null;
    _applyPiperQuest001Patch(PiperQuest001.step4IntroPatch);
  }

  void _tryStartPiperQuest001Step5IfNeeded() {
    if (_worldState.piperQuest001Step >= 5) return;
    if (!PiperQuest001.canStartStep5Punishment(world: _worldState)) return;
    _worldState.piperPunishmentCrisisN++;
    final level = PiperQuest001.punishmentLevelFromCrisisN(
      _worldState.piperPunishmentCrisisN,
    );
    _worldState.piperQuest001Step = 5;
    _worldState.piperNoPhone = level >= 1;
    _worldState.piperUnderPunishment = true;
    _worldState.piperPunishmentPending = false;
    _piperQuest001PresentationSyncedStep = null;
    if (_worldState.piperGgPunishmentThisCrisis &&
        level >= 3 &&
        PiperQuest001.isStep5PunishmentRoom(currentRoom)) {
      _selectedNpcIdInRoom = 'piper';
    }
    _applyPiperQuest001Step5Patch();
  }

  void _maybeResumePiperQuest001AfterLoad() {
    final s = _worldState.piperQuest001Step;
    if (s <= 0) return;
    if (_piperQuest001PresentationSyncedStep == s) return;
    if (s == 5) {
      _applyPiperQuest001Step5Patch();
    } else if (s == 2) {
      _applyPiperQuest001Step2Patch();
    } else if (s == 3) {
      _applyPiperQuest001Step3Patch();
    } else if (s == 4) {
      _applyPiperQuest001Step4Patch();
    } else {
      _applyPiperQuest001Patch(PiperQuest001.patchForStep(s));
    }
    if (s == 2) _selectedNpcIdInRoom = 'piper';
  }

  void _piperQuest001FinishStep1() {
    if (_worldState.piperQuest001Step != 1) return;
    _worldState.piperGradeSecretKnown = true;
    _worldState.piperQuest001Step = 0;
    _resetPiperQuest001PresentationSession();
    newsMessage = sl<LocaleController>().t('piper_quest_001_step01_after_news');
  }

  void _piperQuest001ApplyHomeworkHelp() {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    if (piper != null) {
      PiperQuest001.applyRelationshipDelta(piper, 15);
      piper.changeBehavior(1);
    }
    _worldState.piperCrisisResolved = true;
    _worldState.piperDebtType = 'homework_and_clean_gg_room';
    PiperQuest001.closeCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = sl<LocaleController>().t('piper_quest_001_step06_success_news');
    _saveService.autosave();
  }

  void _piperQuest001ApplyCoverForMoney() {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    if (_playerStats.money < PiperQuest001.coverPaymentAmount) {
      _piperQuest001SnitchToMom(auto: true);
      return;
    }
    _playerStats.changeMoney(-PiperQuest001.coverPaymentAmount);
    if (piper != null) {
      PiperQuest001.applyRelationshipDelta(piper, 10);
      piper.changeBehavior(3);
    }
    _worldState.piperCrisisResolved = true;
    _worldState.piperDebtType = 'cover_for_20';
    PiperQuest001.closeCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = sl<LocaleController>().t('piper_quest_001_step06_success_news');
    _saveService.autosave();
  }

  void _piperQuest001ApplyRefuseHelp() {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    if (piper != null) {
      PiperQuest001.applyRelationshipDelta(piper, -15);
    }
    _worldState.piperQuest001Step = 0;
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  void _piperQuest001RequestGgCommandPiperFromMom() {
    PiperQuest001.applyGgCommandsPiperInsteadOfMom(_worldState);
    newsMessage = sl<LocaleController>().t(
      'piper_quest_001_step7a_mom_grants_news',
    );
    _saveService.autosave();
  }

  void _piperQuest001TellPiperAboutGgPunishment() {
    PiperQuest001.applyGgPunishmentAnnouncedToPiper(_worldState);
    newsMessage = sl<LocaleController>().t(
      'piper_quest_001_step7b_tell_piper_news',
    );
    if (_worldState.piperQuest001Step == 5) {
      _applyPiperQuest001Step5Patch();
    }
    _saveService.autosave();
  }

  void _piperQuest001SnitchToMom({required bool auto}) {
    final piper = sl<NPCService>().npcById('piper');
    if (piper != null) {
      PiperQuest001.applyRelationshipDelta(piper, -15);
      piper.changeBehavior(-5);
    }
    _worldState.piperSnitchedToMom = true;
    _worldState.piperMomTalkingAboutGrades = true;
    PiperQuest001.markStep4AvailableAfterMomKnows(
      _worldState,
      _timeController.dateTime,
      _timeController.dateTime.hour,
    );
    _worldState.piperQuest001Step = 0;
    _worldState.piperQuest001SnitchAckPending = true;
    _resetPiperQuest001PresentationSession();
    newsMessage = auto
        ? sl<LocaleController>().t('piper_quest_001_snitch_auto_news')
        : sl<LocaleController>().t('piper_quest_001_snitch_news');
    _saveService.autosave();
  }

  void _piperQuest001DismissSnitchAck() {
    _worldState.piperQuest001SnitchAckPending = false;
    if (_isMomEvent002ScriptedDialogActive()) {
      _momEvent002PresentationSyncedStep = null;
      _applyMomEvent002Patch(
        MomEvent002Pool.patchForPresentationStep(_worldState.momEvent002Step),
      );
    } else {
      newsMessage = LocationsData.getLocationDisplayName(
        LocationsData.kitchen,
      );
    }
  }

  void _ensurePiperQuest001SnitchAckUiCoherent() {
    if (!_worldState.piperQuest001SnitchAckPending) return;
    if (_isPiperQuest001SnitchAckScene()) return;
    _worldState.piperQuest001SnitchAckPending = false;
  }

  void _piperQuest001FinishStep3() {
    if (_worldState.piperQuest001Step != 3) return;
    _worldState.piperQuest001Step = 0;
    _worldState.piperQuest001Step3CallOverheard = false;
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
  }

  void _piperQuest001FinishStep4() {
    if (_worldState.piperQuest001Step != 4) return;
    _worldState.piperQuest001Step = 0;
    _worldState.piperQuest001Step4ScoldingOverheard = false;
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(LocationsData.corridor);
    _tryStartPiperQuest001Step5IfNeeded();
  }

  void _piperQuest001FinishStep5() {
    if (_worldState.piperQuest001Step != 5) return;
    PiperQuest001.closeCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = sl<LocaleController>().t('piper_quest_001_step06_after_punish_news');
    _saveService.autosave();
  }

  Widget? _piperQuest001SnitchAckActionPanelIfAny() {
    if (!_isPiperQuest001SnitchAckScene()) return null;
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
            setState(() {
              _piperQuest001DismissSnitchAck();
            });
            _saveService.autosave();
          }),
        ],
      ),
    );
  }

  Widget? _piperQuest001PriorityActionPanelIfAny() {
    final t = sl<LocaleController>().t;
    final loc = sl<LocaleController>();

    Widget column(List<Widget> children) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );

    if (!_isPiperQuest001ScriptedDialogActive()) return null;
    final s = _worldState.piperQuest001Step;

    if (s == 1) {
      return column([
        _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep1();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 2) {
      return column([
        _navBtn(t('piper_quest_001_btn_homework_help').toUpperCase(), () {
          setState(() {
            _piperQuest001ApplyHomeworkHelp();
          });
        }),
        const SizedBox(height: 8),
        _navBtn(t('piper_quest_001_btn_cover_20').toUpperCase(), () {
          setState(() {
            _piperQuest001ApplyCoverForMoney();
          });
        }),
        const SizedBox(height: 8),
        _navBtn(t('piper_quest_001_btn_refuse').toUpperCase(), () {
          setState(() {
            _piperQuest001ApplyRefuseHelp();
          });
        }),
      ]);
    }

    if (s == 3) {
      if (!_worldState.piperQuest001Step3CallOverheard) {
        return column([
          _navBtn(t('piper_quest_001_btn_eavesdrop_call').toUpperCase(), () {
            setState(() {
              _worldState.piperQuest001Step3CallOverheard = true;
              newsMessage = _resolvePiperQuest001News(
                'piper_quest_001_step03_news',
                loc,
              );
            });
            _saveService.autosave();
          }),
        ]);
      }
      return column([
        _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep3();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 4) {
      if (!_worldState.piperQuest001Step4ScoldingOverheard) {
        return column([
          _navBtn(t('piper_quest_001_btn_eavesdrop').toUpperCase(), () {
            setState(() {
              _worldState.piperQuest001Step4ScoldingOverheard = true;
              _applyPiperQuest001Step4Patch();
            });
            _saveService.autosave();
          }),
          const SizedBox(height: 8),
          _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
            setState(() {
              _piperQuest001FinishStep4();
            });
            _saveService.autosave();
          }),
        ]);
      }
      return column([
        _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep4();
          });
          _saveService.autosave();
        }),
      ]);
    }

    if (s == 5) {
      if (!_isPiperQuest001Step5Scene()) return null;
      return column([
        _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep5();
          });
        }),
      ]);
    }

    return null;
  }

  bool _isPiperHallWeekendEventScene() {
    return PiperHallWeekendEvents.isActiveScene(
      world: _worldState,
      npcService: sl<NPCService>(),
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      weekdayIndex: _timeController.weekdayIndex,
      hour: _timeController.dateTime.hour,
    );
  }

  bool _isPiperHallWeekendEventScriptedDialogActive() {
    return PiperHallWeekendEvents.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      weekdayIndex: _timeController.weekdayIndex,
      hour: _timeController.dateTime.hour,
      npcService: sl<NPCService>(),
    );
  }

  void _resetPiperHallWeekendEventPresentation() {
    _clearPiperHallWeekendEventVideoIfShowing();
    _ui.setEventImagePath(null);
  }

  void _applyPiperHallWeekendEventIntroPatch() {
    _ui.clearEventSubState();
    if (!_worldState.piperHallEventVideoSeen) return;
    final key = PiperHallWeekendEvents.introNewsL10nForVariant(
      _worldState.piperHallEventVariant,
    );
    newsMessage = sl<LocaleController>().t(key);
    _ui.setEventImagePath(null);
  }

  void _onPiperHallWeekendEventVideoCompleted() {
    if (!mounted || _worldState.piperHallEventStep != 1) return;
    _worldState.piperHallEventVideoSeen = true;
    setState(() {
      _clearPiperHallWeekendEventVideoIfShowing();
      _applyPiperHallWeekendEventIntroPatch();
    });
    _saveService.autosave();
  }

  void _clearPiperHallWeekendEventVideoIfShowing() {
    final path = _eventVideoPath;
    if (path == null || !PiperHallWeekendEvents.hallVideos.contains(path)) {
      return;
    }
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoMuted = false;
  }

  bool _shouldShowPiperHallWeekendEventVideo() {
    return _worldState.piperHallEventStep == 1 &&
        !_worldState.piperHallEventVideoSeen &&
        _isPiperHallWeekendEventScene();
  }

  void _syncPiperHallWeekendEventVideoPresentation() {
    if (_shouldShowPiperHallWeekendEventVideo()) {
      final path = PiperHallWeekendEvents.videoPathForVariant(
        _worldState.piperHallEventVariant,
      );
      if (_eventVideoPath == path &&
          _eventVideoOnComplete == _onPiperHallWeekendEventVideoCompleted) {
        return;
      }
      _eventVideoPath = path;
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoLoop = false;
      _eventVideoOnComplete = _onPiperHallWeekendEventVideoCompleted;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      return;
    }
    _clearPiperHallWeekendEventVideoIfShowing();
  }

  void _tryStartPiperHallWeekendEventIfNeeded(String room) {
    final norm = LocationsData.migrateLegacyRoomId(room);
    if (norm != LocationsData.hall) return;
    if (_worldState.piperHallEventStep != 0) return;

    final npcService = sl<NPCService>();
    final dt = _timeController.dateTime;
    if (!PiperHallWeekendEvents.canRollOnHallEnter(
      world: _worldState,
      npcService: npcService,
      weekdayIndex: _timeController.weekdayIndex,
      hour: dt.hour,
    )) {
      return;
    }

    final variant = PiperHallWeekendEvents.rollVariant();
    _worldState.piperHallEventStep = 1;
    _worldState.piperHallEventVariant = variant;
    _worldState.piperHallEventVideoSeen = false;
    _worldState.piperHallEventBranch = '';
    if (variant == PiperHallWeekendEvents.variantSmokes) {
      _worldState.piperSmokingSecretKnown = true;
    }
    _selectedNpcIdInRoom = 'piper';
    _clearPiperHallWeekendEventVideoIfShowing();
    _applyPiperHallWeekendEventIntroPatch();
    _syncPiperHallWeekendEventVideoPresentation();
    _saveService.autosave();
  }

  void _ensurePiperHallWeekendEventUiCoherent() {
    final step = _worldState.piperHallEventStep;
    if (step <= 0) return;
    if (step == 1 && !_isPiperHallWeekendEventScene()) {
      _clearPiperHallWeekendEventVideoIfShowing();
      return;
    }
    if (step == 1) {
      _syncPiperHallWeekendEventVideoPresentation();
      if (_worldState.piperHallEventVideoSeen) {
        _applyPiperHallWeekendEventIntroPatch();
      }
      return;
    }
    if (step == 2 &&
        PiperHallWeekendEvents.isHallRoom(
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        )) {
      final loc = sl<LocaleController>();
      newsMessage = loc.t(
        PiperHallWeekendEvents.branchNewsL10n(_worldState.piperHallEventBranch),
      );
    }
  }

  void _maybeResumePiperHallWeekendEventAfterLoad() {
    if (_worldState.piperHallEventStep <= 0) return;
    _ensurePiperHallWeekendEventUiCoherent();
  }

  void _piperHallWeekendEventApplySmokesBranch(String branch) {
    if (_worldState.piperHallEventStep != 1 ||
        !_worldState.piperHallEventVideoSeen ||
        _worldState.piperHallEventVariant !=
            PiperHallWeekendEvents.variantSmokes) {
      return;
    }
    _worldState.piperHallEventBranch = branch;
    _worldState.piperHallEventStep = 2;
    _resetPiperHallWeekendEventPresentation();
    newsMessage = sl<LocaleController>().t(
      PiperHallWeekendEvents.branchNewsL10n(branch),
    );
    _saveService.autosave();
  }

  void _piperHallWeekendEventFinish() {
    final step = _worldState.piperHallEventStep;
    if (step != 1 && step != 2) return;
    final variant = _worldState.piperHallEventVariant;
    PiperHallWeekendEvents.incrementCompletion(_worldState, variant);
    _worldState.piperHallEventStep = 0;
    _worldState.piperHallEventVariant = 0;
    _worldState.piperHallEventVideoSeen = false;
    _worldState.piperHallEventBranch = '';
    _resetPiperHallWeekendEventPresentation();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  Widget? _piperHallWeekendEventPriorityActionPanelIfAny() {
    if (!_isPiperHallWeekendEventScriptedDialogActive()) return null;

    if (_worldState.piperHallEventStep == 1 &&
        !_worldState.piperHallEventVideoSeen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: double.infinity,
        child: const SizedBox.shrink(),
      );
    }

    final t = sl<LocaleController>().t;
    final variant = _worldState.piperHallEventVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_worldState.piperHallEventStep == 1 &&
              PiperHallWeekendEvents.hasSmokesBranchMenu(variant)) ...[
            _navBtn(t('piper_event_001_btn_tell_mom').toUpperCase(), () {
              setState(() {
                _piperHallWeekendEventApplySmokesBranch(
                  PiperHallWeekendEvents.branchSnitch,
                );
              });
            }),
            const SizedBox(height: 8),
            _navBtn(t('piper_event_001_btn_blackmail').toUpperCase(), () {
              setState(() {
                _piperHallWeekendEventApplySmokesBranch(
                  PiperHallWeekendEvents.branchBlackmail,
                );
              });
            }),
            const SizedBox(height: 8),
            _navBtn(t('piper_event_001_btn_punish').toUpperCase(), () {
              setState(() {
                _piperHallWeekendEventApplySmokesBranch(
                  PiperHallWeekendEvents.branchPunish,
                );
              });
            }),
          ] else ...[
            _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
              setState(() {
                _piperHallWeekendEventFinish();
              });
            }),
          ],
        ],
      ),
    );
  }
}
