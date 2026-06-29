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
    PiperQuest001.resetStep5HarshPunishUi(_worldState);
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
    _eventVideoPlaybackRate = 1.0;
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
    // Відео квесту — через _syncPiperQuest001Step*VideoPresentation (loop ≥1 с перегляду).
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
    _piperQuest001PresentationSyncedStep = _worldState.piperQuest001Step;
  }

  static const Duration _piperQuest001MinVideoWatch = Duration(seconds: 1);

  void _presentPiperQuest001LoopingVideo({
    required String videoPath,
    VoidCallback? onMinWatchReached,
    Duration? minWatchDuration,
    bool clearVideoOnMinWatch = false,
  }) {
    if (_eventVideoPath == videoPath &&
        _eventVideoMinWatchDuration == minWatchDuration &&
        _eventVideoLoop &&
        !_eventVideoCloseWhenCompleted) {
      return;
    }
    _eventVideoPath = videoPath;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = true;
    _eventVideoOnComplete = null;
    _eventVideoMinWatchDuration = minWatchDuration;
    _eventVideoOnMinWatchReached = onMinWatchReached == null
        ? null
        : () {
            onMinWatchReached();
            if (clearVideoOnMinWatch && mounted) {
              setState(() {
                if (_eventVideoPath == videoPath) {
                  _eventVideoPath = null;
                  _eventVideoOnMinWatchReached = null;
                  _eventVideoMinWatchDuration = null;
                  _eventVideoFullScreen = false;
                  _eventVideoLoop = false;
                }
              });
            }
          };
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
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

  void _clearPiperQuest001Step2VideoIfShowing() {
    if (_eventVideoPath != PiperQuest001.quest001Step2Video) return;
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
  }

  bool _shouldShowPiperQuest001Step2Video() {
    return _worldState.piperQuest001Step == 2 &&
        _isPiperQuest001Step2ApproachScene();
  }

  void _syncPiperQuest001Step2VideoPresentation() {
    if (_shouldShowPiperQuest001Step2Video()) {
      _presentPiperQuest001LoopingVideo(
        videoPath: PiperQuest001.quest001Step2Video,
      );
      return;
    }
    _clearPiperQuest001Step2VideoIfShowing();
  }

  void _applyPiperQuest001Step2Patch() {
    final loc = sl<LocaleController>();
    newsMessage = _resolvePiperQuest001News(
      PiperQuest001.step2NewsL10nKey(_worldState),
      loc,
    );
    _ui.setEventImagePath(null);
    _syncPiperQuest001Step2VideoPresentation();
    _piperQuest001PresentationSyncedStep = 2;
  }

  void _applyPiperQuest001Step3Patch() {
    _applyPiperQuest001Patch(
      PiperQuest001.patchForStep3Phase(
        callOverheard: _worldState.piperQuest001Step3CallOverheard,
      ),
    );
    _syncPiperQuest001Step3VideoPresentation();
  }

  void _onPiperQuest001Step3VideoMinWatchReached() {
    if (!mounted || _worldState.piperQuest001Step != 3) return;
    if (_worldState.piperQuest001Step3VideoSeen) return;
    _worldState.piperQuest001Step3VideoSeen = true;
    setState(() {});
    _saveService.autosave();
  }

  void _clearPiperQuest001Step3VideoIfShowing() {
    if (_eventVideoPath != PiperQuest001.quest001TeacherCallVideo) return;
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
  }

  bool _shouldShowPiperQuest001Step3Video() {
    return _worldState.piperQuest001Step == 3 &&
        !_worldState.piperQuest001Step3CallOverheard &&
        _isPiperQuest001Step3TeacherCallScene();
  }

  void _syncPiperQuest001Step3VideoPresentation() {
    if (_shouldShowPiperQuest001Step3Video()) {
      _presentPiperQuest001LoopingVideo(
        videoPath: PiperQuest001.quest001TeacherCallVideo,
        minWatchDuration: _piperQuest001MinVideoWatch,
        onMinWatchReached: _onPiperQuest001Step3VideoMinWatchReached,
      );
      return;
    }
    _clearPiperQuest001Step3VideoIfShowing();
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

  /// Крок 2: сцена лише в [piper_room] або [room_gg]; поза ними — закрити оверлей, step=2 лишається.
  void _ensurePiperQuest001Step2ApproachUiCoherent() {
    if (_worldState.piperQuest001Step != 2) {
      _clearPiperQuest001Step2VideoIfShowing();
      PiperQuest001.resetStep2GgDealSubmenu(_worldState);
      return;
    }
    if (_isPiperQuest001Step2ApproachScene()) {
      final loc = sl<LocaleController>();
      final expectedNews = _resolvePiperQuest001News(
        PiperQuest001.step2NewsL10nKey(_worldState),
        loc,
      );
      if (newsMessage != expectedNews) {
        newsMessage = expectedNews;
      }
    }
    _syncPiperQuest001Step2VideoPresentation();
  }

  void _ensurePiperQuest001Step5PunishmentUiCoherent() {
    if (_worldState.piperQuest001Step != 5) {
      if (!_isPiperGgPunishVideoActive()) {
        _clearPiperQuest001Step5VideoIfShowing();
      }
      return;
    }
    if (PiperQuest001.ggPunishesInsteadOfMom(_worldState) &&
        (currentZone != 'HOME' ||
            !isInsideRoom ||
            !PiperQuest001.isGgPunishmentSceneActive(
              world: _worldState,
              currentZone: currentZone,
              isInsideRoom: isInsideRoom,
              currentRoom: currentRoom,
            ))) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (currentZone != 'HOME' || !isInsideRoom) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (!PiperQuest001.isStep5PunishmentRoom(currentRoom)) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (_isPiperGgHarshPunishSceneActive()) return;
    _applyPiperQuest001Step5Patch();
  }

  bool _isPiperQuest001Step5Scene() {
    if (_worldState.piperQuest001Step != 5) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (PiperQuest001.ggPunishesInsteadOfMom(_worldState)) {
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
      PiperQuest001.ggVoluntaryPunishVideo,
      PiperQuest001.ggVoluntaryPunishVideoHighBond,
      PiperQuest001.ggVoluntaryPunishVideo3,
      PiperQuest001.ggVoluntaryPunishVideo4,
      PiperQuest001.ggVoluntaryPunishVideo5Sex,
      PiperQuest001.ggHarshPunishSexCowgirlVideo,
      PiperQuest001.ggHarshPunishSexDoggyVideo,
      PiperQuest001.ggVoluntaryPunishVideo5Finish,
      PiperQuest001.ggHarshPunishFinishOnAssVideo,
    };
    if (_eventVideoPath == null || !paths.contains(_eventVideoPath)) return;
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
  }

  void _onPiperQuest001Step5VideoMinWatchReached() {
    if (!mounted || _worldState.piperQuest001Step != 5) return;
    _worldState.piperQuest001Step5VideoSeen = true;
    _saveService.autosave();
  }

  bool _shouldShowPiperQuest001Step5GgSpankVideo() {
    if (_worldState.piperQuest001Step != 5) return false;
    if (!PiperQuest001.ggPunishesInsteadOfMom(_worldState)) return false;
    if (_worldState.piperQuest001Step5VideoSeen) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return PiperQuest001.isGgPunishmentSceneActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  void _syncPiperQuest001Step5GgSpankPresentation() {
    if (_isPiperGgHarshPunishSceneActive()) return;
    if (_worldState.piperQuest001HarshPunishActive) return;
    if (_shouldShowPiperQuest001Step5GgSpankVideo()) {
      _startPiperGgPunishVideo(clearNewsMessage: false);
      return;
    }
    if (_isPiperGgVoluntaryPunishVideoActive() &&
        _worldState.piperQuest001Step == 5) {
      _clearPiperGgPunishVideoIfShowing();
    }
  }

  bool _shouldShowPiperQuest001Step5Video(PiperQuest001Patch patch) {
    final video = patch.videoPath;
    if (video == null || video.isEmpty) return false;
    if (_worldState.piperQuest001Step != 5) return false;
    if (_worldState.piperQuest001Step5VideoSeen) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    if (PiperQuest001.ggPunishesInsteadOfMom(_worldState)) return false;
    return PiperQuest001.isStep5PunishmentRoom(currentRoom);
  }

  void _syncPiperQuest001Step5VideoPresentation(PiperQuest001Patch patch) {
    if (PiperQuest001.ggPunishesInsteadOfMom(_worldState)) {
      _syncPiperQuest001Step5GgSpankPresentation();
      return;
    }

    final video = patch.videoPath;
    if (video == null) {
      _clearPiperQuest001Step5VideoIfShowing();
      return;
    }
    if (_shouldShowPiperQuest001Step5Video(patch)) {
      _presentPiperQuest001LoopingVideo(
        videoPath: video,
        minWatchDuration: _piperQuest001MinVideoWatch,
        onMinWatchReached: _onPiperQuest001Step5VideoMinWatchReached,
        clearVideoOnMinWatch: false,
      );
      return;
    }
    final punishmentPaths = {...PiperQuest001.quest001PunishmentVideos};
    if (_worldState.piperQuest001Step == 5 &&
        _eventVideoPath != null &&
        punishmentPaths.contains(_eventVideoPath) &&
        _shouldShowPiperQuest001Step5Video(patch)) {
      return;
    }
    _clearPiperQuest001Step5VideoIfShowing();
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

  void _ensurePiperQuest001Step6ClosureUiCoherent() {
    if (_worldState.piperQuest001Step != 6) return;
    if (PiperQuest001.isStep2GgDealRevealPending(_worldState)) return;
    // Крок 6 — пасивне очікування; не тримати квестовий текст поза сценою покарання.
  }

  bool _isPiperQuest001Step6Scene() {
    if (_worldState.piperQuest001Step != 6) return false;
    if (currentZone != 'HOME' || !isInsideRoom) return false;
    return true;
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
    PiperQuest001.resetStep2GgDealSubmenu(_worldState);
    _selectedNpcIdInRoom = 'piper';
    _piperQuest001PresentationSyncedStep = null;
    _applyPiperQuest001Step2Patch();
  }

  void _tryStartPiperQuest001Step3IfNeeded() {
    final dt = _timeController.dateTime;
    final hour = dt.hour;
    if (PiperQuest001.isMomExcludedFromQuestChain(_worldState)) {
      PiperQuest001.clearMomChainStateForGgPunisher(_worldState);
      if (PiperQuest001.canScheduleGgPunishmentSkippingMomChain(
        world: _worldState,
        gameDate: dt,
        hour: hour,
      )) {
        PiperQuest001.markGgPunishmentPendingSkippingMomChain(_worldState);
        _tryStartPiperQuest001Step5IfNeeded();
      }
      return;
    }
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
    _worldState.piperQuest001Step3VideoSeen = false;
    _worldState.teacherCalledMom = true;
    _worldState.piperMomTalkingAboutGrades = true;
    _worldState.teacherDealHookOpen = true;
    PiperQuest001.markStep4AvailableAfterMomKnows(
      _worldState,
      _timeController.dateTime,
      _timeController.dateTime.hour,
    );
    _piperQuest001PresentationSyncedStep = null;
    _applyPiperQuest001Step3Patch();
  }

  void _tryStartPiperQuest001Step4IfNeeded() {
    if (_worldState.piperQuest001Step >= 4) return;
    if (PiperQuest001.isMomExcludedFromQuestChain(_worldState)) return;
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
    if (!PiperQuest001.isStep5PunishmentRoom(currentRoom)) return;
    _worldState.piperPunishmentCrisisN++;
    final level = PiperQuest001.punishmentLevelFromCrisisN(
      _worldState.piperPunishmentCrisisN,
    );
    _worldState.piperQuest001Step = 5;
    _worldState.piperNoPhone = level >= 1;
    _worldState.piperUnderPunishment = true;
    _worldState.piperPunishmentPending = false;
    _piperQuest001PresentationSyncedStep = null;
    _worldState.piperQuest001Step5VideoSeen = false;
    if (_worldState.piperGgPunishmentThisCrisis &&
        PiperQuest001.ggPunishesInsteadOfMom(_worldState) &&
        level >= 3 &&
        PiperQuest001.isStep5PunishmentRoom(currentRoom)) {
      _selectedNpcIdInRoom = 'piper';
    }
    _applyPiperQuest001Step5Patch();
  }

  void _maybeResumePiperQuest001AfterLoad() {
    if (PiperQuest001.isMomExcludedFromQuestChain(_worldState)) {
      PiperQuest001.clearMomChainStateForGgPunisher(_worldState);
    }
    if (PiperQuest001.isStep2GgDealRevealPending(_worldState)) {
      _restorePiperQuest001GgDealRevealPresentation();
      _piperQuest001PresentationSyncedStep = 6;
      return;
    }
    final s = _worldState.piperQuest001Step;
    if (s <= 0) return;
    if (_piperQuest001PresentationSyncedStep == s) return;
    if (s == 5) {
      if (PiperQuest001.isStep5PunishmentRoom(currentRoom)) {
        _applyPiperQuest001Step5Patch();
      }
    } else if (s == 2) {
      _applyPiperQuest001Step2Patch();
    } else if (s == 3) {
      _applyPiperQuest001Step3Patch();
    } else if (s == 4) {
      _applyPiperQuest001Step4Patch();
    } else if (s == 6) {
      _ensurePiperQuest001Step6ClosureUiCoherent();
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

  void _piperQuest001LeaveStep2() {
    if (_worldState.piperQuest001Step != 2) return;
    _worldState.piperQuest001Step = 0;
    PiperQuest001.resetStep2GgDealSubmenu(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  void _piperQuest001OpenStep2GgDealSubmenu() {
    if (_worldState.piperQuest001Step != 2) return;
    _worldState.piperQuest001Step2GgDealSubmenu = true;
    newsMessage = sl<LocaleController>().t('piper_quest_001_step02_gg_deal_news');
  }

  void _piperQuest001CloseStep2GgDealSubmenu() {
    if (_worldState.piperQuest001Step != 2) return;
    PiperQuest001.resetStep2GgDealSubmenu(_worldState);
    final loc = sl<LocaleController>();
    newsMessage = _resolvePiperQuest001News(
      PiperQuest001.step2NewsL10nKey(_worldState),
      loc,
    );
  }

  void _piperQuest001ApplyCover20NoPunishment() {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    if (_playerStats.money < PiperQuest001.coverPaymentAmount) {
      showInsufficientMoneyDialog(context);
      return;
    }
    _playerStats.changeMoney(-PiperQuest001.coverPaymentAmount);
    if (piper != null) {
      PiperQuest001.applyRelationshipDelta(piper, 10);
      piper.changeBehavior(2);
    }
    _worldState.piperCrisisResolved = true;
    _worldState.piperDebtType = PiperQuest001.debtTypeGgCoverNoPunish;
    PiperQuest001.resetStep2GgDealSubmenu(_worldState);
    PiperQuest001.closeCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = sl<LocaleController>().t('piper_quest_001_step06_success_news');
    _piperQuest001PresentationSyncedStep = 6;
    _saveService.autosave();
  }

  void _piperQuest001ApplyStep2GgDealBreasts() {
    _piperQuest001ApplyStep2GgDealReveal(kind: 'breasts');
  }

  void _piperQuest001ApplyStep2GgDealAss() {
    _piperQuest001ApplyStep2GgDealReveal(kind: 'ass');
  }

  void _piperQuest001ApplyStep2GgDealFullStrip() {
    _piperQuest001ApplyStep2GgDealReveal(kind: 'full');
  }

  void _piperQuest001ApplyStep2GgDealReveal({required String kind}) {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    final success = PiperQuest001.canGgDealRevealKind(piper, kind);

    _clearPiperQuest001Step2VideoIfShowing();
    _worldState.piperDebtType = PiperQuest001.debtTypeForGgDealRevealKind(kind);
    PiperQuest001.resetStep2GgDealSubmenu(_worldState);
    PiperQuest001.markStep2GgDealRevealPending(
      world: _worldState,
      kind: kind,
      success: success,
    );
    if (success) {
      PiperQuest001.applyGgDealRevealStatRewards(piper, kind, _worldState);
      if (kind == 'ass') {
        PiperQuest001.markGgDealAssShown(_worldState);
      } else if (kind == 'breasts') {
        PiperQuest001.markGgDealBreastsShown(_worldState);
      } else if (kind == 'full') {
        PiperQuest001.markGgDealAssShown(_worldState);
        PiperQuest001.markGgDealBreastsShown(_worldState);
      }
    } else {
      PiperQuest001.applyGgDealRevealRejectedPenalties(piper);
    }
    PiperQuest001.closeCrisisPass(_worldState);

    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;

    final imagePath = PiperQuest001.ggDealRevealImagePath(_worldState);
    _ui.setEventImagePath(null);
    if (imagePath != null) {
      newsMessage = '';
    } else {
      newsMessage = sl<LocaleController>().t(
        'piper_quest_001_step02_gg_deal_rejected_news',
      );
    }
    _piperQuest001PresentationSyncedStep = 6;
    _saveService.autosave();
  }

  void _restorePiperQuest001GgDealRevealPresentation() {
    if (!PiperQuest001.isStep2GgDealRevealPending(_worldState)) return;
    _ui.setEventImagePath(null);
    final imagePath = PiperQuest001.ggDealRevealImagePath(_worldState);
    if (imagePath != null) {
      newsMessage = '';
    } else {
      newsMessage = sl<LocaleController>().t(
        'piper_quest_001_step02_gg_deal_rejected_news',
      );
    }
  }

  void _piperQuest001FinishStep2GgDealReveal() {
    _dismissPiperGgDealRevealIfActive();
  }

  void _dismissPiperGgDealRevealIfActive() {
    if (!PiperQuest001.isStep2GgDealRevealPending(_worldState)) return;
    PiperQuest001.clearStep2GgDealReveal(_worldState);
    PiperQuest001.finishCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  bool _isPiperQuest001GgDealRevealOverlayActive() =>
      PiperQuest001.ggDealRevealImagePath(_worldState) != null;

  String? _piperQuest001GgDealRevealOverlayPath() =>
      PiperQuest001.ggDealRevealImagePath(_worldState);

  bool _isPiperQuest001GgDealRevealActive() =>
      PiperQuest001.isStep2GgDealRevealPending(_worldState);

  void _piperQuest001ApplyPunishFromStep2() {
    if (_worldState.piperQuest001Step != 2) return;
    if (!PiperQuest001.canGgPunishPiperDuringStep2Approach(_worldState)) return;
    _worldState.piperQuest001Step = 0;
    PiperQuest001.resetStep2GgDealSubmenu(_worldState);
    _resetPiperQuest001PresentationSession();
    _startPiperGgVoluntaryPunishFromStep2();
    _saveService.autosave();
  }

  void _clearPiperGgPunishVideoIfShowing() {
    if (!PiperQuest001.isGgPunishVideoPath(_eventVideoPath)) return;
    PiperQuest001.resetStep5HarshPunishUi(_worldState);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    _eventVideoMuted = false;
    _eventVideoPlaybackRate = 1.0;
  }

  void _startPiperGgPunishVideo({bool clearNewsMessage = true}) {
    if (currentZone != 'HOME' || !isInsideRoom) return;
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.piperRoom) {
      return;
    }
    if (_isPiperGgHarshPunishSceneActive()) return;
    if (_worldState.piperQuest001HarshPunishActive) return;
    final crisisN = _worldState.piperPunishmentCrisisN;
    final piper = sl<NPCService>().npcById('piper');
    final videoPath = _worldState.piperQuest001Step == 5 &&
            PiperQuest001.ggPunishesInsteadOfMom(_worldState)
        ? PiperQuest001.ggStep5SpankVideoFor(
            piper: piper,
            world: _worldState,
            crisisN: crisisN,
          )
        : PiperQuest001.ggVoluntaryPunishVideoFor(
            piper: piper,
            world: _worldState,
            crisisN: crisisN,
          );
    final ggPunishContext = PiperQuest001.ggPunishesInsteadOfMom(_worldState) ||
        _worldState.piperGgPunishmentAnnouncedToPiper;
    final offerHarsh = ggPunishContext &&
        videoPath == PiperQuest001.ggVoluntaryPunishVideo3 &&
        PiperQuest001.shouldShowHarshPunishButton(
          piper: piper,
          crisisN: crisisN,
        );
    if (_isPiperGgPunishVideoActive() && _eventVideoPath == videoPath) {
      return;
    }
    _worldState.piperQuest001HarshPunishActive = false;
    _worldState.piperQuest001Step5HarshOfferActive = offerHarsh;
    _eventVideoPath = videoPath;
    _eventVideoPlaybackRate = 1.0;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = false;
    _eventVideoOnComplete = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _ui.setEventImagePath(null);
    _selectedNpcIdInRoom = 'piper';
    if (_shouldShowGgPunishmentDialog()) {
      if (clearNewsMessage || _worldState.piperQuest001Step != 5) {
        newsMessage = sl<LocaleController>().t(
          PiperQuest001.ggPunishmentNewsL10nKey(_worldState),
        );
      }
    } else if (clearNewsMessage) {
      newsMessage = '';
    }
  }

  bool _shouldShowGgPunishmentDialog() =>
      PiperQuest001.ggPunishesInsteadOfMom(_worldState) ||
      _worldState.piperGgPunishmentAnnouncedToPiper;

  void _startPiperGgVoluntaryPunishFromStep2() {
    _startPiperGgPunishVideo();
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
    _piperQuest001PresentationSyncedStep = 6;
    _saveService.autosave();
  }

  void _piperQuest001ApplyCoverForMoney() {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    if (_playerStats.money < PiperQuest001.coverPaymentAmount) {
      if (PiperQuest001.isMomExcludedFromQuestChain(_worldState)) {
        _piperQuest001ApplyRefuseHelp();
        return;
      }
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
    _piperQuest001PresentationSyncedStep = 6;
    _saveService.autosave();
  }

  void _piperQuest001ApplyRefuseHelp() {
    if (_worldState.piperQuest001Step != 2) return;
    final piper = sl<NPCService>().npcById('piper');
    if (piper != null) {
      PiperQuest001.applyRelationshipDelta(piper, -15);
    }
    _worldState.piperQuest001Step = 0;
    if (PiperQuest001.isMomExcludedFromQuestChain(_worldState) &&
        _worldState.piperGgPunishmentThisCrisis) {
      PiperQuest001.markGgPunishmentPendingSkippingMomChain(_worldState);
    }
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  void _piperQuest001RequestGgCommandPiperFromMom() {
    PiperQuest001.applyGgCommandsPiperInsteadOfMom(_worldState);
    _resetPiperQuest001PresentationSession();
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
    _saveService.autosave();
  }

  bool _isPiperGgVoluntaryPunishVideoActive() {
    return PiperQuest001.isGgVoluntaryPunishVideoPath(_eventVideoPath);
  }

  bool _isPiperGgHarshPunishVideoActive() {
    return PiperQuest001.isGgHarshPunishVideoPath(_eventVideoPath);
  }

  bool _isPiperGgHarshPunishSpank4Active() {
    return PiperQuest001.isGgHarshPunishSpank4Path(_eventVideoPath);
  }

  bool _isPiperGgHarshPunishSexVideoActive() {
    return PiperQuest001.isGgHarshPunishSexVideoPath(_eventVideoPath);
  }

  bool _isPiperGgHarshPunishFinishVideoActive() {
    return PiperQuest001.isGgHarshPunishFinishVideoPath(_eventVideoPath);
  }

  bool _isPiperGgHarshPunishSceneActive() {
    return _isPiperGgHarshPunishVideoActive() ||
        _isPiperGgHarshPunishFinishVideoActive();
  }

  bool _isPiperGgPunishVideoActive() {
    return PiperQuest001.isGgPunishVideoPath(_eventVideoPath);
  }

  bool _isPiperQuest001HarshPunishOfferActive() =>
      _worldState.piperQuest001Step5HarshOfferActive &&
      _isPiperGgVoluntaryPunishVideoActive();

  bool _canShowPiperGgSpreadLegsButton() {
    if (!PiperQuest001.shouldShowSpreadLegsButton(
      world: _worldState,
      piper: sl<NPCService>().npcById('piper'),
    )) {
      return false;
    }
    if (_isPiperGgHarshPunishSpank4Active()) return true;
    if (_isPiperGgHarshPunishSexVideoActive()) {
      return _eventVideoPath != PiperQuest001.ggVoluntaryPunishVideo5Sex;
    }
    return false;
  }

  bool _canShowPiperGgHarshSexDoggyButton() {
    if (!_isPiperGgHarshPunishSexVideoActive()) return false;
    return _eventVideoPath != PiperQuest001.ggHarshPunishSexDoggyVideo;
  }

  bool _canShowPiperGgHarshSexCowgirlButton() {
    if (!_isPiperGgHarshPunishSexVideoActive()) return false;
    return _eventVideoPath != PiperQuest001.ggHarshPunishSexCowgirlVideo;
  }

  void _configurePiperHarshPunishVideo(String path, {double playbackRate = 1.0}) {
    _eventVideoPath = path;
    _eventVideoPlaybackRate = playbackRate;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = false;
    _eventVideoOnComplete = null;
    _eventVideoMinWatchDuration = null;
    _eventVideoOnMinWatchReached = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _ui.setEventImagePath(null);
    _selectedNpcIdInRoom = 'piper';
  }

  void _onPiperGgSpreadLegsPressed() {
    if (!_canShowPiperGgSpreadLegsButton()) return;
    final piper = sl<NPCService>().npcById('piper');
    if (!PiperQuest001.canUseSpreadLegsWithVezunchyk(
      world: _worldState,
      piper: piper,
    )) {
      PiperQuest001.applySpreadLegsRejectedPenalties(piper);
      newsMessage = sl<LocaleController>().t(
        'piper_quest_001_spread_legs_rejected_news',
      );
      _saveService.autosave();
      return;
    }
    if (!_worldState.piperQuest001HarshSpreadLegsSexCounted) {
      NpcSexStats.incrementSex(sl<NPCService>().npcById('piper'));
      _worldState.piperQuest001HarshSpreadLegsSexCounted = true;
    }
    if (_isPiperGgHarshPunishSpank4Active()) {
      _worldState.piperQuest001HarshPunishActive = true;
    }
    _configurePiperHarshPunishVideo(PiperQuest001.ggVoluntaryPunishVideo5Sex);
    newsMessage = sl<LocaleController>().t(
      'piper_quest_001_spread_legs_news',
    );
    _saveService.autosave();
  }

  void _onPiperGgHarshSexDoggyPressed() {
    if (!_canShowPiperGgHarshSexDoggyButton()) return;
    _configurePiperHarshPunishVideo(PiperQuest001.ggHarshPunishSexDoggyVideo);
    newsMessage = sl<LocaleController>().t(
      'piper_quest_001_harsh_sex_doggy_news',
    );
    _saveService.autosave();
  }

  void _onPiperGgHarshSexCowgirlPressed() {
    if (!_canShowPiperGgHarshSexCowgirlButton()) return;
    _configurePiperHarshPunishVideo(PiperQuest001.ggHarshPunishSexCowgirlVideo);
    newsMessage = sl<LocaleController>().t(
      'piper_quest_001_harsh_sex_cowgirl_news',
    );
    _saveService.autosave();
  }

  void _startPiperGgHarshPunish() {
    if (!_isPiperQuest001HarshPunishOfferActive()) return;
    final piper = sl<NPCService>().npcById('piper');
    final crisisN = _worldState.piperPunishmentCrisisN;
    if (!PiperQuest001.canUseHarshPunishWithVezunchyk(
      world: _worldState,
      piper: piper,
      crisisN: crisisN,
    )) {
      PiperQuest001.applyGgDealRevealRejectedPenalties(piper);
      _worldState.piperQuest001Step5HarshOfferActive = false;
      newsMessage = sl<LocaleController>().t(
        'piper_quest_001_step02_gg_deal_rejected_news',
      );
      _saveService.autosave();
      return;
    }
    _worldState.piperQuest001Step5HarshOfferActive = false;
    _worldState.piperQuest001HarshPunishActive = true;
    _worldState.piperQuest001HarshSpreadLegsSexCounted = false;
    NpcSexStats.incrementSosala(sl<NPCService>().npcById('piper'));
    _configurePiperHarshPunishVideo(PiperQuest001.ggVoluntaryPunishVideo4);
    newsMessage = '';
    _saveService.autosave();
  }

  void _finishPiperGgHarshPunish({
    String? finishVideoPath,
    double? finishPlaybackRate,
  }) {
    if (!_isPiperGgHarshPunishVideoActive()) return;
    final fromStep5 = _worldState.piperQuest001Step == 5;
    PiperQuest001.markGgVoluntaryPunishDoneThisCrisis(_worldState);
    PiperQuest001.applyGgHarshPunishStatRewards(
      sl<NPCService>().npcById('piper'),
      _worldState,
    );
    _playerStats.changeArousal(-_playerStats.arousal);
    if (fromStep5) {
      _worldState.piperQuest001Step5VideoSeen = true;
    }
    PiperQuest001.closeAndFinishCrisisPass(_worldState);
    _configurePiperHarshPunishVideo(
      finishVideoPath ?? PiperQuest001.ggVoluntaryPunishVideo5Finish,
      playbackRate:
          finishPlaybackRate ?? PiperQuest001.ggHarshPunishFinishPlaybackRate,
    );
    newsMessage = '';
    _saveService.autosave();
  }

  void _finishPiperGgHarshPunishOnAss() {
    if (!_isPiperGgHarshPunishSexVideoActive()) return;
    _finishPiperGgHarshPunish(
      finishVideoPath: PiperQuest001.ggHarshPunishFinishOnAssVideo,
      finishPlaybackRate: 1.0,
    );
  }

  void _leavePiperGgHarshPunish() {
    if (_isPiperGgHarshPunishFinishVideoActive()) {
      _dismissPiperGgPunishSceneOnly();
      return;
    }
    if (!_isPiperGgHarshPunishVideoActive()) return;
    _completePiperQuest001AfterPunish(
      markStep5VideoSeen: _worldState.piperQuest001Step == 5,
    );
  }

  bool _canShowPiperGgVoluntaryPunishButton() {
    final npcService = sl<NPCService>();
    return PiperQuest001.canShowGgVoluntaryPunishButton(
      world: _worldState,
      npcService: npcService,
      piper: npcService.npcById('piper'),
      hour: _timeController.dateTime.hour,
      weekdayIndex: _timeController.weekdayIndex,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  void _startPiperGgVoluntaryPunish() {
    _startPiperGgPunishVideo();
  }

  void _dismissPiperGgPunishSceneOnly() {
    _piperQuest001PresentationSyncedStep = null;
    PiperQuest001.resetStep5HarshPunishUi(_worldState);
    _clearPiperGgPunishVideoIfShowing();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  void _completePiperQuest001AfterPunish({bool markStep5VideoSeen = false}) {
    if (markStep5VideoSeen) {
      _worldState.piperQuest001Step5VideoSeen = true;
    }
    PiperQuest001.closeAndFinishCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    _clearPiperGgPunishVideoIfShowing();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
    _saveService.autosave();
  }

  void _finishPiperGgVoluntaryPunish() {
    if (!_isPiperGgVoluntaryPunishVideoActive()) return;
    final fromStep5 = _worldState.piperQuest001Step == 5;
    final videoPath = _eventVideoPath;
    _worldState.piperQuest001Step5HarshOfferActive = false;
    PiperQuest001.markGgVoluntaryPunishDoneThisCrisis(_worldState);
    PiperQuest001.applyGgVoluntaryPunishStatRewards(
      sl<NPCService>().npcById('piper'),
      videoPath ?? PiperQuest001.ggVoluntaryPunishVideo,
    );
    _playerStats.changeArousal(
      PiperQuest001.ggVoluntaryPunishGgArousalDelta.toDouble(),
    );
    _completePiperQuest001AfterPunish(markStep5VideoSeen: fromStep5);
  }

  void _ensurePiperGgVoluntaryPunishUiCoherent() {
    if (!_isPiperGgPunishVideoActive()) return;
    if (currentZone != 'HOME' ||
        !isInsideRoom ||
        LocationsData.migrateLegacyRoomId(currentRoom) !=
            LocationsData.piperRoom) {
      if (_worldState.piperQuest001Step == 5) {
        _clearPiperGgPunishVideoIfShowing();
        return;
      }
      if (_isPiperGgHarshPunishSceneActive()) {
        _leavePiperGgHarshPunish();
      } else {
        _finishPiperGgVoluntaryPunish();
      }
    }
  }

  void _piperQuest001SnitchToMom({required bool auto}) {
    if (PiperQuest001.isMomExcludedFromQuestChain(_worldState)) return;
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
    _completePiperQuest001AfterPunish(markStep5VideoSeen: true);
  }

  void _piperQuest001FinishStep6() {
    if (_worldState.piperQuest001Step != 6) return;
    PiperQuest001.finishCrisisPass(_worldState);
    _resetPiperQuest001PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
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

  Widget _piperQuest001VideoBlockingEmptyPanel() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: double.infinity,
        child: const SizedBox.shrink(),
      );

  /// Крок 3: відео дзвінка вчителю — «Підслухати» лише після ≥1 с перегляду.
  bool _isPiperQuest001Step3IntroVideoBlockingActions() {
    return _worldState.piperQuest001Step == 3 &&
        _isPiperQuest001Step3TeacherCallScene() &&
        !_worldState.piperQuest001Step3CallOverheard &&
        !_worldState.piperQuest001Step3VideoSeen;
  }

  Widget? _piperQuest001PriorityActionPanelIfAny() {
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

    if (!_isPiperQuest001ScriptedDialogActive()) return null;

    if (_isPiperQuest001GgDealRevealActive()) {
      return column([
        _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep2GgDealReveal();
          });
        }),
      ]);
    }

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
      if (PiperQuest001.usesGgPunisherStep2Buttons(_worldState)) {
        if (_worldState.piperQuest001Step2GgDealSubmenu) {
          final piper = sl<NPCService>().npcById('piper');
          return column([
            _navBtn(t('piper_quest_001_btn_deal_show_breasts').toUpperCase(), () {
              setState(() {
                _piperQuest001ApplyStep2GgDealBreasts();
              });
            }),
            const SizedBox(height: 8),
            _navBtn(t('piper_quest_001_btn_deal_show_ass').toUpperCase(), () {
              setState(() {
                _piperQuest001ApplyStep2GgDealAss();
              });
            }),
            if (PiperQuest001.isGgDealFullStripButtonVisible(piper)) ...[
              const SizedBox(height: 8),
              _navBtn(t('piper_quest_001_btn_deal_strip_full').toUpperCase(), () {
                setState(() {
                  _piperQuest001ApplyStep2GgDealFullStrip();
                });
              }),
            ],
            const SizedBox(height: 8),
            _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
              setState(() {
                _piperQuest001CloseStep2GgDealSubmenu();
              });
            }),
          ]);
        }
        return column([
          _navBtn(t('piper_quest_001_btn_gg_deal').toUpperCase(), () {
            setState(() {
              _piperQuest001OpenStep2GgDealSubmenu();
            });
          }),
          const SizedBox(height: 8),
          _navBtn(t('piper_quest_001_btn_cover_20_no_punish').toUpperCase(), () {
            setState(() {
              _piperQuest001ApplyCover20NoPunishment();
            });
          }),
          const SizedBox(height: 8),
          _navBtn(t('piper_quest_001_btn_punish').toUpperCase(), () {
            setState(() {
              _piperQuest001ApplyPunishFromStep2();
            });
          }),
          const SizedBox(height: 8),
          _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
            setState(() {
              _piperQuest001LeaveStep2();
            });
          }),
        ]);
      }
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
      if (_isPiperQuest001Step3IntroVideoBlockingActions()) {
        return _piperQuest001VideoBlockingEmptyPanel();
      }
      if (!_worldState.piperQuest001Step3CallOverheard) {
        return column([
          _navBtn(t('piper_quest_001_btn_eavesdrop_call').toUpperCase(), () {
            setState(() {
              _worldState.piperQuest001Step3CallOverheard = true;
              _applyPiperQuest001Step3Patch();
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
      if (_isPiperGgPunishVideoActive()) return null;
      return column([
        _navBtn(t('piper_quest_001_btn_leave').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep5();
          });
        }),
      ]);
    }

    if (s == 6) {
      if (!_isPiperQuest001Step6Scene()) return null;
      if (_isPiperQuest001GgDealRevealActive()) return null;
      return column([
        _navBtn(t('mom_quest_001_btn_back').toUpperCase(), () {
          setState(() {
            _piperQuest001FinishStep6();
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
