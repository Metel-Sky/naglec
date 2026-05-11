part of '../../screens/main_game_screen.dart';

/// Екранний флоу Чері: квести, івенти, офіс ТРЦ (дані — у `lib/npcs/cherie/`).
mixin CherieGameFlow on MainGameScreenStateBase implements NpcScreenFlow {
  @override
  String get npcScreenFlowId => NpcScreenFlowIds.cherie;

  bool _isCherieQuest002ScriptedDialogActive() {
    final npcService = sl<NPCService>();
    final d = _timeController.weekdayIndex;
    return CherieQuest002.shouldPresentQuest002ScriptedUi(
      world: _worldState,
      cherie: npcService.npcById('cherie'),
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      weekdayIndex: d,
    );
  }

  bool _isCherieQuest003ScriptedDialogActive() {
    final npcService = sl<NPCService>();
    return CherieQuest003.shouldPresentScriptedUi(
      world: _worldState,
      cherie: npcService.npcById('cherie'),
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  bool _isCherieQuest004ScriptedDialogActive() {
    if (!CherieQuest004.isActiveMidFlow(_worldState)) return false;
    return CherieQuest004.shouldPresentOfficeScriptedUi(
          world: _worldState,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        ) ||
        CherieQuest004.shouldPresentBedroomScriptedUi(
          world: _worldState,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        ) ||
        CherieQuest004.shouldPresentContractHallScriptedUi(
          world: _worldState,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        );
  }

  bool _isCherieQuest005ScriptedDialogActive() {
    return CherieQuest005.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  bool _isCherieQuest006ScriptedDialogActive() {
    return CherieQuest006.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  CherieQuest002StartPlayerGates _cherieQuest002StartPlayerGates() {
    final inv = sl<InventoryController>();
    return CherieQuest002StartPlayerGates(
      physicalFitness: _playerStats.physical_fitness,
      massageExperience: _playerStats.massage_experience,
      hasAromaOilItem: inv.count(CherieQuest002.aromaOilItemId) > 0,
    );
  }

  /// Незавершена зміна аніматором (робоче відео / «закінчити» / tc_2 / діалог до «Піти»).
  bool _isGiftShopAnimatorShiftFlowActive() {
    final introS = _worldState.cherieAnimatorIntroStep;
    if (introS >= 1 && introS <= 5) return true;
    return _worldState.giftShopAnimatorPendingFinishDateKey != null ||
        _ui.cherieAnimatorShiftTc2SequenceActive ||
        _ui.cherieAnimatorShiftTc2DialogPending ||
        (_eventVideoPath != null &&
            CherieEvents.isAnimatorShiftEventVideoPath(_eventVideoPath));
  }

  void _resetCherieOfficeAnimatorQuestSession({
    bool abortGiftShopAnimatorShift = false,
  }) {
    _ui.setCherieQuest001OfficePhase(CherieQuest001OfficePhase.inactive);
    _ui.clearCherieAnimatorShiftTc2Progress();
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    if (abortGiftShopAnimatorShift) {
      _worldState.giftShopAnimatorPendingFinishDateKey = null;
      if (_worldState.cherieAnimatorWorkVideoCount > 0) {
        _worldState.cherieAnimatorWorkVideoCount--;
      }
    }
    _worldState.cherieAnimatorIntroStep = 0;
    _worldState.cherieAnimatorIntroTc2SlotKeyStash = null;
    _worldState.cherieAnimatorIntroTc2TipsStash = null;
    _ui.setCherieAnimatorShiftRewardFromIntro(false);
  }

  /// Після завантаження сейву: відновити UI кроку 5 (tc_2 + нагорода зі stash).
  /// Відновлення сесії квесту 002 після завантаження сейву (UI не зберігається в сейві).
  void _maybeResumeCherieQuest002AfterLoad() {
    final cherie = sl<NPCService>().npcById('cherie');
    var s = _worldState.cherieQuest002Step;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (s == 0 &&
        currentZone == 'POOR_VILLAGE' &&
        isInsideRoom &&
        roomNorm == LocationsData.poorVillageGiftShopOwnerHall &&
        CherieQuest002.shouldResumeMassageStep8InHall(
          cherie: cherie,
          world: _worldState,
        )) {
      _worldState.cherieQuest002Step = 8;
      s = 8;
    }
    if (s < 1 || s > 9) return;
    if (s <= 4) {
      if (CherieQuest002.isComplete(cherie, _worldState)) return;
      if (currentZone != 'CITY' ||
          !isInsideRoom ||
          roomNorm != LocationsData.cityMallGiftShopOffice) {
        return;
      }
    } else {
      if (currentZone != 'POOR_VILLAGE' ||
          !isInsideRoom ||
          roomNorm != LocationsData.poorVillageGiftShopOwnerHall) {
        return;
      }
      if (CherieQuest002.isComplete(cherie, _worldState) &&
          CherieQuest002.massageLegsEpilogueDone(cherie)) {
        return;
      }
    }
    if (_cherieQuest002PresentationSyncedStep == s) return;
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest002OfficePatch(
      CherieQuest002.patchForPresentationStep(s, _worldState),
    );
  }

  void _maybeRestoreCherieAnimatorIntroStep5AfterLoad() {
    if (_worldState.cherieAnimatorIntroStep != 5) return;
    final slot = _worldState.cherieAnimatorIntroTc2SlotKeyStash;
    final tips = _worldState.cherieAnimatorIntroTc2TipsStash;
    if (slot == null || tips == null) {
      _worldState.cherieAnimatorIntroStep = 0;
      return;
    }
    _ui.setCherieAnimatorShiftEarnedTipsForSnack(tips);
    _ui.setCherieAnimatorPendingShiftSlotKey(slot);
    _ui.setCherieAnimatorShiftTc2SequenceActive(true);
    _ui.setCherieAnimatorShiftRewardFromIntro(true);
    if (!mounted) return;
    setState(() {
      _selectedNpcIdInRoom = 'cherie';
      _restoreCherieAnimatorIntroStep5VideoAndDialog();
    });
  }

  /// Не дублювати tc_1 під повноекранним оверлеєм інтро/квесту в офісі Cherie.
  bool get _suppressCherieGiftShopOfficeTc1Underlay {
    if (LocationsData.migrateLegacyRoomId(currentRoom) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (_isCherieQuest002ScriptedDialogActive()) return true;
    if (_isCherieQuest003ScriptedDialogActive()) return true;
    if (_isCherieQuest004ScriptedDialogActive()) return true;
    if (_isCherieQuest005ScriptedDialogActive()) return true;
    if (_isCherieQuest006ScriptedDialogActive()) return true;
    if (_isCherieMassageFunEventScriptedDialogActive()) return true;
    if (_worldState.cherieAnimatorIntroStep != 0) return true;
    return _eventVideoPath != null;
  }

  bool _isCherieMassageFunEventScriptedDialogActive() {
    return CherieMassageFunEvent.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  /// EVENT: cherie_event_003 — інтро першої зміни аніматором (кроки 1–5, одиничні кнопки).
  void _tryStartCherieAnimatorShiftIntroIfNeeded(String enteredRoom) {
    if (enteredRoom != LocationsData.cityMallGiftShopOffice) return;
    if (currentZone != 'CITY' || !isInsideRoom) return;
    if (_worldState.cherieAnimatorIntroStep != 0) return;
    if (_worldState.giftShopAnimatorShiftsCompleted != 0) return;
    if (!_worldState.giftShopAnimatorJobOfferPending) return;
    if (_playerStats.player.energy < MainGameScreenStateBase.kGiftShopAnimatorEnergyCost) return;
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    if (!CherieEvents.isAnimatorShiftTimeWindow(weekdayIndex: day, hour: hour)) {
      return;
    }
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (cherie == null) return;
    if (npcService.getCurrentLocationId(cherie, hour, day) !=
        LocationsData.cityMallGiftShopOffice) {
      return;
    }
    if (_ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return;
    }
    if (CherieQuest002.isActiveMidFlow(_worldState)) {
      return;
    }
    if (CherieQuest003.isActiveMidFlow(_worldState)) {
      return;
    }
    if (CherieQuest004.isActiveMidFlow(_worldState)) {
      return;
    }
    if (CherieQuest005.isActiveMidFlow(_worldState)) {
      return;
    }
    if (CherieQuest006.isActiveMidFlow(_worldState)) {
      return;
    }
    final slotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
      _timeController.dateTime,
      day,
    );
    if (_worldState.lastGiftShopAnimatorDateKey == slotKey) return;
    if (_eventVideoPath != null) return;

    setState(() {
      _worldState.cherieAnimatorIntroStep = 1;
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieAnimatorIntroVisualsForStep(1);
    });
    _saveService.autosave();
  }

  void _resumeCherieAnimatorIntroIfInProgress(String enteredRoom) {
    if (enteredRoom != LocationsData.cityMallGiftShopOffice) return;
    final s = _worldState.cherieAnimatorIntroStep;
    if (s <= 0 || s > 5) return;
    if (_eventVideoPath != null) return;
    setState(() {
      if (s <= 4) {
        _applyCherieAnimatorIntroVisualsForStep(s);
      } else {
        _restoreCherieAnimatorIntroStep5VideoAndDialog();
      }
    });
  }

  void _applyCherieAnimatorIntroLoopVideo(String path) {
    _eventVideoPath = path;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = true;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoOnComplete = () {
      if (!mounted) return;
      setState(() {
        _eventVideoPath = null;
        _eventVideoOnComplete = null;
        _eventVideoCloseWhenCompleted = true;
        _eventVideoFullScreen = false;
        _eventVideoLoop = false;
      });
      _saveService.autosave();
    };
  }

  void _applyCherieAnimatorIntroVisualsForStep(int step) {
    final loc = sl<LocaleController>();
    if (step == 1) {
      newsMessage = loc.t('cherie_animator_intro_step1_dialogue');
      _applyCherieAnimatorIntroLoopVideo(CherieEvents.tc1Webm);
    } else if (step == 2) {
      newsMessage = loc.t('cherie_animator_intro_step2_dialogue');
      _applyCherieAnimatorIntroLoopVideo(CherieEvents.tcChangeClothesWebm);
    } else if (step == 3) {
      newsMessage = loc.t('cherie_animator_intro_step3_dialogue');
      _applyCherieAnimatorIntroLoopVideo(CherieEvents.tc3Webm);
    } else if (step == 4) {
      newsMessage = loc.t('cherie_animator_intro_step4_dialogue');
      _applyCherieAnimatorIntroLoopVideo(CherieEvents.animatorWorkVideoPath);
    }
  }

  void _restoreCherieAnimatorIntroStep5VideoAndDialog() {
    final loc = sl<LocaleController>();
    _ui.setCherieAnimatorShiftTc2SequenceActive(true);
    _applyCherieAnimatorIntroLoopVideo(CherieEvents.animatorShiftEndVideoPath);
    newsMessage = loc.t('cherie_animator_intro_step5_dialogue');
    _ui.setCherieAnimatorShiftTc2DialogPending(true);
  }

  void _onCherieAnimatorIntroAdvance() {
    final s = _worldState.cherieAnimatorIntroStep;
    if (s == 1) {
      setState(() {
        _worldState.cherieAnimatorIntroStep = 2;
        _applyCherieAnimatorIntroVisualsForStep(2);
      });
    } else if (s == 2) {
      setState(() {
        _worldState.cherieAnimatorIntroStep = 3;
        _applyCherieAnimatorIntroVisualsForStep(3);
      });
    } else if (s == 3) {
      final dt = _timeController.dateTime;
      final slotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
        dt,
        _timeController.weekdayIndex,
      );
      setState(() {
        _worldState.cherieAnimatorIntroStep = 4;
        _worldState.giftShopAnimatorPendingFinishDateKey = slotKey;
        _worldState.cherieAnimatorWorkVideoCount += 1;
        _applyCherieAnimatorIntroVisualsForStep(4);
      });
    } else if (s == 4) {
      _finishCherieAnimatorIntroStep4ToTc2();
      return;
    } else {
      return;
    }
    _saveService.autosave();
  }

  void _finishCherieAnimatorIntroStep4ToTc2() async {
    final dt = _timeController.dateTime;
    final slotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
      dt,
      _timeController.weekdayIndex,
    );

    if (!_worldState.giftShopAnimatorJobOfferPending) return;
    if (_worldState.giftShopAnimatorPendingFinishDateKey != slotKey) return;
    if (_worldState.cherieAnimatorIntroStep != 4) return;

    if (_playerStats.player.energy < MainGameScreenStateBase.kGiftShopAnimatorEnergyCost) {
      showInsufficientEnergyDialog(context);
      return;
    }

    final tips = 100 + Random().nextInt(201);
    if (!mounted) return;

    final loc = sl<LocaleController>();
    _ui.setCherieAnimatorShiftEarnedTipsForSnack(tips);
    _ui.setCherieAnimatorPendingShiftSlotKey(slotKey);
    _ui.setCherieAnimatorShiftTc2SequenceActive(true);
    _ui.setCherieAnimatorShiftRewardFromIntro(true);
    _worldState.cherieAnimatorIntroTc2SlotKeyStash = slotKey;
    _worldState.cherieAnimatorIntroTc2TipsStash = tips;

    setState(() {
      _worldState.giftShopAnimatorPendingFinishDateKey = null;
      _worldState.cherieAnimatorIntroStep = 5;

      _eventVideoPath = CherieEvents.animatorShiftEndVideoPath;
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = false;
      _eventVideoLoop = true;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      newsMessage = loc.t('cherie_animator_intro_step5_dialogue');
      _eventVideoOnComplete = () {
        if (!mounted) return;
        setState(() {
          _eventVideoPath = null;
          _eventVideoOnComplete = null;
          _eventVideoCloseWhenCompleted = true;
          _eventVideoFullScreen = false;
          _eventVideoLoop = false;
        });
        _saveService.autosave();
      };
    });
    _ui.setCherieAnimatorShiftTc2DialogPending(true);
    await _saveService.autosave();
  }

  /// Якщо зміни вже були, інтро не може лишатись активним — інакше квест 2 гейтиться на [cherieAnimatorIntroStep].
  /// Знімає застряглий оверлей відео зміни/інтро, щоб не блокував [canStartQuest002] через [_eventVideoPath].
  void _healCherieAnimatorIntroIfStuckAfterShifts() {
    if (_worldState.giftShopAnimatorShiftsCompleted <= 0) return;
    if (_worldState.cherieAnimatorIntroStep == 0) return;
    _worldState.cherieAnimatorIntroStep = 0;
    _worldState.cherieAnimatorIntroTc2SlotKeyStash = null;
    _worldState.cherieAnimatorIntroTc2TipsStash = null;
    _ui.clearCherieAnimatorShiftTc2Progress();
    final path = _eventVideoPath;
    if (path != null && CherieEvents.isAnimatorShiftEventVideoPath(path)) {
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoFullScreen = false;
      _eventVideoLoop = false;
    }
  }

  /// Після згоди на роботу офісна фаза квесту 1 має бути inactive; інакше кнопка блокує старт квесту 2.
  void _healCherieQuest001OfficePhaseIfAnimatorAgreed() {
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie != null &&
        cherie.getVar(CherieQuest001.giftShopWorkAnimatorVar) == true &&
        _ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      _ui.setCherieQuest001OfficePhase(CherieQuest001OfficePhase.inactive);
    }
  }

  /// EVENT: cherie_quest_002 — офіс Cherie, вихідні (пріоритет над квестом 1 / інтро аніматора).
  bool _tryStartCherieQuest002OfficeIfNeeded(String enteredRoom) {
    _healCherieAnimatorIntroIfStuckAfterShifts();
    if (CherieQuest004.isActiveMidFlow(_worldState)) return false;
    if (CherieQuest005.isActiveMidFlow(_worldState)) return false;
    if (CherieQuest006.isActiveMidFlow(_worldState)) return false;
    if (enteredRoom != LocationsData.cityMallGiftShopOffice) return false;
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (_ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return false;
    }
    if (_worldState.cherieAnimatorIntroStep != 0) return false;
    if (_eventVideoPath != null) return false;

    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    final q2PlayerGates = _cherieQuest002StartPlayerGates();
    if (_cherieQuest002PresentationSyncedStep == _worldState.cherieQuest002Step &&
        CherieQuest002.shouldPresentOfficeQuest002Steps(
          currentRoom: currentRoom,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          hour: hour,
          weekdayIndex: day,
          cherie: cherie,
          npcService: npcService,
          world: _worldState,
          playerGates: q2PlayerGates,
        )) {
      return false;
    }
    final patch = CherieQuest002.tryBuildOfficePatchForCurrentStep(
      enteredRoom: enteredRoom,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      hour: hour,
      weekdayIndex: day,
      cherie: cherie,
      npcService: npcService,
      world: _worldState,
      playerGates: q2PlayerGates,
    );
    if (patch == null) return false;

    setState(() {
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest002OfficePatch(patch);
    });
    _saveService.autosave();
    return true;
  }

  bool _isCherieQuest002LocationValidForCurrentStep() {
    final s = _worldState.cherieQuest002Step;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (s >= 1 && s <= 3) {
      return currentZone == 'CITY' &&
          isInsideRoom &&
          roomNorm == LocationsData.cityMallGiftShopOffice;
    }
    if (s == 4) {
      return currentZone == 'CITY' &&
          isInsideRoom &&
          (roomNorm == LocationsData.cityMallGiftShopOffice ||
              roomNorm == LocationsData.cityMallGiftShopWarehouse);
    }
    if (s >= 5 && s <= 9) {
      return currentZone == 'POOR_VILLAGE' &&
          isInsideRoom &&
          roomNorm == LocationsData.poorVillageGiftShopOwnerHall;
    }
    return true;
  }

  void _abortCherieQuest002ProgressAndUi({
    bool applySaturdaySundayBlock = false,
  }) {
    if (CherieQuest002.isActiveMidFlow(_worldState)) {
      final cherie = sl<NPCService>().npcById('cherie');
      CherieQuest002.abortPlayerAbandoned(cherie, _worldState);
    }
    _resetCherieQuest002OfficeSession(
      applySaturdaySundayBlock: applySaturdaySundayBlock,
    );
  }

  /// Квест 2: гравець не на сцені кроку (інша кімната / зона) — обнулення прогресу.
  void _maybeAbortCherieQuest002WrongLocation() {
    if (!CherieQuest002.isActiveMidFlow(_worldState)) return;
    if (_isCherieQuest002LocationValidForCurrentStep()) return;
    _abortCherieQuest002ProgressAndUi(applySaturdaySundayBlock: false);
    _saveService.autosave();
  }

  bool _isCherieQuest003LocationValidForActiveStep() {
    return CherieQuest003.isLocationValidForActiveStep(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    );
  }

  void _resetCherieQuest003OfficeSession() {
    _cherieQuest003PresentationSyncedStep = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
  }

  void _abortCherieQuest003ProgressAndUi() {
    CherieQuest003.abortAbandoned(_worldState);
    _resetCherieQuest003OfficeSession();
    newsMessage = LocationsData.getLocationDisplayName(currentRoom);
  }

  void _maybeAbortCherieQuest003WrongLocation() {
    if (!CherieQuest003.isActiveMidFlow(_worldState)) return;
    if (_isCherieQuest003LocationValidForActiveStep()) return;
    _abortCherieQuest003ProgressAndUi();
    _saveService.autosave();
  }

  void _applyCherieQuest003Patch(CherieQuest003OfficePatch p) {
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    _ui.setEventImagePath(null);
    if (p.videoPath != null) {
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = p.videoMuted;
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
    _cherieQuest003PresentationSyncedStep = _worldState.cherieQuest003Step;
  }

  void _tryResumeCherieQuest003OfficeIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.cityMallGiftShopOffice) return;
    if (currentZone != 'CITY' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return;
    final s = _worldState.cherieQuest003Step;
    if (s < 1 || s > 3) return;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest003.shouldPresentScriptedUi(
      world: _worldState,
      cherie: cherie,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest003PresentationSyncedStep == s) return;
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest003Patch(CherieQuest003.patchForStep(s));
  }

  void _maybeResumeCherieQuest003AfterLoad() {
    final s = _worldState.cherieQuest003Step;
    if (s < 1 || s > 3) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' ||
        !isInsideRoom ||
        roomNorm != LocationsData.cityMallGiftShopOffice) {
      return;
    }
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest003.shouldPresentScriptedUi(
      world: _worldState,
      cherie: cherie,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest003PresentationSyncedStep == s) return;
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest003Patch(CherieQuest003.patchForStep(s));
  }

  void _onCherieQuest003GoWork() {
    if (_worldState.cherieQuest003Step != 1) return;
    setState(() {
      _worldState.cherieQuest003Step = 2;
      _applyCherieQuest003Patch(CherieQuest003.patchForStep(2));
    });
    _saveService.autosave();
  }

  void _onCherieQuest003FinishWork() {
    if (_worldState.cherieQuest003Step != 2) return;
    setState(() {
      _worldState.cherieQuest003Step = 3;
      _applyCherieQuest003Patch(CherieQuest003.patchForStep(3));
    });
    _saveService.autosave();
  }

  void _onCherieQuest003LeaveFinale() {
    if (_worldState.cherieQuest003Step != 3) return;
    if (_playerStats.player.energy < CherieQuest003.energyCostLeave) {
      showInsufficientEnergyDialog(context);
      return;
    }
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final tips = Random().nextInt(
          CherieQuest003.tipsRandomMax - CherieQuest003.tipsRandomMin + 1,
        ) +
        CherieQuest003.tipsRandomMin;
    setState(() {
      CherieQuest003.applyFinaleRewards(
        cherie: cherie,
        world: _worldState,
        changeMoney: _playerStats.changeMoney,
        changeEnergy: _playerStats.changeEnergy,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        addGameMinutes: _timeController.addMinutes,
        tips: tips,
      );
      _resetCherieQuest003OfficeSession();
      newsMessage = LocationsData.getLocationDisplayName(currentRoom);
    });
    _saveService.autosave();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sl<LocaleController>().t('cherie_quest_003_snack_finale'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- cherie_quest_004 (масажист) ---

  void _resetCherieQuest004PresentationSession() {
    _cherieQuest004PresentationSyncedStep = null;
    _cherieQuest004PresentationSyncedBranch = null;
    _cherieQuest004PresentationSyncedLegsMassagePhase = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
  }

  void _abortCherieQuest004ProgressAndUi() {
    CherieQuest004.abortAbandoned(_worldState);
    _resetCherieQuest004PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(currentRoom);
  }

  void _maybeAbortCherieQuest004WrongLocation() {
    if (!CherieQuest004.isActiveMidFlow(_worldState)) return;
    if (CherieQuest004.isLocationValidForActiveStep(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _abortCherieQuest004ProgressAndUi();
    _saveService.autosave();
  }

  /// Перший рядок діалогу в debug: `step` у [GameWorldState], фаза ніг, гілка, ключ l10n.
  String _cherieQuest004DebugDialogHeader(String l10nKey) {
    final s = _worldState.cherieQuest004Step;
    final legs = _worldState.cherieQuest004LegsMassagePhase;
    final br = _worldState.cherieQuest004Branch;
    return 'Квест4 debug · крок step=$s · ноги=$legs · branch=$br · $l10nKey';
  }

  void _applyCherieQuest004Patch(CherieQuest004Patch p) {
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (kDebugMode) {
      newsMessage =
          '${_cherieQuest004DebugDialogHeader(p.newsL10nKey)}\n$newsMessage';
    }
    _ui.setEventImagePath(null);
    if (p.videoPath != null) {
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = p.videoMuted;
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
    _cherieQuest004PresentationSyncedStep = _worldState.cherieQuest004Step;
    _cherieQuest004PresentationSyncedBranch = _worldState.cherieQuest004Branch;
    _cherieQuest004PresentationSyncedLegsMassagePhase =
        _worldState.cherieQuest004LegsMassagePhase;
  }

  void _teleportCherieQuest004ToBedroom() {
    if (currentZone != 'POOR_VILLAGE') {
      _addTravelTime(currentZone, 'POOR_VILLAGE');
    }
    _nav.setZoneAndRoom(
      'POOR_VILLAGE',
      LocationsData.poorVillageGiftShopOwnerRoom1,
    );
    _nav.setIsInsideRoom(true);
    _worldState.currentZone = 'POOR_VILLAGE';
    _worldState.currentRoom = LocationsData.poorVillageGiftShopOwnerRoom1;
    _worldState.isInsideRoom = true;
    currentZone = 'POOR_VILLAGE';
    currentRoom = LocationsData.poorVillageGiftShopOwnerRoom1;
    isInsideRoom = true;
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.poorVillageGiftShopOwnerRoom1,
    );
  }

  void _teleportCherieQuest004ToCherieHall() {
    if (currentZone != 'POOR_VILLAGE') {
      _addTravelTime(currentZone, 'POOR_VILLAGE');
    }
    _nav.setZoneAndRoom(
      'POOR_VILLAGE',
      LocationsData.poorVillageGiftShopOwnerHall,
    );
    _nav.setIsInsideRoom(true);
    _worldState.currentZone = 'POOR_VILLAGE';
    _worldState.currentRoom = LocationsData.poorVillageGiftShopOwnerHall;
    _worldState.isInsideRoom = true;
    currentZone = 'POOR_VILLAGE';
    currentRoom = LocationsData.poorVillageGiftShopOwnerHall;
    isInsideRoom = true;
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.poorVillageGiftShopOwnerHall,
    );
  }

  void _teleportCherieQuest004ToPoorVillageOverview() {
    if (currentZone != 'POOR_VILLAGE') {
      _addTravelTime(currentZone, 'POOR_VILLAGE');
    }
    _nav.setZoneAndRoom('POOR_VILLAGE', LocationsData.poorVillageOverview);
    _nav.setIsInsideRoom(false);
    _worldState.currentZone = 'POOR_VILLAGE';
    _worldState.currentRoom = LocationsData.poorVillageOverview;
    _worldState.isInsideRoom = false;
    currentZone = 'POOR_VILLAGE';
    currentRoom = LocationsData.poorVillageOverview;
    isInsideRoom = false;
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.poorVillageOverview);
  }

  void _finishCherieQuest004BedroomRun() {
    CherieQuest004.resetSession(_worldState);
    _resetCherieQuest004PresentationSession();
    _teleportCherieQuest004ToPoorVillageOverview();
  }

  bool _tryStartCherieQuest004OfficeIfNeeded(String enteredRoom) {
    if (CherieQuest005.isActiveMidFlow(_worldState)) return false;
    if (CherieQuest006.isActiveMidFlow(_worldState)) return false;
    if (LocationsData.migrateLegacyRoomId(enteredRoom) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (_ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return false;
    }
    if (_worldState.cherieAnimatorIntroStep != 0) return false;
    if (_eventVideoPath != null) return false;
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest004.canStartOfficeEntry(
      cherie: cherie,
      world: _worldState,
      weekdayIndex: day,
      hour: hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      npcService: npcService,
      q1phase: _ui.cherieQuest001OfficePhase,
      quest002ScriptedActive: _isCherieQuest002ScriptedDialogActive(),
      quest002MidFlow: CherieQuest002.isActiveMidFlow(_worldState),
      quest003ScriptedActive: _isCherieQuest003ScriptedDialogActive(),
      eventVideoPath: _eventVideoPath,
    )) {
      return false;
    }
    if (cherie == null) return false;

    setState(() {
      CherieQuest004.startOfficePhase(_worldState, cherie);
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
    return true;
  }

  void _tryResumeCherieQuest004OfficeIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.cityMallGiftShopOffice) return;
    if (currentZone != 'CITY' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return;
    if (!CherieQuest004.isOfficePhase(_worldState)) return;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest004.shouldPresentOfficeScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest004PresentationSyncedStep == _worldState.cherieQuest004Step &&
        _cherieQuest004PresentationSyncedBranch ==
            _worldState.cherieQuest004Branch &&
        _cherieQuest004PresentationSyncedLegsMassagePhase ==
            _worldState.cherieQuest004LegsMassagePhase) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest004Patch(
      CherieQuest004.patchForState(world: _worldState, cherie: cherie),
    );
  }

  void _tryResumeCherieQuest004BedroomIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.poorVillageGiftShopOwnerRoom1) return;
    if (currentZone != 'POOR_VILLAGE' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.poorVillageGiftShopOwnerRoom1) return;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest004.shouldPresentBedroomScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest004PresentationSyncedStep == _worldState.cherieQuest004Step &&
        _cherieQuest004PresentationSyncedBranch ==
            _worldState.cherieQuest004Branch &&
        _cherieQuest004PresentationSyncedLegsMassagePhase ==
            _worldState.cherieQuest004LegsMassagePhase) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest004Patch(
      CherieQuest004.patchForState(world: _worldState, cherie: cherie),
    );
  }

  void _tryResumeCherieQuest004ContractHallIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.poorVillageGiftShopOwnerHall) return;
    if (currentZone != 'POOR_VILLAGE' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.poorVillageGiftShopOwnerHall) return;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest004.shouldPresentContractHallScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest004PresentationSyncedStep == _worldState.cherieQuest004Step &&
        _cherieQuest004PresentationSyncedBranch ==
            _worldState.cherieQuest004Branch &&
        _cherieQuest004PresentationSyncedLegsMassagePhase ==
            _worldState.cherieQuest004LegsMassagePhase) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest004Patch(
      CherieQuest004.patchForState(world: _worldState, cherie: cherie),
    );
  }

  void _maybeResumeCherieQuest004AfterLoad() {
    if (!CherieQuest004.isActiveMidFlow(_worldState)) return;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (CherieQuest004.shouldPresentOfficeScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      if (_cherieQuest004PresentationSyncedStep == _worldState.cherieQuest004Step &&
          _cherieQuest004PresentationSyncedBranch ==
              _worldState.cherieQuest004Branch &&
          _cherieQuest004PresentationSyncedLegsMassagePhase ==
              _worldState.cherieQuest004LegsMassagePhase) {
        return;
      }
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
      return;
    }
    if (CherieQuest004.shouldPresentBedroomScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      if (_cherieQuest004PresentationSyncedStep == _worldState.cherieQuest004Step &&
          _cherieQuest004PresentationSyncedBranch ==
              _worldState.cherieQuest004Branch &&
          _cherieQuest004PresentationSyncedLegsMassagePhase ==
              _worldState.cherieQuest004LegsMassagePhase) {
        return;
      }
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
      return;
    }
    if (CherieQuest004.shouldPresentContractHallScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      if (_cherieQuest004PresentationSyncedStep == _worldState.cherieQuest004Step &&
          _cherieQuest004PresentationSyncedBranch ==
              _worldState.cherieQuest004Branch &&
          _cherieQuest004PresentationSyncedLegsMassagePhase ==
              _worldState.cherieQuest004LegsMassagePhase) {
        return;
      }
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    }
  }

  void _onCherieQuest004OfficeRide() {
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    if (_worldState.cherieQuest004Step != 1) return;
    setState(() {
      // Телепорт при кроці 1 — інакше [CherieQuest004.suppressTravelTime] з кроку 3 прибере час дороги.
      _teleportCherieQuest004ToBedroom();
      _worldState.cherieQuest004Step = CherieQuest004.stepAfterRide(cherie);
      _worldState.cherieQuest004Branch = 0;
      _worldState.cherieQuest004LegsMassagePhase = false;
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004Ellipsis() {
    if (_worldState.cherieQuest004Step != 3) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest004Step = 4;
      _worldState.cherieQuest004Branch = 0;
      _worldState.cherieQuest004LegsMassagePhase = false;
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004Step4Finish() {
    if (_worldState.cherieQuest004Step != 4) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      if (_worldState.cherieQuest004LegsMassagePhase) {
        CherieQuest004.applyRewardStep5Finish(
          cherie,
          changeMoney: _playerStats.changeMoney,
          addGameMinutes: _timeController.addMinutes,
          changeMassageExperience: _playerStats.changeMassageExperience,
          changeEnergy: _playerStats.changeEnergy,
        );
      } else {
        CherieQuest004.applyRewardStep4Finish(
          cherie,
          changeMoney: _playerStats.changeMoney,
          changeMassageExperience: _playerStats.changeMassageExperience,
          changeEnergy: _playerStats.changeEnergy,
        );
      }
      _finishCherieQuest004BedroomRun();
    });
    _saveService.autosave();
  }

  void _onCherieQuest004OfferLegs() {
    if (_worldState.cherieQuest004Step != 4) return;
    if (_worldState.cherieQuest004LegsMassagePhase) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest004LegsMassagePhase = true;
      _worldState.cherieQuest004Branch = 0;
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004OfferTurn() {
    if (_worldState.cherieQuest004Step != 4) return;
    if (!_worldState.cherieQuest004LegsMassagePhase) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest004Step = 6;
      _worldState.cherieQuest004Branch = 0;
      _worldState.cherieQuest004LegsMassagePhase = false;
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004Step6Finish() {
    if (_worldState.cherieQuest004Step != 6) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final m = CherieQuest004.readMasseur(cherie);
    if (m <= 3) {
      setState(() {
        CherieQuest004.applyRewardStep6TurnLt3Finish(
          cherie,
          changeMoney: _playerStats.changeMoney,
          addGameMinutes: _timeController.addMinutes,
          changeMassageExperience: _playerStats.changeMassageExperience,
          changeCharisma: _playerStats.changeCharisma,
          changeEnergy: _playerStats.changeEnergy,
        );
        _finishCherieQuest004BedroomRun();
      });
      _saveService.autosave();
      return;
    }
    setState(() {
      CherieQuest004.applyRewardStep6TurnGte3AfterMassage5Finish(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest004BedroomRun();
    });
    _saveService.autosave();
  }

  void _onCherieQuest004RemovePanties() {
    if (_worldState.cherieQuest004Step != 6) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    if (CherieQuest004.readMasseur(cherie) < 4) return;
    setState(() {
      _worldState.cherieQuest004Step = 7;
      _worldState.cherieQuest004Branch = 0;
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004Step7Finish() {
    if (_worldState.cherieQuest004Step != 7) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest004.applyRewardStep7PantiesFinish(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest004BedroomRun();
    });
    _saveService.autosave();
  }

  void _onCherieQuest004Step8Finish() {
    if (_worldState.cherieQuest004Step != 8) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest004.applyRewardMassageSessionWithArousal(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
        masseurDelta: 1,
      );
      _finishCherieQuest004BedroomRun();
    });
    _saveService.autosave();
  }

  void _onCherieQuest004GropeChest() {
    if (_worldState.cherieQuest004Step != 8) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final m = CherieQuest004.readMasseur(cherie);
    // Сценарій: masseur ≤ 8 — massage_no_2; ≥ 9 — перехід на massage_8.
    if (m < 9) {
      setState(() {
        _worldState.cherieQuest004Branch = CherieQuest004Branch.gropeRebuff;
        _applyCherieQuest004Patch(
          CherieQuest004.patchForState(world: _worldState, cherie: cherie),
        );
      });
      _saveService.autosave();
      return;
    }
    setState(() {
      _worldState.cherieQuest004Step = 9;
      _worldState.cherieQuest004Branch = 0;
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004GropeRebuffFinish() {
    if (_worldState.cherieQuest004Step != 8) return;
    if (_worldState.cherieQuest004Branch != CherieQuest004Branch.gropeRebuff) {
      return;
    }
    _onCherieQuest004Step8Finish();
  }

  void _onCherieQuest004Step9Finish() {
    if (_worldState.cherieQuest004Step != 9) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest004.applyRewardMassageSessionWithArousal(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
        masseurDelta: 1,
      );
      _finishCherieQuest004BedroomRun();
    });
    _saveService.autosave();
  }

  void _onCherieQuest004PetKitty() {
    if (_worldState.cherieQuest004Step != 9) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final m = CherieQuest004.readMasseur(cherie);
    // Сценарій: masseur ≤ 12 — massage_no_1; ≥ 13 — перехід на massage_9 (крок 10).
    if (m <= 12) {
      setState(() {
        _worldState.cherieQuest004Branch = CherieQuest004Branch.petRebuff;
        _applyCherieQuest004Patch(
          CherieQuest004.patchForState(world: _worldState, cherie: cherie),
        );
      });
      _saveService.autosave();
      return;
    }
    setState(() {
      _worldState.cherieQuest004Step = 10;
      _worldState.cherieQuest004Branch = 0;
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004PetRebuffFinish() {
    if (_worldState.cherieQuest004Step != 9) return;
    if (_worldState.cherieQuest004Branch != CherieQuest004Branch.petRebuff) {
      return;
    }
    _onCherieQuest004Step9Finish();
  }

  void _onCherieQuest004Step10Finish() {
    if (_worldState.cherieQuest004Step != 10) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest004Step = 11;
      _worldState.cherieQuest004Branch = 0;
      _teleportCherieQuest004ToCherieHall();
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest004Patch(
        CherieQuest004.patchForState(world: _worldState, cherie: cherie),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest004ContractLeave() {
    if (_worldState.cherieQuest004Step != 11) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest004.applyContractFinale(
        cherie,
        _worldState,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _resetCherieQuest004PresentationSession();
      _teleportCherieQuest004ToPoorVillageOverview();
    });
    _saveService.autosave();
  }

  VoidCallback? _cherieQuest004ActionHandler({
    required String actionId,
    required int step,
    required int branch,
  }) {
    switch (actionId) {
      case 'ride':
        return _onCherieQuest004OfficeRide;
      case 'ellipsis':
        return _onCherieQuest004Ellipsis;
      case 'offerLegs':
        return _onCherieQuest004OfferLegs;
      case 'offerTurn':
        return _onCherieQuest004OfferTurn;
      case 'removePanties':
        return _onCherieQuest004RemovePanties;
      case 'gropeChest':
        return _onCherieQuest004GropeChest;
      case 'petKitty':
        return _onCherieQuest004PetKitty;
      case 'leave':
        return _onCherieQuest004ContractLeave;
      case 'finish':
        if (step == 4) return _onCherieQuest004Step4Finish;
        if (step == 6) return _onCherieQuest004Step6Finish;
        if (step == 7) return _onCherieQuest004Step7Finish;
        if (step == 8) {
          if (branch == CherieQuest004Branch.gropeRebuff) {
            return _onCherieQuest004GropeRebuffFinish;
          }
          return _onCherieQuest004Step8Finish;
        }
        if (step == 9) {
          if (branch == CherieQuest004Branch.petRebuff) {
            return _onCherieQuest004PetRebuffFinish;
          }
          return _onCherieQuest004Step9Finish;
        }
        if (step == 10) return _onCherieQuest004Step10Finish;
        return null;
      default:
        return null;
    }
  }

  Widget? _cherieQuest004PriorityActionPanelIfAny() {
    if (!_isCherieQuest004ScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;
    final cherie = sl<NPCService>().npcById('cherie');
    final s = _worldState.cherieQuest004Step;
    final br = _worldState.cherieQuest004Branch;
    final m = CherieQuest004.readMasseur(cherie);

    if (CherieQuest004.shouldPresentOfficeScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      final actionIds = CherieQuestRuntime.quest004OfficeActionIds(step: s);
      if (actionIds.isEmpty) return null;
      final key = CherieQuestRuntime.quest004ActionL10nKey(actionIds.first);
      if (key == null) return null;
      final onTap = _cherieQuest004ActionHandler(
        actionId: actionIds.first,
        step: s,
        branch: br,
      );
      if (onTap == null) return null;
      return _actionPanelSection(<Widget>[
        _navBtn(t(key).toUpperCase(), onTap),
      ]);
    }

    if (CherieQuest004.shouldPresentBedroomScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      final children = <Widget>[];
      void addPair(String label, VoidCallback onTap) {
        if (children.isNotEmpty) children.add(const SizedBox(height: 8));
        children.add(_navBtn(label.toUpperCase(), onTap));
      }

      final actionIds = CherieQuestRuntime.quest004BedroomActionIds(
        step: s,
        branch: br,
        legsMassagePhase: _worldState.cherieQuest004LegsMassagePhase,
        masseur: m,
      );
      if (actionIds.isEmpty) {
        return null;
      }
      for (final actionId in actionIds) {
        final key = CherieQuestRuntime.quest004ActionL10nKey(actionId);
        if (key == null) continue;
        final onTap = _cherieQuest004ActionHandler(
          actionId: actionId,
          step: s,
          branch: br,
        );
        if (onTap == null) continue;
        addPair(t(key), onTap);
      }
      if (children.isEmpty) return null;

      return _actionPanelSection(children);
    }

    if (CherieQuest004.shouldPresentContractHallScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      final actionIds = CherieQuestRuntime.quest004ContractActionIds(step: s);
      if (actionIds.isEmpty) return null;
      final key = CherieQuestRuntime.quest004ActionL10nKey(actionIds.first);
      if (key == null) return null;
      final onTap = _cherieQuest004ActionHandler(
        actionId: actionIds.first,
        step: s,
        branch: br,
      );
      if (onTap == null) return null;
      return _actionPanelSection(<Widget>[
        _navBtn(t(key).toUpperCase(), onTap),
      ]);
    }

    return null;
  }

  void _resetCherieQuest005PresentationSession() {
    _cherieQuest005PresentationSyncedStep = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
  }

  void _abortCherieQuest005ProgressAndUi() {
    CherieQuest005.abortAbandoned(_worldState);
    _resetCherieQuest005PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(currentRoom);
  }

  void _maybeAbortCherieQuest005WrongLocation() {
    if (!CherieQuest005.isActiveMidFlow(_worldState)) return;
    if (CherieQuest005.isLocationValidForActiveStep(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _abortCherieQuest005ProgressAndUi();
    _saveService.autosave();
  }

  // --- EVENT: cherie_event_004 — розваги після массажу ---

  String _cherieMassageFunEventDebugHeader(String l10nKey) {
    final s = _worldState.cherieMassageFunEventStep;
    final c = _worldState.cherieMassageFunCompletions;
    return 'Cherie massage fun · step=$s · completions=$c · $l10nKey';
  }

  void _resetCherieMassageFunEventPresentationSession() {
    _cherieMassageFunEventPresentationSyncedStep = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
  }

  void _abortCherieMassageFunEventProgressAndUi() {
    _worldState.cherieMassageFunEventStep = 0;
    _resetCherieMassageFunEventPresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(currentRoom);
  }

  void _maybeAbortCherieMassageFunEventWrongLocation() {
    if (_worldState.cherieMassageFunEventStep <= 0) return;
    if (CherieMassageFunEvent.isLocationValidForActiveStep(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _abortCherieMassageFunEventProgressAndUi();
    _saveService.autosave();
  }

  void _applyCherieMassageFunEventPatch(CherieMassageFunEventPatch p) {
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (kDebugMode) {
      newsMessage =
          '${_cherieMassageFunEventDebugHeader(p.newsL10nKey)}\n$newsMessage';
    }
    _ui.setEventImagePath(null);
    if (p.videoPath != null) {
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = p.videoMuted;
      _eventVideoFullScreen = p.fullScreen;
      _eventVideoCloseWhenCompleted = false;
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
    _cherieMassageFunEventPresentationSyncedStep =
        _worldState.cherieMassageFunEventStep;
  }

  void _tryResumeCherieMassageFunEventOfficeIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.cityMallGiftShopOffice) return;
    if (currentZone != 'CITY' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return;
    if (_worldState.cherieMassageFunEventStep != 1) return;
    if (_cherieMassageFunEventPresentationSyncedStep ==
        _worldState.cherieMassageFunEventStep) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieMassageFunEventPatch(
      CherieMassageFunEvent.patchForPresentationStep(1),
    );
  }

  void _tryResumeCherieMassageFunEventBedroomIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.poorVillageGiftShopOwnerRoom1) return;
    if (currentZone != 'POOR_VILLAGE' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.poorVillageGiftShopOwnerRoom1) return;
    final s = _worldState.cherieMassageFunEventStep;
    if (s < 2 || s > 8) return;
    if (_cherieMassageFunEventPresentationSyncedStep == s) return;
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieMassageFunEventPatch(
      CherieMassageFunEvent.patchForPresentationStep(s),
    );
  }

  void _maybeResumeCherieMassageFunEventAfterLoad() {
    if (_worldState.cherieMassageFunEventStep == 1) {
      if (CherieMassageFunEvent.isScriptedDialogActive(
            world: _worldState,
            currentZone: currentZone,
            isInsideRoom: isInsideRoom,
            currentRoom: currentRoom,
          ) &&
          _cherieMassageFunEventPresentationSyncedStep !=
              _worldState.cherieMassageFunEventStep) {
        _selectedNpcIdInRoom = 'cherie';
        _applyCherieMassageFunEventPatch(
          CherieMassageFunEvent.patchForPresentationStep(1),
        );
      }
      return;
    }
    if (_worldState.cherieMassageFunEventStep >= 2 &&
        _worldState.cherieMassageFunEventStep <= 8) {
      if (CherieMassageFunEvent.isScriptedDialogActive(
            world: _worldState,
            currentZone: currentZone,
            isInsideRoom: isInsideRoom,
            currentRoom: currentRoom,
          ) &&
          _cherieMassageFunEventPresentationSyncedStep !=
              _worldState.cherieMassageFunEventStep) {
        _selectedNpcIdInRoom = 'cherie';
        _applyCherieMassageFunEventPatch(
          CherieMassageFunEvent.patchForPresentationStep(
            _worldState.cherieMassageFunEventStep,
          ),
        );
      }
    }
  }

  void _finishCherieMassageFunEventCommonExit() {
    _worldState.cherieMassageFunEventStep = 0;
    _resetCherieMassageFunEventPresentationSession();
    _teleportCherieQuest005ToPoorVillageOverview();
  }

  int _randomMassageFunTips50to150() => 50 + Random().nextInt(101);

  void _onCherieMassageFunEventRide() {
    if (_worldState.cherieMassageFunEventStep != 1) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _teleportCherieQuest005ToBedroom();
      _worldState.cherieMassageFunEventStep = 2;
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(2),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventGropeChest() {
    if (_worldState.cherieMassageFunEventStep != 2) return;
    setState(() {
      _worldState.cherieMassageFunEventStep = 3;
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(3),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventPetKitty() {
    if (_worldState.cherieMassageFunEventStep != 3) return;
    setState(() {
      _worldState.cherieMassageFunEventStep = 4;
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(4),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventHaveFun() {
    if (_worldState.cherieMassageFunEventStep != 4) return;
    setState(() {
      _worldState.cherieMassageFunEventStep = 5;
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(5),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventLetHer() {
    if (_worldState.cherieMassageFunEventStep != 5) return;
    setState(() {
      _worldState.cherieMassageFunEventStep = 6;
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(6),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventStep6Leave() {
    if (_worldState.cherieMassageFunEventStep != 6) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final tips = _randomMassageFunTips50to150();
    setState(() {
      _playerStats.changeEnergy(-30);
      _playerStats.changeMoney(100 + tips);
      _timeController.addMinutes(60);
      cherie.addRelationship(15);
      _playerStats.changeCharisma(1);
      _playerStats.changeArousal(-_playerStats.arousal);
      cherie.arousal = 0;
      cherie.changeBehavior(10);
      _worldState.cherieMassageFunCompletions++;
      _finishCherieMassageFunEventCommonExit();
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventStep6Continue() {
    if (_worldState.cherieMassageFunEventStep != 6) return;
    if (_worldState.cherieMassageFunCompletions <
        CherieMassageFunEvent.minCompletionsForBonusPath) {
      return;
    }
    setState(() {
      _worldState.cherieMassageFunEventStep = 7;
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(7),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventStep7FinishSex() {
    if (_worldState.cherieMassageFunEventStep != 7) return;
    setState(() {
      _worldState.cherieMassageFunEventStep = 8;
      _applyCherieMassageFunEventPatch(
        CherieMassageFunEvent.patchForPresentationStep(8),
      );
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventStep8Leave() {
    if (_worldState.cherieMassageFunEventStep != 8) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final tips = _randomMassageFunTips50to150();
    setState(() {
      _playerStats.changeEnergy(-30);
      _playerStats.changeMoney(100 + tips);
      _timeController.addMinutes(60);
      cherie.addRelationship(20);
      _playerStats.changeCharisma(1);
      _playerStats.changeArousal(-_playerStats.arousal);
      cherie.arousal = 0;
      cherie.changeBehavior(10);
      _worldState.cherieMassageFunCompletions++;
      _finishCherieMassageFunEventCommonExit();
    });
    _saveService.autosave();
  }

  void _onCherieMassageFunEventEarlyFinish() {
    final s = _worldState.cherieMassageFunEventStep;
    if (s != 2 && s != 3) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieMassageFunEvent.applyEarlyFinishFromStep2Or3(
        cherie: cherie,
        fromStep: s,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieMassageFunEventCommonExit();
    });
    _saveService.autosave();
  }

  Widget? _cherieMassageFunPriorityActionPanelIfAny() {
    if (!_isCherieMassageFunEventScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;
    final s = _worldState.cherieMassageFunEventStep;
    final completions = _worldState.cherieMassageFunCompletions;

    void addPair(List<Widget> children, String label, VoidCallback onTap) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 8));
      children.add(_navBtn(label.toUpperCase(), onTap));
    }

    final children = <Widget>[];
    if (s == 1) {
      addPair(children, t(CherieQuest005L10n.btnRide), _onCherieMassageFunEventRide);
    } else if (s == 2) {
      addPair(children, t(CherieQuest005L10n.btnGropeChest), _onCherieMassageFunEventGropeChest);
      addPair(children, t(CherieQuest005L10n.btnFinish), _onCherieMassageFunEventEarlyFinish);
    } else if (s == 3) {
      addPair(children, t(CherieQuest005L10n.btnPetKitty), _onCherieMassageFunEventPetKitty);
      addPair(children, t(CherieQuest005L10n.btnFinish), _onCherieMassageFunEventEarlyFinish);
    } else if (s == 4) {
      addPair(children, t('cherie_massage_fun_btn_have_fun'), _onCherieMassageFunEventHaveFun);
    } else if (s == 5) {
      addPair(children, t('cherie_massage_fun_btn_let_her_go'), _onCherieMassageFunEventLetHer);
    } else if (s == 6) {
      addPair(children, t(CherieQuest005L10n.btnLeave), _onCherieMassageFunEventStep6Leave);
      if (completions >= CherieMassageFunEvent.minCompletionsForBonusPath) {
        addPair(children, t('cherie_massage_fun_btn_continue'), _onCherieMassageFunEventStep6Continue);
      }
    } else if (s == 7) {
      addPair(children, t('cherie_massage_fun_btn_finish_sex'), _onCherieMassageFunEventStep7FinishSex);
    } else if (s == 8) {
      addPair(children, t(CherieQuest005L10n.btnLeave), _onCherieMassageFunEventStep8Leave);
    } else {
      return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  void _resetCherieQuest006PresentationSession() {
    _cherieQuest006PresentationSyncedStep = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
  }

  void _abortCherieQuest006ProgressAndUi() {
    CherieQuest006.abortAbandoned(_worldState);
    _resetCherieQuest006PresentationSession();
    newsMessage = LocationsData.getLocationDisplayName(currentRoom);
  }

  void _maybeAbortCherieQuest006WrongLocation() {
    if (!CherieQuest006.isActiveMidFlow(_worldState)) return;
    if (CherieQuest006.isLocationValidForActiveStep(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    _abortCherieQuest006ProgressAndUi();
    _saveService.autosave();
  }

  String _cherieQuest005DebugDialogHeader(String l10nKey) {
    final s = _worldState.cherieQuest005Step;
    final a = _worldState.cherieQuest005Actor;
    final l = _worldState.cherieQuest005Lizun;
    return 'Квест5 debug · step=$s · actor=$a · lizun=$l · $l10nKey';
  }

  void _applyCherieQuest005Patch(CherieQuest005Patch p) {
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (kDebugMode) {
      newsMessage =
          '${_cherieQuest005DebugDialogHeader(p.newsL10nKey)}\n$newsMessage';
    }
    if (p.videoPath != null) {
      _ui.setEventImagePath(null);
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = p.videoMuted;
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
      if (p.imagePath != null) {
        _ui.setEventImagePath(p.imagePath);
        _eventVideoFullScreen = p.fullScreen;
      } else {
        _ui.setEventImagePath(null);
        _eventVideoFullScreen = false;
      }
    }
    _cherieQuest005PresentationSyncedStep = _worldState.cherieQuest005Step;
  }

  String _cherieQuest006DebugDialogHeader(String l10nKey) {
    final s = _worldState.cherieQuest006Step;
    return 'Квест6 debug · step=$s · $l10nKey';
  }

  void _applyCherieQuest006Patch(CherieQuest006Patch p) {
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (kDebugMode) {
      newsMessage =
          '${_cherieQuest006DebugDialogHeader(p.newsL10nKey)}\n$newsMessage';
    }
    if (p.videoPath != null) {
      _ui.setEventImagePath(null);
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = p.videoMuted;
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
      _ui.setEventImagePath(null);
    }
    _cherieQuest006PresentationSyncedStep = _worldState.cherieQuest006Step;
  }

  void _teleportCherieQuest005ToBedroom() {
    _nav.setZoneAndRoom(
      'POOR_VILLAGE',
      LocationsData.poorVillageGiftShopOwnerRoom1,
    );
    _nav.setIsInsideRoom(true);
    _worldState.currentZone = 'POOR_VILLAGE';
    _worldState.currentRoom = LocationsData.poorVillageGiftShopOwnerRoom1;
    _worldState.isInsideRoom = true;
    currentZone = 'POOR_VILLAGE';
    currentRoom = LocationsData.poorVillageGiftShopOwnerRoom1;
    isInsideRoom = true;
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.poorVillageGiftShopOwnerRoom1,
    );
  }

  void _teleportCherieQuest005ToPoorVillageOverview() {
    _nav.setZoneAndRoom('POOR_VILLAGE', LocationsData.poorVillageOverview);
    _nav.setIsInsideRoom(false);
    _worldState.currentZone = 'POOR_VILLAGE';
    _worldState.currentRoom = LocationsData.poorVillageOverview;
    _worldState.isInsideRoom = false;
    currentZone = 'POOR_VILLAGE';
    currentRoom = LocationsData.poorVillageOverview;
    isInsideRoom = false;
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.poorVillageOverview);
  }

  void _finishCherieQuest005Run() {
    _worldState.cherieQuest005Complete =
        _worldState.cherieQuest005Actor >= CherieQuest005.completeActorThreshold;
    CherieQuest005.resetSession(_worldState);
    _resetCherieQuest005PresentationSession();
    _teleportCherieQuest005ToPoorVillageOverview();
  }

  bool _tryStartCherieQuest005OfficeIfNeeded(String enteredRoom) {
    if (LocationsData.migrateLegacyRoomId(enteredRoom) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (_ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return false;
    }
    if (_worldState.cherieAnimatorIntroStep != 0) return false;
    if (_eventVideoPath != null) return false;
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest005.canStartOfficeEntry(
      cherie: cherie,
      world: _worldState,
      weekdayIndex: day,
      hour: hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      npcService: npcService,
      q1phase: _ui.cherieQuest001OfficePhase,
      quest002ScriptedActive: _isCherieQuest002ScriptedDialogActive(),
      quest002MidFlow: CherieQuest002.isActiveMidFlow(_worldState),
      quest003ScriptedActive: _isCherieQuest003ScriptedDialogActive(),
      quest004MidFlow: CherieQuest004.isActiveMidFlow(_worldState),
      eventVideoPath: _eventVideoPath,
    )) {
      return false;
    }

    setState(() {
      CherieQuest005.startOfficePhase(_worldState);
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
    return true;
  }

  void _tryResumeCherieQuest005OfficeIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.cityMallGiftShopOffice) return;
    if (currentZone != 'CITY' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return;
    if (!CherieQuest005.isOfficePhase(_worldState)) return;
    if (!CherieQuest005.shouldPresentOfficeScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest005PresentationSyncedStep ==
        _worldState.cherieQuest005Step) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest005Patch(
      CherieQuest005.patchForState(world: _worldState),
    );
  }

  void _tryResumeCherieQuest005BedroomIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.poorVillageGiftShopOwnerRoom1) return;
    if (currentZone != 'POOR_VILLAGE' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.poorVillageGiftShopOwnerRoom1) return;
    if (!CherieQuest005.shouldPresentBedroomScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest005PresentationSyncedStep ==
        _worldState.cherieQuest005Step) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest005Patch(
      CherieQuest005.patchForState(world: _worldState),
    );
  }

  void _maybeResumeCherieQuest005AfterLoad() {
    if (!CherieQuest005.isActiveMidFlow(_worldState)) return;
    if (CherieQuest005.shouldPresentOfficeScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      if (_cherieQuest005PresentationSyncedStep ==
          _worldState.cherieQuest005Step) {
        return;
      }
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
      return;
    }
    if (CherieQuest005.shouldPresentBedroomScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      if (_cherieQuest005PresentationSyncedStep ==
          _worldState.cherieQuest005Step) {
        return;
      }
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    }
  }

  void _teleportCherieQuest006ToTrcMall() {
    _nav.setZoneAndRoom('CITY', LocationsData.cityMall);
    _nav.setIsInsideRoom(true);
    _worldState.currentZone = 'CITY';
    _worldState.currentRoom = LocationsData.cityMall;
    _worldState.isInsideRoom = true;
    currentZone = 'CITY';
    currentRoom = LocationsData.cityMall;
    isInsideRoom = true;
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.cityMall);
  }

  bool _tryStartCherieQuest006OfficeIfNeeded(String enteredRoom) {
    if (LocationsData.migrateLegacyRoomId(enteredRoom) !=
        LocationsData.cityMallGiftShopOffice) {
      return false;
    }
    if (currentZone != 'CITY' || !isInsideRoom) return false;
    if (_ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return false;
    }
    if (_worldState.cherieAnimatorIntroStep != 0) return false;
    if (_eventVideoPath != null) return false;
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    if (!CherieQuest006.canStartOfficeEntry(
      cherie: cherie,
      world: _worldState,
      weekdayIndex: day,
      hour: hour,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
      npcService: npcService,
      q1phase: _ui.cherieQuest001OfficePhase,
      quest002ScriptedActive: _isCherieQuest002ScriptedDialogActive(),
      quest002MidFlow: CherieQuest002.isActiveMidFlow(_worldState),
      quest003ScriptedActive: _isCherieQuest003ScriptedDialogActive(),
      quest004MidFlow: CherieQuest004.isActiveMidFlow(_worldState),
      quest005MidFlow: CherieQuest005.isActiveMidFlow(_worldState),
      eventVideoPath: _eventVideoPath,
    )) {
      return false;
    }

    setState(() {
      CherieQuest006.startOfficePhase(_worldState);
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest006Patch(
        CherieQuest006.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
    return true;
  }

  void _tryResumeCherieQuest006OfficeIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.cityMallGiftShopOffice) return;
    if (currentZone != 'CITY' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.cityMallGiftShopOffice) return;
    if (!CherieQuest006.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest006PresentationSyncedStep ==
        _worldState.cherieQuest006Step) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest006Patch(
      CherieQuest006.patchForState(world: _worldState),
    );
  }

  void _maybeResumeCherieQuest006AfterLoad() {
    if (!CherieQuest006.isActiveMidFlow(_worldState)) return;
    if (!CherieQuest006.isScriptedDialogActive(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      return;
    }
    if (_cherieQuest006PresentationSyncedStep ==
        _worldState.cherieQuest006Step) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest006Patch(
      CherieQuest006.patchForState(world: _worldState),
    );
  }

  void _onCherieQuest006GiveOral() {
    if (_worldState.cherieQuest006Step != 1) return;
    setState(() {
      _worldState.cherieQuest006Step = 2;
      _applyCherieQuest006Patch(
        CherieQuest006.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest006GrabHair() {
    if (_worldState.cherieQuest006Step != 2) return;
    setState(() {
      _worldState.cherieQuest006Step = 3;
      _applyCherieQuest006Patch(
        CherieQuest006.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest006Finish() {
    if (_worldState.cherieQuest006Step != 3) return;
    setState(() {
      _worldState.cherieQuest006Step = 4;
      _applyCherieQuest006Patch(
        CherieQuest006.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest006LeaveFinish() {
    if (_worldState.cherieQuest006Step != 4) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest006.applyFinaleRewards(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeCharisma: _playerStats.changeCharisma,
        changeEnergy: _playerStats.changeEnergy,
        clearPlayerArousal: () {
          _playerStats.player.arousal = 0;
        },
      );
      CherieQuest006.markComplete(_worldState);
      _resetCherieQuest006PresentationSession();
      _teleportCherieQuest006ToTrcMall();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005OfficeRide() {
    if (_worldState.cherieQuest005Step != 1) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _teleportCherieQuest005ToBedroom();
      _worldState.cherieQuest005Step = 2;
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step2Or3Finish() {
    final s = _worldState.cherieQuest005Step;
    if (s != 2 && s != 3) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      if (s == 2) {
        CherieQuest005.applyRewardStep2Finish(
          cherie,
          changeMoney: _playerStats.changeMoney,
          addGameMinutes: _timeController.addMinutes,
          changeMassageExperience: _playerStats.changeMassageExperience,
          changeCharisma: _playerStats.changeCharisma,
          changeArousal: _playerStats.changeArousal,
          changeEnergy: _playerStats.changeEnergy,
        );
      } else {
        CherieQuest005.applyRewardStep3Finish(
          cherie,
          changeMoney: _playerStats.changeMoney,
          addGameMinutes: _timeController.addMinutes,
          changeMassageExperience: _playerStats.changeMassageExperience,
          changeCharisma: _playerStats.changeCharisma,
          changeArousal: _playerStats.changeArousal,
          changeEnergy: _playerStats.changeEnergy,
        );
      }
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005GropeChest() {
    if (_worldState.cherieQuest005Step != 2) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest005Step = 3;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005PetKitty() {
    if (_worldState.cherieQuest005Step != 3) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest005Step = 4;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step4Finish() {
    if (_worldState.cherieQuest005Step != 4) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final pick = Random().nextInt(3);
    _worldState.cherieQuest005Step42PantsPick = pick;
    cherie.changeArousal(CherieQuest005.step42CherieArousalDeltaForPick(pick));
    setState(() {
      _worldState.cherieQuest005Step = 6;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step4Lick() {
    if (_worldState.cherieQuest005Step != 4) return;
    if (_worldState.cherieQuest005Lizun != 1) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      _worldState.cherieQuest005Step = 5;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step4EllipsisToStep42() {
    if (_worldState.cherieQuest005Step != 4) return;
    if (_worldState.cherieQuest005Lizun != 2) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final pick = Random().nextInt(3);
    _worldState.cherieQuest005Step42PantsPick = pick;
    cherie.changeArousal(CherieQuest005.step42CherieArousalDeltaForPick(pick));
    setState(() {
      _worldState.cherieQuest005Step = 6;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step4LeaveEarly() {
    if (_worldState.cherieQuest005Step != 4) return;
    if (_worldState.cherieQuest005Lizun != 1) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest005.applyRewardStep4LeaveEarly(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step41Leave() {
    if (_worldState.cherieQuest005Step != 5) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest005.applyRewardStep41Finish(
        cherie,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step6Ellipsis() {
    if (_worldState.cherieQuest005Step != 6) return;
    setState(() {
      _worldState.cherieQuest005Step =
          CherieQuest005.stepAfterPantsEllipsis(_worldState);
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step7Leave() {
    if (_worldState.cherieQuest005Step != 7) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest005.applyRewardVariant1Leave(
        cherie,
        _worldState,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step8Agree() {
    if (_worldState.cherieQuest005Step != 8) return;
    setState(() {
      _worldState.cherieQuest005Step = 9;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step9Leave() {
    if (_worldState.cherieQuest005Step != 9) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest005.applyRewardPhotoSessionLeave(
        cherie,
        _worldState,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step10ExitPool() {
    if (_worldState.cherieQuest005Step != 10) return;
    setState(() {
      _worldState.cherieQuest005Step = 11;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step11Agree() {
    if (_worldState.cherieQuest005Step != 11) return;
    setState(() {
      _worldState.cherieQuest005Step = 12;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step11Decline() {
    if (_worldState.cherieQuest005Step != 11) return;
    setState(() {
      _worldState.cherieQuest005Step = 13;
      _applyCherieQuest005Patch(
        CherieQuest005.patchForState(world: _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step12Leave() {
    if (_worldState.cherieQuest005Step != 12) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest005.applyRewardPoolAgreeLeave(
        cherie,
        _worldState,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  void _onCherieQuest005Step13Leave() {
    if (_worldState.cherieQuest005Step != 13) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    setState(() {
      CherieQuest005.applyRewardPoolDeclineLeave(
        cherie,
        _worldState,
        changeMoney: _playerStats.changeMoney,
        addGameMinutes: _timeController.addMinutes,
        changeMassageExperience: _playerStats.changeMassageExperience,
        changeCharisma: _playerStats.changeCharisma,
        changeArousal: _playerStats.changeArousal,
        changeEnergy: _playerStats.changeEnergy,
      );
      _finishCherieQuest005Run();
    });
    _saveService.autosave();
  }

  VoidCallback? _cherieQuest005ActionHandler({
    required String actionId,
    required int step,
  }) {
    switch (actionId) {
      case 'ride':
        return _onCherieQuest005OfficeRide;
      case 'gropeChest':
        return _onCherieQuest005GropeChest;
      case 'petKitty':
        return _onCherieQuest005PetKitty;
      case 'lick':
        return _onCherieQuest005Step4Lick;
      case 'exitPool':
        return _onCherieQuest005Step10ExitPool;
      case 'decline':
        return _onCherieQuest005Step11Decline;
      case 'ellipsis':
        if (step == 4) return _onCherieQuest005Step4EllipsisToStep42;
        return _onCherieQuest005Step6Ellipsis;
      case 'agree':
        if (step == 8) return _onCherieQuest005Step8Agree;
        return _onCherieQuest005Step11Agree;
      case 'finish':
        if (step == 2 || step == 3) return _onCherieQuest005Step2Or3Finish;
        return _onCherieQuest005Step4Finish;
      case 'leave':
        if (step == 4) return _onCherieQuest005Step4LeaveEarly;
        if (step == 5) return _onCherieQuest005Step41Leave;
        if (step == 7) return _onCherieQuest005Step7Leave;
        if (step == 9) return _onCherieQuest005Step9Leave;
        if (step == 12) return _onCherieQuest005Step12Leave;
        if (step == 13) return _onCherieQuest005Step13Leave;
        return null;
      default:
        return null;
    }
  }

  Widget? _cherieQuest006PriorityActionPanelIfAny() {
    if (!_isCherieQuest006ScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;
    final s = _worldState.cherieQuest006Step;
    final actionIds = CherieQuestRuntime.quest006ActionIds(step: s);
    if (actionIds.isEmpty) return null;
    final actionId = actionIds.first;
    final key = CherieQuestRuntime.quest006ActionL10nKey(actionId);
    if (key == null) return null;
    VoidCallback onTap;
    switch (actionId) {
      case 'oral':
        onTap = _onCherieQuest006GiveOral;
        break;
      case 'hair':
        onTap = _onCherieQuest006GrabHair;
        break;
      case 'finish':
        onTap = _onCherieQuest006Finish;
        break;
      case 'leave':
        onTap = _onCherieQuest006LeaveFinish;
        break;
      default:
        return null;
    }
    return _actionPanelSection(<Widget>[
      _navBtn(
        t(key).toUpperCase(),
        onTap,
      ),
    ]);
  }

  Widget? _cherieQuest005PriorityActionPanelIfAny() {
    if (!_isCherieQuest005ScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;
    final s = _worldState.cherieQuest005Step;
    final liz = _worldState.cherieQuest005Lizun;

    if (CherieQuest005.shouldPresentOfficeScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      final actionIds = CherieQuestRuntime.quest005OfficeActionIds(step: s);
      if (actionIds.isEmpty) return null;
      final key = CherieQuestRuntime.quest005ActionL10nKey(actionIds.first);
      if (key == null) return null;
      final onTap = _cherieQuest005ActionHandler(
        actionId: actionIds.first,
        step: s,
      );
      if (onTap == null) return null;
      return _actionPanelSection(<Widget>[
        _navBtn(t(key).toUpperCase(), onTap),
      ]);
    }

    if (CherieQuest005.shouldPresentBedroomScriptedUi(
      world: _worldState,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      final children = <Widget>[];
      void addPair(String label, VoidCallback onTap) {
        if (children.isNotEmpty) children.add(const SizedBox(height: 8));
        children.add(_navBtn(label.toUpperCase(), onTap));
      }

      final actionIds = CherieQuestRuntime.quest005BedroomActionIds(
        step: s,
        lizun: liz,
      );
      if (actionIds.isEmpty) {
        return null;
      }
      for (final actionId in actionIds) {
        final key = CherieQuestRuntime.quest005ActionL10nKey(actionId);
        if (key == null) continue;
        final onTap = _cherieQuest005ActionHandler(
          actionId: actionId,
          step: s,
        );
        if (onTap == null) continue;
        addPair(t(key), onTap);
      }
      if (children.isEmpty) return null;

      return _actionPanelSection(children);
    }

    return null;
  }

  void _applyCherieQuest002OfficePatch(CherieQuest002OfficePatch p) {
    final loc = sl<LocaleController>();
    newsMessage = loc.t(p.newsL10nKey);
    if (p.imagePath != null) {
      _ui.setEventImagePath(p.imagePath);
    } else {
      _ui.setEventImagePath(null);
    }
    if (p.videoPath != null) {
      _eventVideoPath = p.videoPath;
      _eventVideoMuted = p.videoMuted;
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
    _cherieQuest002PresentationSyncedStep = _worldState.cherieQuest002Step;
  }

  void _resetCherieQuest002OfficeSession({
    bool applySaturdaySundayBlock = false,
  }) {
    _cherieQuest002PresentationSyncedStep = null;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoFullScreen = false;
    _eventVideoLoop = false;
    if (applySaturdaySundayBlock &&
        _timeController.weekdayIndex == 5) {
      _worldState.cherieQuest002SundayBlocked = true;
    }
    newsMessage = LocationsData.getLocationDisplayName(currentRoom);
  }

  void _teleportToCherieHomeHallForQuest002() {
    if (currentZone != 'POOR_VILLAGE') {
      _addTravelTime(currentZone, 'POOR_VILLAGE');
    }
    _nav.setZoneAndRoom(
      'POOR_VILLAGE',
      LocationsData.poorVillageGiftShopOwnerHall,
    );
    _nav.setIsInsideRoom(true);
    _worldState.currentZone = 'POOR_VILLAGE';
    _worldState.currentRoom = LocationsData.poorVillageGiftShopOwnerHall;
    _worldState.isInsideRoom = true;
    
    currentZone = 'POOR_VILLAGE';
    currentRoom = LocationsData.poorVillageGiftShopOwnerHall;
    isInsideRoom = true;
  }

  void _teleportCherieQuest002ToCityOverview() {
    if (currentZone != 'CITY') {
      _addTravelTime(currentZone, 'CITY');
    }
    _nav.setZoneAndRoom('CITY', LocationsData.cityOverview);
    _nav.setIsInsideRoom(false);
    _worldState.currentZone = 'CITY';
    _worldState.currentRoom = LocationsData.cityOverview;
    _worldState.isInsideRoom = false;
    
    currentZone = 'CITY';
    currentRoom = LocationsData.cityOverview;
    isInsideRoom = false;
    newsMessage =
        LocationsData.getLocationDisplayName(LocationsData.cityOverview);
  }

  void _exitCherieQuest002Step5EarlyToCity(int tips) {
    final loc = sl<LocaleController>();
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null || !mounted) return;
    if (_playerStats.player.energy < CherieQuest002.energyRewardBlockCost) {
      showInsufficientEnergyDialog(context);
      return;
    }
    setState(() {
      _playerStats.changeMoney(
        CherieQuest002.rewardMoneyTransport +
            CherieQuest002.rewardMoneyAnimatorShift +
            tips,
      );
      _playerStats.changeEnergy(
        -CherieQuest002.energyRewardBlockCost.toDouble(),
      );
      _playerStats.changeCharisma(1);
      cherie.addRelationship(5);
      CherieQuest002.resetAfterPartialPayout(_worldState);
      _resetCherieQuest002OfficeSession();
      _teleportCherieQuest002ToCityOverview();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.t('cherie_quest_002_snack_done').replaceAll('%s', '$tips'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _saveService.autosave();
  }

  /// Перший «Закінчити» на кроці 8 масажу: нагороди, телефон, квест=true, далі тижневий цикл ніг.
  void _exitCherieQuest002Step8MainMassageFinishToCity(int tips) {
    final loc = sl<LocaleController>();
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null || !mounted) return;
    if (_playerStats.player.energy < CherieQuest002.energyRewardBlockCost) {
      showInsufficientEnergyDialog(context);
      return;
    }
    setState(() {
      _playerStats.changeMoney(
        CherieQuest002.rewardMoneyTransport +
            CherieQuest002.rewardMoneyAnimatorShift +
            tips,
      );
      _playerStats.changeEnergy(
        -CherieQuest002.energyRewardBlockCost.toDouble(),
      );
      _playerStats.changeCharisma(1);
      cherie.addRelationship(5);
      CherieQuest002.markQuest002MainArcComplete(cherie, _worldState);
      _worldState.cherieQuest002Step = 0;
      _worldState.cherieQuest002WarehouseWhoAsked = false;
      _resetCherieQuest002OfficeSession();
      _teleportCherieQuest002ToCityOverview();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.t('cherie_quest_002_snack_done').replaceAll('%s', '$tips'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _saveService.autosave();
  }

  /// Тиждень з однією кнопкою на кроці 8: без виплат, старт cooldown 2 понеділки.
  void _exitCherieQuest002Step8FinishOnlyHallWeekToCity() {
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null || !mounted) return;
    setState(() {
      CherieQuest002.applyAfterStep8FinishOnlyHallVisit(_worldState);
      _worldState.cherieQuest002Step = 0;
      _resetCherieQuest002OfficeSession();
      _teleportCherieQuest002ToCityOverview();
    });
    _saveService.autosave();
  }

  /// Повторне кроці 8: відмова від гілки ніг.
  void _exitCherieQuest002MassageLegsForfeitToCity() {
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null || !mounted) return;
    setState(() {
      CherieQuest002.markMassageLegsWaived(cherie, _worldState);
      _resetCherieQuest002OfficeSession();
      _teleportCherieQuest002ToCityOverview();
    });
    _saveService.autosave();
  }

  void _exitCherieQuest002Step9FinaleToCity() {
    final loc = sl<LocaleController>();
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null || !mounted) return;
    if (_playerStats.player.energy < CherieQuest002.energyRewardBlockCost) {
      showInsufficientEnergyDialog(context);
      return;
    }
    const tips = CherieQuest002.rewardTipsStep9Fixed;
    setState(() {
      _playerStats.changeMoney(
        CherieQuest002.rewardMoneyTransport +
            CherieQuest002.rewardMoneyAnimatorShift +
            tips,
      );
      _playerStats.changeEnergy(
        -CherieQuest002.energyRewardBlockCost.toDouble(),
      );
      _playerStats.changeCharisma(CherieQuest002.rewardCharismaStep9);
      cherie.addRelationship(CherieQuest002.rewardRelationshipStep9.toDouble());
      CherieQuest002.markMassageLegsFinale(cherie, _worldState);
      _resetCherieQuest002OfficeSession();
      _teleportCherieQuest002ToCityOverview();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.t('cherie_quest_002_snack_finale').replaceAll('%s', '$tips'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _saveService.autosave();
  }

  void _onCherieQuest002WarehouseWho() {
    if (_worldState.cherieQuest002Step != 4) return;
    if (_worldState.cherieQuest002WarehouseWhoAsked) return;
    if (!mounted) return;
    setState(() {
      _worldState.cherieQuest002WarehouseWhoAsked = true;
      final loc = sl<LocaleController>();
      newsMessage = loc.t(
        CherieQuest002.dialogueL10nKeyForStep(_worldState, 4),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest002OfferHelpFromHome() {
    if (_worldState.cherieQuest002Step != 5) return;
    _worldState.cherieQuest002Step = 6;
    if (!mounted) return;
    setState(() {
      _applyCherieQuest002OfficePatch(
        CherieQuest002.patchForPresentationStep(6, _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest002LeaveHomeEarly() {
    if (_worldState.cherieQuest002Step != 5) return;
    final tips = 100 + Random().nextInt(201);
    _exitCherieQuest002Step5EarlyToCity(tips);
  }

  void _onCherieQuest002OfferLegMassage() {
    if (_worldState.cherieQuest002Step != 8) return;
    _worldState.cherieQuest002Step = 9;
    if (!mounted) return;
    setState(() {
      _applyCherieQuest002OfficePatch(
        CherieQuest002.patchForPresentationStep(9, _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest002FinishMassageNoLegs() {
    if (_worldState.cherieQuest002Step != 8) return;
    final cherie = sl<NPCService>().npcById('cherie');
    if (cherie == null) return;
    final complete = cherie.getVar(CherieQuest002.npcVarComplete) == true;
    final legsDone = CherieQuest002.massageLegsEpilogueDone(cherie);
    if (complete &&
        _worldState.cherieQuest002MassageFinishOnlyNextHallVisit &&
        !legsDone) {
      _exitCherieQuest002Step8FinishOnlyHallWeekToCity();
      return;
    }
    if (complete &&
        _worldState.cherieQuest002MassageLegsReturnPending &&
        !legsDone) {
      _exitCherieQuest002MassageLegsForfeitToCity();
      return;
    }
    if (!complete) {
      final tips = 100 + Random().nextInt(201);
      _exitCherieQuest002Step8MainMassageFinishToCity(tips);
    }
  }

  void _onCherieQuest002PrimaryContinue() {
    final stepAtPress = _worldState.cherieQuest002Step;
    if (stepAtPress == 9) {
      _exitCherieQuest002Step9FinaleToCity();
      return;
    }

    if (stepAtPress == 1) {
      _playerStats.changeMoney(200);
    }
    CherieQuest002.advanceAfterLinearPrimary(_worldState);
    final s = _worldState.cherieQuest002Step;
    if (!mounted) return;
    setState(() {
      _applyCherieQuest002OfficePatch(
        CherieQuest002.patchForPresentationStep(s, _worldState),
      );
    });
    _saveService.autosave();
  }

  void _onCherieQuest002DeliverBoxes() {
    if (_worldState.cherieQuest002Step != 4) return;
    if (!mounted) return;
    setState(() {
      _teleportToCherieHomeHallForQuest002();
      _worldState.cherieQuest002Step = 5;
      _selectedNpcIdInRoom = 'cherie';
      _applyCherieQuest002OfficePatch(
        CherieQuest002.patchForPresentationStep(5, _worldState),
      );
    });
    _saveService.autosave();
  }

  void _tryStartCherieGiftShopOfficeAnimatorQuestIfNeeded(String enteredRoom) {
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    final patch = CherieQuest001.tryBuildOfficeEntryPatch(
      enteredRoom: enteredRoom,
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      hour: hour,
      weekdayIndex: day,
      cherie: cherie,
      npcService: npcService,
      physicalFitness: _playerStats.physical_fitness,
      massageExperience: _playerStats.massage_experience,
    );
    if (patch == null) {
      if (cherie != null &&
          cherie.getVar(CherieQuest001.giftShopWorkAnimatorVar) == true &&
          _ui.cherieQuest001OfficePhase !=
              CherieQuest001OfficePhase.inactive) {
        _ui.setCherieQuest001OfficePhase(CherieQuest001OfficePhase.inactive);
      }
      return;
    }

    final loc = sl<LocaleController>();
    _ui.setCherieQuest001OfficePhase(patch.phase);
    _selectedNpcIdInRoom = patch.selectedNpcId;
    newsMessage = loc.t(patch.newsL10nKey);
    final v = patch.video;
    if (v != null) {
      _eventVideoPath = v.path;
      _eventVideoMuted = v.muted;
      _eventVideoFullScreen = v.fullScreen;
      _eventVideoCloseWhenCompleted = v.closeWhenCompleted;
      _eventVideoLoop = v.loop;
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
  }
}
