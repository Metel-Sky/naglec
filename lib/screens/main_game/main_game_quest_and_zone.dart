part of '../main_game_screen.dart';

/// Квести й час, контент зон, права панель дій і навігація по зонах.
mixin MainGameQuestFlows on MainGameScreenStateBase, MomGameFlow, CherieGameFlow, PiperGameFlow, MainGameNpcFinance {
  bool get _useQuestRuntimeV2 => sl<SettingsController>().useQuestRuntimeV2;

  bool get _allowEventImageOverlay =>
      _danielleSpyCaughtUiActive || _isPiperQuest001GgDealRevealOverlayActive();

  /// Активне in-room відео у StreetView (intro / душ / sex / kompromat).
  bool get _hasActiveStreetViewRoomVideo =>
      SemJuniperRoomIntro.isSceneActive(
        introUiActive: _semJuniperIntroUiActive,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ) ||
      (_juniperShowerVideoPath != null &&
          _juniperShowerVideoPath!.trim().isNotEmpty) ||
      (_juniperSemRoomSexUiActive &&
          _juniperSemRoomSexVideoPath != null &&
          _juniperSemRoomSexVideoPath!.trim().isNotEmpty) ||
      JuniperManuelKompromatInRoomScene.isVideoSceneActive(
        phase: _juniperManuelKompromatPhase,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ) ||
      JuniperQuest003.isLoungeVideoSceneActive(
        uiActive: _juniperQuest003UiActive,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ) ||
      _isJuniperQuest003HallStreetViewVideoActive() ||
      (_momQuest001VideoPath != null && _isMomQuest001ScriptedDialogActive());

  /// Перший шар — view зони з [VideoSceneWidget], не [EventInteractionOverlay].
  bool get _usesStreetViewRoomContentLayer =>
      InRoomVideoPlayback.usesZoneRoomContentLayer(
        hasActiveInRoomVideo: _hasActiveStreetViewRoomVideo,
        overlayEventVideoPath: _overlayEventVideoPath,
        eventVideoPendingButton: _eventVideoPendingButton,
        eventImagePath: _eventImagePath,
        allowEventImageOverlay: _allowEventImageOverlay,
      );

  bool get _questRuntimeMirrorMode =>
      sl<SettingsController>().questRuntimeMirrorMode;

  /// Без стандартного растру NPC у кімнаті (Danielle spy, reveal Пайпер тощо).
  bool get _suppressRoomNpcRasterForScene =>
      _danielleSpyCaughtUiActive ||
      _juniperShowerUiActive ||
      _juniperSemRoomSexUiActive ||
      _isJuniperManuelKompromatStep1UiCoherent() ||
      _isJuniperManuelKompromatStep2UiCoherent() ||
      _isJuniperManuelKompromatStep2AfterFleeUiCoherent() ||
      _isJuniperManuelKompromatStep3UiCoherent() ||
      _isJuniperManuelKompromatStep4UiCoherent() ||
      _juniperQuest003UiActive ||
      _juniperQuest003HallUiActive ||
      SemJuniperRoomIntro.isSceneActive(
        introUiActive: _semJuniperIntroUiActive,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ) ||
      _isPiperQuest001GgDealRevealOverlayActive() ||
      (_momQuest001VideoPath != null && _isMomQuest001ScriptedDialogActive());

  /// Галерея, профіль, рюкзак, характеристики та оверлей «домовитись» — закрити перед іншою дією гравця.
  void _prepareForPlayerAction() {
    _dismissNpcGalleryIfOpen();
    _dismissPiperGgDealRevealIfActive();
  }

  /// Чи [newsMessage] зараз належить активному кроку квесту чи івенту в цій локації.
  /// Квести/івенти з обов'язковими 100% збудженення — пріоритетніше звичайних квестів і generic stojak.
  Widget? _fullArousalQuestPriorityActionPanelIfAny() {
    // return _momStojakQuestPriorityActionPanelIfAny(); // when implemented
    return null;
  }

  bool _canShowJuniperQuest003MasturbateRoomButton() =>
      !_juniperQuest003UiActive &&
      JuniperQuest003.canShowMasturbateButton(
        arousal: _playerStats.arousal,
        maxArousal: _playerStats.player.maxArousal,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  void _appendJuniperQuest003MasturbateRoomButton(List<Widget> actionWidgets) {
    if (!_canShowJuniperQuest003MasturbateRoomButton()) return;
    final t = sl<LocaleController>().t;
    actionWidgets.add(
      _navBtn(
        t(JuniperQuest003.l10nBtnMasturbate).toUpperCase(),
        () => setState(_onJuniperQuest003MasturbatePressed),
      ),
    );
    actionWidgets.add(const SizedBox(height: 8));
  }

  /// gg_event_001_stojak: лише «Піти», без квестових/стандартних кнопок NPC.
  Widget? _ggEvent001StojakPriorityActionPanelIfAny() {
    if (!isInsideRoom) return null;
    if (_juniperQuest003UiActive) return null;
    if (_canShowJuniperQuest003MasturbateRoomButton()) return null;
    final activeNPCs = _getActiveNPCsInCurrentRoom();
    if (activeNPCs.isEmpty) return null;
    final stats = _playerStats;
    if (!GgEvent001Stojak.shouldShowGenericStojakFallback(
      activeNpcs: activeNPCs,
      selectedNpcIdInRoom: _selectedNpcIdInRoom,
      playerArousal: stats.arousal,
      playerMaxArousal: stats.player.maxArousal,
      zone: currentZone,
      room: currentRoom,
      hour: _timeController.dateTime.hour,
      world: _worldState,
    )) {
      return null;
    }
    final npc = GgEvent001Stojak.npcForStojakInRoom(
      activeNpcs: activeNPCs,
      selectedNpcIdInRoom: _selectedNpcIdInRoom,
    );
    if (npc != null) {
      GgEvent001Stojak.onStojakPanelFirstBuild(npc);
    }
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(t('gg_event_001_stojak_btn_leave'), _handleBackTap),
        ],
      ),
    );
  }

  /// ГГ не мився 3+ дні — NPC у кімнаті лише «Фу, йди помийся.» і «Піти».
  Widget? _ggHygieneStinkyPriorityActionPanelIfAny() {
    if (!isInsideRoom) return null;
    if (_canShowJuniperQuest003MasturbateRoomButton()) return null;
    if (!GgHygiene.isStinky(_worldState)) return null;
    if (_isQuestOrEventScriptedDialogForNews()) return null;
    final activeNPCs = _getActiveNPCsInCurrentRoom();
    if (activeNPCs.isEmpty) return null;
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(t('gg_event_001_stojak_btn_leave'), _handleBackTap),
        ],
      ),
    );
  }

  bool _isQuestOrEventScriptedDialogForNews() {
    if (_ui.cherieQuest001OfficePhase != CherieQuest001OfficePhase.inactive) {
      return true;
    }
    if (_worldState.cherieAnimatorIntroStep != 0) return true;
    if (_useQuestUiIsolation && _isQuestUiIsolationScriptedDialogForNews()) {
      return true;
    }
    return _isCherieMassageFunEventScriptedDialogActive() ||
        _isCherieQuest002ScriptedDialogActive() ||
        _isCherieQuest003ScriptedDialogActive() ||
        _isCherieQuest004ScriptedDialogActive() ||
        _isCherieQuest005ScriptedDialogActive() ||
        _isCherieQuest006ScriptedDialogActive() ||
        _isMomQuest001ScriptedDialogActive() ||
        _isMomEvent002ScriptedDialogActive() ||
        _isPiperQuest001SnitchAckScene() ||
        _isPiperQuest001ScriptedDialogActive() ||
        _isPiperHallWeekendEventScriptedDialogActive() ||
        _isPiperGgVoluntaryPunishVideoActive() ||
        _isPiperGgHarshPunishSceneActive() ||
        _isPiperQuest001GgDealRevealActive() ||
        _sashaComunicateInHallUiActive ||
        _sashaMorningRunUiActive ||
        _juniperPalivoApologyTalkActive ||
        (!_useQuestUiIsolation &&
            (SemJuniperRoomIntro.isSceneActive(
                  introUiActive: _semJuniperIntroUiActive,
                  zone: currentZone,
                  streetHouse: currentStreetHouse,
                  insideRoom: isInsideRoom,
                  room: currentRoom,
                ) ||
                _semGirlsTalkActive ||
                _semGirlsSisterTalkActive ||
                _semGirlsHintTalkActive ||
                _juniperQuest002Step1UiActive ||
                _semGirlsFollowUpActive ||
                _juniperShowerUiActive ||
                _juniperSemRoomSexUiActive ||
                _isJuniperManuelKompromatStep1UiCoherent() ||
                _isJuniperManuelKompromatStep2UiCoherent() ||
                _isJuniperManuelKompromatStep2AfterFleeUiCoherent() ||
                _isJuniperManuelKompromatStep3UiCoherent() ||
                _isJuniperManuelKompromatStep4UiCoherent() ||
                _juniperQuest003HallUiActive ||
                JuniperQuest003.isCorridorHallSoundsHintContext(
                  world: _worldState,
                  zone: currentZone,
                  streetHouse: currentStreetHouse,
                  insideRoom: isInsideRoom,
                  room: currentRoom,
                ) ||
                JuniperQuest003.isHallFollowUpDialogContext(
                  world: _worldState,
                  gameDateKey: _timeController.onlyDate,
                  hour: _timeController.dateTime.hour,
                  zone: currentZone,
                  streetHouse: currentStreetHouse,
                  insideRoom: isInsideRoom,
                  room: currentRoom,
                ) ||
                _isJuniperQuest003OfferHelpScriptedDialogActive()));
  }

  bool _juniperQuest003GreenCorridorHintActive() =>
      JuniperQuest003.isCorridorHallSoundsHintContext(
        world: _worldState,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  bool _isJuniperManuelKompromatStep1UiCoherent() =>
      JuniperManuelKompromatInRoomScene.isStep1UiCoherent(
        phase: _juniperManuelKompromatPhase,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  bool _isJuniperManuelKompromatStep2UiCoherent() =>
      JuniperManuelKompromatInRoomScene.isStep2UiCoherent(
        phase: _juniperManuelKompromatPhase,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  bool _isJuniperManuelKompromatStep2AfterFleeUiCoherent() =>
      JuniperManuelKompromatInRoomScene.isStep2AfterFleeUiCoherent(
        phase: _juniperManuelKompromatPhase,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  bool _isJuniperManuelKompromatStep3UiCoherent() =>
      JuniperManuelKompromatInRoomScene.isStep3UiCoherent(
        phase: _juniperManuelKompromatPhase,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  bool _isJuniperManuelKompromatStep4UiCoherent() =>
      JuniperManuelKompromatInRoomScene.isStep4UiCoherent(
        phase: _juniperManuelKompromatPhase,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  void _resetJuniperQuest002DialogNewsIfPresent() {
    final t = sl<LocaleController>().t;
    if (!JuniperQuest002Naslidku.isQuestDialogMessage(newsMessage, t)) {
      return;
    }
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
  }

  void _purgeJuniperQuest002Step1IfMisplaced() {
    if (!_juniperQuest002Step1UiActive) return;
    final activeNPCs = _getActiveNPCsInCurrentRoom();
    if (JuniperQuest002Naslidku.isStep1UiCoherent(
      step1UiActive: true,
      activeNpcs: activeNPCs,
    )) {
      return;
    }
    _juniperQuest002Step1UiActive = false;
    _resetJuniperQuest002DialogNewsIfPresent();
  }

  void _ensureJuniperQuest002Step1UiCoherent() {
    _purgeJuniperQuest002Step1IfMisplaced();
    if (!_juniperQuest002Step1UiActive) return;
    newsMessage = sl<LocaleController>().t(JuniperQuest002Naslidku.l10nStep1Dialogue);
  }

  void _beginJuniperQuest002Step1Talk() {
    _timeController.addMinutes(5);
    JuniperQuest002Naslidku.markStarted(_worldState);
    _selectedNpcIdInRoom = kJuniperNpcId;
    _juniperQuest002Step1UiActive = true;
    newsMessage = sl<LocaleController>().t(JuniperQuest002Naslidku.l10nStep1Dialogue);
    _saveService.autosave();
  }

  void _deferJuniperQuest002Step1() {
    _juniperQuest002Step1UiActive = false;
    _resetJuniperQuest002DialogNewsIfPresent();
    _selectedNpcIdInRoom = kJuniperNpcId;
    _saveService.autosave();
  }

  void _juniperQuest002ShowVideoPressed() {
    // Крок 2 — буде в наступному ТЗ.
  }

  void _onJuniperQuest003MasturbatePressed() {
    final npcService = sl<NPCService>();
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final juniperInHouse = JuniperQuest003.isJuniperInFriendHouse(
      npcService: npcService,
      hour: hour,
      day: day,
    );
    if (juniperInHouse) {
      JuniperQuest003.beginLoungeCatchPin(_worldState);
    }
    if (JuniperQuest003OfferHelp.canEnterOfferHelpFlow(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
      juniperInFriendHouse: juniperInHouse,
    )) {
      _clearJuniperQuest003HallUiOnly();
      _enterJuniperQuest003OfferHelpFlowIfNeeded();
      return;
    }
    _clearJuniperQuest003HallUiOnly();
    final videoPath = JuniperQuest003.resolveMasturbateVideoPath(
      npcService: npcService,
      hour: hour,
      day: day,
    );
    JuniperQuest003.markStarted(_worldState);
    JuniperQuest003.applyPlayerArousalReset(_playerStats);
    final handle = _launchInRoomVideo(
      videoPath: videoPath,
      previousPlaybackTick: _juniperQuest003PlaybackTick,
      loop: true,
    );
    _juniperQuest003UiActive = true;
    _juniperQuest003VideoPath = handle.videoPath;
    _juniperQuest003PlaybackTick = handle.playbackTick;
    _juniperQuest003CatchSceneActive =
        handle.videoPath == JuniperQuest003.juniperHandjobVideoPath;
    newsMessage = '';
    _saveService.autosave();
  }

  bool _isJuniperQuest003OfferHelpScriptedDialogActive() {
    final step = JuniperQuest003OfferHelp.activeStep(_worldState);
    if (step == JuniperQuest003OfferHelpStep.inactive) return false;
    return JuniperQuest003OfferHelp.isOfferUiCoherent(
      world: _worldState,
      uiActive: _juniperQuest003UiActive,
      step: step,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    );
  }

  void _launchJuniperQuest003OfferHelpVideo(
    JuniperQuest003OfferHelpStep step,
  ) {
    final videoPath = JuniperQuest003OfferHelp.videoPathForStep(step);
    if (videoPath == null) return;
    _clearJuniperQuest003HallUiOnly();
    final handle = _launchInRoomVideo(
      videoPath: videoPath,
      previousPlaybackTick: _juniperQuest003PlaybackTick,
      loop: true,
    );
    _juniperQuest003UiActive = true;
    _juniperQuest003VideoPath = handle.videoPath;
    _juniperQuest003PlaybackTick = handle.playbackTick;
  }

  void _beginJuniperQuest003OfferHelpStep1() {
    JuniperQuest003.clearHallFollowUpForOfferBranch(_worldState);
    JuniperQuest003.markStarted(_worldState);
    JuniperQuest003.applyPlayerArousalReset(_playerStats);
    JuniperQuest003OfferHelp.beginStep1(_worldState);
    _clearJuniperQuest003UiOnly();
    _launchJuniperQuest003OfferHelpVideo(
      JuniperQuest003OfferHelpStep.step1Offer,
    );
    _ensureJuniperQuest003OfferHelpUiCoherent();
    _saveService.autosave();
  }

  void _resumeJuniperQuest003OfferHelpFlow() {
    JuniperQuest003.clearHallFollowUpForOfferBranch(_worldState);
    final step = JuniperQuest003OfferHelp.activeStep(_worldState);
    JuniperQuest003.markStarted(_worldState);
    _launchJuniperQuest003OfferHelpVideo(step);
    _ensureJuniperQuest003OfferHelpUiCoherent();
    _saveService.autosave();
  }

  void _enterJuniperQuest003OfferHelpFlowIfNeeded() {
    final npcService = sl<NPCService>();
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final juniperInHouse = JuniperQuest003.isJuniperInFriendHouse(
      npcService: npcService,
      hour: hour,
      day: day,
    );
    if (JuniperQuest003OfferHelp.canStartOfferHelp(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
      juniperInFriendHouse: juniperInHouse,
    )) {
      _beginJuniperQuest003OfferHelpStep1();
      return;
    }
    if (JuniperQuest003OfferHelp.canResumeOfferHelp(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      _resumeJuniperQuest003OfferHelpFlow();
    }
  }

  void _syncJuniperQuest003OfferHelpPendingUi() {
    if (_juniperQuest003UiActive) return;
    if (!JuniperQuest003OfferHelp.canResumeOfferHelp(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return;
    }
    _resumeJuniperQuest003OfferHelpFlow();
  }

  void _ensureJuniperQuest003OfferHelpUiCoherent() {
    final step = JuniperQuest003OfferHelp.activeStep(_worldState);
    if (!_juniperQuest003UiActive ||
        !JuniperQuest003OfferHelp.isOfferUiCoherent(
          world: _worldState,
          uiActive: true,
          step: step,
          zone: currentZone,
          streetHouse: currentStreetHouse,
          insideRoom: isInsideRoom,
          room: currentRoom,
        )) {
      return;
    }
    final key = JuniperQuest003OfferHelp.dialogueL10nKeyForStep(step);
    if (key != null) {
      newsMessage = sl<LocaleController>().t(key);
    } else {
      newsMessage = '';
    }
  }

  void _onJuniperQuest003OfferRefused() {
    JuniperQuest003OfferHelp.applyRefusePenalties(
      npcService: sl<NPCService>(),
    );
    JuniperQuest003OfferHelp.beginColdShoulder(
      _worldState,
      gameDateKey: _timeController.onlyDate,
    );
    _clearJuniperQuest003UiOnly();
    JuniperQuest003.clearLoungePin(_worldState);
    _resetJuniperQuest003DialogNewsIfPresent();
    _resetNewsMessageIfOutsideQuestEventContext();
    _saveService.autosave();
  }

  void _onJuniperQuest003OfferAgreeStep1() {
    JuniperQuest003OfferHelp.advanceToStep2(_worldState);
    _launchJuniperQuest003OfferHelpVideo(
      JuniperQuest003OfferHelpStep.step2SecretTalk,
    );
    _ensureJuniperQuest003OfferHelpUiCoherent();
    _saveService.autosave();
  }

  void _onJuniperQuest003OfferSecretStep2() {
    JuniperQuest003OfferHelp.advanceToStep3Sex(_worldState);
    _launchJuniperQuest003OfferHelpVideo(
      JuniperQuest003OfferHelpStep.step3Sex,
    );
    JuniperVideoSexStats.onVideoStarted(
      JuniperQuest003OfferHelp.videoStep3SexPath,
    );
    newsMessage = '';
    _saveService.autosave();
  }

  void _finishJuniperQuest003OfferHelpSexScene() {
    JuniperQuest003OfferHelp.finishSexScene(_worldState);
    _clearJuniperQuest003UiOnly();
    _resetNewsMessageIfOutsideQuestEventContext();
    _saveService.autosave();
  }

  void _syncJuniperQuest003OfferHelpOnRoomEntry() {
    JuniperQuest003OfferHelp.syncStuckStepIfBelowCatchThreshold(_worldState);
    _syncJuniperQuest003OfferHelpPendingUi();
    final step = JuniperQuest003OfferHelp.activeStep(_worldState);
    if (step == JuniperQuest003OfferHelpStep.inactive) return;
    if (!JuniperQuest003.isInFriendLounge(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      if (_juniperQuest003UiActive) {
        _clearJuniperQuest003UiOnly();
      }
      return;
    }
    if (!_juniperQuest003UiActive) {
      _launchJuniperQuest003OfferHelpVideo(step);
    }
    _ensureJuniperQuest003OfferHelpUiCoherent();
    _saveService.autosave();
  }

  void _leaveJuniperQuest003LoungeWithoutMasturbating() {
    _exitFriendHouseInteriorToCorridor();
    _resetNewsMessageIfOutsideQuestEventContext();
    _saveService.autosave();
  }

  void _finishJuniperQuest003Scene() {
    if (!mounted) return;
    if (JuniperQuest003OfferHelp.isOfferHelpVideoPath(_juniperQuest003VideoPath) &&
        JuniperQuest003OfferHelp.isOfferHelpFlowActive(_worldState)) {
      final step = JuniperQuest003OfferHelp.activeStep(_worldState);
      setState(() {
        if (step == JuniperQuest003OfferHelpStep.step3Sex) {
          _finishJuniperQuest003OfferHelpSexScene();
        } else {
          _onJuniperQuest003OfferRefused();
        }
      });
      return;
    }
    final wasCatchScene = _juniperQuest003CatchSceneActive ||
        _juniperQuest003VideoPath == JuniperQuest003.juniperHandjobVideoPath ||
        (_worldState.juniperQuest003LoungePinActive &&
            !JuniperQuest003OfferHelp.isOfferHelpFlowActive(_worldState));
    final catchVideoPath = _juniperQuest003VideoPath ??
        (wasCatchScene ? JuniperQuest003.juniperHandjobVideoPath : null);

    if (wasCatchScene) {
      JuniperQuest003OfferHelp.syncStuckStepIfBelowCatchThreshold(_worldState);
      final canHallFollowUp =
          JuniperQuest003.canBeginHallFollowUpAfterCatch(_worldState);
      if (catchVideoPath != null) {
        JuniperQuest003.applyCatchSceneRewards(
          npcService: sl<NPCService>(),
          videoPath: catchVideoPath,
        );
      }
      JuniperQuest003.recordLoungeCatch(
        _worldState,
        gameDateKey: _timeController.onlyDate,
      );
      setState(() {
        _clearJuniperQuest003UiOnly();
        JuniperQuest003.clearLoungePin(_worldState);
        if (canHallFollowUp) {
          JuniperQuest003.beginHallFollowUp(
            _worldState,
            gameDateKey: _timeController.onlyDate,
          );
        }
        _exitFriendHouseInteriorToCorridor();
        if (canHallFollowUp &&
            JuniperQuest003.isHallFollowUpAllowed(_worldState)) {
          newsMessage = sl<LocaleController>().t(
            JuniperQuest003.l10nCorridorHallSounds,
          );
        } else {
          _ensureJuniperQuest003HallFollowUpUiCoherent();
        }
        _saveService.autosave();
      });
      return;
    }

    setState(() {
      _clearJuniperQuest003UiOnly();
      JuniperQuest003.clearLoungePin(_worldState);
      _exitFriendHouseInteriorToCorridor();
      _resetNewsMessageIfOutsideQuestEventContext();
      _saveService.autosave();
    });
  }

  void _finishJuniperQuest003HallScene() {
    if (!mounted) return;
    setState(() {
      JuniperQuest003.applyHallFollowUpRewards(npcService: sl<NPCService>());
      JuniperQuest003.completeHallFollowUp(_worldState);
      _clearJuniperQuest003HallUiOnly();
      _exitFriendHouseInteriorToCorridor();
      _resetJuniperQuest003DialogNewsIfPresent();
      _resetNewsMessageIfOutsideQuestEventContext();
      _saveService.autosave();
    });
  }

  void _beginJuniperQuest003HallScene() {
    _clearJuniperQuest003UiOnly();
    _juniperQuest003HallUiActive = true;
    final handle = _launchInRoomVideo(
      videoPath: JuniperQuest003.hallFollowUpVideoPath,
      previousPlaybackTick: _juniperQuest003HallPlaybackTick,
      loop: true,
    );
    _juniperQuest003HallVideoPath = handle.videoPath;
    _juniperQuest003HallPlaybackTick = handle.playbackTick;
    _ensureJuniperQuest003HallFollowUpUiCoherent();
  }

  bool _isJuniperQuest003HallFollowUpDialogContext() =>
      JuniperQuest003.isHallFollowUpDialogContext(
        world: _worldState,
        gameDateKey: _timeController.onlyDate,
        hour: _timeController.dateTime.hour,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  bool _isJuniperQuest003HallStreetViewVideoActive() =>
      _juniperQuest003HallUiActive &&
      JuniperQuest003.isInFriendHall(
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  String? _semJuniperQuest003HallStreetViewVideoPath() {
    if (!_isJuniperQuest003HallStreetViewVideoActive()) return null;
    final active = _juniperQuest003HallVideoPath?.trim();
    if (active != null && active.isNotEmpty) return active;
    return JuniperQuest003.hallFollowUpVideoPath;
  }

  String? _semJuniperQuest003LoungeStreetViewVideoPath() =>
      JuniperQuest003.streetViewVideoPath(
        loungeUiActive: _juniperQuest003UiActive,
        hallUiActive: false,
        loungeVideoPathActive: _juniperQuest003VideoPath,
        hallVideoPathActive: null,
        world: _worldState,
        gameDateKey: _timeController.onlyDate,
        hour: _timeController.dateTime.hour,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      );

  void _ensureJuniperQuest003HallFollowUpUiCoherent() {
    if (!JuniperQuest003.isHallFollowUpActive(_worldState)) return;
    final t = sl<LocaleController>().t;
    if (_juniperQuest003HallUiActive &&
        JuniperQuest003.isHallFollowUpDialogContext(
          world: _worldState,
          gameDateKey: _timeController.onlyDate,
          hour: _timeController.dateTime.hour,
          zone: currentZone,
          streetHouse: currentStreetHouse,
          insideRoom: isInsideRoom,
          room: currentRoom,
        )) {
      newsMessage = t(JuniperQuest003.l10nHallDialogue);
      return;
    }
    if (JuniperQuest003.isCorridorHallSoundsHintContext(
      world: _worldState,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      newsMessage = t(JuniperQuest003.l10nCorridorHallSounds);
    }
  }

  void _resetJuniperQuest003DialogNewsIfPresent() {
    final t = sl<LocaleController>().t;
    if (!JuniperQuest003.isQuestDialogMessage(newsMessage, t)) return;
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
  }

  void _purgeJuniperQuest003HallIfMisplaced() {
    if (!_juniperQuest003HallUiActive) return;
    if (JuniperQuest003.isHallFollowUpVideoSceneActive(
      uiActive: true,
      world: _worldState,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return;
    }
    _clearJuniperQuest003HallUiOnly();
  }

  void _syncJuniperQuest003HallFollowUpOnRoomEntry() {
    JuniperQuest003OfferHelp.syncStuckStepIfBelowCatchThreshold(_worldState);
    _purgeJuniperQuest003HallIfMisplaced();
    if (!JuniperQuest003.isHallFollowUpActive(_worldState) ||
        _worldState.juniperQuest003HallSceneDone) {
      return;
    }
    if (JuniperQuest003.isCorridorHallSoundsHintContext(
      world: _worldState,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      _ensureJuniperQuest003HallFollowUpUiCoherent();
      return;
    }
    if (!JuniperQuest003.isHallFollowUpDialogContext(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      hour: _timeController.dateTime.hour,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return;
    }
    if (!_juniperQuest003HallUiActive) {
      _beginJuniperQuest003HallScene();
    } else {
      final hallPath = _juniperQuest003HallVideoPath?.trim();
      if (hallPath == null || hallPath.isEmpty) {
        _beginJuniperQuest003HallScene();
      } else {
        _ensureJuniperQuest003HallFollowUpUiCoherent();
      }
    }
    _saveService.autosave();
  }

  void _closeMasturbateVideoOverlay() {
    _showMasturbateVideo = false;
    _masturbateVideoPath = null;
  }

  void _purgeJuniperQuest003IfMisplaced() {
    if (!_juniperQuest003UiActive) return;
    if (JuniperQuest003OfferHelp.isOfferHelpFlowActive(_worldState)) {
      final step = JuniperQuest003OfferHelp.activeStep(_worldState);
      if (JuniperQuest003OfferHelp.isOfferUiCoherent(
        world: _worldState,
        uiActive: true,
        step: step,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      )) {
        return;
      }
      _clearJuniperQuest003UiOnly();
      return;
    }
    if (JuniperQuest003.isLoungeVideoSceneActive(
      uiActive: true,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return;
    }
    _clearJuniperQuest003UiOnly();
    JuniperQuest003.clearLoungePin(_worldState);
  }

  Widget? _juniperQuest003HallDuringVideoPriorityActionPanelIfAny() {
    if (!_juniperQuest003HallUiActive) return null;
    if (!JuniperQuest003.isHallFollowUpVideoSceneActive(
      uiActive: true,
      world: _worldState,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return null;
    }
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(
            t('danielle_spy_parents_leave'),
            _finishJuniperQuest003HallScene,
          ),
        ],
      ),
    );
  }

  Widget? _juniperQuest003OfferHelpActionPanel(
    JuniperQuest003OfferHelpStep step,
  ) {
    final t = sl<LocaleController>().t;
    switch (step) {
      case JuniperQuest003OfferHelpStep.step1Offer:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _navBtn(
                t(JuniperQuest003OfferHelp.l10nBtnRefuse),
                () => setState(_onJuniperQuest003OfferRefused),
              ),
              const SizedBox(height: 8),
              _navBtn(
                t(JuniperQuest003OfferHelp.l10nBtnAgree),
                () => setState(_onJuniperQuest003OfferAgreeStep1),
              ),
            ],
          ),
        );
      case JuniperQuest003OfferHelpStep.step2SecretTalk:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _navBtn(
                t(JuniperQuest003OfferHelp.l10nBtnRefuse),
                () => setState(_onJuniperQuest003OfferRefused),
              ),
              const SizedBox(height: 8),
              _navBtn(
                t(JuniperQuest003OfferHelp.l10nBtnSecret),
                () => setState(_onJuniperQuest003OfferSecretStep2),
              ),
            ],
          ),
        );
      case JuniperQuest003OfferHelpStep.step3Sex:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _navBtn(
                t('danielle_spy_parents_leave'),
                () => setState(_finishJuniperQuest003OfferHelpSexScene),
              ),
            ],
          ),
        );
      case JuniperQuest003OfferHelpStep.inactive:
        return null;
    }
  }

  Widget? _juniperQuest003DuringVideoPriorityActionPanelIfAny() {
    if (!_juniperQuest003UiActive) return null;
    if (!JuniperQuest003.isLoungeVideoSceneActive(
      uiActive: true,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return null;
    }
    final offerStep = JuniperQuest003OfferHelp.activeStep(_worldState);
    if (JuniperQuest003OfferHelp.isOfferUiCoherent(
      world: _worldState,
      uiActive: true,
      step: offerStep,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return _juniperQuest003OfferHelpActionPanel(offerStep);
    }
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(t('danielle_spy_parents_leave'), _finishJuniperQuest003Scene),
        ],
      ),
    );
  }

  Widget? _juniperQuest002Step1PriorityActionPanelIfAny() {
    if (!_juniperQuest002Step1UiActive) return null;
    final activeNPCs = _getActiveNPCsInCurrentRoom();
    if (!JuniperQuest002Naslidku.isStep1UiCoherent(
      step1UiActive: true,
      activeNpcs: activeNPCs,
    )) {
      return null;
    }
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(t(JuniperQuest002Naslidku.l10nBtnShowVideo), () {
            setState(() {
              _juniperQuest002ShowVideoPressed();
            });
          }),
          const SizedBox(height: 8),
          _navBtn(t(JuniperQuest002Naslidku.l10nBtnDefer), () {
            setState(_deferJuniperQuest002Step1);
          }),
        ],
      ),
    );
  }

  void _resetJuniperManuelKompromatDialogNewsIfPresent() {
    final t = sl<LocaleController>().t;
    if (!JuniperManuelKompromatInRoomScene.isKompromatDialogMessage(
      newsMessage,
      t,
    )) {
      return;
    }
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
  }

  void _purgeJuniperManuelKompromatIfMisplaced() {
    final step1Ok = _isJuniperManuelKompromatStep1UiCoherent();
    final step2Ok = _isJuniperManuelKompromatStep2UiCoherent();
    final step2AfterFleeOk = _isJuniperManuelKompromatStep2AfterFleeUiCoherent();
    final step3Ok = _isJuniperManuelKompromatStep3UiCoherent();
    final step4Ok = _isJuniperManuelKompromatStep4UiCoherent();

    if (!step1Ok && _juniperManuelKompromatUiActive) {
      _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
      _juniperManuelKompromatVideoPath = null;
      _ui.setEventImagePath(null);
    } else if (!step2Ok && _juniperManuelKompromatStep2UiActive) {
      _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
      _juniperManuelKompromatVideoPath = null;
    } else if (!step2AfterFleeOk &&
        _juniperManuelKompromatStep2AfterFleeUiActive) {
      _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
    } else if (!step3Ok && _juniperManuelKompromatStep3UiActive) {
      _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
      _juniperManuelKompromatVideoPath = null;
      _ui.setEventImagePath(null);
    } else if (!step4Ok && _juniperManuelKompromatStep4UiActive) {
      _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
      _juniperManuelKompromatVideoPath = null;
    }

    if (!step1Ok && !step2Ok && !step2AfterFleeOk && !step3Ok && !step4Ok) {
      _resetJuniperManuelKompromatDialogNewsIfPresent();
    }
  }

  void _ensureJuniperManuelKompromatUiCoherent() {
    _purgeJuniperManuelKompromatIfMisplaced();
    final t = sl<LocaleController>().t;
    if (_isJuniperManuelKompromatStep2AfterFleeUiCoherent()) {
      newsMessage = t(JuniperQuest001.l10nStep2AfterFlee);
      return;
    }
    if (_isJuniperManuelKompromatStep4UiCoherent()) {
      final key = JuniperManuelKompromatInRoomScene.dialogueL10nKeyForPhase(
        _juniperManuelKompromatPhase,
      );
      if (key != null) {
        newsMessage = t(key);
      }
      return;
    }
    if (_isJuniperManuelKompromatStep3UiCoherent()) {
      final key = JuniperManuelKompromatInRoomScene.dialogueL10nKeyForPhase(
        _juniperManuelKompromatPhase,
      );
      if (key != null) {
        newsMessage = t(key);
      }
      return;
    }
    if (_isJuniperManuelKompromatStep2UiCoherent()) {
      newsMessage = t(JuniperQuest001.l10nStep2Intro);
      return;
    }
    if (_isJuniperManuelKompromatStep1UiCoherent()) {
      final key = JuniperManuelKompromatInRoomScene.dialogueL10nKeyForPhase(
        _juniperManuelKompromatPhase,
      );
      if (key != null) {
        newsMessage = t(key);
      }
    }
  }

  /// Після перемотки часу — хто в кімнаті за розкладом зараз; без застарілого вибору NPC.
  void _syncActiveLocationAfterTimeChange() {
    _ensureJuniperManuelKompromatUiCoherent();
    _ensureJuniperQuest002Step1UiCoherent();
    if (!isInsideRoom) {
      _selectedNpcIdInRoom = null;
      return;
    }
    _syncDanielleSpyParentsOnParentsRoomContext();
    final activeNPCs = _getActiveNPCsInCurrentRoom();
    final selectedId = _selectedNpcIdInRoom;
    if (selectedId != null &&
        !activeNPCs.any((n) => n.id == selectedId)) {
      if (selectedId == kJuniperNpcId &&
          (_juniperSemRoomSexUiActive ||
              _juniperShowerUiActive ||
              _semJuniperEveningClipShowOnThisVisit)) {
        return;
      }
      _selectedNpcIdInRoom = null;
    }
    _syncDefaultNpcSelectionInRoomIfNeeded();
  }

  /// Не показувати текст квестів/івентів поза їхнім контекстом — назва поточної локації.
  void _resetNewsMessageIfOutsideQuestEventContext() {
    _purgeSemJuniperRoomIntroIfMisplaced();
    _purgeJuniperManuelKompromatIfMisplaced();
    _purgeJuniperQuest002Step1IfMisplaced();
    _purgeJuniperQuest003IfMisplaced();
    _purgeJuniperQuest003HallIfMisplaced();
    _purgeJuniperSemRoomSexIfBlockedOrMisplaced();
    if (_isQuestOrEventScriptedDialogForNews()) return;
    if (_ui.cherieAnimatorShiftTc2DialogPending) return;
    if (_danielleSpyCaughtUiActive || _spyOnSemParentsUiActive) return;
    if (_juniperShowerUiActive) return;
    if (_juniperSemRoomSexUiActive) return;
    if (_juniperQuest003HallUiActive) return;
    if (_isJuniperManuelKompromatStep1UiCoherent()) return;
    if (_isJuniperManuelKompromatStep2UiCoherent()) return;
    if (_isJuniperManuelKompromatStep2AfterFleeUiCoherent()) return;
    if (_isJuniperManuelKompromatStep4UiCoherent()) return;
    if (_isJuniperManuelKompromatStep3UiCoherent()) return;
    if (_collegeToiletUnderwearSaleActive) return;
    if (_semTalkSubmenuActive ||
        _semParentsTalkActive ||
        _semGirlsTalkActive ||
        _semGirlsSisterTalkActive ||
        _semGirlsHintTalkActive ||
        _juniperPalivoApologyTalkActive ||
        _juniperQuest002Step1UiActive ||
        _semGirlsFollowUpActive ||
        SemJuniperRoomIntro.isSceneActive(
          introUiActive: _semJuniperIntroUiActive,
          zone: currentZone,
          streetHouse: currentStreetHouse,
          insideRoom: isInsideRoom,
          room: currentRoom,
        ) ||
        JuniperQuest003.isCorridorHallSoundsHintContext(
          world: _worldState,
          zone: currentZone,
          streetHouse: currentStreetHouse,
          insideRoom: isInsideRoom,
          room: currentRoom,
        )) {
      return;
    }
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.migrateLegacyRoomId(currentRoom),
    );
  }

  /// Тап по NPC у кімнаті: не тягнути застарілий текст іншого квесту/івенту в діалог.
  void _handleRoomNpcTap(NPCModel npc) {
    _prepareForPlayerAction();
    _selectedNpcIdInRoom = npc.id;
    if (npc.id != kJuniperNpcId && _semJuniperEveningClipShowOnThisVisit) {
      _semJuniperEveningClipShowOnThisVisit = false;
      _juniperEveningClipVideoPath = null;
    }
    if (npc.id == kJuniperNpcId &&
        JuniperQuest003OfferHelp.isColdShoulderActive(
          _worldState,
          gameDateKey: _timeController.onlyDate,
        )) {
      newsMessage = sl<LocaleController>().t(
        JuniperQuest003OfferHelp.l10nColdShoulderDialogue,
      );
      return;
    }
    if (_isQuestOrEventScriptedDialogForNews()) return;
    if (GgHygiene.isStinky(_worldState)) {
      newsMessage = sl<LocaleController>().t('gg_hygiene_stinky_reply');
      return;
    }
    newsMessage = '';
    if (npc.id == 'den') {
      _resetDenLocalUi();
      newsMessage = _getDenDialogueText(npc);
    } else if (npc.id == 'loshok' ||
        npc.id == 'rockefeller' ||
        npc.id == 'nicole' ||
        npc.id == 'dekan') {
      _ui.setEventImagePath(null);
    }
  }

  int _legacyQuestStep(String questId) {
    switch (questId) {
      case 'cherie_quest_002':
        return _worldState.cherieQuest002Step;
      case 'cherie_quest_003':
        return _worldState.cherieQuest003Step;
      case 'cherie_quest_004':
        return _worldState.cherieQuest004Step;
      case 'cherie_quest_005':
        return _worldState.cherieQuest005Step;
      case 'cherie_quest_006':
        return _worldState.cherieQuest006Step;
      case 'mom_quest_001':
        return _worldState.momQuest001Step;
      default:
        return 0;
    }
  }

  int _questStep(String questId) {
    final runtimeValue = _questRuntime.step(questId);
    final legacyValue = _legacyQuestStep(questId);
    if (_questRuntimeMirrorMode && runtimeValue != legacyValue) {
      debugPrint(
        'QUEST_MIRROR_MISMATCH step quest=$questId runtime=$runtimeValue legacy=$legacyValue',
      );
    }
    return _useQuestRuntimeV2 ? runtimeValue : legacyValue;
  }

  bool _questFlag(String questId, String key) {
    final runtimeValue = _questRuntime.flag(questId, key);
    bool legacyValue = runtimeValue;
    if (questId == 'cherie_quest_005' && key == 'complete') {
      legacyValue = _worldState.cherieQuest005Complete;
    }
    if (_questRuntimeMirrorMode && runtimeValue != legacyValue) {
      debugPrint(
        'QUEST_MIRROR_MISMATCH flag quest=$questId key=$key runtime=$runtimeValue legacy=$legacyValue',
      );
    }
    return _useQuestRuntimeV2 ? runtimeValue : legacyValue;
  }

  void _setQuestStep(String questId, int step) {
    _questRuntime.setStep(questId, step);
    if (!_useQuestRuntimeV2) {
      _questStateRepository.writeStep(questId, step);
    }
  }


  /// Повне оновлення сцени локації при зміні дати/години/дня тижня (ключ віджета + хуки як при заході).
  String _locationSceneTickKey(String zoneLabel) {
    final dt = _timeController.dateTime;
    return '${zoneLabel}_${currentRoom}_${dt.year}_${dt.month}_${dt.day}_${dt.hour}_${_timeController.weekdayIndex}';
  }

  String _streetLocationSceneTickKey() {
    final dt = _timeController.dateTime;
    final sh = currentStreetHouse ?? 'nil';
    final hallQ3 = _isJuniperQuest003HallFollowUpDialogContext()
        ? 'h${_juniperQuest003HallPlaybackTick}_${_semJuniperQuest003HallStreetViewVideoPath() ?? ''}'
        : 'h0';
    final loungeQ3 = _juniperQuest003UiActive
        ? 'l${_juniperQuest003PlaybackTick}_${_juniperQuest003VideoPath ?? ''}'
        : 'l0';
    return 'street_${sh}_${currentRoom}_${dt.year}_${dt.month}_${dt.day}_${dt.hour}_${_timeController.weekdayIndex}_${hallQ3}_$loungeQ3';
  }


  /// Автозапуск відео з Сашею в залі о 19:00 при вході в кімнату або після промотки часу (фаза intro).
  void _tryAutoStartSashaHallComunicateVideo() {
    if (_spyOnSemParentsUiActive || _danielleSpyCaughtUiActive) return;
    if (_sashaComunicatePhase != ComunicateSashaInHallPhase.intro ||
        _sashaComunicateInHallUiActive) {
      return;
    }
    final hour = _timeController.dateTime.hour;
    if (hour != 19) return;
    if (currentZone != 'STREET' ||
        currentStreetHouse != LocationsData.friendHouse ||
        !isInsideRoom ||
        currentRoom != LocationsData.friendHall) {
      return;
    }
    if (_selectedNpcIdInRoom != null && _selectedNpcIdInRoom != 'sasha') {
      return;
    }
    final npcService = sl<NPCService>();
    final day = _timeController.weekdayIndex;
    final inRoom = npcService
        .getNPCsInRoom(currentRoom, hour, day)
        .where(
          (n) => npcService.getCurrentLocationId(n, hour, day) == currentRoom,
        )
        .any((n) => n.id == 'sasha');
    if (!inRoom) return;

    _selectedNpcIdInRoom = 'sasha';
    _applySashaHallVideoAndTalkPhaseState();
  }

  void _applySashaHallVideoAndTalkPhaseState() {
    _sashaComunicateInHallUiActive = true;
    _sashaComunicatePhase = ComunicateSashaInHallPhase.videoAndTalk;
    _ui.setEventImagePath(null);
    _eventVideoPath = SashaEvents.comunicateSashaInHallVideoPath;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = true;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    newsMessage = SashaEvents.comunicateHallStep2Talk;
  }

  /// Ліва панель [GameDialogPanel]: текст фази івенту Саші в залі (кнопки лише в навігаційній колонці).
  void _syncSashaHallNewsMessageIfInEvent() {
    if (currentZone != 'STREET' ||
        currentStreetHouse != LocationsData.friendHouse ||
        !isInsideRoom ||
        currentRoom != LocationsData.friendHall) {
      return;
    }
    final hour = _timeController.dateTime.hour;
    if (hour != 18 && hour != 19) return;
    if (_selectedNpcIdInRoom != null && _selectedNpcIdInRoom != 'sasha') {
      return;
    }
    final npcService = sl<NPCService>();
    final day = _timeController.weekdayIndex;
    final sashaHere = npcService
        .getNPCsInRoom(currentRoom, hour, day)
        .where(
          (n) => npcService.getCurrentLocationId(n, hour, day) == currentRoom,
        )
        .any((n) => n.id == 'sasha');
    if (!sashaHere) return;

    switch (_sashaComunicatePhase) {
      case ComunicateSashaInHallPhase.intro:
        newsMessage = SashaEvents.comunicateHallStep1Intro;
        break;
      case ComunicateSashaInHallPhase.videoAndTalk:
        newsMessage = SashaEvents.comunicateHallStep2Talk;
        break;
      case ComunicateSashaInHallPhase.moneyChoice:
        newsMessage = SashaEvents.comunicateHallStep3Talk;
        break;
    }
  }

  /// Саша: відновлення івенту №2 (sasha_event_002) після сейв/лоад.
  /// Показуємо тільки коли гравець на «вулиці» (сітка будинків), поза кімнатами.
  void _tryResumeSashaMorningRunIfInProgress() {
    if (_spyOnSemParentsUiActive || _danielleSpyCaughtUiActive) return;
    if (currentZone != 'STREET' ||
        currentStreetHouse != null ||
        isInsideRoom ||
        currentRoom != LocationsData.street) {
      return;
    }

    final npcService = sl<NPCService>();
    final sasha = npcService.allNPCs.where((n) => n.id == 'sasha').toList();
    final sashaNpc = sasha.isEmpty ? null : sasha.first;
    if (sashaNpc == null) return;

    final todayKey = SashaEvents.dateKey(_timeController.dateTime);
    final rawLast = sashaNpc.variables[SashaEvents.morningRunLastDateKeyVar];
    final lastDateKey = rawLast is String ? rawLast : null;

    final rawStep = sashaNpc.variables[SashaEvents.morningRunStepVar];
    final step = rawStep is int
        ? rawStep
        : (rawStep is num ? rawStep.toInt() : 0);

    if (lastDateKey == null || lastDateKey != todayKey) return;
    if (step <= 0) return;

    final phase = SashaEvents.phaseFromStep(step);
    _sashaMorningRunUiActive = true;
    _sashaMorningRunPhase = phase;

    _ui.setEventImagePath(null);
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = true;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;

    _eventVideoPath = phase == SashaMorningRunPhase.intro
        ? SashaEvents.morningRunVideoRun1Path
        : SashaEvents.morningRunVideoRun2Path;
  }

  /// Оновлює текст зліва під час активного івенту Саші №2.
  void _syncSashaMorningRunNewsMessageIfInEvent() {
    if (!_sashaMorningRunUiActive) return;
    if (currentZone != 'STREET' ||
        currentStreetHouse != null ||
        isInsideRoom ||
        currentRoom != LocationsData.street) {
      return;
    }
    if (_selectedNpcIdInRoom != null && _selectedNpcIdInRoom != 'sasha') {
      // не чіпаємо, якщо активний інший контент/персонаж
      return;
    }

    switch (_sashaMorningRunPhase) {
      case SashaMorningRunPhase.intro:
        newsMessage = SashaEvents.morningRunStep1Talk;
        break;
      case SashaMorningRunPhase.video2:
        newsMessage = SashaEvents.morningRunStep2Talk;
        break;
      case SashaMorningRunPhase.payOffer:
        newsMessage = SashaEvents.morningRunStep3Talk;
        break;
      case SashaMorningRunPhase.moneyAmountChoice:
        newsMessage = SashaEvents.morningRunStep3Talk;
        break;
      case SashaMorningRunPhase.afterPaid:
        newsMessage = SashaEvents.morningRunAfterPaidTalk;
        break;
    }
  }

  /// Запуск івенту №2: якщо гравець прийшов на «вулицю» о 7:00 (крок ТЗ: тап на «вул. Шевченка»),
  /// і цей івент ще не був стартований сьогодні.
  void _tryStartSashaMorningRunOnStreetOverview() {
    if (_spyOnSemParentsUiActive || _danielleSpyCaughtUiActive) return;
    if (_sashaMorningRunUiActive) return;
    if (currentZone != 'STREET' ||
        currentStreetHouse != null ||
        isInsideRoom ||
        currentRoom != LocationsData.street) {
      return;
    }
    if (_timeController.dateTime.hour != 7) return;

    final npcService = sl<NPCService>();
    final sasha = npcService.allNPCs.where((n) => n.id == 'sasha').toList();
    final sashaNpc = sasha.isEmpty ? null : sasha.first;
    if (sashaNpc == null) return;

    final todayKey = SashaEvents.dateKey(_timeController.dateTime);
    final lastDateKeyRaw = sashaNpc.variables[SashaEvents.morningRunLastDateKeyVar];
    final lastDateKey = lastDateKeyRaw is String ? lastDateKeyRaw : null;

    final rawStep = sashaNpc.variables[SashaEvents.morningRunStepVar];
    final step = rawStep is int
        ? rawStep
        : (rawStep is num ? rawStep.toInt() : 0);

    // Якщо вже стартували сьогодні або проміжний крок не нуль — не запускаємо повторно.
    if (lastDateKey == todayKey) return;
    if (step > 0) return;

    sashaNpc.setVar(SashaEvents.morningRunLastDateKeyVar, todayKey);
    sashaNpc.setVar(
      SashaEvents.morningRunStepVar,
      SashaEvents.stepForPhase(SashaMorningRunPhase.intro),
    );

    _sashaMorningRunUiActive = true;
    _sashaMorningRunPhase = SashaMorningRunPhase.intro;

    _ui.setEventImagePath(null);
    _eventVideoPath = SashaEvents.morningRunVideoRun1Path;
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = true;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;

    newsMessage = SashaEvents.morningRunStep1Talk;
    _saveService.autosave();
  }

  /// Примусово повертає ГГ додому в свою кімнату при виснаженні.
  void _goHomeToRoomGgFromExhaustion() {
    final fromZone = currentZone;
    _addTravelTime(fromZone, "HOME");
    setState(() {
      currentZone = "HOME";
      currentStreetHouse = null;
      currentRoom = LocationsData.roomGg;
      isInsideRoom = true;
      isBackpackOpen = false;
      isStatsOpen = false;
      isNpcGalleryOpen = false;
      isPhoneOpen = false;
      isLaptopOpen = false;
      _isExhausted = false;
      newsMessage =
          LocationsData.getLocationDisplayName(LocationsData.roomGg);
    });
    _saveService.autosave();
  }

  void _exitHomeRoomToCorridorGrid() {
    _timeController.addMinutes(5);
    setState(() {
      isInsideRoom = false;
      currentRoom = LocationsData.corridor;
      _selectedNpcIdInRoom = null;
      _tryStartPiperQuest001Step4IfNeeded();
      if (_worldState.piperQuest001Step != 4) {
        newsMessage =
            LocationsData.getLocationDisplayName(LocationsData.corridor);
      }
      _ensurePiperQuest001Step2ApproachUiCoherent();
      _ensurePiperQuest001Step4CorridorUiCoherent();
    });
  }

  void _handleRoomEntry(String name) {
    if (_isCollegeAuditorium(name) &&
        _isCollegeLessonLateWindow(_timeController.dateTime)) {
      _showCollegeLateDialog();
      return;
    }
    _nav.handleRoomEntry(name);
    setState(() {
      _prepareForPlayerAction();
      if (LocationsData.migrateLegacyRoomId(name) != LocationsData.toilet) {
        _resetCollegeToiletUnderwearSaleUi();
      }
      if (name == LocationsData.cityMallGiftShop ||
          name == LocationsData.cityMallGiftShopOffice ||
          name == LocationsData.cityMallGiftShopWarehouse) {
        _selectedNpcIdInRoom = null;
      }
      if (_danielleSpyCaughtUiActive) {
        _clearDanielleSpyCaughtUiOnly();
      }
      _syncDanielleSpyParentsOnParentsRoomContext();
      if (currentZone == 'STREET' &&
          currentStreetHouse == LocationsData.friendHouse &&
          isInsideRoom &&
          JuniperShowerVideos.isInFriendBathroom(name)) {
        _syncJuniperShowerOnRoomEntry();
      }
      _syncJuniperManuelKompromatStep4OnRoomEntry();
      _syncJuniperManuelKompromatStep3OnRoomEntry();
      _syncJuniperManuelKompromatOnRoomEntry();
      _syncJuniperManuelKompromatStep2OnRoomEntry();
      _maybeStartDanielleSpyCaughtAutoInRoom();
      _tryAutoStartSashaHallComunicateVideo();
      _syncSashaHallNewsMessageIfInEvent();
      var skipCherieOfficeAutoStarters = false;
      if (name == LocationsData.cityMallGiftShopOffice) {
        final hourMf = _timeController.dateTime.hour;
        final dayMf = _timeController.weekdayIndex;
        final npcServiceMf = sl<NPCService>();
        final cherieMf = npcServiceMf.npcById('cherie');
        if (_worldState.cherieMassageFunEventStep == 0 &&
            _eventVideoPath == null &&
            CherieMassageFunEvent.canStartOfficeEntry(
              world: _worldState,
              weekdayIndex: dayMf,
              hour: hourMf,
              currentZone: currentZone,
              isInsideRoom: isInsideRoom,
              currentRoom: currentRoom,
              cherie: cherieMf,
              npcService: npcServiceMf,
              cherieAnimatorIntroInactive:
                  _worldState.cherieAnimatorIntroStep == 0,
              cherieQuest001OfficePhaseInactive:
                  _ui.cherieQuest001OfficePhase ==
                      CherieQuest001OfficePhase.inactive,
            )) {
          _worldState.cherieMassageFunEventStep = 1;
          _selectedNpcIdInRoom = 'cherie';
          _cherieMassageFunEventPresentationSyncedStep = null;
          _applyCherieMassageFunEventPatch(
            CherieMassageFunEvent.patchForPresentationStep(1),
          );
          skipCherieOfficeAutoStarters = true;
        }
      }
      if (!skipCherieOfficeAutoStarters) {
        _tryStartCherieGiftShopOfficeAnimatorQuestIfNeeded(name);
        _tryStartCherieAnimatorShiftIntroIfNeeded(name);
        _resumeCherieAnimatorIntroIfInProgress(name);
        if (name == LocationsData.cityMallGiftShopOffice) {
          _tryStartCherieQuest002OfficeIfNeeded(name);
          if (!CherieQuest002.isActiveMidFlow(_worldState)) {
            _tryStartCherieQuest005OfficeIfNeeded(name);
            if (!CherieQuest005.isActiveMidFlow(_worldState)) {
              _tryStartCherieQuest006OfficeIfNeeded(name);
            }
            if (!CherieQuest005.isActiveMidFlow(_worldState) &&
                !CherieQuest006.isActiveMidFlow(_worldState)) {
              _tryStartCherieQuest004OfficeIfNeeded(name);
            }
          }
        }
      }
      _tryResumeCherieQuest003OfficeIfNeeded(name);
      _tryResumeCherieQuest005OfficeIfNeeded(name);
      _tryResumeCherieQuest006OfficeIfNeeded(name);
      _tryResumeCherieQuest004OfficeIfNeeded(name);
      _tryResumeCherieQuest002HomeIfNeeded(name);
      _tryResumeCherieQuest005BedroomIfNeeded(name);
      _tryResumeCherieMassageFunEventOfficeIfNeeded(name);
      _tryResumeCherieMassageFunEventBedroomIfNeeded(name);
      _tryResumeCherieQuest004BedroomIfNeeded(name);
      _tryResumeCherieQuest004ContractHallIfNeeded(name);
      if (currentZone == 'CITY' &&
          isInsideRoom &&
          LocationsData.migrateLegacyRoomId(name) ==
              LocationsData.cityBcRockefellerOffice &&
          _worldState.rockefellerNikeFinalReviewInProgress &&
          _eventVideoPath == null) {
        _ui.setEventImagePath(null);
        _eventVideoPath = 'lib/assets/npcs/rockefeller/reklama.webm';
        _eventVideoMuted = false;
        _eventVideoFullScreen = true;
        _eventVideoCloseWhenCompleted = false;
        _eventVideoLoop = false;
        _eventVideoPendingButton = null;
        _eventVideoOnButtonPressed = null;
        _eventVideoOnComplete = null;
        newsMessage = sl<LocaleController>().t('rockefeller_nike_review_news');
      }
      _maybeAbortCherieQuest002WrongLocation();
      _maybeAbortCherieQuest003WrongLocation();
      _maybeAbortCherieQuest004WrongLocation();
      _maybeAbortCherieQuest005WrongLocation();
      _maybeAbortCherieQuest006WrongLocation();
      _maybeAbortCherieMassageFunEventWrongLocation();
      _tryStartMomQuest001HallIfNeeded(name);
      _syncMomEvent002KitchenRecheckIfNeeded();
      _tryStartMomEvent002KitchenIfNeeded(name);
      _maybeResumeMomEvent002AfterLoad(name);
      _maybeAbortMomEvent002WrongLocation();
      _ensureMomEvent002KitchenPaymentUiCoherent();
      _syncPiperQuest001DailyIfNeeded();
      _tryStartPiperQuest001Step1IfNeeded(name);
      _ensurePiperQuest001LibraryDialogUiCoherent();
      _tryStartPiperQuest001Step2IfNeeded();
      _ensurePiperQuest001Step2ApproachUiCoherent();
      _ensurePiperGgVoluntaryPunishUiCoherent();
      _ensurePiperQuest001SnitchAckUiCoherent();
      _tryStartPiperQuest001Step3IfNeeded();
      _ensurePiperQuest001Step3TeacherCallUiCoherent();
      _tryStartPiperQuest001Step4IfNeeded();
      _ensurePiperQuest001Step4CorridorUiCoherent();
      _tryStartPiperQuest001Step5IfNeeded();
      _ensurePiperQuest001Step5PunishmentUiCoherent();
      _ensurePiperQuest001Step6ClosureUiCoherent();
      _tryStartPiperHallWeekendEventIfNeeded(name);
      _ensurePiperHallWeekendEventUiCoherent();
      _ensureCherieQuest002HomeHallUiCoherent();
      _syncSemJuniperArcOnRoomEntry();
      _ensureSemJuniperIntroUiCoherent();
      _ensureJuniperManuelKompromatUiCoherent();
      _ensureJuniperQuest002Step1UiCoherent();
      _syncQuestUiArbitration();
      _resetNewsMessageIfOutsideQuestEventContext();
    });
  }

  bool _isCollegeAuditorium(String room) {
    final norm = LocationsData.migrateLegacyRoomId(room);
    return norm == LocationsData.auditorium1 ||
        norm == LocationsData.auditorium2 ||
        norm == LocationsData.auditorium3;
  }

  int? _collegeLessonStartHour(DateTime dt) {
    if (!collegeWeekdayIndices.contains(_timeController.weekdayIndex)) {
      return null;
    }
    if (dt.hour == 10 || dt.hour == 11) return 10;
    if (dt.hour == 13 || dt.hour == 14) return 13;
    if (dt.hour == 16 || dt.hour == 17) return 16;
    return null;
  }

  bool _isCollegeLessonStartWindow(DateTime dt) {
    final start = _collegeLessonStartHour(dt);
    return start != null && dt.hour == start && dt.minute <= 15;
  }

  bool _isCollegeLessonLateWindow(DateTime dt) {
    final start = _collegeLessonStartHour(dt);
    if (start == null) return false;
    if (dt.hour == start) return dt.minute > 15;
    return dt.hour == start + 1;
  }

  int? _collegeLessonEndHour(DateTime dt) {
    final start = _collegeLessonStartHour(dt);
    if (start == null) return null;
    return start + 2;
  }

  String? _collegeTeacherIdForAuditorium(String room) {
    final norm = LocationsData.migrateLegacyRoomId(room);
    if (norm == LocationsData.auditorium1) return 'amia';
    if (norm == LocationsData.auditorium2) return 'lisa';
    if (norm == LocationsData.auditorium3) return 'nicole';
    return null;
  }

  void _showCollegeLateDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameTheme.bgDark,
        content: const Text(
          'Ти запізнився на пару',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _attendCollegeLesson() {
    final endHour = _collegeLessonEndHour(_timeController.dateTime);
    if (endHour == null) return;
    final teacherId = _collegeTeacherIdForAuditorium(currentRoom);
    final teacher =
        teacherId == null ? null : sl<NPCService>().npcById(teacherId);
    teacher?.addRelationship(3);
    _playerStats.changeCollegeSuccess(1);
    final dt = _timeController.dateTime;
    _timeController.dateTime = DateTime(dt.year, dt.month, dt.day, endHour, 0);
    newsMessage = 'Пара закінчилась.';
    _collegeLessonPromptKey = null;
    _saveService.autosave();
  }

  void _showCollegeLessonStartDialogIfNeeded() {
    final dt = _timeController.dateTime;
    if (currentZone != 'COLLEGE' ||
        !isInsideRoom ||
        !_isCollegeAuditorium(currentRoom) ||
        !_isCollegeLessonStartWindow(dt)) {
      return;
    }
    final key =
        '${dt.year}-${dt.month}-${dt.day}-${_timeController.weekdayIndex}-${dt.hour}-$currentRoom';
    if (_collegeLessonPromptKey == key) return;
    _collegeLessonPromptKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _collegeLessonPromptKey != key) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GameTheme.bgDark,
          content: const Text(
            'Пара починається.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _collegeLessonPromptKey = null;
                _handleBackTap();
              },
              child: const Text('Вийти'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(_attendCollegeLesson);
              },
              child: const Text('Йти на пару'),
            ),
          ],
        ),
      );
    });
  }

  void _resetCollegeToiletUnderwearSaleUi() {
    _collegeToiletUnderwearSaleActive = false;
    _collegeToiletUnderwearSalePendingItemId = null;
  }

  bool _isCollegeToiletGuysBreakWindow() {
    final day = _timeController.weekdayIndex;
    final hour = _timeController.dateTime.hour;
    final minute = _timeController.dateTime.minute;
    return currentZone == 'COLLEGE' &&
        isInsideRoom &&
        LocationsData.migrateLegacyRoomId(currentRoom) == LocationsData.toilet &&
        collegeWeekdayIndices.contains(day) &&
        hour == 12 &&
        minute >= 30 &&
        minute <= 59;
  }

  void _openCollegeToiletUnderwearSale() {
    _ui.setEventImagePath(null);
    final sellable =
        CollegeToiletUnderwearSaleService.sellableItems(_inventory.items);
    if (sellable.isEmpty) {
      newsMessage = 'Тобі поки що нічого продавати.';
      return;
    }
    _collegeToiletUnderwearSaleActive = true;
    _collegeToiletUnderwearSalePendingItemId = null;
    newsMessage = 'Пацани готові переглянути речі. Обери, що продати.';
  }

  GameItem? _collegeToiletUnderwearSaleItemById(String itemId) {
    for (final item in _inventory.items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  void _selectCollegeToiletUnderwearSaleItem(String itemId) {
    final item = _collegeToiletUnderwearSaleItemById(itemId);
    if (item == null ||
        !CollegeToiletUnderwearSaleService.isSellableItem(item)) {
      return;
    }
    final price = CollegeToiletUnderwearSaleService.priceForItem(
      item,
      _timeController.onlyDate,
    );
    _collegeToiletUnderwearSalePendingItemId = itemId;
    if (CollegeToiletUnderwearSaleService.canTriggerExposure(item)) {
      final risk = CollegeToiletUnderwearSaleService.riskLabel(price);
      newsMessage =
          'Пацани оживились, коли побачили річ.\n'
          'За це готові дати \$$price.\n'
          'Ризик: $risk.';
    } else {
      newsMessage =
          'Пацани оживились, коли побачили річ.\n'
          'За це готові дати \$$price.';
    }
  }

  void _confirmCollegeToiletUnderwearSale() {
    final itemId = _collegeToiletUnderwearSalePendingItemId;
    if (itemId == null) return;
    final item = _collegeToiletUnderwearSaleItemById(itemId);
    if (item == null ||
        !CollegeToiletUnderwearSaleService.isSellableItem(item)) {
      _collegeToiletUnderwearSalePendingItemId = null;
      return;
    }

    final price = CollegeToiletUnderwearSaleService.priceForItem(
      item,
      _timeController.onlyDate,
    );
    _inventory.removeItem(item.id);
    _playerStats.changeMoney(price);

    final todayKey = _timeController.onlyDate;
    final ownerId =
        CollegeToiletUnderwearSaleService.ownerIdFromItemId(item.id);
    var message =
        'Ти продав ${item.name} за \$$price.\n'
        'Пацани швидко сховали покупку.';

    final canExposeToday =
        _worldState.underwearSaleExposureDayKey != todayKey;
    if (canExposeToday &&
        CollegeToiletUnderwearSaleService.canTriggerExposure(item) &&
        CollegeToiletUnderwearSaleService.rollExposure(
          price,
          Random(),
        )) {
      final exposedOwnerId = ownerId!;
      final npc = sl<NPCService>().npcById(exposedOwnerId);
      if (npc != null) {
        npc.addRelationship(-35);
        npc.changeBehavior(-15);
        _worldState.underwearSaleExposureDayKey = todayKey;
        _worldState.underwearSaleExposedOwnerId = exposedOwnerId;
        final ownerName =
            CollegeToiletUnderwearSaleService.ownerDisplayName(exposedOwnerId);
        message +=
            '\n\nПогана новина: хтось занадто багато базікав.\n'
            '$ownerName дізналась, що її річ продали.';
      }
    }

    _collegeToiletUnderwearSalePendingItemId = null;
    final remaining =
        CollegeToiletUnderwearSaleService.sellableItems(_inventory.items);
    if (remaining.isEmpty) {
      _resetCollegeToiletUnderwearSaleUi();
      message += '\n\nБільше нічого продавати.';
    }
    newsMessage = message;
    _saveService.autosave();
  }

  List<Widget> _buildCollegeToiletUnderwearSaleActions() {
    final pendingId = _collegeToiletUnderwearSalePendingItemId;
    if (pendingId != null) {
      return [
        _navBtn('Продати', () {
          setState(_confirmCollegeToiletUnderwearSale);
        }),
        const SizedBox(height: 8),
        _navBtn('Назад', () {
          setState(() {
            _collegeToiletUnderwearSalePendingItemId = null;
            newsMessage = 'Обери, що продати.';
          });
        }),
      ];
    }

    final dateKey = _timeController.onlyDate;
    final sellable =
        CollegeToiletUnderwearSaleService.sellableItems(_inventory.items);
    if (sellable.isEmpty) {
      return [
        _navBtn('Назад', () {
          setState(_resetCollegeToiletUnderwearSaleUi);
        }),
      ];
    }

    final widgets = <Widget>[];
    for (final item in sellable) {
      final price =
          CollegeToiletUnderwearSaleService.priceForItem(item, dateKey);
      widgets.add(
        _navBtn('${item.name} — \$$price', () {
          setState(() => _selectCollegeToiletUnderwearSaleItem(item.id));
        }),
      );
      widgets.add(const SizedBox(height: 8));
    }
    widgets.add(
      _navBtn('Назад', () {
        setState(_resetCollegeToiletUnderwearSaleUi);
      }),
    );
    return widgets;
  }

  /// Якщо крок 5–9 у залі, а прапорець сесії зник — відновлюємо діалог / відео.
  void _ensureCherieQuest002HomeHallUiCoherent() {
    final cherie = sl<NPCService>().npcById('cherie');
    if (!CherieQuest002.shouldPresentHomeHallSteps(
          world: _worldState,
          cherie: cherie,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        )) {
      return;
    }
    if (_cherieQuest002PresentationSyncedStep == _worldState.cherieQuest002Step) {
      return;
    }
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest002OfficePatch(
      CherieQuest002.patchForPresentationStep(
        _worldState.cherieQuest002Step,
        _worldState,
      ),
    );
  }

  /// Продовження після завантаження сейву: кроки 5–9 у залі Home Cherie.
  void _tryResumeCherieQuest002HomeIfNeeded(String enteredRoom) {
    final enteredNorm = LocationsData.migrateLegacyRoomId(enteredRoom);
    if (enteredNorm != LocationsData.poorVillageGiftShopOwnerHall) return;
    if (currentZone != 'POOR_VILLAGE' || !isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (roomNorm != LocationsData.poorVillageGiftShopOwnerHall) return;
    final cherie = sl<NPCService>().npcById('cherie');
    var s = _worldState.cherieQuest002Step;
    if (s == 0 &&
        CherieQuest002.shouldResumeMassageStep8InHall(
          cherie: cherie,
          world: _worldState,
        )) {
      _worldState.cherieQuest002Step = 8;
      s = 8;
    }
    if (!CherieQuest002.isHomeHallPhase(s)) return;
    if (_cherieQuest002PresentationSyncedStep == s) return;
    _selectedNpcIdInRoom = 'cherie';
    _applyCherieQuest002OfficePatch(
      CherieQuest002.patchForPresentationStep(s, _worldState),
    );
  }

  bool _isInFriendParentsRoom() =>
      currentZone == 'STREET' &&
      currentStreetHouse == LocationsData.friendHouse &&
      isInsideRoom &&
      LocationsData.migrateLegacyRoomId(currentRoom) ==
          LocationsData.friendParentsRoom;

  bool _danielleSpyParentsCanTriggerNow() {
    final dt = _timeController.dateTime;
    return DanielleSpyParentsQuest.canTrigger(
      world: _worldState,
      npcService: sl<NPCService>(),
      playerStats: _playerStats,
      hourAfterEntry: dt.hour,
      weekdayIndex: _timeController.weekdayIndex,
    );
  }

  bool _blocksDanielleSpyParentsAutoStart() =>
      _isJuniperManuelKompromatStep1UiCoherent() ||
      _isJuniperManuelKompromatStep2UiCoherent() ||
      _isJuniperManuelKompromatStep2AfterFleeUiCoherent() ||
      _isJuniperManuelKompromatStep3UiCoherent() ||
      _isJuniperManuelKompromatStep4UiCoherent() ||
      _juniperShowerUiActive ||
      _juniperSemRoomSexUiActive ||
      JuniperManuelKompromatInRoomScene.canTriggerStep2(
        world: _worldState,
        gameDateKey: _timeController.onlyDate,
        hour: _timeController.dateTime.hour,
        minute: _timeController.dateTime.minute,
      ) ||
      JuniperManuelKompromatInRoomScene.canTriggerStep3(
        world: _worldState,
        gameDateKey: _timeController.onlyDate,
        hour: _timeController.dateTime.hour,
        minute: _timeController.dateTime.minute,
      ) ||
      JuniperManuelKompromatInRoomScene.canTriggerStep4(
        world: _worldState,
        gameDateKey: _timeController.onlyDate,
        weekdayIndex: _timeController.weekdayIndex,
        hour: _timeController.dateTime.hour,
        minute: _timeController.dateTime.minute,
      );

  /// Автостарт / скидання spyOnSemParents біля кімнати батьків (лише вікно 20:00, будні).
  void _syncDanielleSpyParentsOnParentsRoomContext() {
    final inParents = _isInFriendParentsRoom();

    if (_spyOnSemParentsUiActive && !inParents) {
      _clearDanielleSpyParentsUiOnly();
      return;
    }

    if (_spyOnSemParentsUiActive) {
      if (!_danielleSpyParentsCanTriggerNow()) {
        _clearDanielleSpyParentsUiOnly();
      }
      return;
    }

    if (!inParents) return;
    if (_blocksDanielleSpyParentsAutoStart()) return;
    if (!_danielleSpyParentsCanTriggerNow()) return;

    _spyOnSemParentsUiActive = true;
    _spyParentsPhase = DanielleSpyParentsPhase.door;
    _ui.setEventImagePath(DanielleSpyParentsQuest.imagePath);
    newsMessage = sl<LocaleController>().t('danielle_spy_parents_dialogue');
    _saveService.autosave();
  }

  void _clearDanielleSpyParentsUiOnly() {
    _spyOnSemParentsUiActive = false;
    _spyParentsPhase = DanielleSpyParentsPhase.door;
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoLoop = false;
  }

  void _syncSemJuniperArcOnRoomEntry() {
    final dateKey = _timeController.onlyDate;
    JuniperQuest003OfferHelp.syncStuckStepIfBelowCatchThreshold(_worldState);
    SemQuest001.syncArcTimersIfDue(_worldState, dateKey);
    _purgeSemJuniperRoomIntroIfMisplaced();

    // Quest 003 hall/offer — завжди, навіть якщо нижче early-return (corridor noise / intro).
    void syncQuest003FollowUps() {
      _syncJuniperQuest003HallFollowUpOnRoomEntry();
      _syncJuniperQuest003OfferHelpOnRoomEntry();
    }

    if (SemQuest001.shouldShowCorridorNoise(
      world: _worldState,
      gameDateKey: dateKey,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      SemQuest001.markCorridorNoiseShown(_worldState);
      // Не перебивати зелений текст quest 003.
      if (!JuniperQuest003.isCorridorHallSoundsHintContext(
        world: _worldState,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      )) {
        newsMessage = sl<LocaleController>().t(SemQuest001.l10nCorridorNoise);
      }
      _saveService.autosave();
      syncQuest003FollowUps();
      return;
    }
    if (!_semJuniperIntroUiActive) {
      final h = _timeController.dateTime.hour;
      final d = _timeController.weekdayIndex;
      if (SemJuniperRoomIntro.canAutoStartSkipped(
        world: _worldState,
        gameDateKey: dateKey,
        weekdayIndex: d,
        hour: h,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      )) {
        _beginSemJuniperRoomIntro(skippedFacadePath: true);
        _saveService.autosave();
        syncQuest003FollowUps();
        return;
      }
      if (SemJuniperRoomIntro.canAutoStart(
        world: _worldState,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      )) {
        _beginSemJuniperRoomIntro(skippedFacadePath: false);
        _saveService.autosave();
        syncQuest003FollowUps();
        return;
      }
    }
    _syncDefaultNpcSelectionInRoomIfNeeded();
    _syncSemJuniperEveningVisitOnRoomEntry();
    _syncJuniperSemRoomSexOnRoomEntry();
    _syncJuniperShowerOnRoomEntry();
    _syncJuniperManuelKompromatStep4OnRoomEntry();
    _syncJuniperManuelKompromatStep3OnRoomEntry();
    _syncJuniperManuelKompromatOnRoomEntry();
    _syncJuniperManuelKompromatStep2OnRoomEntry();
    syncQuest003FollowUps();
  }

  void _clearJuniperManuelKompromatUiOnly() {
    _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
    _juniperManuelKompromatVideoPath = null;
    _ui.setEventImagePath(null);
    _resetJuniperManuelKompromatDialogNewsIfPresent();
  }

  void _syncJuniperManuelKompromatOnRoomEntry() {
    final h = _timeController.dateTime.hour;
    final d = _timeController.weekdayIndex;
    final inBathroom = JuniperQuest001.isInFriendBathroom(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    );

    if (_juniperManuelKompromatUiActive && !inBathroom) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (_juniperManuelKompromatStep3UiActive && !inBathroom) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (_juniperManuelKompromatStep4UiActive && !inBathroom) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (!inBathroom) return;

    if (_juniperManuelKompromatStep4UiActive) return;
    if (_juniperManuelKompromatStep3UiActive) return;

    final juniperInShower = JuniperShowerVideos.isJuniperInShowerAt(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      weekdayIndex: d,
      hour: h,
    );
    if (juniperInShower) return;

    if (_juniperShowerUiActive && !juniperInShower) {
      _clearJuniperShowerUiOnly();
    }

    if (_juniperManuelKompromatUiActive) return;
    if (_juniperManuelKompromatStep2UiActive ||
        _juniperManuelKompromatStep2AfterFleeUiActive) {
      return;
    }
    if (_juniperShowerUiActive || _juniperSemRoomSexUiActive) return;

    if (!JuniperQuest001.canTriggerStep1(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      weekdayIndex: d,
      hour: h,
    )) {
      return;
    }
    if (!JuniperQuest001.rollStep1Trigger()) return;

    _beginJuniperManuelKompromatStep1();
  }

  void _clearJuniperManuelKompromatStep2UiOnly() {
    _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
    _juniperManuelKompromatVideoPath = null;
    _resetJuniperManuelKompromatDialogNewsIfPresent();
  }

  void _syncJuniperManuelKompromatStep2OnRoomEntry() {
    final dt = _timeController.dateTime;
    final h = dt.hour;
    final minute = dt.minute;
    final inHall = JuniperQuest001.isInFriendHall(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    );
    final inLounge = JuniperQuest001.isInFriendLounge(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    );

    if (_juniperManuelKompromatStep2UiActive && !inHall) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (_juniperManuelKompromatStep2AfterFleeUiActive && !inLounge) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (!inHall) return;

    if (_juniperManuelKompromatStep2UiActive) return;
    if (_juniperManuelKompromatStep2AfterFleeUiActive) return;
    if (_juniperManuelKompromatUiActive ||
        _spyOnSemParentsUiActive ||
        _juniperShowerUiActive ||
        _juniperSemRoomSexUiActive) {
      return;
    }

    if (!JuniperManuelKompromatInRoomScene.canTriggerStep2(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      hour: h,
      minute: minute,
    )) {
      return;
    }
    if (!JuniperManuelKompromatInRoomScene.rollStep2Trigger()) return;

    _beginJuniperManuelKompromatStep2();
  }

  void _syncJuniperManuelKompromatStep3OnRoomEntry() {
    final dt = _timeController.dateTime;
    final h = dt.hour;
    final minute = dt.minute;
    final inBathroom = JuniperQuest001.isInFriendBathroom(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    );

    if (_juniperManuelKompromatStep3UiActive && !inBathroom) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (!inBathroom) return;

    if (_juniperManuelKompromatStep3UiActive) return;
    if (_juniperManuelKompromatStep4UiActive) return;
    if (JuniperShowerVideos.isJuniperInShowerAt(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      weekdayIndex: _timeController.weekdayIndex,
      hour: h,
    )) {
      return;
    }
    if (_juniperManuelKompromatUiActive ||
        _juniperManuelKompromatStep2UiActive ||
        _juniperManuelKompromatStep2AfterFleeUiActive ||
        _juniperShowerUiActive ||
        _juniperSemRoomSexUiActive) {
      return;
    }

    if (!JuniperManuelKompromatInRoomScene.canTriggerStep3(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      hour: h,
      minute: minute,
    )) {
      return;
    }
    if (!JuniperManuelKompromatInRoomScene.rollStep3Trigger()) return;

    _beginJuniperManuelKompromatStep3();
  }

  void _syncJuniperManuelKompromatStep4OnRoomEntry() {
    final dt = _timeController.dateTime;
    final h = dt.hour;
    final minute = dt.minute;
    final d = _timeController.weekdayIndex;
    final inBathroom = JuniperQuest001.isInFriendBathroom(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    );

    if (_juniperManuelKompromatStep4UiActive && !inBathroom) {
      _purgeJuniperManuelKompromatIfMisplaced();
    }
    if (!inBathroom) return;

    if (_juniperManuelKompromatStep4UiActive) return;
    if (JuniperShowerVideos.isJuniperInShowerAt(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      weekdayIndex: d,
      hour: h,
    )) {
      return;
    }
    if (_juniperManuelKompromatUiActive ||
        _juniperManuelKompromatStep2UiActive ||
        _juniperManuelKompromatStep2AfterFleeUiActive ||
        _juniperManuelKompromatStep3UiActive ||
        _juniperShowerUiActive ||
        _juniperSemRoomSexUiActive) {
      return;
    }

    if (!JuniperManuelKompromatInRoomScene.canTriggerStep4(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      weekdayIndex: d,
      hour: h,
      minute: minute,
    )) {
      return;
    }
    if (!JuniperManuelKompromatInRoomScene.rollStep4Trigger()) return;

    _beginJuniperManuelKompromatStep4();
  }

  void _beginJuniperManuelKompromatInRoomVideo(
    JuniperManuelKompromatPhase phase,
  ) {
    final handle = _launchInRoomVideo(
      videoPath: JuniperManuelKompromatInRoomScene.videoPathForPhase(phase),
      previousPlaybackTick: _juniperManuelKompromatPlaybackTick,
      allowEventImageOverlay: _allowEventImageOverlay,
    );
    _juniperManuelKompromatPhase = phase;
    _juniperManuelKompromatPlaybackTick = handle.playbackTick;
    _juniperManuelKompromatVideoPath = handle.videoPath;
    JuniperVideoSexStats.onVideoStarted(handle.videoPath);
  }

  /// Старт кроку 1 kompromat: відео одразу у StreetView (перший шар).
  void _beginJuniperManuelKompromatStep1() {
    JuniperQuest001.recordStep1Witness(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      hour: _timeController.dateTime.hour,
    );
    _beginJuniperManuelKompromatInRoomVideo(
      JuniperManuelKompromatPhase.step1Video,
    );
    JuniperQuest001.applyKompromatVideoArousal(_playerStats);
    _ensureJuniperManuelKompromatUiCoherent();
    _saveService.autosave();
  }

  /// Старт кроку 2 kompromat: відео у залі Sem.
  void _beginJuniperManuelKompromatStep2() {
    if (_spyOnSemParentsUiActive) {
      _clearDanielleSpyParentsUiOnly();
    }
    _beginJuniperManuelKompromatInRoomVideo(
      JuniperManuelKompromatPhase.step2Video,
    );
    _ensureJuniperManuelKompromatUiCoherent();
    _saveService.autosave();
  }

  /// Старт кроку 3 kompromat: відео у ванні Sem.
  void _beginJuniperManuelKompromatStep3() {
    _beginJuniperManuelKompromatInRoomVideo(
      JuniperManuelKompromatPhase.step3Video,
    );
    _ensureJuniperManuelKompromatUiCoherent();
    _saveService.autosave();
  }

  /// Старт кроку 4 kompromat: відео у ванні Sem (пн / ср / пт).
  void _beginJuniperManuelKompromatStep4() {
    _beginJuniperManuelKompromatInRoomVideo(
      JuniperManuelKompromatPhase.step4Video,
    );
    _ensureJuniperManuelKompromatUiCoherent();
    _saveService.autosave();
  }

  void _juniperManuelKompromatStep2FleePressed() {
    JuniperManuelKompromatInRoomScene.applyStep2Flee(
      world: _worldState,
      npcs: sl<NPCService>().allNPCs,
      playerStats: _playerStats,
      gameDateKey: _timeController.onlyDate,
    );
    setState(() {
      _juniperManuelKompromatVideoPath = null;
      _juniperManuelKompromatPhase =
          JuniperManuelKompromatPhase.step2AfterFlee;
      currentZone = 'STREET';
      currentStreetHouse = LocationsData.friendHouse;
      currentRoom = JuniperQuest001.step2EscapeRoomId;
      isInsideRoom = true;
      _worldState.currentZone = currentZone;
      _worldState.currentStreetHouse = currentStreetHouse;
      _worldState.currentRoom = currentRoom;
      _worldState.isInsideRoom = true;
      _selectedNpcIdInRoom = null;
      _ensureJuniperManuelKompromatUiCoherent();
    });
    _saveService.autosave();
  }

  void _finishJuniperManuelKompromatStep2AfterFleeScene() {
    if (!mounted) return;
    setState(() {
      _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
      _exitFriendHouseInteriorToCorridor();
    });
    _saveService.autosave();
  }

  void _clearJuniperManuelKompromatStep3UiOnly() {
    _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
    _juniperManuelKompromatVideoPath = null;
    _ui.setEventImagePath(null);
    _resetJuniperManuelKompromatDialogNewsIfPresent();
  }

  void _clearJuniperManuelKompromatStep4UiOnly() {
    _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.inactive;
    _juniperManuelKompromatVideoPath = null;
    _resetJuniperManuelKompromatDialogNewsIfPresent();
  }

  void _finishJuniperManuelKompromatStep4Scene() {
    if (!mounted) return;
    setState(() {
      _clearJuniperManuelKompromatStep4UiOnly();
      _exitFriendHouseInteriorToCorridor();
    });
    _saveService.autosave();
  }

  void _juniperManuelKompromatStep4RecordPressed() {
    JuniperManuelKompromatInRoomScene.applyStep4RecordAttempt(
      world: _worldState,
      npcs: sl<NPCService>().allNPCs,
      playerStats: _playerStats,
    );
    setState(() {
      _juniperManuelKompromatVideoPath = null;
      _juniperManuelKompromatPhase =
          JuniperManuelKompromatPhase.step4AfterRecord;
      currentZone = 'STREET';
      currentStreetHouse = LocationsData.friendHouse;
      currentRoom = JuniperQuest001.step2EscapeRoomId;
      isInsideRoom = true;
      _worldState.currentZone = currentZone;
      _worldState.currentStreetHouse = currentStreetHouse;
      _worldState.currentRoom = currentRoom;
      _worldState.isInsideRoom = true;
      _selectedNpcIdInRoom = null;
      _ensureJuniperManuelKompromatUiCoherent();
    });
    _saveService.autosave();
  }

  void _finishJuniperManuelKompromatStep3Scene() {
    if (!mounted) return;
    setState(() {
      _clearJuniperManuelKompromatStep3UiOnly();
      _exitFriendHouseInteriorToCorridor();
    });
    _saveService.autosave();
  }

  void _juniperManuelKompromatStep3RecordPressed() {
    JuniperManuelKompromatInRoomScene.applyStep3RecordAttempt(
      world: _worldState,
      npcs: sl<NPCService>().allNPCs,
      playerStats: _playerStats,
      gameDateKey: _timeController.onlyDate,
    );
    _juniperManuelKompromatPhase =
        JuniperManuelKompromatPhase.step3AfterRecord;
    _juniperManuelKompromatVideoPath = null;
    _ui.setEventImagePath(JuniperQuest001.step1ClosedDoorImagePath);
    _ensureJuniperManuelKompromatUiCoherent();
    _saveService.autosave();
  }

  void _juniperManuelKompromatRecordPressed() {
    JuniperQuest001.applyStep1RecordAttempt(
      world: _worldState,
      npcs: sl<NPCService>().allNPCs,
      gameDateKey: _timeController.onlyDate,
      hour: _timeController.dateTime.hour,
    );
    _juniperManuelKompromatPhase = JuniperManuelKompromatPhase.step1AfterRecord;
    _juniperManuelKompromatVideoPath = null;
    _ui.setEventImagePath(JuniperQuest001.step1ClosedDoorImagePath);
    _ensureJuniperManuelKompromatUiCoherent();
    _saveService.autosave();
  }

  void _finishJuniperManuelKompromatScene() {
    if (!mounted) return;
    setState(() {
      _clearJuniperManuelKompromatUiOnly();
      _exitFriendHouseInteriorToCorridor();
      _saveService.autosave();
    });
  }

  void _syncSemJuniperEveningVisitOnRoomEntry() {
    final dateKey = _timeController.onlyDate;
    final h = _timeController.dateTime.hour;
    final d = _timeController.weekdayIndex;
    _semJuniperEveningClipShowOnThisVisit = false;
    _juniperEveningClipVideoPath = null;
    if (_semJuniperIntroUiActive) return;
    if (!SemJuniperEveningVisits.isActiveInRoom(
      world: _worldState,
      gameDateKey: dateKey,
      weekdayIndex: d,
      hour: h,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return;
    }
    if (SemJuniperEveningVisits.hasEveningClipForRoom(currentRoom)) {
      final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
      final sem = sl<NPCService>().npcById(kSemNpcId);
      final semLoc = sem == null
          ? null
          : sl<NPCService>().getCurrentLocationId(sem, h, d);
      if (SemJuniperEveningVisits.shouldPlayEveningClipForRoom(
        roomId: currentRoom,
        semLocationId: semLoc,
      )) {
        _semJuniperEveningClipShowOnThisVisit = true;
        _juniperEveningClipPlaybackTick++;
        _juniperEveningClipVideoPath = roomNorm == LocationsData.friendKitchen
            ? JuniperKitchenVideos.randomVideoPath()
            : SemJuniperEveningVisits.dailyClipPath(dateKey, roomNorm);
      }
    }
    if (_selectedNpcIdInRoom == null || _selectedNpcIdInRoom == kJuniperNpcId) {
      _selectedNpcIdInRoom = kJuniperNpcId;
    }
  }

  InRoomVideoSceneHandle _launchJuniperShowerInRoomVideo(String videoPath) =>
      InRoomVideoSceneLauncher.launch(
        videoPath: videoPath,
        previousPlaybackTick: _juniperShowerPlaybackTick,
        clearOverlayBlockers: () {
          _deferJuniperBathroomKompromatForShower();
          _ui.setEventImagePath(null);
          _eventVideoPath = null;
          _eventVideoPendingButton = null;
          _eventVideoOnButtonPressed = null;
        },
        overlayEventVideoPath: _overlayEventVideoPath,
        eventVideoPendingButton: _eventVideoPendingButton,
        eventImagePath: _eventImagePath,
        allowEventImageOverlay: _allowEventImageOverlay,
        loop: true,
      );

  void _deferJuniperBathroomKompromatForShower() {
    if (_juniperManuelKompromatStep3UiActive) {
      _clearJuniperManuelKompromatStep3UiOnly();
      return;
    }
    if (_juniperManuelKompromatStep4UiActive) {
      _clearJuniperManuelKompromatStep4UiOnly();
      return;
    }
    if (_juniperManuelKompromatUiActive) {
      _clearJuniperManuelKompromatUiOnly();
    }
  }

  void _syncJuniperShowerOnRoomEntry() {
    final dateKey = _timeController.onlyDate;
    final h = _timeController.dateTime.hour;
    final d = _timeController.weekdayIndex;
    final inBathroom = currentZone == 'STREET' &&
        currentStreetHouse == LocationsData.friendHouse &&
        isInsideRoom &&
        JuniperShowerVideos.isInFriendBathroom(currentRoom);
    final juniperInShower = JuniperShowerVideos.isJuniperInShowerAt(
      world: _worldState,
      gameDateKey: dateKey,
      weekdayIndex: d,
      hour: h,
    );

    if (_juniperShowerUiActive && (!inBathroom || !juniperInShower)) {
      _clearJuniperShowerUiOnly();
    }
    if (!inBathroom || !juniperInShower) return;

    _deferJuniperBathroomKompromatForShower();

    final startingScene = !_juniperShowerUiActive;
    _juniperShowerSetIndex = JuniperShowerVideos.randomSetIndex();
    final tier1Path = JuniperShowerVideos.videoPath(
      setIndex: _juniperShowerSetIndex,
      tier: 1,
    );
    if (startingScene) {
      final handle = _launchJuniperShowerInRoomVideo(tier1Path);
      _juniperShowerUiActive = true;
      _selectedNpcIdInRoom = kJuniperNpcId;
      _juniperShowerPlaybackTick = handle.playbackTick;
      _juniperShowerVideoPath = handle.videoPath;
      _juniperShowerTier = 1;
      JuniperVideoRewards.tryGrantShowerArousal(_playerStats);
      newsMessage = '';
      return;
    }
    _juniperShowerUiActive = true;
    _selectedNpcIdInRoom = kJuniperNpcId;
    _juniperShowerPlaybackTick++;
    _applyJuniperShowerTier(1);
  }

  void _applyJuniperShowerTier(int tier) {
    _juniperShowerTier = tier.clamp(1, 3);
    _juniperShowerVideoPath = JuniperShowerVideos.videoPath(
      setIndex: _juniperShowerSetIndex,
      tier: _juniperShowerTier,
    );
    JuniperVideoRewards.tryGrantShowerArousal(_playerStats);
    newsMessage = '';
  }

  void _juniperShowerWatchMoreAfterVideo1() {
    setState(() => _applyJuniperShowerTier(2));
  }

  void _juniperShowerWatchMoreAfterVideo2() {
    setState(() => _applyJuniperShowerTier(3));
  }

  void _finishJuniperShowerScene() {
    if (!mounted) return;
    setState(() {
      _clearJuniperShowerUiOnly();
      _selectedNpcIdInRoom = null;
      _exitFriendHouseInteriorToCorridor();
      _saveService.autosave();
    });
  }

  void _clearJuniperSemRoomSexUiOnly() {
    _juniperSemRoomSexUiActive = false;
    _juniperSemRoomSexTier = 1;
    _juniperSemRoomSexVideoPath = null;
  }

  void _purgeJuniperSemRoomSexIfBlockedOrMisplaced() {
    if (!_juniperSemRoomSexUiActive) return;
    final dateKey = _timeController.onlyDate;
    final h = _timeController.dateTime.hour;
    final d = _timeController.weekdayIndex;
    final inSemRoom = currentZone == 'STREET' &&
        currentStreetHouse == LocationsData.friendHouse &&
        isInsideRoom &&
        JuniperSemRoomSexVideos.isInSemRoom(currentRoom);
    final sceneActive = JuniperSemRoomSexVideos.isSceneActiveAt(
      world: _worldState,
      gameDateKey: dateKey,
      weekdayIndex: d,
      hour: h,
    );
    final questSuppressed = JuniperQuest003.suppressesSemRoomSexScene(
      world: _worldState,
      loungeUiActive: _juniperQuest003UiActive,
      hallUiActive: _juniperQuest003HallUiActive,
    );
    if (!inSemRoom || !sceneActive || questSuppressed) {
      _clearJuniperSemRoomSexUiOnly();
    }
  }

  void _syncJuniperSemRoomSexOnRoomEntry() {
    if (_semJuniperIntroUiActive) return;
    _purgeJuniperSemRoomSexIfBlockedOrMisplaced();
    if (JuniperQuest003.suppressesSemRoomSexScene(
      world: _worldState,
      loungeUiActive: _juniperQuest003UiActive,
      hallUiActive: _juniperQuest003HallUiActive,
    )) {
      return;
    }
    final dateKey = _timeController.onlyDate;
    final h = _timeController.dateTime.hour;
    final d = _timeController.weekdayIndex;
    final inSemRoom = currentZone == 'STREET' &&
        currentStreetHouse == LocationsData.friendHouse &&
        isInsideRoom &&
        JuniperSemRoomSexVideos.isInSemRoom(currentRoom);
    final sceneActive = JuniperSemRoomSexVideos.isSceneActiveAt(
      world: _worldState,
      gameDateKey: dateKey,
      weekdayIndex: d,
      hour: h,
    );

    if (!inSemRoom || !sceneActive) {
      return;
    }

    final startingScene = !_juniperSemRoomSexUiActive;
    _juniperSemRoomSexUiActive = true;
    if (startingScene) {
      if (JuniperQuest003.isCatchDaySemRoomSexScene(
        world: _worldState,
        gameDateKey: dateKey,
        hour: h,
      )) {
        JuniperQuest003.markCatchDaySemRoomSexPlayedForDate(
          _worldState,
          gameDateKey: dateKey,
        );
        _saveService.autosave();
      }
      _juniperSemRoomSexPlaybackTick++;
      _applyJuniperSemRoomSexTier(1);
    }
    _selectedNpcIdInRoom = kJuniperNpcId;
  }

  void _applyJuniperSemRoomSexTier(int tier) {
    _juniperSemRoomSexTier = tier.clamp(1, JuniperSemRoomSexVideos.tierCount);
    _juniperSemRoomSexVideoPath = JuniperSemRoomSexVideos.videoPath(
      tier: _juniperSemRoomSexTier,
    );
    JuniperVideoSexStats.onVideoStarted(_juniperSemRoomSexVideoPath!);
    newsMessage = '';
  }

  void _juniperSemRoomSexWatchMore() {
    setState(
      () => _applyJuniperSemRoomSexTier(_juniperSemRoomSexTier + 1),
    );
  }

  void _finishJuniperSemRoomSexScene() {
    if (!mounted) return;
    if (_juniperSemRoomSexTier >= JuniperSemRoomSexVideos.tierCount) {
      JuniperSemRoomSexVideos.applyCompletionRewards(
        world: _worldState,
        playerStats: _playerStats,
      );
    }
    setState(() {
      _clearJuniperSemRoomSexUiOnly();
      _selectedNpcIdInRoom = null;
      _exitFriendHouseInteriorToCorridor();
      _saveService.autosave();
    });
  }

  void _beginSemJuniperRoomIntro({required bool skippedFacadePath}) {
    _semJuniperIntroUiActive = true;
    _semJuniperIntroSkippedPath = skippedFacadePath;
    _selectedNpcIdInRoom = kJuniperNpcId;
    _ui.setEventImagePath(null);
    newsMessage = _semJuniperIntroDialogueMessage();
  }

  String _semJuniperIntroDialogueMessage() {
    final key = _semJuniperIntroSkippedPath
        ? SemJuniperRoomIntro.l10nSkippedDialogue
        : SemJuniperRoomIntro.l10nDialogue;
    return sl<LocaleController>().t(key);
  }

  /// Sem поруч (фасад або в кімнаті будинку) — доступне підменю «Поговорити».
  bool get _semTalkContextActive {
    if (_semSummonedAtFriendFacade) return true;
    if (!isInsideRoom) return false;
    if (_selectedNpcIdInRoom == kSemNpcId) return true;
    return _getActiveNPCsInCurrentRoom().any((n) => n.id == kSemNpcId);
  }

  void _semTalkAboutNews() {
    final t = sl<LocaleController>().t;
    SemQuest001.syncArcTimersIfDue(_worldState, _timeController.onlyDate);
    if (_semTalkContextActive &&
        SemQuest001.canShowSemNewsButton(
          world: _worldState,
          gameDateKey: _timeController.onlyDate,
          semSummonedAtFacade: _semTalkContextActive,
        )) {
      _timeController.addMinutes(5);
      setState(() {
        _semTalkSubmenuActive = false;
        _semGirlsFollowUpActive = true;
        newsMessage = t(SemQuest001.l10nFoundSomeoneDialogue);
      });
      _saveService.autosave();
      return;
    }
    setState(() {
      _semTalkSubmenuActive = false;
      newsMessage = t(SemTalkMenu.l10nNewsFallback);
    });
  }

  void _semTalkPalivoWitness() {
    _timeController.addMinutes(5);
    SemPalivoGirlsTalk.markDone(_worldState);
    _saveService.autosave();
    setState(() {
      _semTalkSubmenuActive = false;
      newsMessage = sl<LocaleController>().t(SemPalivoGirlsTalk.l10nDialogue);
    });
  }

  void _semTalkAboutGirls() {
    final t = sl<LocaleController>().t;
    if (!_semTalkContextActive) {
      setState(() {
        _semTalkSubmenuActive = false;
        newsMessage = t(SemTalkMenu.l10nGirlsDone);
      });
      return;
    }
    if (!SemQuest001.canShowGirlsTalkButton(
      world: _worldState,
      gameDateKey: _timeController.onlyDate,
      semSummonedAtFacade: _semSummonedAtFriendFacade,
    )) {
      setState(() {
        _semTalkSubmenuActive = false;
        newsMessage = t(SemTalkMenu.l10nGirlsDone);
      });
      return;
    }
    setState(() {
      _semTalkSubmenuActive = false;
      _semGirlsTalkActive = true;
      newsMessage = '';
    });
  }

  List<Widget>? _semGirlsTalkFlowButtonsIfAny() {
    if (!_semTalkContextActive) return null;
    final t = sl<LocaleController>().t;
    if (_semGirlsSisterTalkActive) {
      return [
        _navBtn(t(SemQuest001.l10nGirlsSubBackButton), () {
          SemQuest001.markSisterTalkDone(_worldState);
          _saveService.autosave();
          setState(() {
            _semGirlsSisterTalkActive = false;
            newsMessage = '';
          });
        }),
      ];
    }
    if (_semGirlsHintTalkActive) {
      return [
        _navBtn(t(SemQuest001.l10nGirlsSubBackButton), () {
          setState(() {
            _semGirlsHintTalkActive = false;
            if (!_worldState.semGirlsSisterTalkDone) {
              newsMessage = '';
            } else {
              _semGirlsTalkActive = false;
              newsMessage = t('friend_house_summon_news');
            }
          });
        }),
      ];
    }
    if (!_semGirlsTalkActive) return null;
    final buttons = <Widget>[];
    if (!_worldState.semJuniperGirlsTalkDone) {
      buttons.add(
        _navBtn(t(SemQuest001.l10nGirlsHintButton), () {
          _timeController.addMinutes(5);
          SemQuest001.markGirlsHintDone(
            _worldState,
            _timeController.onlyDate,
          );
          _saveService.autosave();
          setState(() {
            _semGirlsHintTalkActive = true;
            newsMessage = t(SemQuest001.l10nGirlsTalkDialogue);
          });
        }),
      );
      buttons.add(const SizedBox(height: 8));
    }
    if (!_worldState.semGirlsSisterTalkDone) {
      buttons.add(
        _navBtn(t(SemQuest001.l10nGirlsSisterAskButton), () {
          _timeController.addMinutes(5);
          setState(() {
            _semGirlsSisterTalkActive = true;
            newsMessage = t(SemQuest001.l10nGirlsSisterDialogue);
          });
        }),
      );
      buttons.add(const SizedBox(height: 8));
    }
    buttons.add(_navBtn(t('friend_house_btn_leave'), () {
      setState(() {
        _semGirlsTalkActive = false;
        newsMessage =
            _semSummonedAtFriendFacade ? t('friend_house_summon_news') : '';
      });
    }));
    return buttons;
  }

  Widget? _semGirlsTalkPriorityActionPanelIfAny() {
    if (!isInsideRoom ||
        currentZone != 'STREET' ||
        currentStreetHouse != LocationsData.friendHouse) {
      return null;
    }
    final buttons = _semGirlsTalkFlowButtonsIfAny();
    if (buttons == null) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }

  void _semTalkAboutParents() {
    final t = sl<LocaleController>().t;
    final sem = findSemNpc(sl<NPCService>().allNPCs);
    if (sem != null && SemParentsTalkEvent.canShowAskButton(sem)) {
      _timeController.addMinutes(SemParentsTalkEvent.minutesOnOpenDialogue);
      setState(() {
        _semTalkSubmenuActive = false;
        _semParentsTalkActive = true;
        newsMessage = t(SemParentsTalkEvent.l10nDialogueKey);
      });
      return;
    }
    setState(() {
      _semTalkSubmenuActive = false;
      newsMessage = t(SemTalkMenu.l10nParentsDone);
    });
  }

  void _purgeSemJuniperRoomIntroIfMisplaced() {
    if (!SemJuniperRoomIntro.isSceneActive(
      introUiActive: _semJuniperIntroUiActive,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      if (!_semJuniperIntroUiActive) return;
      _semJuniperIntroUiActive = false;
      _semJuniperIntroSkippedPath = false;
      final t = sl<LocaleController>().t;
      final introText = t(SemJuniperRoomIntro.l10nDialogue);
      final skippedIntroText = t(SemJuniperRoomIntro.l10nSkippedDialogue);
      if (newsMessage == introText || newsMessage == skippedIntroText) {
        newsMessage = LocationsData.getLocationDisplayName(
          LocationsData.migrateLegacyRoomId(currentRoom),
        );
      }
    }
  }

  void _ensureSemJuniperIntroUiCoherent() {
    _purgeSemJuniperRoomIntroIfMisplaced();
    if (!_semJuniperIntroUiActive) return;
    if (SemJuniperRoomIntro.isInSemRoom(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      newsMessage = _semJuniperIntroDialogueMessage();
      return;
    }
    _semJuniperIntroUiActive = false;
    _semJuniperIntroSkippedPath = false;
    _ui.setEventImagePath(null);
    final t = sl<LocaleController>().t;
    final introText = t(SemJuniperRoomIntro.l10nDialogue);
    final skippedIntroText = t(SemJuniperRoomIntro.l10nSkippedDialogue);
    if (newsMessage == introText || newsMessage == skippedIntroText) {
      newsMessage = LocationsData.getLocationDisplayName(
        LocationsData.migrateLegacyRoomId(currentRoom),
      );
    }
  }

  Widget? _juniperManuelKompromatStep2AfterFleePriorityActionPanelIfAny() {
    if (!_isJuniperManuelKompromatStep2AfterFleeUiCoherent()) return null;
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(t('mom_quest_001_btn_back').toUpperCase(), _handleBackTap),
        ],
      ),
    );
  }

  Widget? _semJuniperIntroPriorityActionPanelIfAny() {
    if (!SemJuniperRoomIntro.isSceneActive(
      introUiActive: _semJuniperIntroUiActive,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      return null;
    }
    final t = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _navBtn(
            t(SemJuniperRoomIntro.l10nLeaveButton).toUpperCase(),
            _finishSemJuniperIntro,
          ),
        ],
      ),
    );
  }

  void _applyDanielleSpyWatchTier(int tier) {
    _spyParentsPhase = switch (tier) {
      1 => DanielleSpyParentsPhase.watchVideo1,
      2 => DanielleSpyParentsPhase.watchVideo2,
      3 => DanielleSpyParentsPhase.watchVideo3,
      _ => DanielleSpyParentsPhase.watchVideo1,
    };
    _ui.setEventImagePath(null);
    _eventVideoPath = DanielleSpyParentsQuest.peekVideoPathForTier(tier);
    _eventVideoMuted = false;
    _eventVideoFullScreen = true;
    _eventVideoCloseWhenCompleted = false;
    _eventVideoLoop = true;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoOnComplete = _finishSpyOnSemParentsToCorridor;
    final loc = sl<LocaleController>();
    final msgKey = DanielleSpyParentsQuest.afterPeekDialogueKeyForTier(tier);
    newsMessage = loc.t(msgKey);
  }

  void _danielleSpyWatchMoreAfterVideo1() {
    setState(() => _applyDanielleSpyWatchTier(2));
  }

  void _danielleSpyWatchMoreAfterVideo2() {
    setState(() => _applyDanielleSpyWatchTier(3));
  }

  /// Danielle у поточній кімнаті за розкладом (як у панелі дій NPC).
  bool _isNpcEffectivelyInCurrentRoom(String npcId) {
    if (!isInsideRoom) return false;
    final npcService = sl<NPCService>();
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final list = npcService.getNPCsInRoom(currentRoom, hour, day);
    for (final npc in list) {
      if (npc.id == npcId &&
          npcService.getCurrentLocationId(npc, hour, day) == currentRoom) {
        return true;
      }
    }
    return false;
  }

  /// Мама / Elsa / Piper у ванні — телефон можна знайти в їх кімнаті під час обшуку.
  bool _isFamilyRoomOwnerInShower(String roomId, int hour, int day) {
    final String? npcId = switch (roomId) {
      LocationsData.momRoom => 'mom',
      LocationsData.elsaRoom => 'elsa',
      LocationsData.piperRoom => 'piper',
      _ => null,
    };
    if (npcId == null) return false;
    final npcService = sl<NPCService>();
    final npc = npcService.npcById(npcId);
    if (npc == null) return false;
    return npcService.getCurrentLocationId(npc, hour, day) ==
        LocationsData.bathroom;
  }

  void _syncDanielleSpyCaughtUiWithNav() {
    if (!mounted) return;
    if (_danielleSpyCaughtUiActive) {
      if (!isInsideRoom ||
          !_isNpcEffectivelyInCurrentRoom(DanielleSpyCaughtQuest.npcId)) {
        setState(_clearDanielleSpyCaughtUiOnly);
      }
      return;
    }
    if (!DanielleSpyCaughtQuest.isPending(_worldState)) return;
    if (_spyOnSemParentsUiActive) return;
    if (!isInsideRoom) return;
    if (!_isNpcEffectivelyInCurrentRoom(DanielleSpyCaughtQuest.npcId)) {
      return;
    }
    setState(_maybeStartDanielleSpyCaughtAutoInRoom);
  }

  void _clearDanielleSpyCaughtUiOnly() {
    _danielleSpyCaughtUiActive = false;
  }

  /// Автостарт «спалився», якщо Danielle у поточній кімнаті (без вибору в смузі).
  void _maybeStartDanielleSpyCaughtAutoInRoom() {
    if (!DanielleSpyCaughtQuest.isPending(_worldState)) return;
    if (_spyOnSemParentsUiActive) return;
    if (_danielleSpyCaughtUiActive) return;
    if (!isInsideRoom) return;
    if (!_isNpcEffectivelyInCurrentRoom(DanielleSpyCaughtQuest.npcId)) {
      return;
    }
    _danielleSpyCaughtUiActive = true;
    _selectedNpcIdInRoom = null;
    newsMessage = sl<LocaleController>().t(
      DanielleSpyCaughtQuest.dialogueL10nKey(_worldState),
    );
  }

  Widget _buildFullScreenMainPanelOverlay() {
    if (_selectedNpcForProfile != null) {
      return NpcProfileView(
        npc: _selectedNpcForProfile!,
        timeController: _timeController,
        npcService: sl<NPCService>(),
        gameWorld: _worldState,
      );
    }
    if (isNpcGalleryOpen) {
      return NpcGalleryView(
        npcs: npcsExcludingSecondary(sl<NPCService>().allNPCs),
        timeController: _timeController,
        onBack: () => setState(() => isNpcGalleryOpen = false),
        onNpcCardTap: (npc) => setState(() => _selectedNpcForProfile = npc),
      );
    }
    if (isBackpackOpen) {
      return BackpackView(
        inventory: _inventory,
        playerStats: _playerStats,
        onChanged: () => setState(() {}),
      );
    }
    if (isStatsOpen) {
      return ListenableBuilder(
        listenable: _playerStats,
        builder: (context, _) => PlayerStatsView(playerStats: _playerStats),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMainContent() {
    if (isNpcGalleryOpen ||
        _selectedNpcForProfile != null ||
        isBackpackOpen ||
        isStatsOpen) {
      return const ColoredBox(color: GameTheme.bgDark);
    }

    if (currentZone == "HOME") {
      if (isLaptopOpen) {
        return LaptopScreen(
          onClose: () => setState(() {
            isLaptopOpen = false;
            _isWatchingPornInLaptop = false;
            _isWatchingElsaVideoInLaptop = false;
          }),
          onWatchingPornChanged: (v) => setState(() => _isWatchingPornInLaptop = v),
          onElsaVideoWatchingChanged: (v) => setState(() => _isWatchingElsaVideoInLaptop = v),
          bottomRightOverlay: _showMasturbateVideo
              ? MasturbateVideoOverlay(
                  videoPath: _masturbateVideoPath,
                  closeWhenCompleted: true,
                  onClose: () => setState(_closeMasturbateVideoOverlay),
                )
              : null,
        );
      }
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return HomeView(
            key: ValueKey(_locationSceneTickKey('home')),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            onRoomTap: _handleRoomEntry,
            onBack: _exitHomeRoomToCorridorGrid,
            timeController: _timeController,
            selectedNpcIdInRoom: _selectedNpcIdInRoom,
            suppressRoomNpcRaster: _suppressRoomNpcRasterForScene,
            inRoomVideoPath: _momQuest001VideoPath,
            inRoomVideoPlaybackTick: _momQuest001VideoTick,
            inRoomVideoLoop: _momQuest001VideoLoop,
            onNPCTap: (npc) {
              setState(() => _handleRoomNpcTap(npc));
            },
            onOpenLaptop: () => setState(() => isLaptopOpen = true),
            onSleep: _onSleepInRoom,
          );
        },
      );
    }

    if (currentZone == "COLLEGE") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          final activeNPCs = _getActiveNPCsInCurrentRoom();
          final bool hasSelectedNpc = _selectedNpcIdInRoom != null &&
              activeNPCs.any((n) => n.id == _selectedNpcIdInRoom);
          final NPCModel? effectiveActiveNpc = hasSelectedNpc
              ? activeNPCs.firstWhere((n) => n.id == _selectedNpcIdInRoom)
              : (activeNPCs.isNotEmpty ? activeNPCs.first : null);

          final String? activeNpcIdInRoom =
              _danielleSpyCaughtUiActive ? null : effectiveActiveNpc?.id;
          final piperLibraryEavesdrop = _isPiperQuest001LibraryEavesdropScene();
          return CollegeView(
            key: ValueKey(_locationSceneTickKey('college')),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            onRoomTap: _handleRoomEntry,
            onBack: () {
              _timeController.addMinutes(5);
            },
            timeController: _timeController,
            suppressRoomNpcRaster:
                _suppressRoomNpcRasterForScene || piperLibraryEavesdrop,
            piperLibraryEavesdropActive: piperLibraryEavesdrop,
            onNPCTap: (npc) {
              setState(() => _handleRoomNpcTap(npc));
            },
            activeNpcIdInRoom: activeNpcIdInRoom,
          );
        },
      );
    }

    if (currentZone == "CITY") {
      if (_showMomOfficeView) {
        final showImage = _momOfficeVideoIndex == null;
        if (showImage) {
          final imagePath = _momOfficeUseButtonImage
              ? MainGameScreenStateBase._momOfficeButtonImagePath
              : MainGameScreenStateBase._momOfficeImagePath;
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
            ),
          );
        }
        final videoPath =
            MainGameScreenStateBase._momOfficeVideoPaths[_momOfficeVideoIndex! - 1];
        return InRoomVideoSceneLauncher.buildZoneLayer(
          videoPath: videoPath,
          playbackTick: _momOfficeVideoIndex!,
          keyPrefix: 'mom_office',
          fallbackImagePath: MainGameScreenStateBase.momOfficeFallbackImagePath,
        );
      }
      if (_showRockefellerReceptionView &&
          currentRoom == LocationsData.cityBcRockefellerOffice) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            RockefellerCompanyView.receptionInteriorImagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey[900]),
          ),
        );
      }
      if (_showRockefellerCabinetView &&
          currentRoom == LocationsData.cityBcRockefellerOffice) {
        return ListenableBuilder(
          listenable: _timeController,
          builder: (context, _) {
            final npcService = sl<NPCService>();
            final roc = npcService.npcById('rockefeller');
            final hour = _timeController.dateTime.hour;
            final day = _timeController.weekdayIndex;
            final rockefellerHere = roc != null &&
                npcService.getCurrentLocationId(roc, hour, day) ==
                    LocationsData.cityBcRockefellerCabinet;
            final imagePath = rockefellerHere
                ? RockefellerCompanyView.cabinetInteriorImagePath
                : RockefellerCompanyView.cabinetEmptyOfficeImagePath;
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[900]),
              ),
            );
          },
        );
      }
      if (_showLogisticsOfficeVideo) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _showLogisticsOfficeVideo = false;
              _approachedSecretary = false;
            }),
            child: const VideoSceneWidget(
              key: ValueKey('luda_work'),
              videoPath: 'lib/assets/npcs/luda/work.webm',
            ),
          ),
        );
      }
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          final inventory = sl<InventoryController>();
          const shopMaxPerItem = 5;
          final mallProducts = isMallShopRoom(currentRoom)
              ? getProductsForMallRoom(currentRoom).where((p) {
                  final cnt = inventory.count(p.id);
                  if (p.purchasableOnce) return cnt == 0;
                  return cnt < shopMaxPerItem;
                }).toList()
              : null;
          return CityView(
            key: ValueKey(_locationSceneTickKey('city')),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            selectedNpcIdInRoom: _selectedNpcIdInRoom,
            suppressRoomNpcRaster: _suppressRoomNpcRasterForScene,
            suppressCherieGiftShopOfficeTc1Background:
                _suppressCherieGiftShopOfficeTc1Underlay,
            onRoomTap: _handleRoomEntry,
            onLogisticsOfficeTap: () {
              setState(_enterLogisticsMomOfficeFlow);
            },
            onRockefellerCabinetTap: () {
              final npcService = sl<NPCService>();
              final roc = npcService.npcById('rockefeller');
              final hour = _timeController.dateTime.hour;
              final day = _timeController.weekdayIndex;
              final rockefellerHere = roc != null &&
                  npcService.getCurrentLocationId(roc, hour, day) ==
                      LocationsData.cityBcRockefellerCabinet;
              setState(() {
                _showRockefellerReceptionView = false;
                _showRockefellerCabinetView = true;
                _selectedNpcIdInRoom = rockefellerHere ? 'rockefeller' : null;
                if (rockefellerHere) {
                  _ui.setEventImagePath(null);
                  newsMessage = '';
                  _tryStartRockefellerNikeQuestInOffice(day);
                }
              });
            },
            onRockefellerReceptionTap: () {
              setState(() {
                _showRockefellerCabinetView = false;
                _showRockefellerReceptionView = true;
                newsMessage = t('rockefeller_reception_news');
              });
            },
            onBack: () {
              _timeController.addMinutes(5);
              setState(() {
                if (currentRoom == LocationsData.cityBusinessCenter || currentRoom == LocationsData.cityMall || currentRoom == LocationsData.cityEliteResidential || currentRoom == LocationsData.cityVipGym) {
                  currentRoom = LocationsData.cityOverview;
                  isInsideRoom = false;
                } else if (isInsideRoom &&
                    LocationsData.getCityEliteApartmentIdForInnerRoom(currentRoom) != null) {
                  currentRoom = LocationsData.getCityEliteApartmentIdForInnerRoom(currentRoom)!;
                  isInsideRoom = false;
                } else if (!isInsideRoom &&
                    LocationsData.cityEliteResidentialRoomIds.contains(currentRoom)) {
                  currentRoom = LocationsData.cityEliteResidential;
                  isInsideRoom = false;
                } else if (isInsideRoom &&
                    (currentRoom == LocationsData.cityBcCallCenterOperatorsHall ||
                        currentRoom == LocationsData.cityBcCallCenterBossOffice)) {
                  currentRoom = LocationsData.cityBcCallCenter;
                  isInsideRoom = true;
                } else if (isInsideRoom &&
                    LocationsData.cityGleamTeamRoomIds.contains(currentRoom)) {
                  currentRoom = LocationsData.cityBcGleamTeam;
                  isInsideRoom = true;
                } else if (isInsideRoom &&
                    LocationsData.cityLogisticsRoomIds.contains(currentRoom)) {
                  currentRoom = LocationsData.cityBcLogistics;
                  isInsideRoom = true;
                } else if (isInsideRoom &&
                    LocationsData.cityCarDealershipRoomIds.contains(currentRoom)) {
                  currentRoom = LocationsData.cityCarDealership;
                  isInsideRoom = true;
                } else if (isInsideRoom && currentRoom == LocationsData.cityCarDealership) {
                  currentRoom = LocationsData.cityOverview;
                  isInsideRoom = false;
                } else if (isInsideRoom &&
                    LocationsData.cityBusinessCenterRoomIds.contains(currentRoom)) {
                  currentRoom = LocationsData.cityBusinessCenter;
                  isInsideRoom = false;
                } else if (isInsideRoom &&
                    (currentRoom == LocationsData.cityMallRestaurantHall ||
                        currentRoom == LocationsData.cityMallRestaurantVip)) {
                  currentRoom = LocationsData.cityMallCinema;
                  isInsideRoom = true;
                } else if (isInsideRoom &&
                    (currentRoom == LocationsData.cityMallGiftShopOffice ||
                        currentRoom == LocationsData.cityMallGiftShopWarehouse)) {
                  currentRoom = LocationsData.cityMallGiftShop;
                  isInsideRoom = true;
                } else if (isInsideRoom &&
                    LocationsData.isMallAreaRoom(currentRoom)) {
                  currentRoom = LocationsData.cityMall;
                  isInsideRoom = false;
                } else if (isInsideRoom &&
                    LocationsData.cityVipGymRoomIds.contains(currentRoom)) {
                  currentRoom = LocationsData.cityVipGym;
                  isInsideRoom = false;
                } else {
                  isInsideRoom = false;
                  currentRoom = LocationsData.cityOverview;
                }
                _maybeAbortCherieQuest002WrongLocation();
              });
            },
            timeController: _timeController,
            onNPCTap: (npc) {
              setState(() {
                _handleRoomNpcTap(npc);
              });
            },
            mallShopProducts: mallProducts,
            mallShopTitle: isMallShopRoom(currentRoom) ? getMallShopTitle(currentRoom) : null,
            onMallShopProductTap: isMallShopRoom(currentRoom) ? _showMallPurchaseConfirm : null,
          );
        },
      );
    }

    if (currentZone == "POOR_DISTRICT") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return PoorDistrictView(
            key: ValueKey(_locationSceneTickKey('poor')),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            selectedNpcIdInRoom: _selectedNpcIdInRoom,
            suppressRoomNpcRaster: _suppressRoomNpcRasterForScene,
            onRoomTap: _handleRoomEntry,
            onBack: () {
              if (isInsideRoom) {
                _timeController.addMinutes(5);
                setState(() {
                  currentRoom = LocationsData.poorDistrictOverview;
                  isInsideRoom = false;
                  newsMessage = LocationsData.getLocationDisplayName(
                    LocationsData.poorDistrictOverview,
                  );
                  _maybeAbortCherieQuest002WrongLocation();
                });
              } else {
                _addTravelTime("POOR_DISTRICT", "CITY");
                setState(() {
                  currentZone = "CITY";
                  currentRoom = LocationsData.cityOverview;
                  isInsideRoom = false;
                  newsMessage = LocationsData.getLocationDisplayName(
                    LocationsData.cityOverview,
                  );
                  _maybeAbortCherieQuest002WrongLocation();
                });
              }
            },
            timeController: _timeController,
            onNPCTap: (npc) {
              setState(() => _handleRoomNpcTap(npc));
            },
          );
        },
      );
    }
    if (currentZone == "POOR_VILLAGE") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return PoorVillageView(
            key: ValueKey(_locationSceneTickKey('poor_village')),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            selectedNpcIdInRoom: _selectedNpcIdInRoom,
            suppressRoomNpcRaster: _suppressRoomNpcRasterForScene,
            onRoomTap: _handleRoomEntry,
            onBack: () {
              if (isInsideRoom) {
                _timeController.addMinutes(5);
                setState(() {
                  currentRoom = LocationsData.poorVillageOverview;
                  isInsideRoom = false;
                  newsMessage = LocationsData.getLocationDisplayName(
                    LocationsData.poorVillageOverview,
                  );
                  _maybeAbortCherieQuest002WrongLocation();
                });
              } else {
                _addTravelTime("POOR_VILLAGE", "CITY");
                setState(() {
                  currentZone = "CITY";
                  currentRoom = LocationsData.cityOverview;
                  isInsideRoom = false;
                  newsMessage = LocationsData.getLocationDisplayName(
                    LocationsData.cityOverview,
                  );
                  _maybeAbortCherieQuest002WrongLocation();
                });
              }
            },
            timeController: _timeController,
            onNPCTap: (npc) {
              setState(() => _handleRoomNpcTap(npc));
            },
          );
        },
      );
    }
    if (currentZone == "OUT_OF_TOWN") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return OutOfTownView(
            key: ValueKey(_locationSceneTickKey('out_of_town')),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            selectedNpcIdInRoom: _selectedNpcIdInRoom,
            suppressRoomNpcRaster: _suppressRoomNpcRasterForScene,
            onRoomTap: _handleRoomEntry,
            onBack: () {
              if (isInsideRoom) {
                _timeController.addMinutes(5);
                setState(() {
                  currentRoom = LocationsData.outOfTownOverview;
                  isInsideRoom = false;
                  newsMessage = LocationsData.getLocationDisplayName(
                    LocationsData.outOfTownOverview,
                  );
                });
              } else {
                _addTravelTime("OUT_OF_TOWN", "CITY");
                setState(() {
                  currentZone = "CITY";
                  currentRoom = LocationsData.cityOverview;
                  isInsideRoom = false;
                  newsMessage = LocationsData.getLocationDisplayName(
                    LocationsData.cityOverview,
                  );
                });
              }
            },
            timeController: _timeController,
            onNPCTap: (npc) {
              setState(() => _handleRoomNpcTap(npc));
            },
          );
        },
      );
    }

    if (currentZone == "STREET") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return StreetView(
            key: ValueKey(_streetLocationSceneTickKey()),
            currentStreetHouse: currentStreetHouse,
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            selectedNpcIdInRoom: _selectedNpcIdInRoom,
            suppressRoomNpcRaster: _suppressRoomNpcRasterForScene,
            semJuniperEveningClipShowOnThisVisit:
                _semJuniperEveningClipShowOnThisVisit,
            semJuniperEveningClipPlaybackTick:
                _juniperEveningClipPlaybackTick,
            semJuniperEveningClipVideoPath: _semJuniperEveningClipShowOnThisVisit
                ? _juniperEveningClipVideoPath
                : null,
            semJuniperIntroActive: SemJuniperRoomIntro.isSceneActive(
              introUiActive: _semJuniperIntroUiActive,
              zone: currentZone,
              streetHouse: currentStreetHouse,
              insideRoom: isInsideRoom,
              room: currentRoom,
            ),
            semJuniperShowerVideoPath: _juniperShowerVideoPath,
            semJuniperShowerPlaybackTick: _juniperShowerPlaybackTick,
            semJuniperSemRoomSexVideoPath: _juniperSemRoomSexUiActive
                ? _juniperSemRoomSexVideoPath
                : null,
            semJuniperSemRoomSexPlaybackTick: _juniperSemRoomSexPlaybackTick,
            semJuniperManuelKompromatVideoPath:
                JuniperManuelKompromatInRoomScene.streetViewVideoPath(
                  phase: _juniperManuelKompromatPhase,
                  videoPathActive: _juniperManuelKompromatVideoPath,
                  zone: currentZone,
                  streetHouse: currentStreetHouse,
                  insideRoom: isInsideRoom,
                  room: currentRoom,
                ),
            semJuniperManuelKompromatPlaybackTick:
                _juniperManuelKompromatPlaybackTick,
            semJuniperQuest003VideoPath: _semJuniperQuest003LoungeStreetViewVideoPath(),
            semJuniperQuest003PlaybackTick: _juniperQuest003PlaybackTick,
            semJuniperQuest003HallVideoActive:
                _isJuniperQuest003HallStreetViewVideoActive(),
            semJuniperQuest003HallVideoPath:
                _semJuniperQuest003HallStreetViewVideoPath(),
            semJuniperQuest003HallPlaybackTick: _juniperQuest003HallPlaybackTick,
            friendHouseStreetFacade: _friendHouseStreetFacade,
            onFriendHouseStreetFacadeChanged: (visible) => setState(() {
              _friendHouseStreetFacade = visible;
              if (!visible) {
                _resetSemTalkFlowUi();
              } else if (!_semSummonedAtFriendFacade) {
                _resetSemTalkFlowUi(clearSummoned: false);
              }
            }),
            onRoomTap: _handleRoomEntry,
            onBack: () {
              _timeController.addMinutes(5);
              setState(() {
                if (currentStreetHouse != null && isInsideRoom) {
                  if (_juniperSemRoomSexUiActive) {
                    _clearJuniperSemRoomSexUiOnly();
                    _selectedNpcIdInRoom = null;
                  }
                  isInsideRoom = false;
                  currentRoom = LocationsData.getFirstRoomIdForStreetHouse(
                          currentStreetHouse) ??
                      LocationsData.corridor;
                } else if (currentStreetHouse != null) {
                  currentStreetHouse = null;
                  currentRoom = LocationsData.street;
                  isInsideRoom = false;
                } else {
                  isInsideRoom = false;
                  currentRoom = LocationsData.street;
                }
                _ensureJuniperManuelKompromatUiCoherent();
                _resetNewsMessageIfOutsideQuestEventContext();
              });
            },
            timeController: _timeController,
            onNPCTap: (npc) {
              setState(() => _handleRoomNpcTap(npc));
            },
          );
        },
      );
    }

    return Center(
      child: Text(
        sl<LocaleController>().t('debug_location_label').replaceAll('%s', currentZone),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
  void _handleBackTap() {
    setState(_prepareForPlayerAction);
    if (CherieQuest002.shouldPresentHomeHallSteps(
          world: _worldState,
          cherie: sl<NPCService>().npcById('cherie'),
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
        )) {
      setState(() {
        _abortCherieQuest002ProgressAndUi(
          applySaturdaySundayBlock: _timeController.weekdayIndex == 5,
        );
      });
      _saveService.autosave();
      return;
    }
    if (currentZone == 'CITY' && isInsideRoom) {
      final rn = LocationsData.migrateLegacyRoomId(currentRoom);
      if (_isCherieQuest002ScriptedDialogActive()) {
        final q2s = _questStep('cherie_quest_002');
        if (q2s >= 1 &&
            q2s <= 4 &&
            (rn == LocationsData.cityMallGiftShopOffice ||
                rn == LocationsData.cityMallGiftShopWarehouse)) {
          setState(() {
            _abortCherieQuest002ProgressAndUi(
              applySaturdaySundayBlock:
                  _timeController.weekdayIndex == 5,
            );
          });
          _saveService.autosave();
          return;
        }
      }
      if (_isCherieQuest003ScriptedDialogActive()) {
        final q3s = _questStep('cherie_quest_003');
        if (q3s >= 1 &&
            q3s <= 3 &&
            rn == LocationsData.cityMallGiftShopOffice) {
          setState(_abortCherieQuest003ProgressAndUi);
          _saveService.autosave();
          return;
        }
      }
      if (_isCherieQuest004ScriptedDialogActive()) {
        final q4s = _questStep('cherie_quest_004');
        if (q4s == 1 && rn == LocationsData.cityMallGiftShopOffice) {
          setState(_abortCherieQuest004ProgressAndUi);
          _saveService.autosave();
          return;
        }
      }
      if (_isCherieQuest005ScriptedDialogActive()) {
        final q5s = _questStep('cherie_quest_005');
        if (q5s == 1 && rn == LocationsData.cityMallGiftShopOffice) {
          setState(_abortCherieQuest005ProgressAndUi);
          _saveService.autosave();
          return;
        }
      }
      if (_isCherieQuest006ScriptedDialogActive()) {
        final q6s = _questStep('cherie_quest_006');
        if (q6s >= 1 &&
            q6s <= 4 &&
            rn == LocationsData.cityMallGiftShopOffice) {
          setState(_abortCherieQuest006ProgressAndUi);
          _saveService.autosave();
          return;
        }
      }
      if (rn == LocationsData.cityMallGiftShopOffice) {
        final shiftFlowActive = _isGiftShopAnimatorShiftFlowActive();
        final officeQuestActive = _ui.cherieQuest001OfficePhase !=
            CherieQuest001OfficePhase.inactive;
        if (officeQuestActive || shiftFlowActive) {
          setState(() {
            _resetCherieOfficeAnimatorQuestSession(
              abortGiftShopAnimatorShift: shiftFlowActive,
            );
          });
          _saveService.autosave();
        }
      }
    }
    if (currentZone == 'POOR_VILLAGE' && isInsideRoom) {
      if (_isCherieQuest004ScriptedDialogActive()) {
        setState(_abortCherieQuest004ProgressAndUi);
        _saveService.autosave();
        return;
      }
      if (_isCherieQuest005ScriptedDialogActive()) {
        setState(_abortCherieQuest005ProgressAndUi);
        _saveService.autosave();
        return;
      }
    }
    if (_spyOnSemParentsUiActive) {
      _finishSpyOnSemParentsToCorridor();
      return;
    }
    if (_juniperShowerUiActive) {
      _finishJuniperShowerScene();
      return;
    }
    if (_juniperQuest003UiActive) {
      _finishJuniperQuest003Scene();
      return;
    }
    if (_juniperQuest003HallUiActive) {
      _finishJuniperQuest003HallScene();
      return;
    }
    if (_juniperSemRoomSexUiActive) {
      _finishJuniperSemRoomSexScene();
      return;
    }
    if (_juniperManuelKompromatStep4UiActive) {
      _finishJuniperManuelKompromatStep4Scene();
      return;
    }
    if (_juniperManuelKompromatStep3UiActive) {
      _finishJuniperManuelKompromatStep3Scene();
      return;
    }
    if (_juniperManuelKompromatStep2AfterFleeUiActive) {
      _finishJuniperManuelKompromatStep2AfterFleeScene();
      return;
    }
    if (_juniperManuelKompromatStep2UiActive) {
      setState(() {
        _clearJuniperManuelKompromatStep2UiOnly();
        _ensureJuniperManuelKompromatUiCoherent();
        _resetNewsMessageIfOutsideQuestEventContext();
      });
      _saveService.autosave();
      return;
    }
    if (_juniperQuest002Step1UiActive) {
      setState(_deferJuniperQuest002Step1);
      return;
    }
    if (_juniperManuelKompromatUiActive) {
      _finishJuniperManuelKompromatScene();
      return;
    }
    if (currentZone == 'STREET' &&
        currentStreetHouse == LocationsData.friendHouse &&
        isInsideRoom &&
        _semJuniperEveningClipShowOnThisVisit) {
      setState(() {
        _semJuniperEveningClipShowOnThisVisit = false;
        _juniperEveningClipVideoPath = null;
        _selectedNpcIdInRoom = null;
        _exitFriendHouseInteriorToCorridor();
      });
      _saveService.autosave();
      return;
    }
    if (SemJuniperRoomIntro.isSceneActive(
      introUiActive: _semJuniperIntroUiActive,
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
    )) {
      _finishSemJuniperIntro();
      return;
    }
    if (_danielleSpyCaughtUiActive) {
      _finishDanielleSpyCaughtQuest();
      return;
    }
    if (_sashaMorningRunUiActive) {
      _exitSashaMorningRunEventToStreetOverview(
        incrementTimesCompleted: true,
      );
      return;
    }
    if (_sashaComunicateInHallUiActive) {
      _exitSashaCommunicateInHallToCorridor();
      return;
    }
    if (_collegeToiletUnderwearSaleActive) {
      setState(() {
        if (_collegeToiletUnderwearSalePendingItemId != null) {
          _collegeToiletUnderwearSalePendingItemId = null;
        } else {
          _resetCollegeToiletUnderwearSaleUi();
        }
      });
      return;
    }
    if (currentZone == 'STREET' &&
        currentStreetHouse == null &&
        !isInsideRoom &&
        _friendHouseStreetFacade) {
      setState(() {
        _friendHouseStreetFacade = false;
        _resetSemTalkFlowUi();
      });
      return;
    }
    if (_showMomOfficeView) {
      setState(_exitMomOfficeView);
      return;
    }
    _nav.handleBackTap();
    setState(() {
      _resetCollegeToiletUnderwearSaleUi();
      _maybeAbortCherieQuest002WrongLocation();
      _maybeAbortCherieQuest003WrongLocation();
      _maybeAbortCherieQuest004WrongLocation();
      _maybeAbortCherieQuest005WrongLocation();
      _maybeAbortCherieQuest006WrongLocation();
      _maybeAbortCherieMassageFunEventWrongLocation();
      _ensurePiperQuest001Step2ApproachUiCoherent();
      _tryStartPiperQuest001Step4IfNeeded();
      _ensurePiperQuest001Step4CorridorUiCoherent();
      _ensureJuniperManuelKompromatUiCoherent();
      _ensureJuniperQuest002Step1UiCoherent();
      _resetNewsMessageIfOutsideQuestEventContext();
    });
  }

  void _exitSashaCommunicateInHallToCorridor() {
    if (!mounted) return;
    setState(() {
      _sashaComunicateInHallUiActive = false;
      _sashaComunicatePhase =
          ComunicateSashaInHallPhase.intro;

      _ui.setEventImagePath(null);
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoCloseWhenCompleted = true;

      _exitFriendHouseInteriorToCorridor();
      _saveService.autosave();
    });
  }

  void _appendNavButtonSpacerIfNeeded(List<Widget> actionWidgets) {
    if (actionWidgets.isEmpty) return;
    if (actionWidgets.last is SizedBox) return;
    actionWidgets.add(const SizedBox(height: 8));
  }

  Widget _navBtn(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: GameTheme.actionButtonStyle(color: GameTheme.textBlack),
      onPressed: () {
        setState(_prepareForPlayerAction);
        onTap();
      },
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFlyersButton() {
    return _navBtn(
      sl<LocaleController>().t('flyers_go_button').toUpperCase(),
      () => setState(() => _showFlyersVideo = true),
    );
  }

  Widget _buildConstructionButton() {
    return _navBtn(
      sl<LocaleController>().t('construction_go_button').toUpperCase(),
      () => setState(() => _showConstructionVideo = true),
    );
  }

  Widget _buildCallCenterButton() {
    return _navBtn(
      sl<LocaleController>().t('call_center_go_button').toUpperCase(),
      () => _startCallCenterJob(),
    );
  }

  void _startCallCenterJob() async {
    final dt = _timeController.dateTime;
    final todayKey = '${dt.year}-${dt.month}-${dt.day}';

    if (!_worldState.callCenterJobOfferPending) return;

    final inJobTimeWindow = dt.hour >= 8 && dt.hour < 13 && _timeController.weekdayIndex <= 4;
    if (!inJobTimeWindow) return;

    if (_worldState.lastCallCenterDateKey == todayKey) return;

    _timeController.addMinutes(180);
    _playerStats.changeMoney(150);
    _playerStats.changeEnergy(-20);
    _worldState.lastCallCenterDateKey = todayKey;
    await _saveService.autosave();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sl<LocaleController>().t('job_earned_call_center')),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  Widget _buildGiftShopAnimatorWorkButton() {
    return _navBtn(
      sl<LocaleController>().t('gift_shop_go_button').toUpperCase(),
      _onGiftShopAnimatorWorkButtonPressed,
    );
  }

  /// Перша зміна (інтро): тап по «Працювати аніматором»; квест 2 крок 1 — теж звідси; далі — робоче відео.
  void _onGiftShopAnimatorWorkButtonPressed() {
    setState(() {
      _healCherieAnimatorIntroIfStuckAfterShifts();
      _healCherieQuest001OfficePhaseIfAnimatorAgreed();
    });
    if (!_worldState.giftShopAnimatorJobOfferPending) return;
    if (!mounted) return;

    final npcServiceEarly = sl<NPCService>();
    final cherieEarly = npcServiceEarly.npcById('cherie');
    final hourEarly = _timeController.dateTime.hour;
    final dayEarly = _timeController.weekdayIndex;
    final q2GatesEarly = _cherieQuest002StartPlayerGates();
    final bool startingQuest002Office =
        _worldState.giftShopAnimatorShiftsCompleted > 0 &&
            CherieQuest002.canStartQuest002FromAnimatorButton(
              world: _worldState,
              cherie: cherieEarly,
              weekdayIndex: dayEarly,
              playerGates: q2GatesEarly,
            ) &&
            CherieQuest002.isAnimatorOfficeWindowWithCherie(
              currentZone: currentZone,
              isInsideRoom: isInsideRoom,
              currentRoom: currentRoom,
              hour: hourEarly,
              weekdayIndex: dayEarly,
              cherie: cherieEarly,
              npcService: npcServiceEarly,
            ) &&
            _ui.cherieQuest001OfficePhase == CherieQuest001OfficePhase.inactive &&
            !_isCherieQuest002ScriptedDialogActive() &&
            _eventVideoPath == null;

    final bool startingQuest003Office =
        _worldState.giftShopAnimatorShiftsCompleted > 0 &&
        CherieQuest003.canStartFromAnimatorWorkButton(
          world: _worldState,
          cherie: cherieEarly,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
          hour: hourEarly,
          weekdayIndex: dayEarly,
          npcService: npcServiceEarly,
          cherieQuest001OfficePhase: _ui.cherieQuest001OfficePhase,
          quest002ScriptedActive: _isCherieQuest002ScriptedDialogActive(),
          eventVideoPath: _eventVideoPath,
          giftShopAnimatorJobOfferPending:
              _worldState.giftShopAnimatorJobOfferPending,
          giftShopAnimatorPendingFinishDateKey:
              _worldState.giftShopAnimatorPendingFinishDateKey,
          giftShopAnimatorShiftsCompleted:
              _worldState.giftShopAnimatorShiftsCompleted,
        );

    final minEnergyForAnimatorStart = startingQuest002Office
        ? CherieQuest002.energyRewardBlockCost
        : startingQuest003Office
            ? CherieQuest003.energyCostLeave
            : MainGameScreenStateBase.kGiftShopAnimatorEnergyCost;
    if (_playerStats.player.energy < minEnergyForAnimatorStart) {
      showInsufficientEnergyDialog(context);
      return;
    }

    if (_worldState.giftShopAnimatorShiftsCompleted == 0) {
      final stepBefore = _worldState.cherieAnimatorIntroStep;
      _tryStartCherieAnimatorShiftIntroIfNeeded(
        LocationsData.cityMallGiftShopOffice,
      );
      if (!mounted) return;
      if (_worldState.cherieAnimatorIntroStep == stepBefore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sl<LocaleController>().t('gift_shop_animator_cannot_start'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final npcService = sl<NPCService>();
    final cherie = npcService.npcById('cherie');
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final q2Gates = _cherieQuest002StartPlayerGates();
    if (CherieQuest003.canStartFromAnimatorWorkButton(
          world: _worldState,
          cherie: cherie,
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
          hour: hour,
          weekdayIndex: day,
          npcService: npcService,
          cherieQuest001OfficePhase: _ui.cherieQuest001OfficePhase,
          quest002ScriptedActive: _isCherieQuest002ScriptedDialogActive(),
          eventVideoPath: _eventVideoPath,
          giftShopAnimatorJobOfferPending:
              _worldState.giftShopAnimatorJobOfferPending,
          giftShopAnimatorPendingFinishDateKey:
              _worldState.giftShopAnimatorPendingFinishDateKey,
          giftShopAnimatorShiftsCompleted:
              _worldState.giftShopAnimatorShiftsCompleted,
        )) {
      setState(() {
        _setQuestStep('cherie_quest_003', 1);
        _selectedNpcIdInRoom = 'cherie';
        _applyCherieQuest003Patch(CherieQuest003.patchForStep(1));
      });
      _saveService.autosave();
      return;
    }

    if (CherieQuest002.canStartQuest002FromAnimatorButton(
          world: _worldState,
          cherie: cherie,
          weekdayIndex: day,
          playerGates: q2Gates,
        ) &&
        CherieQuest002.isAnimatorOfficeWindowWithCherie(
          currentZone: currentZone,
          isInsideRoom: isInsideRoom,
          currentRoom: currentRoom,
          hour: hour,
          weekdayIndex: day,
          cherie: cherie,
          npcService: npcService,
        ) &&
        _ui.cherieQuest001OfficePhase == CherieQuest001OfficePhase.inactive &&
        !_isCherieQuest002ScriptedDialogActive() &&
        _eventVideoPath == null) {
      setState(() {
        _worldState.cherieQuest002WarehouseWhoAsked = false;
        _worldState.cherieQuest002Step = 1;
        _selectedNpcIdInRoom = 'cherie';
        _applyCherieQuest002OfficePatch(
          CherieQuest002.patchForPresentationStep(1, _worldState),
        );
      });
      _saveService.autosave();
      return;
    }

    if (CherieQuest002.isOnlySundayBlockPreventingQuest002(
          world: _worldState,
          cherie: cherie,
          weekdayIndex: day,
          playerGates: q2Gates,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sl<LocaleController>().t('cherie_quest_002_sunday_snackbar'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _playCherieAnimatorWorkVideo();
  }

  Widget _buildGiftShopAnimatorFinishButton() {
    return _navBtn(
      sl<LocaleController>().t('gift_shop_finish_animator_button').toUpperCase(),
      _finishGiftShopAnimatorShift,
    );
  }

  /// EVENT: cherie_event_001 — відео зміни; +1 до [GameWorldState.cherieAnimatorWorkVideoCount].
  void _playCherieAnimatorWorkVideo() {
    final dt = _timeController.dateTime;
    final slotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
      dt,
      _timeController.weekdayIndex,
    );

    if (_eventVideoPath != null) return;
    if (!_worldState.giftShopAnimatorJobOfferPending) return;
    if (!CherieEvents.isAnimatorShiftTimeWindow(
      weekdayIndex: _timeController.weekdayIndex,
      hour: dt.hour,
    )) {
      return;
    }
    if (_worldState.giftShopAnimatorPendingFinishDateKey == slotKey) return;

    setState(() {
      _worldState.giftShopAnimatorPendingFinishDateKey = slotKey;
      _worldState.cherieAnimatorWorkVideoCount += 1;
      _eventVideoPath = CherieEvents.animatorWorkVideoPath;
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
    });
    _saveService.autosave();
  }

  void _finishGiftShopAnimatorShift() async {
    final dt = _timeController.dateTime;
    final slotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
      dt,
      _timeController.weekdayIndex,
    );

    if (!_worldState.giftShopAnimatorJobOfferPending) return;
    if (_worldState.giftShopAnimatorShiftsCompleted == 0) return;
    if (_worldState.giftShopAnimatorPendingFinishDateKey != slotKey) return;

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

    setState(() {
      _worldState.giftShopAnimatorPendingFinishDateKey = null;

      // EVENT: cherie_event_002 — крок 2: tc_2 (loop) + діалог одразу; гроші / час / стати — на «Піти».
      _eventVideoPath = CherieEvents.animatorShiftEndVideoPath;
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = false;
      _eventVideoLoop = true;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      newsMessage = loc.t('cherie_animator_shift_end_dialogue');
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

  void _onCherieAnimatorShiftTc2LeavePressed() {
    final tips = _ui.cherieAnimatorShiftEarnedTipsForSnack ??
        _worldState.cherieAnimatorIntroTc2TipsStash;
    final slotKey = _ui.cherieAnimatorPendingShiftSlotKey ??
        _worldState.cherieAnimatorIntroTc2SlotKeyStash;
    final fromIntro = _ui.cherieAnimatorShiftRewardFromIntro ||
        _worldState.cherieAnimatorIntroStep == 5;
    _ui.clearCherieAnimatorShiftTc2Progress();
    if (!mounted) return;
    if (tips != null && slotKey != null) {
      setState(() {
        _timeController.addMinutes(240);
        _playerStats.changeMoney(300 + tips);
        _playerStats.changeEnergy(-MainGameScreenStateBase.kGiftShopAnimatorEnergyCost.toDouble());
        _playerStats.changeCharisma(1);
        if (fromIntro) {
          _playerStats.changeArousal(10);
        }
        _worldState.cherieAnimatorIntroStep = 0;
        _worldState.cherieAnimatorIntroTc2SlotKeyStash = null;
        _worldState.cherieAnimatorIntroTc2TipsStash = null;
        _worldState.lastGiftShopAnimatorDateKey = slotKey;
        _worldState.giftShopAnimatorShiftsCompleted += 1;
        newsMessage = LocationsData.getLocationDisplayName(currentRoom);
        _eventVideoPath = null;
        _eventVideoOnComplete = null;
        _eventVideoCloseWhenCompleted = true;
        _eventVideoFullScreen = false;
        _eventVideoLoop = false;
      });
    } else {
      setState(() {
        _worldState.cherieAnimatorIntroStep = 0;
        newsMessage = LocationsData.getLocationDisplayName(currentRoom);
        _eventVideoPath = null;
        _eventVideoOnComplete = null;
        _eventVideoCloseWhenCompleted = true;
        _eventVideoFullScreen = false;
        _eventVideoLoop = false;
      });
    }
    _saveService.autosave();
    if (!mounted) return;
    if (tips != null) {
      final loc = sl<LocaleController>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.t('job_earned_gift_shop_animator').replaceAll('%s', '$tips'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Ім'я зверху діалогу, коли гравець обрав NPC у [MainGameNpcAvatarStrip].
  String _messageWithSelectedNpcStripLine(String baseMessage) {
    final id = _selectedNpcIdInRoom;
    if (id == null || id.isEmpty) return baseMessage;
    NPCModel npc;
    try {
      npc = sl<NPCService>().allNPCs.firstWhere((n) => n.id == id);
    } catch (_) {
      return baseMessage;
    }
    final title = npc.name.trim().isNotEmpty ? npc.name : npc.fullName;
    if (title.isEmpty) return baseMessage;
    if (baseMessage.trim().isEmpty) return title;
    return '$title\n\n$baseMessage';
  }

  /// Імена NPC для підсвічування в тексті діалогу (активний у кімнаті або перший зі списку).
  List<String> _dialogueHighlightNames(int hour, int day) {
    if (!isInsideRoom) return const [];
    if (currentRoom == LocationsData.cityBcLogistics) return const [];
    final npcService = sl<NPCService>();
    if (_selectedNpcIdInRoom != null) {
      try {
        final picked = npcService.allNPCs.firstWhere((n) => n.id == _selectedNpcIdInRoom);
        if (picked.fullName != picked.name && picked.fullName.isNotEmpty) {
          return [picked.name, picked.fullName];
        }
        return [picked.name];
      } catch (_) {}
    }
    final activeNPCs = npcService
        .getNPCsInRoom(currentRoom, hour, day)
        .where((npc) => npcService.getCurrentLocationId(npc, hour, day) == currentRoom)
        .toList();
    if (activeNPCs.isEmpty) return const [];
    final npc = activeNPCs.first;
    if (npc.fullName != npc.name && npc.fullName.isNotEmpty) {
      return [npc.name, npc.fullName];
    }
    return [npc.name];
  }

  /// У залі вдома ГГ — кнопки тренування з гантелями / гирею (лише UI; логіка — окремо).
  /// Якщо є обидва предмети — дві кнопки підряд.
  /// Гейти:
  /// - тільки з 09:00 до 21:00 включно;
  /// - тільки коли в залі немає NPC (окрім ГГ).
  /// - кнопка доступна 1 раз на добу (після завершення тренування).
  void _appendHomeHallWorkoutButtonsIfNeeded(
    List<Widget> actionWidgets, {
    required String currentRoomNorm,
    required int hour,
    required bool hasOtherNpcsInRoom,
  }) {
    if (currentZone != 'HOME' || !isInsideRoom) return;
    if (currentRoomNorm != LocationsData.hall) return;
    if (hour < 9 || hour > 21) return;
    if (hasOtherNpcsInRoom) return;
    final onlyDate = _timeController.onlyDate;
    final canDumbbellsToday =
        _worldState.homeHallDumbbellsWorkoutLastDateKey != onlyDate;
    final canKettlebellToday =
        _worldState.homeHallKettlebellWorkoutLastDateKey != onlyDate;
    final hasDumbbells = _inventory.count('ganteli') > 0;
    final hasKettlebell = _inventory.count('girya') > 0;
    if (!hasDumbbells && !hasKettlebell) return;
    if (hasDumbbells && canDumbbellsToday) {
      actionWidgets.add(
        SizedBox(
          width: double.infinity,
          child: _navBtn(
            // Явно метод [MainGameScreenStateBase.t], без локальної змінної `t` (конфлікт імен у part/mixin).
            t('home_hall_workout_dumbbells'),
            () {
              _onHomeHallWorkoutDumbbellsTap();
            },
          ),
        ),
      );
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (hasKettlebell && canKettlebellToday) {
      actionWidgets.add(
        SizedBox(
          width: double.infinity,
          child: _navBtn(
            t('home_hall_workout_kettlebell'),
            () {
              _onHomeHallWorkoutKettlebellTap();
            },
          ),
        ),
      );
      actionWidgets.add(const SizedBox(height: 8));
    }
  }

  /// Житловий зал у будь-якому будинку / квартирі — «Відпочити годинку».
  void _appendResidentialHallRestButtonIfNeeded(
    List<Widget> actionWidgets, {
    required String currentRoomNorm,
  }) {
    if (!HallRestAction.canUse(
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoomNorm,
    )) {
      return;
    }
    actionWidgets.add(
      SizedBox(
        width: double.infinity,
        child: _navBtn(
          t('hall_rest_one_hour'),
          _onResidentialHallRestTap,
        ),
      ),
    );
    actionWidgets.add(const SizedBox(height: 8));
  }

  void _onResidentialHallRestTap() {
    setState(_prepareForPlayerAction);
    HallRestAction.apply(
      world: _worldState,
      playerStats: _playerStats,
      timeController: _timeController,
    );
    setState(_resetNewsMessageIfOutsideQuestEventContext);
  }

  void _onHomeHallWorkoutDumbbellsTap() {
    const int maxWorkoutStrength = 150;
    if (_playerStats.physical_fitness >= maxWorkoutStrength) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(t('home_hall_workout_strength_max_reached')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('dialog_close')),
            ),
          ],
        ),
      );
      return;
    }
    if (_playerStats.player.energy <= 30) {
      setState(() {
        newsMessage = t('home_hall_workout_need_rest');
      });
      return;
    }

    setState(() {
      _eventVideoPath = 'lib/assets/gg/ganteli.mp4';
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = false;
      _eventVideoLoop = true;
      _eventVideoOnComplete = null;
      // Для гантелей кнопка «Закінчити» має бути в локаційному меню (праворуч), а не у відео-оверлеї.
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _ui.setEventImagePath(null);
    });
  }

  void _onHomeHallWorkoutDumbbellsFinishPressed() {
    const int maxWorkoutStrength = 150;
    setState(() {
      _eventVideoPath = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoLoop = false;
      _eventVideoOnComplete = null;
      _ui.setEventImagePath(null);
      currentZone = 'HOME';
      currentRoom = LocationsData.hall;
      isInsideRoom = true;
      currentStreetHouse = null;
    });
    _timeController.addMinutes(30);
    _playerStats.changeEnergy(-25);
    if (_playerStats.physical_fitness < maxWorkoutStrength) {
      _playerStats.changePhysicalFitness(1);
      if (_playerStats.physical_fitness > maxWorkoutStrength) {
        _playerStats.changePhysicalFitness(
          maxWorkoutStrength - _playerStats.physical_fitness,
        );
      }
    } else {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(t('home_hall_workout_strength_max_reached')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('dialog_close')),
            ),
          ],
        ),
      );
    }
    _worldState.homeHallDumbbellsWorkoutLastDateKey = _timeController.onlyDate;
    _saveService.autosave();
  }

  void _onHomeHallWorkoutKettlebellTap() {
    const int minWorkoutStrengthExclusive = 100;
    const int maxWorkoutStrength = 250;
    if (_playerStats.physical_fitness >= maxWorkoutStrength) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(t('home_hall_workout_strength_max_reached')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('dialog_close')),
            ),
          ],
        ),
      );
      return;
    }
    if (_playerStats.physical_fitness <= minWorkoutStrengthExclusive) {
      setState(() {
        newsMessage = t('home_hall_workout_kettlebell_too_weak');
      });
      return;
    }
    if (_playerStats.player.energy <= 35) {
      setState(() {
        newsMessage = t('home_hall_workout_need_rest');
      });
      return;
    }

    setState(() {
      _eventVideoPath = 'lib/assets/gg/girya.mp4';
      _eventVideoMuted = false;
      _eventVideoFullScreen = true;
      _eventVideoCloseWhenCompleted = false;
      _eventVideoLoop = true;
      _eventVideoOnComplete = null;
      // Для гирі кнопка «Закінчити» теж має бути в локаційному меню.
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _ui.setEventImagePath(null);
    });
  }

  void _onHomeHallWorkoutKettlebellFinishPressed() {
    const int maxWorkoutStrength = 250;
    setState(() {
      _eventVideoPath = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoLoop = false;
      _eventVideoOnComplete = null;
      _ui.setEventImagePath(null);
      currentZone = 'HOME';
      currentRoom = LocationsData.hall;
      isInsideRoom = true;
      currentStreetHouse = null;
    });
    _timeController.addMinutes(30);
    _playerStats.changeEnergy(-30);
    if (_playerStats.physical_fitness < maxWorkoutStrength) {
      _playerStats.changePhysicalFitness(2);
      if (_playerStats.physical_fitness > maxWorkoutStrength) {
        _playerStats.changePhysicalFitness(
          maxWorkoutStrength - _playerStats.physical_fitness,
        );
      }
    } else {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(t('home_hall_workout_strength_max_reached')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('dialog_close')),
            ),
          ],
        ),
      );
    }
    _worldState.homeHallKettlebellWorkoutLastDateKey = _timeController.onlyDate;
    _saveService.autosave();
  }

  /// Кнопки переходу між зонами: Дім → … → (з дому / вул. Шевченка «В МІСТО») → …
  void _appendStandardWorldTravelButtons(List<Widget> actionWidgets) {
    if (currentZone != "HOME") {
      actionWidgets.add(        _navBtn("ДІМ", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "HOME");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semTalkSubmenuActive = false;
            _semParentsTalkActive = false;
          }
          currentStreetHouse = null;
          currentZone = "HOME";
          currentRoom = LocationsData.corridor;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          newsMessage =
              LocationsData.getLocationDisplayName(LocationsData.corridor);
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (currentZone == "POOR_VILLAGE" && !isInsideRoom) {
      actionWidgets.add(_navBtn("Місто", () {
        _nav.spendMoveEnergy();
        _addTravelTime("POOR_VILLAGE", "CITY");
        setState(() {
          currentZone = "CITY";
          currentRoom = LocationsData.cityOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _maybeAbortCherieQuest002WrongLocation();
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (currentZone != "STREET") {
      actionWidgets.add(_navBtn("ВУЛ. ШЕВЧЕНКА", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "STREET");
        setState(() {
          _friendHouseStreetFacade = false;
          _semSummonedAtFriendFacade = false;
          _semTalkSubmenuActive = false;
          _semParentsTalkActive = false;
          currentZone = "STREET";
          currentStreetHouse = null;
          currentRoom = LocationsData.street;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _tryStartSashaMorningRunOnStreetOverview();
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (currentZone != "COLLEGE") {
      actionWidgets.add(_navBtn("КОЛЕДЖ", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "COLLEGE");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semTalkSubmenuActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "COLLEGE";
          currentRoom = LocationsData.collegeHall;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (currentZone == "HOME" || currentZone == "STREET") {
      actionWidgets.add(_navBtn("В МІСТО", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "CITY");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semTalkSubmenuActive = false;
            _semParentsTalkActive = false;
            currentStreetHouse = null;
          }
          currentZone = "CITY";
          currentRoom = LocationsData.cityOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if ((currentZone == "CITY" ||
            currentZone == "POOR_VILLAGE" ||
            currentZone == "OUT_OF_TOWN") &&
        currentZone != "POOR_DISTRICT") {
      actionWidgets.add(_navBtn("Бідний р-н", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "POOR_DISTRICT");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semTalkSubmenuActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "POOR_DISTRICT";
          currentRoom = LocationsData.poorDistrictOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if ((currentZone == "CITY" ||
            currentZone == "POOR_DISTRICT" ||
            currentZone == "OUT_OF_TOWN") &&
        currentZone != "POOR_VILLAGE") {
      actionWidgets.add(_navBtn("Мажорщина", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "POOR_VILLAGE");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semTalkSubmenuActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "POOR_VILLAGE";
          currentRoom = LocationsData.poorVillageOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (currentZone == "CITY" ||
        currentZone == "POOR_DISTRICT" ||
        currentZone == "POOR_VILLAGE") {
      actionWidgets.add(_navBtn("На море", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "OUT_OF_TOWN");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semTalkSubmenuActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "OUT_OF_TOWN";
          currentRoom = LocationsData.outOfTownOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _resetNewsMessageIfOutsideQuestEventContext();
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
  }

  List<Widget> _buildSashaMorningRunActions({
    required NPCModel? sashaNpc,
  }) {
    final eventButtons = <Widget>[];
    final actions = _sashaEventRuntime.morningRunActions(_sashaMorningRunPhase);
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      if (action.id == 'giveMoney' && sashaNpc == null) {
        continue;
      }
      eventButtons.add(_navBtn(action.label, () {
        _onSashaMorningRunAction(action.id, sashaNpc);
      }));
      if (i != actions.length - 1) {
        eventButtons.add(const SizedBox(height: 8));
      }
    }
    return eventButtons;
  }

  void _finishSashaMorningRunAfterPayment(NPCModel sashaNpc) {
    setState(() {
      _sashaMorningRunPhase = SashaMorningRunPhase.afterPaid;
      newsMessage = SashaEvents.morningRunAfterPaidTalk;
      sashaNpc.setVar(
        SashaEvents.morningRunStepVar,
        SashaEvents.stepForPhase(SashaMorningRunPhase.afterPaid),
      );
    });
    _saveService.autosave();
  }

  void _onSashaMorningRunAction(String actionId, NPCModel? sashaNpc) {
    switch (actionId) {
      case 'approach':
        if (sashaNpc == null) return;
        setState(() {
          _sashaMorningRunPhase = SashaMorningRunPhase.video2;
          _ui.setEventImagePath(null);
          _eventVideoPath = SashaEvents.morningRunVideoRun2Path;
          _eventVideoMuted = false;
          _eventVideoFullScreen = true;
          _eventVideoCloseWhenCompleted = false;
          _eventVideoLoop = true;
          _eventVideoOnComplete = null;
          _eventVideoPendingButton = null;
          _eventVideoOnButtonPressed = null;
          newsMessage = SashaEvents.morningRunStep2Talk;
          sashaNpc.setVar(
            SashaEvents.morningRunStepVar,
            SashaEvents.stepForPhase(SashaMorningRunPhase.video2),
          );
        });
        _saveService.autosave();
        return;
      case 'continueToPayOffer':
        if (sashaNpc == null) return;
        setState(() {
          _sashaMorningRunPhase = SashaMorningRunPhase.payOffer;
          newsMessage = SashaEvents.morningRunStep3Talk;
          sashaNpc.setVar(
            SashaEvents.morningRunStepVar,
            SashaEvents.stepForPhase(SashaMorningRunPhase.payOffer),
          );
        });
        _saveService.autosave();
        return;
      case 'giveMoney':
        if (sashaNpc == null) return;
        setState(() {
          _sashaMorningRunPhase = SashaMorningRunPhase.moneyAmountChoice;
          sashaNpc.setVar(
            SashaEvents.morningRunStepVar,
            SashaEvents.stepForPhase(SashaMorningRunPhase.moneyAmountChoice),
          );
        });
        _saveService.autosave();
        return;
      case 'backFromMoneyChoice':
        if (sashaNpc == null) return;
        setState(() {
          _sashaMorningRunPhase = SashaMorningRunPhase.payOffer;
          sashaNpc.setVar(
            SashaEvents.morningRunStepVar,
            SashaEvents.stepForPhase(SashaMorningRunPhase.payOffer),
          );
        });
        _saveService.autosave();
        return;
      case 'give10':
        if (sashaNpc == null) return;
        if (!SashaEvents.applyMorningRunGiveCash(
          sasha: sashaNpc,
          player: _playerStats,
          amount: 10,
        )) {
          showInsufficientMoneyDialog(context);
          return;
        }
        _finishSashaMorningRunAfterPayment(sashaNpc);
        return;
      case 'give20':
        if (sashaNpc == null) return;
        if (!SashaEvents.applyMorningRunGiveCash(
          sasha: sashaNpc,
          player: _playerStats,
          amount: 20,
        )) {
          showInsufficientMoneyDialog(context);
          return;
        }
        _finishSashaMorningRunAfterPayment(sashaNpc);
        return;
      case 'give50':
        if (sashaNpc == null) return;
        if (!SashaEvents.applyMorningRunGiveAsDebt(
          world: _worldState,
          sasha: sashaNpc,
          player: _playerStats,
          gameNow: _timeController.dateTime,
        )) {
          showInsufficientMoneyDialog(context);
          return;
        }
        _finishSashaMorningRunAfterPayment(sashaNpc);
        return;
      case 'sendAway':
        if (sashaNpc != null) {
          SashaEvents.applySendAway(sasha: sashaNpc);
        }
        _exitSashaMorningRunEventToStreetOverview(
          incrementTimesCompleted: true,
        );
        return;
      case 'leave':
        _exitSashaMorningRunEventToStreetOverview(
          incrementTimesCompleted: true,
        );
        return;
    }
  }

  List<Widget> _buildSashaHallActions({
    required NPCModel sashaNpc,
  }) {
    final canUseEnergyDrink = SashaEvents.hasRedBullStyleEnergy(_inventory);
    final actions = _sashaEventRuntime.hallActions(_sashaComunicatePhase);
    final buttons = <Widget>[];
    var added = 0;
    for (final action in actions) {
      if (action.id == 'giveEnergyDrink' && !canUseEnergyDrink) continue;
      if (added > 0) {
        buttons.add(const SizedBox(height: 8));
      }
      buttons.add(_navBtn(action.label, () {
        _onSashaHallAction(action.id, sashaNpc);
      }));
      added += 1;
    }
    return buttons;
  }

  void _onSashaHallAction(String actionId, NPCModel sashaNpc) {
    switch (actionId) {
      case 'approach':
        setState(() {
          _selectedNpcIdInRoom = 'sasha';
          _applySashaHallVideoAndTalkPhaseState();
        });
        return;
      case 'leave':
        _exitSashaCommunicateInHallToCorridor();
        return;
      case 'continueToMoneyChoice':
        setState(() {
          _sashaComunicatePhase = ComunicateSashaInHallPhase.moneyChoice;
          _ui.setEventImagePath(null);
          _eventVideoPath = SashaEvents.comunicateSashaInHallVideoPath;
          _eventVideoMuted = false;
          _eventVideoFullScreen = true;
          _eventVideoCloseWhenCompleted = false;
          _eventVideoLoop = true;
          _eventVideoOnComplete = null;
          _eventVideoPendingButton = null;
          _eventVideoOnButtonPressed = null;
          newsMessage = SashaEvents.comunicateHallStep3Talk;
        });
        return;
      case 'giveMoney':
        if (_playerStats.money < 3) {
          showInsufficientMoneyDialog(context);
          return;
        }
        _playerStats.changeMoney(-3);
        SashaEvents.applyGiveMoney(sasha: sashaNpc, dollarsGiven: 3);
        _exitSashaCommunicateInHallToCorridor();
        return;
      case 'giveEnergyDrink':
        if (!SashaEvents.hasRedBullStyleEnergy(_inventory)) return;
        SashaEvents.consumeOneRedBullStyleEnergy(_inventory);
        SashaEvents.applyEnergyDrink(
          sasha: sashaNpc,
          playerStats: _playerStats,
        );
        _exitSashaCommunicateInHallToCorridor();
        return;
      case 'sendAway':
        SashaEvents.applySendAway(sasha: sashaNpc);
        _exitSashaCommunicateInHallToCorridor();
        return;
    }
  }

  /// Квест Cherie 003 — одна кнопка на крок (офіс ТРЦ).
  Widget? _cherieQuest003PriorityActionPanelIfAny() {
    if (!_isCherieQuest003ScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;
    final s = _questStep('cherie_quest_003');
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' ||
        !isInsideRoom ||
        roomNorm != LocationsData.cityMallGiftShopOffice) {
      return null;
    }
    final actionIds = CherieQuestRuntime.quest003ActionIds(step: s);
    if (actionIds.isEmpty) {
      return null;
    }
    final actionId = actionIds.first;
    final key = CherieQuestRuntime.quest003ActionL10nKey(actionId);
    if (key == null) return null;
    VoidCallback onTap;
    switch (actionId) {
      case 'goWork':
        onTap = _onCherieQuest003GoWork;
        break;
      case 'finishWork':
        onTap = _onCherieQuest003FinishWork;
        break;
      case 'leave':
        onTap = _onCherieQuest003LeaveFinale;
        break;
      default:
        return null;
    }
    return _actionPanelSection(<Widget>[
      _navBtn(t(key).toUpperCase(), onTap),
    ]);
  }

  /// Квест Cherie 002 має перекривати інші панелі дій (офіс, склад, зал).
  Widget? _cherieQuest002PriorityActionPanelIfAny() {
    if (!_isCherieQuest002ScriptedDialogActive()) return null;
    final t = sl<LocaleController>().t;

    if (CherieQuest002.shouldPresentHomeHallSteps(
      world: _worldState,
      cherie: sl<NPCService>().npcById('cherie'),
      currentZone: currentZone,
      isInsideRoom: isInsideRoom,
      currentRoom: currentRoom,
    )) {
      final qStep = _questStep('cherie_quest_002');
      final homeChildren = <Widget>[];
      final npcService = sl<NPCService>();
      final cherieH = npcService.npcById('cherie');
      final finishOnlyWeek = cherieH != null &&
          cherieH.getVar(CherieQuest002.npcVarComplete) == true &&
          _worldState.cherieQuest002MassageFinishOnlyNextHallVisit;
      final actionIds = CherieQuestRuntime.quest002HomeActionIds(
        step: qStep,
        finishOnlyWeek: finishOnlyWeek,
      );
      for (var i = 0; i < actionIds.length; i++) {
        final actionId = actionIds[i];
        final key = CherieQuestRuntime.quest002ActionL10nKey(
          actionId: actionId,
          step: qStep,
        );
        if (key == null) continue;
        VoidCallback onTap;
        switch (actionId) {
          case 'offerHelp':
            onTap = _onCherieQuest002OfferHelpFromHome;
            break;
          case 'goLeave':
            onTap = _onCherieQuest002LeaveHomeEarly;
            break;
          case 'offerLegMassage':
            onTap = _onCherieQuest002OfferLegMassage;
            break;
          case 'finishMassage':
            onTap = _onCherieQuest002FinishMassageNoLegs;
            break;
          case 'finishFinal':
          case 'followCherie':
          case 'massageEllipsis':
            onTap = _onCherieQuest002PrimaryContinue;
            break;
          default:
            continue;
        }
        homeChildren.add(_navBtn(t(key).toUpperCase(), onTap));
        if (i != actionIds.length - 1) {
          homeChildren.add(const SizedBox(height: 8));
        }
      }
      if (homeChildren.isEmpty) return null;
      return _actionPanelSection(homeChildren);
    }

    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (currentZone != 'CITY' || !isInsideRoom) return null;
    final s = _questStep('cherie_quest_002');
    if (s < 1 || s > 4) return null;
    if (s >= 1 && s <= 3 && roomNorm != LocationsData.cityMallGiftShopOffice) {
      return null;
    }
    if (s == 4 &&
        roomNorm != LocationsData.cityMallGiftShopOffice &&
        roomNorm != LocationsData.cityMallGiftShopWarehouse) {
      return null;
    }

    final mallChildren = <Widget>[];
    final warehouseWhoAsked = _questStateRepository.readFlag(
      'cherie_quest_002',
      'warehouseWhoAsked',
    );
    final mallActionIds = CherieQuestRuntime.quest002MallActionIds(
      step: s,
      warehouseWhoAsked: warehouseWhoAsked,
    );
    for (var i = 0; i < mallActionIds.length; i++) {
      final actionId = mallActionIds[i];
      final key = CherieQuestRuntime.quest002ActionL10nKey(
        actionId: actionId,
        step: s,
      );
      if (key == null) continue;
      VoidCallback onTap;
      switch (actionId) {
        case 'deliverBoxes':
          onTap = _onCherieQuest002DeliverBoxes;
          break;
        case 'whoAreYou':
          onTap = _onCherieQuest002WarehouseWho;
          break;
        case 'primaryContinue':
          onTap = _onCherieQuest002PrimaryContinue;
          break;
        default:
          continue;
      }
      mallChildren.add(_navBtn(t(key).toUpperCase(), onTap));
      if (i != mallActionIds.length - 1) {
        mallChildren.add(const SizedBox(height: 8));
      }
    }
    return _actionPanelSection(mallChildren);
  }

  Widget _buildActionPanel({bool skipQuestUiIsolation = false}) {
    return ListenableBuilder(
      listenable: Listenable.merge([_timeController, _playerStats, _ui]),
      builder: (context, _) {
        _syncMomEvent002KitchenRecheckIfNeeded();
        _syncQuestUiArbitration();
        if (!skipQuestUiIsolation) {
          final questUiIsolationPanel = _questUiIsolationActionPanelIfAny();
          if (questUiIsolationPanel != null) return questUiIsolationPanel;
        }
        final int hour = _timeController.dateTime.hour;
        final int day = _timeController.weekdayIndex;
        final currentRoomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
        final isHomeHallDumbbellsWorkoutVideoActive =
            currentZone == 'HOME' &&
            isInsideRoom &&
            currentRoomNorm == LocationsData.hall &&
            _eventVideoPath == 'lib/assets/gg/ganteli.mp4';
        final isHomeHallKettlebellWorkoutVideoActive =
            currentZone == 'HOME' &&
            isInsideRoom &&
            currentRoomNorm == LocationsData.hall &&
            _eventVideoPath == 'lib/assets/gg/girya.mp4';
        final isPiperGgVoluntaryPunishVideoActive =
            _isPiperGgVoluntaryPunishVideoActive();

        if (isHomeHallDumbbellsWorkoutVideoActive) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('home_hall_workout_finish'),
                    _onHomeHallWorkoutDumbbellsFinishPressed,
                  ),
                ),
              ],
            ),
          );
        }
        if (isHomeHallKettlebellWorkoutVideoActive) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('home_hall_workout_finish'),
                    _onHomeHallWorkoutKettlebellFinishPressed,
                  ),
                ),
              ],
            ),
          );
        }
        if (_isPiperGgHarshPunishFinishVideoActive()) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('piper_quest_001_btn_leave').toUpperCase(),
                    () {
                      setState(() {
                        _leavePiperGgHarshPunish();
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }
        if (_isPiperGgHarshPunishSexVideoActive()) {
          final showDoggy = _canShowPiperGgHarshSexDoggyButton();
          final showCowgirl = _canShowPiperGgHarshSexCowgirlButton();
          final showSpreadLegs = _canShowPiperGgSpreadLegsButton();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDoggy) ...[
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(
                      this.t('piper_quest_001_btn_harsh_doggy').toUpperCase(),
                      () {
                        setState(() {
                          _onPiperGgHarshSexDoggyPressed();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (showCowgirl) ...[
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(
                      this.t('piper_quest_001_btn_harsh_cowgirl').toUpperCase(),
                      () {
                        setState(() {
                          _onPiperGgHarshSexCowgirlPressed();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (showSpreadLegs) ...[
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(
                      this.t('piper_quest_001_btn_spread_legs').toUpperCase(),
                      () {
                        setState(() {
                          _onPiperGgSpreadLegsPressed();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('piper_quest_001_btn_harsh_finish'),
                    () {
                      setState(() {
                        _finishPiperGgHarshPunish();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('piper_quest_001_btn_harsh_finish_on_ass'),
                    () {
                      setState(() {
                        _finishPiperGgHarshPunishOnAss();
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }
        if (_isPiperGgHarshPunishSpank4Active()) {
          final showSpreadLegs = _canShowPiperGgSpreadLegsButton();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('piper_quest_001_btn_harsh_finish'),
                    () {
                      setState(() {
                        _finishPiperGgHarshPunish();
                      });
                    },
                  ),
                ),
                if (showSpreadLegs) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(
                      this.t('piper_quest_001_btn_spread_legs').toUpperCase(),
                      () {
                        setState(() {
                          _onPiperGgSpreadLegsPressed();
                        });
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('piper_quest_001_btn_leave').toUpperCase(),
                    () {
                      setState(() {
                        _leavePiperGgHarshPunish();
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }
        if (isPiperGgVoluntaryPunishVideoActive) {
          final showHarshOffer = _isPiperQuest001HarshPunishOfferActive();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('piper_quest_gg_punish_finish_btn'),
                    () {
                      setState(() {
                        _finishPiperGgVoluntaryPunish();
                      });
                    },
                  ),
                ),
                if (showHarshOffer) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(
                      this.t('piper_quest_001_btn_punish_harsh').toUpperCase(),
                      () {
                        setState(() {
                          _startPiperGgHarshPunish();
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        final juniperQuest002Step1Priority =
            _shouldAllowLegacyClusterActionPanel(QuestFlowIds.juniperQuest002Step1)
                ? _juniperQuest002Step1PriorityActionPanelIfAny()
                : null;
        if (juniperQuest002Step1Priority != null) {
          return juniperQuest002Step1Priority;
        }
        if (_juniperPalivoApologyTalkActive) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    this.t('sem_juniper_girls_sub_btn_back'),
                    () {
                      setState(() {
                        _juniperPalivoApologyTalkActive = false;
                        newsMessage = '';
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }

        final fullArousalQuestPriority =
            _fullArousalQuestPriorityActionPanelIfAny();
        if (fullArousalQuestPriority != null) return fullArousalQuestPriority;

        final semJuniperIntroPriority =
            _shouldAllowLegacyClusterActionPanel(QuestFlowIds.semJuniperIntro)
                ? _semJuniperIntroPriorityActionPanelIfAny()
                : null;
        if (semJuniperIntroPriority != null) return semJuniperIntroPriority;

        final kompromatStep2AfterFleePriority =
            _shouldAllowLegacyClusterActionPanel(QuestFlowIds.juniperManuelKompromat)
                ? _juniperManuelKompromatStep2AfterFleePriorityActionPanelIfAny()
                : null;
        if (kompromatStep2AfterFleePriority != null) {
          return kompromatStep2AfterFleePriority;
        }

        final semGirlsTalkPriority =
            _shouldAllowLegacyClusterActionPanel(QuestFlowIds.semGirlsTalk)
                ? _semGirlsTalkPriorityActionPanelIfAny()
                : null;
        if (semGirlsTalkPriority != null) return semGirlsTalkPriority;

        if (_showMomOfficeView) {
          return _buildMomOfficeActionPanel();
        }

        final momQ001Priority = _momQuest001PriorityActionPanelIfAny();
        if (momQ001Priority != null) return momQ001Priority;

        final piperSnitchAckPriority = _piperQuest001SnitchAckActionPanelIfAny();
        if (piperSnitchAckPriority != null) return piperSnitchAckPriority;

        final momE002Priority = _momEvent002PriorityActionPanelIfAny();
        if (momE002Priority != null) return momE002Priority;

        final piperQ001Priority = _piperQuest001PriorityActionPanelIfAny();
        if (piperQ001Priority != null) return piperQ001Priority;

        final piperHallEventPriority = _piperHallWeekendEventPriorityActionPanelIfAny();
        if (piperHallEventPriority != null) return piperHallEventPriority;

        final cherieMfPriority = _cherieMassageFunPriorityActionPanelIfAny();
        if (cherieMfPriority != null) return cherieMfPriority;
        final cherieQ3Priority = _cherieQuest003PriorityActionPanelIfAny();
        if (cherieQ3Priority != null) return cherieQ3Priority;
        final cherieQ6Priority = _cherieQuest006PriorityActionPanelIfAny();
        if (cherieQ6Priority != null) return cherieQ6Priority;
        final cherieQ5Priority = _cherieQuest005PriorityActionPanelIfAny();
        if (cherieQ5Priority != null) return cherieQ5Priority;
        final cherieQ4Priority = _cherieQuest004PriorityActionPanelIfAny();
        if (cherieQ4Priority != null) return cherieQ4Priority;
        final cherieQ2Priority = _cherieQuest002PriorityActionPanelIfAny();
        if (cherieQ2Priority != null) return cherieQ2Priority;

        final stinkyPriority = _ggHygieneStinkyPriorityActionPanelIfAny();
        if (stinkyPriority != null) return stinkyPriority;

        final stojakPriority = _ggEvent001StojakPriorityActionPanelIfAny();
        if (stojakPriority != null) return stojakPriority;

        final juniperQuest003DuringVideoPriority =
            _shouldAllowLegacyClusterActionPanel(QuestFlowIds.juniperQuest003Lounge)
                ? _juniperQuest003DuringVideoPriorityActionPanelIfAny()
                : null;
        if (juniperQuest003DuringVideoPriority != null) {
          return juniperQuest003DuringVideoPriority;
        }

        final juniperQuest003HallDuringVideoPriority =
            _shouldAllowLegacyClusterActionPanel(QuestFlowIds.juniperQuest003Hall)
                ? _juniperQuest003HallDuringVideoPriorityActionPanelIfAny()
                : null;
        if (juniperQuest003HallDuringVideoPriority != null) {
          return juniperQuest003HallDuringVideoPriority;
        }

        final arousal100InRoomGg = _playerStats.arousal >= 100 &&
            currentZone == 'HOME' &&
            currentRoom == LocationsData.roomGg;

        // Кнопка «Вздрочнуть» тільки: у розділі порно в ноутбуці АБО збудження 100 і ГГ у своїй кімнаті
        final showMasturbatePanel = (isLaptopOpen && _isWatchingPornInLaptop) || arousal100InRoomGg;

        if (showMasturbatePanel) {
          final t = sl<LocaleController>().t;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(t('laptop_masturbate').toUpperCase(), () {
                    _playerStats.changeArousal(-_playerStats.arousal);
                    _masturbateVideoPath = null;
                    _saveService.autosave();
                    setState(() => _showMasturbateVideo = true);
                  }),
                ),
                const SizedBox(height: 8),
                if (isLaptopOpen && _isWatchingElsaVideoInLaptop) ...[
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(t('laptop_save_compromat').toUpperCase(), () {
                      final world = sl<GameWorldState>();
                      // Відео elsa_kompromat у ноуті відповідає Elsa (id: piper).
                      if (!world.compromatNpcIds.contains('piper')) {
                        world.compromatNpcIds.add('piper');
                      }
                      _saveService.autosave();
                      setState(() => _isWatchingElsaVideoInLaptop = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('laptop_save_compromat_to_laptop_result')),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                if (isLaptopOpen) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _navBtn(t('laptop_close').toUpperCase(), () {
                      setState(() {
                        isLaptopOpen = false;
                        _isWatchingPornInLaptop = false;
                      });
                    }),
                  ),
                ],
              ],
            ),
          );
        }

        final introStep = _worldState.cherieAnimatorIntroStep;
        if (introStep >= 1 &&
            introStep <= 4 &&
            !CherieQuest003.isActiveMidFlow(_worldState) &&
            !CherieQuest004.isActiveMidFlow(_worldState) &&
            !CherieQuest005.isActiveMidFlow(_worldState) &&
            !CherieQuest006.isActiveMidFlow(_worldState) &&
            currentZone == 'CITY' &&
            isInsideRoom &&
            currentRoomNorm == LocationsData.cityMallGiftShopOffice) {
          final t = sl<LocaleController>().t;
          final labelKey = switch (introStep) {
            1 => 'cherie_animator_intro_btn_go_change',
            2 => 'cherie_animator_intro_btn_return_cherie',
            3 => 'cherie_animator_intro_btn_go_work',
            _ => 'cherie_animator_intro_btn_finish_work',
          };
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    t(labelKey).toUpperCase(),
                    _onCherieAnimatorIntroAdvance,
                  ),
                ),
              ],
            ),
          );
        }

        if (_ui.cherieAnimatorShiftTc2DialogPending) {
          final t = sl<LocaleController>().t;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _navBtn(
                    t(CherieQuest001L10n.leave).toUpperCase(),
                    _onCherieAnimatorShiftTc2LeavePressed,
                  ),
                ),
              ],
            ),
          );
        }

        if (_sashaMorningRunUiActive &&
            currentZone == 'STREET' &&
            currentStreetHouse == null &&
            !isInsideRoom &&
            currentRoom == LocationsData.street) {
          final npcService = sl<NPCService>();
          final sashaList = npcService.allNPCs.where((n) => n.id == 'sasha').toList();
          final sasha = sashaList.isEmpty ? null : sashaList.first;

          final eventButtons = _buildSashaMorningRunActions(
            sashaNpc: sasha,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: eventButtons,
            ),
          );
        }

        if (_collegeToiletUnderwearSaleActive && _isCollegeToiletGuysBreakWindow()) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildCollegeToiletUnderwearSaleActions(),
            ),
          );
        }

        // Ніч у домі в кімнаті (поки що): у локаційному меню лише «Назад» (як нічні двері).
        final bool isHomeNightInsideRoom = currentZone == 'HOME' &&
            isInsideRoom &&
            (hour >= 22 || hour < 7);
        if (isHomeNightInsideRoom) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _navBtn('НАЗАД', _handleBackTap),
              ],
            ),
          );
        }

        final t = sl<LocaleController>().t;

        // 1. Отримуємо список NPC з сервісу (хто має в розкладі цю кімнату)
        final npcService = sl<NPCService>();
        final List<NPCModel> npcList = npcService.getNPCsInRoom(currentRoom, hour, day);

        // 2. Залишаємо тільки тих, хто зараз фактично в цій кімнаті (перший збіг розкладу),
        // щоб при перетині слотів (наприклад обід 13–14 і робота 9–18) не показувати кнопки дій
        final List<NPCModel> activeNPCs = npcList
            .where((npc) =>
                npcService.getCurrentLocationId(npc, hour, day) == currentRoomNorm)
            .toList();

        // 3. Створюємо список віджетів всередині білдера
        List<Widget> actionWidgets = [];
        _appendJuniperQuest003MasturbateRoomButton(actionWidgets);
        void showSondoxPlaceholder() {
          const path = 'lib/assets/items/hypnotic.jpg';
          _ui.setEventImagePath(path);
          Future<void>.delayed(const Duration(seconds: 2), () {
            if (!mounted || _eventImagePath != path) return;
            _ui.setEventImagePath(null);
          });
        }

        final roomIdLower = currentRoom.toLowerCase();
        final roomDisplayNameLower = LocationsData.getLocationDisplayName(currentRoom).toLowerCase();
        final isUtilityRoom = roomIdLower.contains('kitchen') ||
            roomIdLower.contains('bathroom') ||
            roomIdLower.contains('toilet') ||
            roomIdLower.contains('hall') ||
            roomIdLower.contains('yard') ||
            roomIdLower.contains('corridor') ||
            roomDisplayNameLower.contains('кухня') ||
            roomDisplayNameLower.contains('ванна') ||
            roomDisplayNameLower.contains('туалет') ||
            roomDisplayNameLower.contains('зал') ||
            roomDisplayNameLower.contains('двір') ||
            roomDisplayNameLower.contains('коридор') ||
            roomDisplayNameLower.contains('гардероб');
        // Кнопки обшуку/ноутбука/речей тільки в спальнях та кімнатах NPC.
        final isNpcRoomLike = (roomIdLower.contains('room') || roomIdLower.contains('bedroom')) &&
            currentRoom != LocationsData.roomGg &&
            !isUtilityRoom;

        if (isInsideRoom && LocationsData.isAnyBathroom(currentRoomNorm)) {
          final localeWash = sl<LocaleController>();
          actionWidgets.add(
            _navBtn(localeWash.t('gg_hygiene_wash_btn').toUpperCase(), () {
              GgHygiene.wash(_worldState, _timeController.dateTime);
              _playerStats.updateUI();
              _saveService.autosave();
              setState(() {
                newsMessage = localeWash.t('gg_hygiene_washed');
              });
            }),
          );
          actionWidgets.add(const SizedBox(height: 8));
        }

        if (_canShowFriendHouseOvernightButton()) {
          actionWidgets.add(
            _navBtn(
              t('friend_house_btn_overnight').toUpperCase(),
              _onFriendHouseOvernightStay,
            ),
          );
          actionWidgets.add(const SizedBox(height: 8));
        }

        final int minute = _timeController.dateTime.minute;
        final hasSondox = _inventory.hasUsableSondox;
        final momForSondox = npcService.npcById('mom');
        final sisterForSondoxId = currentRoomNorm == LocationsData.elsaRoom
            ? 'elsa'
            : currentRoomNorm == LocationsData.piperRoom
                ? 'piper'
                : null;
        final sisterForSondox = sisterForSondoxId == null
            ? null
            : npcService.npcById(sisterForSondoxId);
        final showMomSleepingPillButton = currentZone == 'HOME' &&
            isInsideRoom &&
            currentRoomNorm == LocationsData.kitchen &&
            hasSondox &&
            momForSondox?.getVar('sondox') != true &&
            day >= 0 &&
            day <= 4 &&
            hour >= 10 &&
            hour <= 15;
        if (showMomSleepingPillButton) {
          actionWidgets.add(
            _navBtn('Підсипати в мамин стакан снодійне', () {
              if (momForSondox == null || !_inventory.consumeSondoxUse()) {
                return;
              }
              momForSondox.setVar('sondox', true);
              _saveService.autosave();
              setState(() {
                showSondoxPlaceholder();
                newsMessage = 'Ти підсипав снодійне. Сондокс подіє ближче до ночі.';
              });
            }),
          );
          actionWidgets.add(const SizedBox(height: 8));
        }
        final showSisterSleepingPillButton = currentZone == 'HOME' &&
            isInsideRoom &&
            (currentRoomNorm == LocationsData.elsaRoom ||
                currentRoomNorm == LocationsData.piperRoom) &&
            hasSondox &&
            sisterForSondox?.getVar('sondox') != true &&
            day >= 0 &&
            day <= 4 &&
            hour >= 10 &&
            hour <= 16;

        // Як розклад туалету (sem/den/loshok): будні 12:30–12:59.
        final bool collegeToiletGuysBreak = currentZone == 'COLLEGE' &&
            isInsideRoom &&
            currentRoomNorm == LocationsData.toilet &&
            collegeWeekdayIndices.contains(day) &&
            hour == 12 &&
            minute >= 30 &&
            minute <= 59;
        final bool showAttendCollegeLessonButton = currentZone == 'COLLEGE' &&
            isInsideRoom &&
            _isCollegeAuditorium(currentRoomNorm) &&
            _isCollegeLessonStartWindow(_timeController.dateTime);
        if (showAttendCollegeLessonButton) {
          actionWidgets.add(
            _navBtn('Піти на пару', () {
              setState(_attendCollegeLesson);
            }),
          );
          actionWidgets.add(const SizedBox(height: 8));
        }
        if (collegeToiletGuysBreak) {
          actionWidgets.add(
            _navBtn('Поговорити з пацанами', () {
              if (GgHygiene.isStinky(_worldState)) {
                setState(() {
                  newsMessage =
                      sl<LocaleController>().t('gg_hygiene_stinky_reply');
                });
                return;
              }
              setState(() {
                _ui.setEventImagePath(null);
                newsMessage = '''
Ти заходиш у курінь: Сем кивнув, Ден щось буркнув, Лошок розвів руками.
«Ну шо, норм перерва?» — «Та так собі, але ліпше ніж пара.»
Пахне дешевим одеколоном і сухарями.''';
              });
            }),
          );
          actionWidgets.add(const SizedBox(height: 8));
          actionWidgets.add(
            _navBtn('Продати шмотки', () {
              setState(_openCollegeToiletUnderwearSale);
            }),
          );
          actionWidgets.add(const SizedBox(height: 8));
        }

        // Вихідні, вікно як [CherieEvents.isAnimatorShiftTimeWindow], офіс Cherie.
        if (currentZone == 'CITY' &&
            isInsideRoom &&
            currentRoomNorm == LocationsData.cityMallGiftShopOffice &&
            CherieEvents.isAnimatorShiftTimeWindow(weekdayIndex: day, hour: hour) &&
            _worldState.giftShopAnimatorJobOfferPending &&
            _ui.cherieQuest001OfficePhase ==
                CherieQuest001OfficePhase.inactive &&
            !_isCherieQuest002ScriptedDialogActive() &&
            !_isCherieQuest003ScriptedDialogActive()) {
          final animatorShiftSlotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
            _timeController.dateTime,
            day,
          );
          final giftShopAnimatorPendingFinishToday =
              _worldState.giftShopAnimatorPendingFinishDateKey ==
                  animatorShiftSlotKey;
          final showGiftShopAnimatorShiftRow =
              !_ui.cherieAnimatorShiftTc2SequenceActive &&
                  (_worldState.giftShopAnimatorShiftsCompleted > 0 ||
                      (_worldState.giftShopAnimatorShiftsCompleted == 0 &&
                          _worldState.cherieAnimatorIntroStep == 0));
          final officeChildren = <Widget>[];
          if (showGiftShopAnimatorShiftRow) {
            officeChildren.add(
              SizedBox(
                width: double.infinity,
                child: giftShopAnimatorPendingFinishToday
                    ? _buildGiftShopAnimatorFinishButton()
                    : _buildGiftShopAnimatorWorkButton(),
              ),
            );
            officeChildren.add(const SizedBox(height: 8));
          }
          officeChildren.add(
            SizedBox(
              width: double.infinity,
              child: _navBtn(
                t(CherieQuest001L10n.leave).toUpperCase(),
                _handleBackTap,
              ),
            ),
          );
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: officeChildren,
            ),
          );
        }


        // У логістиці (приймальня) — завжди кнопки локацій, не дії з секретаркою (щоб не з’являлись о 9:00).
        // У приймальні Рокфеллера — стандартно лише кнопки зон, крім сценарної кнопки «Зніматись в рекламі».
        final showNpcActions = isInsideRoom &&
            activeNPCs.isNotEmpty &&
            currentRoom != LocationsData.cityBcLogistics &&
            !(currentRoom == LocationsData.cityBcRockefellerOffice &&
                !_showRockefellerCabinetView &&
                !_showRockefellerReceptionView);
        if (showNpcActions) {
          final bool hasSelectedNpc = _selectedNpcIdInRoom != null &&
              activeNPCs.any((n) => n.id == _selectedNpcIdInRoom);
          final bool implicitCherieGiftShopOffice = currentZone == 'CITY' &&
              !hasSelectedNpc &&
              currentRoomNorm == LocationsData.cityMallGiftShopOffice &&
              activeNPCs.length == 1 &&
              activeNPCs.single.id == 'cherie';
          // Завжди показуємо кнопки взаємодії з NPC у кімнаті (ефективний NPC — обраний у панелі або перший у списку).
          {
            final NPCModel effectiveNpcBase = hasSelectedNpc
                ? activeNPCs.firstWhere((n) => n.id == _selectedNpcIdInRoom)
                : activeNPCs.first;

            final NPCModel npc = effectiveNpcBase;
          // Sasha — comunicate_sasha_in_zal.
          // Шукаємо Сашу в кімнаті явно: «ефективний» NPC може бути іншим (порядок у allNPCs / інший персонаж у залі),
          // і тоді раніше гілка npc.id == 'sasha' ніколи не спрацьовувала.
          NPCModel? sashaInHallNpc;
          for (final n in activeNPCs) {
            if (n.id == 'sasha') {
              sashaInHallNpc = n;
              break;
            }
          }
          if (sashaInHallNpc != null &&
              currentZone == 'STREET' &&
              currentStreetHouse == LocationsData.friendHouse &&
              currentRoom == LocationsData.friendHall &&
              (hour == 18 || hour == 19)) {
            if (_selectedNpcIdInRoom != null &&
                _selectedNpcIdInRoom != 'sasha') {
              actionWidgets.add(_navBtn('НАЗАД', _handleBackTap));
            } else {
              final NPCModel sashaNpc = sashaInHallNpc;
              actionWidgets.addAll(_buildSashaHallActions(sashaNpc: sashaNpc));
            }
          } else if (npc.id == 'den' &&
              currentZone == 'COLLEGE' &&
              currentRoom == LocationsData.collegeCorridor) {
            if (_selectedNpcIdInRoom != null && _selectedNpcIdInRoom != 'den') {
              // Ден стартує неактивним: показуємо тільки навігацію,
              // щоб права панель не була порожньою.
              actionWidgets.add(_navBtn('НАЗАД', _handleBackTap));
            } else {
            final bool denFirstMeetingDone =
                npc.getVar(DenEventVars.firstMeetingDone) == true;
            final bool denIntroduction =
                npc.getVar(DenEventVars.introduction) == true;
            final bool denSecondMeeting =
                npc.getVar(DenEventVars.secondMeeting) == true;
            final bool denThirdMeeting =
                npc.getVar(DenEventVars.thirdMeeting) == true;

            final List<Widget> denNavButtons = [
              if (!denFirstMeetingDone) ...[
                if (_denIntroUiPhase == DenIntroUiPhase.initial) ...[
                  _navBtn('Познайомитись', () {
                    setState(() {
                      _denIntroUiPhase = DenIntroUiPhase.agreed;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                  const SizedBox(height: 8),
                  _navBtn('Піти', () {
                    _exitDenEventToCorridor();
                  }),
                ] else if (_denIntroUiPhase == DenIntroUiPhase.agreed) ...[
                  _navBtn('Погодитися', () {
                    setState(() {
                      _denIntroUiPhase = DenIntroUiPhase.blya;
                      _ui.setEventImagePath(DenHooliganQuestMedia.introAgreePlaceholderImage);
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                ] else if (_denIntroUiPhase == DenIntroUiPhase.blya) ...[
                  _navBtn('Бля...', () {
                    setState(() {
                      // Запускаємо відео (без очікування завершення).
                      _ui.setEventImagePath(null);
                      _eventVideoPath = DenHooliganQuestMedia.introBlyaVideo;
                      _eventVideoMuted = DenHooliganQuestMedia.videoMuted;
                      _eventVideoFullScreen = DenHooliganQuestMedia.videoFullScreen;
                      _eventVideoCloseWhenCompleted = DenHooliganQuestMedia.introBlyaCloseWhenCompleted;
                      _eventVideoLoop = true;
                      _eventVideoOnComplete = () {
                        if (!mounted) return;
                        setState(() {
                          _eventVideoPath = null;
                          _eventVideoOnComplete = null;
                          _eventVideoPendingButton = null;
                          _eventVideoOnButtonPressed = null;
                          _eventVideoCloseWhenCompleted = true;
                          _eventVideoLoop = false;
                        });
                      };
                      _eventVideoPendingButton = null;
                      _eventVideoOnButtonPressed = null;
                      _denIntroUiPhase = DenIntroUiPhase.afterBlya;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                ] else ...[
                  _navBtn('Піти', () {
                    npc.setVar(DenEventVars.firstMeetingDone, true);
                    _exitDenEventToCorridor(add30Minutes: true);
                    _saveService.autosave();
                  }),
                ],
              ] else if (!denIntroduction) ...[
                // 2 кнопки: обговорити ситуацію / піти
                _navBtn('Обговорити ситуацію', () {
                  npc.setVar(DenEventVars.introduction, true);
                  setState(() {
                    _denStage2InProgress = true;
                    _denSecondUiPhase = DenSecondUiPhase.afterDiscuss;
                    newsMessage = _getDenDialogueText(npc);
                  });
                }),
                const SizedBox(height: 8),
                _navBtn('Піти', () {
                  _exitDenEventToCorridor();
                }),
              ] else if (_denStage2InProgress) ...[
                if (_denSecondUiPhase == DenSecondUiPhase.afterDiscuss) ...[
                  _navBtn('Погодитися', () {
                    setState(() {
                      _ui.setEventImagePath(null);
                      _eventVideoPath = DenHooliganQuestMedia.secondAgreeVideo;
                      _eventVideoMuted = DenHooliganQuestMedia.videoMuted;
                      _eventVideoFullScreen = DenHooliganQuestMedia.videoFullScreen;
                      _eventVideoCloseWhenCompleted = DenHooliganQuestMedia.secondAgreeCloseWhenCompleted;
                      _eventVideoLoop = true;
                      _eventVideoOnComplete = () {
                        if (!mounted) return;
                        setState(() {
                          _eventVideoPath = null;
                          _eventVideoOnComplete = null;
                          _eventVideoPendingButton = null;
                          _eventVideoOnButtonPressed = null;
                          _eventVideoLoop = false;
                        });
                      };
                      _eventVideoPendingButton = null;
                      _eventVideoOnButtonPressed = null;
                      _denSecondUiPhase = DenSecondUiPhase.afterAgree;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                ] else if (_denSecondUiPhase == DenSecondUiPhase.afterAgree) ...[
                  _navBtn('Бля...', () {
                    setState(() {
                      _ui.setEventImagePath(null);
                      _eventVideoPath = DenHooliganQuestMedia.secondBlyaVideo;
                      _eventVideoMuted = DenHooliganQuestMedia.videoMuted;
                      _eventVideoFullScreen = DenHooliganQuestMedia.videoFullScreen;
                      _eventVideoCloseWhenCompleted = DenHooliganQuestMedia.secondBlyaCloseWhenCompleted;
                      _eventVideoLoop = true;
                      _eventVideoOnComplete = () {
                        if (!mounted) return;
                        setState(() {
                          _eventVideoPath = null;
                          _eventVideoOnComplete = null;
                          _eventVideoPendingButton = null;
                          _eventVideoOnButtonPressed = null;
                          _eventVideoCloseWhenCompleted = true;
                          _eventVideoLoop = false;
                        });
                      };
                      _eventVideoPendingButton = null;
                      _eventVideoOnButtonPressed = null;
                      _denSecondUiPhase = DenSecondUiPhase.afterBlya;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                ] else if (_denSecondUiPhase == DenSecondUiPhase.afterBlya) ...[
                  _navBtn('Так?!', () {
                    setState(() {
                      // Друге відео повинно закриватися тільки на кнопці "Піти".
                      // Тому тут не очищаємо video state.
                      _denSecondUiPhase = DenSecondUiPhase.afterDa;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                ] else if (_denSecondUiPhase == DenSecondUiPhase.afterDa) ...[
                  _navBtn('І як же?', () {
                    setState(() {
                      _ui.setEventImagePath(null);
                      _denSecondUiPhase = DenSecondUiPhase.afterHow;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                ] else ...[
                  _navBtn('Піти', () {
                    npc.setVar(DenEventVars.secondChainDone, true);
                    _saveService.autosave();
                    _exitDenEventToCorridor();
                  }),
                ],
              ] else if (!denSecondMeeting) ...[
                if (npc.getVar(DenEventVars.secondChainDone) == true) ...[
                  // Прапор другої зустрічі ставиться на старті третього ланцюжка.
                  _navBtn('Обговорити ситуацію', () {
                    npc.setVar(DenEventVars.secondMeeting, true);
                    _saveService.autosave();
                    setState(() {
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                  const SizedBox(height: 8),
                  _navBtn('Піти', () {
                    _exitDenEventToCorridor();
                  }),
                ] else ...[
                  _navBtn('Піти', () {
                    _exitDenEventToCorridor();
                  }),
                ],
              ] else if (!denThirdMeeting) ...[
                if (_denThirdUiPhase == DenThirdUiPhase.initial) ...[
                  _navBtn('Обговорити ситуацію', () {
                    setState(() {
                      _denThirdUiPhase = DenThirdUiPhase.afterDiscuss;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                  const SizedBox(height: 8),
                  _navBtn('Піти', () {
                    _exitDenEventToCorridor();
                  }),
                ] else ...[
                  _navBtn('Піти', () {
                    npc.setVar(DenEventVars.thirdMeeting, true);
                    syncDenHooliganQuestFlagFromProgress(npc);
                    _saveService.autosave();
                    _exitDenEventToCorridor();
                  }),
                ],
              ] else ...[
                if (_denAfterUiPhase == DenAfterUiPhase.initial) ...[
                  _navBtn('Поговорити', () {
                    setState(() {
                      _denAfterUiPhase = DenAfterUiPhase.afterTalk;
                      newsMessage = _getDenDialogueText(npc);
                    });
                  }),
                  const SizedBox(height: 8),
                  _navBtn('Піти', () {
                    _exitDenEventToCorridor();
                  }),
                ] else ...[
                  _navBtn('Піти', () {
                    _exitDenEventToCorridor();
                  }),
                ],
              ],
            ];

            actionWidgets.addAll(denNavButtons);
            }
          } else if (npc.id == 'cherie' &&
              currentRoomNorm == LocationsData.cityMallGiftShopOffice) {
            // Один NPC у офісі: дії мають показуватись і без тапу по смузі (implicitCherieGiftShopOffice).
            // Квест 002 / 003 / 005: кнопки в priority-панелях.
            if (hasSelectedNpc || implicitCherieGiftShopOffice) {
              if (!_isCherieQuest002ScriptedDialogActive() &&
                  !_isCherieQuest003ScriptedDialogActive() &&
                  !_isCherieQuest004ScriptedDialogActive() &&
                  !_isCherieQuest005ScriptedDialogActive() &&
                  !_isCherieQuest006ScriptedDialogActive()) {
                final phase = _ui.cherieQuest001OfficePhase;
                if (phase == CherieQuest001OfficePhase.statsBlocked) {
                  actionWidgets.add(
                    _navBtn(
                      t(CherieQuest001L10n.wrongDoor),
                      _handleBackTap,
                    ),
                  );
                } else if (phase == CherieQuest001OfficePhase.step1Ask) {
                  actionWidgets.add(
                    _navBtn(
                      t(CherieQuest001L10n.askJob),
                      () {
                        setState(() {
                          _ui.setCherieQuest001OfficePhase(
                            CherieQuest001OfficePhase.step2Decide,
                          );
                          newsMessage = t(CherieQuest001L10n.step2Dialogue);
                        });
                      },
                    ),
                  );
                  actionWidgets.add(const SizedBox(height: 8));
                  actionWidgets.add(
                    _navBtn(
                      t(CherieQuest001L10n.leave),
                      _handleBackTap,
                    ),
                  );
                } else if (phase == CherieQuest001OfficePhase.step2Decide) {
                  actionWidgets.add(
                    _navBtn(
                      t(CherieQuest001L10n.agree),
                      () {
                        setState(() {
                          CherieQuest001.applyQuestOneAccepted(
                            cherie: npc,
                            world: _worldState,
                            now: _timeController.dateTime,
                          );
                          _resetCherieOfficeAnimatorQuestSession();
                          newsMessage = t(CherieQuest001L10n.afterAgree);
                        });
                        _saveService.autosave();
                      },
                    ),
                  );
                  actionWidgets.add(const SizedBox(height: 8));
                  actionWidgets.add(
                    _navBtn(
                      t(CherieQuest001L10n.thinkLater),
                      _handleBackTap,
                    ),
                  );
                } else {
                  // Після згоди та поза активними фазами — лише «Піти».
                  actionWidgets.add(
                    _navBtn(t(CherieQuest001L10n.leave), _handleBackTap),
                  );
                }
              }
            }
          } else if (npc.id == 'loshok' &&
              currentZone == 'COLLEGE' &&
              currentRoom == LocationsData.collegeCorridor) {
            actionWidgets.addAll([
              _navBtn('Поговорити', () {
                setState(() {
                  newsMessage = '''
Привіт, Лошок, як справи?
Так собі, тобі щось потрібно?''';
                  _ui.setEventImagePath(null); // на всяк випадок прибираємо будь-які оверлеї
                });
              }),
              const SizedBox(height: 8),
              _navBtn('Піти', _exitLoshokToCorridor),
            ]);
          } else {
            if (npc.id == 'piper' && _canShowPiperGgVoluntaryPunishButton()) {
              actionWidgets.add(
                _navBtn(
                  t('piper_quest_gg_punish_piper_btn').toUpperCase(),
                  () {
                    setState(() {
                      _startPiperGgVoluntaryPunish();
                    });
                  },
                ),
              );
              actionWidgets.add(const SizedBox(height: 8));
            }
            if (npc.id == kJuniperNpcId &&
                JuniperQuest003OfferHelp.isColdShoulderActive(
                  _worldState,
                  gameDateKey: _timeController.onlyDate,
                )) {
              actionWidgets.add(
                _navBtn(t('danielle_spy_parents_leave'), _handleBackTap),
              );
            } else if (npc.id == kJuniperNpcId &&
                JuniperQuest002Naslidku.canShowTalkAboutKompromatButton(
                  world: _worldState,
                  activeNpcs: activeNPCs,
                  step1UiActive: _juniperQuest002Step1UiActive,
                )) {
              actionWidgets.add(
                _navBtn(t(JuniperQuest002Naslidku.l10nBtnTalkKompromat), () {
                  setState(_beginJuniperQuest002Step1Talk);
                }),
              );
              actionWidgets.add(const SizedBox(height: 8));
            }
            if (npc.id == kJuniperNpcId &&
                !JuniperQuest003OfferHelp.isColdShoulderActive(
                  _worldState,
                  gameDateKey: _timeController.onlyDate,
                ) &&
                JuniperPalivoApologyTalk.canShowButton(_worldState)) {
              actionWidgets.add(
                _navBtn(t(JuniperPalivoApologyTalk.l10nBtn), () {
                  _timeController.addMinutes(5);
                  JuniperPalivoApologyTalk.markDone(_worldState);
                  JuniperPalivoApologyTalk.applyRewards();
                  _saveService.autosave();
                  setState(() {
                    _juniperPalivoApologyTalkActive = true;
                    newsMessage = t(JuniperPalivoApologyTalk.l10nDialogue);
                  });
                }),
              );
              actionWidgets.add(const SizedBox(height: 8));
            }
            // Для всіх інших NPC — стандартні кнопки взаємодії (навіть якщо ще не тапнули по смузі NPC).
            if (!(npc.id == kJuniperNpcId &&
                JuniperQuest003OfferHelp.isColdShoulderActive(
                  _worldState,
                  gameDateKey: _timeController.onlyDate,
                ))) {
              actionWidgets.add(
                NpcInteractionButtons(
                key: ValueKey(npc.id),
                npc: npc,
                location: currentRoom,
                hour: hour,
                onUpdate: () => setState(() {
                  _prepareForPlayerAction();
                }),
                onBack: _handleBackTap,
                onActionExecuted: (label, npc, {dialogueL10nKey}) =>
                    _handleNpcActionExecuted(
                      label,
                      npc,
                      dialogueL10nKey: dialogueL10nKey,
                    ),
                onFinanceGiveMoney: () => _npcFinanceGiveMoney(npc),
                onFinanceGiveLoan: () => _npcFinanceGiveLoan(npc),
                onFinanceAskMomMoney: (amount) => _npcFinanceAskMomMoney(npc, amount),
                onFinanceRepayGgDebt:
                    NpcFinanceService.ggOwesNpc(_worldState, npc.id) > 0
                        ? () => _npcFinanceRepayGgDebt(npc)
                        : null,
                onFinanceAskAboutDebt: NpcFinanceService.showAskAboutDebtButton(
                  _worldState,
                  npc.id,
                )
                    ? () => _npcFinanceAskAboutDebt(npc)
                    : null,
                onFinanceOfferAlternatives:
                    NpcFinanceService.showOfferAlternativesButton(
                  w: _worldState,
                  npcId: npc.id,
                  gender: npc.gender,
                  gameNow: _timeController.dateTime,
                )
                    ? () => _npcFinanceOfferAlternatives(npc)
                    : null,
                onTalkPiperSnitch: npc.id == 'mom' &&
                        _isPiperQuest001SnitchOfferScene()
                    ? () {
                        setState(() {
                          _piperQuest001SnitchToMom(auto: false);
                        });
                      }
                    : null,
                onTalkGgCommandPiper: npc.id == 'mom' &&
                        PiperQuest001.canRequestGgCommandPiperOnKitchen(
                          world: _worldState,
                          npcService: sl<NPCService>(),
                          mom: npc,
                          hour: hour,
                          weekdayIndex: day,
                          currentZone: currentZone,
                          isInsideRoom: isInsideRoom,
                          currentRoom: currentRoom,
                        )
                    ? () {
                        setState(() {
                          _piperQuest001RequestGgCommandPiperFromMom();
                        });
                      }
                    : null,
                onTalkTellPiperAboutPunishment: npc.id == 'piper' &&
                        PiperQuest001.canTellPiperAboutGgPunishmentInRoom(
                          world: _worldState,
                          npcService: sl<NPCService>(),
                          piper: npc,
                          hour: hour,
                          weekdayIndex: day,
                          currentZone: currentZone,
                          isInsideRoom: isInsideRoom,
                          currentRoom: currentRoom,
                        )
                    ? () {
                        setState(() {
                          _piperQuest001TellPiperAboutGgPunishment();
                        });
                      }
                    : null,
                onMomDeliverGroceries: npc.id == 'mom' &&
                        _canMomDeliverGroceriesToMom()
                    ? () {
                        setState(() {
                          _momApplyGroceryDelivery();
                        });
                      }
                    : null,
                onTalkSemNews:
                    npc.id == kSemNpcId ? _semTalkAboutNews : null,
                onTalkSemGirls: npc.id == kSemNpcId &&
                        SemQuest001.isGirlsTalkUnlockedByGameDay(
                          world: _worldState,
                          gameDateKey: _timeController.onlyDate,
                        )
                    ? _semTalkAboutGirls
                    : null,
                onTalkSemParents:
                    npc.id == kSemNpcId ? _semTalkAboutParents : null,
                onTalkSemPalivoWitness: npc.id == kSemNpcId &&
                        SemPalivoGirlsTalk.canShowButton(_worldState)
                    ? _semTalkPalivoWitness
                    : null,
                ),
              );
            }
          }
          }
          _appendResidentialHallRestButtonIfNeeded(
            actionWidgets,
            currentRoomNorm: currentRoomNorm,
          );
        } else if (isInsideRoom &&
            currentRoom == LocationsData.cityBcRockefellerOffice &&
            !_showRockefellerCabinetView &&
            !_showRockefellerReceptionView) {
          final t = sl<LocaleController>().t;
          final canShowNikeButton = RockefellerQuests.canShowShootingButton(
            world: _worldState,
            weekdayIndex: day,
            hour: hour,
          );
          if (_worldState.rockefellerNikeShootingInProgress) {
            actionWidgets.add(_navBtn(t('rockefeller_nike_btn_finish'), () {
              setState(() {
                _timeController.addMinutes(240);
                _worldState.rockefellerNikeShootingInProgress = false;
                _worldState.rockefellerNikeShootingDays =
                    (_worldState.rockefellerNikeShootingDays + 1).clamp(0, 5);
                _ui.setEventImagePath(null);
                newsMessage = '';
              });
              _saveService.autosave();
            }));
            actionWidgets.add(const SizedBox(height: 8));
          } else if (_worldState.rockefellerNikeFinalReviewInProgress) {
            actionWidgets.add(
              _navBtn(t('rockefeller_nike_btn_collect_and_leave'), () {
                setState(() {
                  _timeController.addMinutes(240);
                  _playerStats.changeMoney(5000);
                  _playerStats.changeCharisma(5);
                  _worldState.rockefellerNikeFinalReviewInProgress = false;
                  _worldState.rockefellerNikeAdCompleted = true;
                  _ui.setEventImagePath(null);
                  _eventVideoPath = null;
                  _eventVideoOnComplete = null;
                  _eventVideoPendingButton = null;
                  _eventVideoOnButtonPressed = null;
                  _eventVideoLoop = false;
                  newsMessage = '';
                });
                _saveService.autosave();
              }),
            );
            actionWidgets.add(const SizedBox(height: 8));
          } else if (canShowNikeButton) {
            final reviewUnlocked = RockefellerQuests.isReviewUnlocked(_worldState);
            actionWidgets.add(
              _navBtn(
                reviewUnlocked
                    ? t('rockefeller_nike_btn_review_video')
                    : t('rockefeller_nike_btn_shoot'),
                () {
                  setState(() {
                    if (reviewUnlocked) {
                      _worldState.rockefellerNikeFinalReviewInProgress = true;
                      _ui.setEventImagePath(null);
                      _eventVideoPath =
                          'lib/assets/npcs/rockefeller/reklama.webm';
                      _eventVideoMuted = false;
                      _eventVideoFullScreen = true;
                      _eventVideoCloseWhenCompleted = false;
                      _eventVideoLoop = false;
                      _eventVideoPendingButton = null;
                      _eventVideoOnButtonPressed = null;
                      _eventVideoOnComplete = null;
                      newsMessage = t('rockefeller_nike_review_news');
                    } else {
                      _worldState.rockefellerNikeShootingInProgress = true;
                      _ui.setEventImagePath(
                        'lib/assets/npcs/rockefeller/video_recording.jpg',
                      );
                      newsMessage = t('rockefeller_nike_shooting_news');
                    }
                  });
                  _saveService.autosave();
                },
              ),
            );
            actionWidgets.add(const SizedBox(height: 8));
          }
          _appendStandardWorldTravelButtons(actionWidgets);
        } else if (isInsideRoom && activeNPCs.isEmpty) {
          _appendHomeHallWorkoutButtonsIfNeeded(
            actionWidgets,
            currentRoomNorm: currentRoomNorm,
            hour: hour,
            hasOtherNpcsInRoom: activeNPCs.isNotEmpty,
          );
          // Порожня кімната: для кімнат NPC показуємо додаткові дії огляду, завжди додаємо кнопку «Назад».
          if (isNpcRoomLike) {
            actionWidgets.addAll([
              ElevatedButton(
                style: GameTheme.actionButtonStyle(),
                onPressed: () {
                  if (isNpcGalleryOpen ||
                      _selectedNpcForProfile != null ||
                      isBackpackOpen ||
                      isStatsOpen) {
                    setState(_prepareForPlayerAction);
                  }
                  final hour = _timeController.dateTime.hour;
                  final day = _timeController.weekdayIndex;
                  final ownerInShower = _isFamilyRoomOwnerInShower(
                    currentRoomNorm,
                    hour,
                    day,
                  );
                  final loot = RoomSearchLootService.rollNpcBedroom(
                    currentRoomNorm,
                    Random(),
                    _worldState,
                    ownerInShower: ownerInShower,
                  );
                  if (loot == null) {
                    DismissibleInfoOverlay.show(context, t('room_search_nothing'));
                    return;
                  }
                  if (loot.money > 0) {
                    _playerStats.changeMoney(loot.money);
                    if (loot.money == 100 &&
                        currentRoomNorm == LocationsData.cityEliteApartment3Bedroom) {
                      _worldState.shalinaRoomSearchCash100Granted = true;
                    }
                    DismissibleInfoOverlay.show(
                      context,
                      t('room_search_found_money').replaceFirst('%s', '${loot.money}'),
                    );
                  } else if (loot.item != null) {
                    final found = loot.item!;
                    _inventory.addItem(found);
                    switch (found.id) {
                      case 'key_elsa_room':
                        _worldState.homeRoomSearchKeyElsaGranted = true;
                        break;
                      case 'key_piper_room':
                        _worldState.homeRoomSearchKeyPiperGranted = true;
                        break;
                      case 'keys_mom_room':
                        _worldState.homeRoomSearchKeyMomGranted = true;
                        break;
                      case 'room_key':
                        if (currentRoomNorm == LocationsData.elsaRoom) {
                          _worldState.homeRoomSearchKeyElsaGranted = true;
                        } else if (currentRoomNorm == LocationsData.piperRoom) {
                          _worldState.homeRoomSearchKeyPiperGranted = true;
                        } else if (currentRoomNorm == LocationsData.momRoom) {
                          _worldState.homeRoomSearchKeyMomGranted = true;
                        }
                        break;
                      case 'ecstasy_pack_2':
                        if (currentRoomNorm == LocationsData.cityEliteApartment3Bedroom) {
                          _worldState.shalinaRoomSearchEcstasyGranted = true;
                        }
                        break;
                    }
                    _showFoundItemDialog(context, found);
                  } else {
                    DismissibleInfoOverlay.show(context, t('room_search_loot_empty'));
                  }
                  _saveService.autosave();
                },
                child: Text(
                  t('room_search_button').toUpperCase(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: GameTheme.actionButtonStyle(),
                onPressed: () {
                  if (isNpcGalleryOpen ||
                      _selectedNpcForProfile != null ||
                      isBackpackOpen ||
                      isStatsOpen) {
                    setState(_prepareForPlayerAction);
                  }
                  // TODO: реальна логіка перевірки ноутбука
                },
                child: const Text(
                  'ПЕРЕВІРИТИ НОУТБУК',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: GameTheme.actionButtonStyle(),
                onPressed: () {
                  if (isNpcGalleryOpen ||
                      _selectedNpcForProfile != null ||
                      isBackpackOpen ||
                      isStatsOpen) {
                    setState(_prepareForPlayerAction);
                  }
                  // TODO: реальна логіка «поритись в речах»
                },
                child: const Text(
                  'ПОРИТИСЬ В РЕЧАХ',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
            ]);
          }
          // У `CITY` (наприклад ресторани) навіть коли NPC зникли з розкладу —
          // користувачу потрібні кнопки навігації по зонам.
          // Для кімнат NPC (спальні/кімнати) залишаємо оригінальну логіку.
          _appendResidentialHallRestButtonIfNeeded(
            actionWidgets,
            currentRoomNorm: currentRoomNorm,
          );
          if (currentZone == 'CITY' && !isNpcRoomLike) {
            _appendStandardWorldTravelButtons(actionWidgets);
          } else {
            actionWidgets.add(_navBtn('НАЗАД', _handleBackTap));
          }
        } else if (!isInsideRoom) {
          if (currentZone == "STREET" &&
              currentStreetHouse == null &&
              _friendHouseStreetFacade) {
            NPCModel? semNpc;
            for (final n in npcService.allNPCs) {
              if (n.id == 'sem') {
                semNpc = n;
                break;
              }
            }
            if (_semSummonedAtFriendFacade) {
              final flowButtons = _semGirlsTalkFlowButtonsIfAny();
              if (flowButtons != null) {
                actionWidgets.addAll(flowButtons);
              } else if (_semTalkSubmenuActive) {
                actionWidgets.add(
                  _navBtn(t(SemTalkMenu.l10nBtnNews), _semTalkAboutNews),
                );
                actionWidgets.add(const SizedBox(height: 8));
                if (SemQuest001.isGirlsTalkUnlockedByGameDay(
                  world: _worldState,
                  gameDateKey: _timeController.onlyDate,
                )) {
                  actionWidgets.add(
                    _navBtn(t(SemTalkMenu.l10nBtnGirls), _semTalkAboutGirls),
                  );
                  actionWidgets.add(const SizedBox(height: 8));
                }
                actionWidgets.add(
                  _navBtn(t(SemTalkMenu.l10nBtnParents), _semTalkAboutParents),
                );
                actionWidgets.add(const SizedBox(height: 8));
                if (SemPalivoGirlsTalk.canShowButton(_worldState)) {
                  actionWidgets.add(
                    _navBtn(
                      t(SemPalivoGirlsTalk.l10nBtnWitness),
                      _semTalkPalivoWitness,
                    ),
                  );
                  actionWidgets.add(const SizedBox(height: 8));
                }
                actionWidgets.add(_navBtn(t(SemQuest001.l10nGirlsSubBackButton), () {
                  setState(() => _semTalkSubmenuActive = false);
                }));
              } else if (_semGirlsFollowUpActive) {
                actionWidgets.add(_navBtn(t('friend_house_btn_leave'), () {
                  SemQuest001.markFollowUpDone(
                    _worldState,
                    _timeController.onlyDate,
                  );
                  _saveService.autosave();
                  setState(() {
                    _semGirlsFollowUpActive = false;
                    newsMessage = t('friend_house_summon_news');
                  });
                }));
              } else if (_semParentsTalkActive) {
                actionWidgets.add(_navBtn(t('friend_house_btn_leave'), () {
                  final sem = findSemNpc(npcService.allNPCs);
                  if (sem != null) SemParentsTalkEvent.markComplete(sem);
                  _saveService.autosave();
                  setState(() {
                    _resetSemTalkFlowUi();
                    _friendHouseStreetFacade = false;
                    currentZone = 'STREET';
                    currentStreetHouse = null;
                    currentRoom = LocationsData.street;
                    isInsideRoom = false;
                    newsMessage = t(SemParentsTalkEvent.l10nAfterStreetKey);
                  });
                }));
              } else if (semNpc != null) {
                final sem = semNpc;
                actionWidgets.add(_navBtn('Поговорити', () {
                  if (GgHygiene.isStinky(_worldState)) {
                    setState(() {
                      newsMessage = t('gg_hygiene_stinky_reply');
                    });
                    return;
                  }
                  final h = _timeController.dateTime.hour;
                  final d = _timeController.weekdayIndex;
                  final summon = SemDoorSummon.check(npcService, h, d);
                  if (!summon.canSummon) {
                    setState(
                      () => newsMessage = t(summon.blockL10nKey!),
                    );
                    return;
                  }
                  _timeController.addMinutes(5);
                  sem.setVar('phone_unlocked', true);
                  setState(() {
                    _semTalkSubmenuActive = true;
                    newsMessage = t('friend_house_summon_news');
                  });
                }));
                actionWidgets.add(const SizedBox(height: 8));
                actionWidgets.add(_navBtn(t('friend_house_sem_invite_porn'), () {}));
                actionWidgets.add(const SizedBox(height: 8));
              }
            } else {
              actionWidgets.add(_navBtn(t('friend_house_btn_call_sem'), () {
                final h = _timeController.dateTime.hour;
                final d = _timeController.weekdayIndex;
                _timeController.addMinutes(5);
                final summon = SemDoorSummon.check(npcService, h, d);
                if (!summon.canSummon) {
                  setState(
                    () => newsMessage = t(summon.blockL10nKey!),
                  );
                  return;
                }
                setState(() {
                  _semSummonedAtFriendFacade = true;
                  newsMessage = t('friend_house_summon_news');
                });
              }));
              actionWidgets.add(const SizedBox(height: 8));
            }
            _appendNavButtonSpacerIfNeeded(actionWidgets);
            actionWidgets.add(_navBtn(t('friend_house_btn_enter'), () {
              setState(() {
                _friendHouseStreetFacade = false;
                _resetSemTalkFlowUi();
              });
              _handleRoomEntry(LocationsData.friendHouse);
            }));
            actionWidgets.add(const SizedBox(height: 8));
            actionWidgets.add(_navBtn(t('friend_house_btn_leave'), () {
              setState(() {
                _friendHouseStreetFacade = false;
                _resetSemTalkFlowUi();
              });
            }));
          } else {
            _appendStandardWorldTravelButtons(actionWidgets);
          }
        }

        // Якщо гравець ще не обрав NPC, але ми зайшли у гілку showNpcActions,
        // то interaction-кнопки не додаються — показуємо навігацію по зонам.
        if (actionWidgets.isEmpty) {
          _appendStandardWorldTravelButtons(actionWidgets);
        }

        if (showSisterSleepingPillButton) {
          final insertIndex = actionWidgets.isNotEmpty
              ? actionWidgets.length - 1
              : actionWidgets.length;
          actionWidgets.insert(
            insertIndex,
            _navBtn('Підсипати снодійне', () {
              if (sisterForSondox == null || !_inventory.consumeSondoxUse()) {
                return;
              }
              sisterForSondox.setVar('sondox', true);
              _saveService.autosave();
              setState(() {
                showSondoxPlaceholder();
                newsMessage = 'Ти підсипав снодійне. Сондокс подіє ближче до ночі.';
              });
            }),
          );
          actionWidgets.insert(insertIndex + 1, const SizedBox(height: 8));
        }

        // 4. Повертаємо контейнер зі списком, який тепер бачить actionWidgets
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: actionWidgets,
          ),
        );
      },
    );
  }

  /// Кабінет мами: work_03 — лише «Зберегти компромат» + «Назад»; інакше взаємодії з мамою або навігація.
  Widget _buildMomOfficeActionPanel() {
    return ListenableBuilder(
      listenable: Listenable.merge([_timeController, _ui]),
      builder: (context, _) {
        final hour = _timeController.dateTime.hour;
        final isMomAtWork = _isMomAtLogisticsOfficeNow();
        final isKompromatVideo = _isMomOfficeKompromatVideoActive();
        final t = sl<LocaleController>().t;
        final list = <Widget>[];

        if (isKompromatVideo) {
          if (!_isMomOfficeCompromatAlreadySaved()) {
            list.add(
              _navBtn(
                t('laptop_save_compromat'),
                () {
                  final saved = _saveMomOfficeCompromatFromVideo3();
                  if (!saved) return;
                  setState(() {});
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('mom_compromat_saved_laptop')),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            );
            list.add(const SizedBox(height: 8));
          }
          list.add(_navBtn('Назад', () => setState(_exitMomOfficeView)));
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: list,
            ),
          );
        }

        if (isMomAtWork) {
          final mom = sl<NPCService>().npcById('mom');
          if (mom != null) {
            list.add(
              NpcInteractionButtons(
                key: const ValueKey('mom_office_cabinet'),
                npc: mom,
                location: LocationsData.cityBcLogisticsMomOffice,
                hour: hour,
                onUpdate: () => setState(_prepareForPlayerAction),
                onActionExecuted: (label, npc, {dialogueL10nKey}) =>
                    _handleNpcActionExecuted(
                      label,
                      npc,
                      dialogueL10nKey: dialogueL10nKey,
                    ),
                onFinanceGiveMoney: () => _npcFinanceGiveMoney(mom),
                onFinanceGiveLoan: () => _npcFinanceGiveLoan(mom),
                onFinanceAskMomMoney: (amount) => _npcFinanceAskMomMoney(mom, amount),
                onFinanceRepayGgDebt:
                    NpcFinanceService.ggOwesNpc(_worldState, mom.id) > 0
                        ? () => _npcFinanceRepayGgDebt(mom)
                        : null,
                onFinanceAskAboutDebt: NpcFinanceService.showAskAboutDebtButton(
                  _worldState,
                  mom.id,
                )
                    ? () => _npcFinanceAskAboutDebt(mom)
                    : null,
                onFinanceOfferAlternatives:
                    NpcFinanceService.showOfferAlternativesButton(
                  w: _worldState,
                  npcId: mom.id,
                  gender: mom.gender,
                  gameNow: _timeController.dateTime,
                )
                    ? () => _npcFinanceOfferAlternatives(mom)
                    : null,
                onTalkPiperSnitch: _isPiperQuest001SnitchOfferScene()
                    ? () {
                        setState(() {
                          _piperQuest001SnitchToMom(auto: false);
                        });
                      }
                    : null,
              ),
            );
            list.add(const SizedBox(height: 8));
          }
        } else {
          void closeAndGo(String zone, String room, bool insideRoom) {
            setState(() {
              _friendHouseStreetFacade = false;
              _semSummonedAtFriendFacade = false;
              _semTalkSubmenuActive = false;
              _semParentsTalkActive = false;
              _showMomOfficeView = false;
              _nav.spendMoveEnergy();
              _addTravelTime('CITY', zone);
              currentZone = zone;
              currentRoom = room;
              isInsideRoom = insideRoom;
              if (zone != 'STREET') {
                currentStreetHouse = null;
              }
              isStatsOpen = false;
              isBackpackOpen = false;
              newsMessage = LocationsData.getLocationDisplayName(room);
              if (zone == 'STREET') {
                _tryStartSashaMorningRunOnStreetOverview();
              }
            });
          }
          list.add(_navBtn('ДІМ', () => closeAndGo('HOME', LocationsData.corridor, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn('ВУЛ. ШЕВЧЕНКА', () => closeAndGo('STREET', LocationsData.street, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn('КОЛЕДЖ', () => closeAndGo('COLLEGE', LocationsData.collegeHall, false)));
          list.add(const SizedBox(height: 8));
          list.add(
            _navBtn('Бідний р-н', () => closeAndGo('POOR_DISTRICT', LocationsData.poorDistrictOverview, false)),
          );
          list.add(const SizedBox(height: 8));
          list.add(
            _navBtn('Мажорщина', () => closeAndGo('POOR_VILLAGE', LocationsData.poorVillageOverview, false)),
          );
          list.add(const SizedBox(height: 8));
          list.add(
            _navBtn('На море', () => closeAndGo('OUT_OF_TOWN', LocationsData.outOfTownOverview, false)),
          );
          list.add(const SizedBox(height: 8));
        }

        list.add(_navBtn('Назад', () => setState(_exitMomOfficeView)));
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: list,
          ),
        );
      },
    );
  }

  void _tryStartRockefellerNikeQuestInOffice(int weekdayIndex) {
    if (!RockefellerQuests.canStartOfficeQuest(
      world: _worldState,
      weekdayIndex: weekdayIndex,
    )) {
      return;
    }
    _worldState.rockefellerNikeOfficeStep = RockefellerQuests.officeStepIntro;
    _ui.setEventImagePath('lib/assets/location/biznes_centr/rokfeller_camera.jpg');
    newsMessage = sl<LocaleController>().t('rockefeller_nike_quest_step1_news');
  }

  void _exitRockefellerQuestToCityOverview() {
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoLoop = false;
    _showRockefellerCabinetView = false;
    _showRockefellerReceptionView = false;
    _selectedNpcIdInRoom = null;
    currentRoom = LocationsData.cityOverview;
    isInsideRoom = false;
    newsMessage = LocationsData.getLocationDisplayName(LocationsData.cityOverview);
  }

  Widget _buildRockefellerReceptionNavButtons() {
    final loc = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: _navBtn(
              loc('rockefeller_reception_btn_back'),
              () => setState(() {
                _showRockefellerReceptionView = false;
                newsMessage = '';
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Офіс Рокфеллера: дії з NPC (якщо він у офісі) + навігація по зонах, як у [_buildMomOfficeActionPanel] для порожнього кабінету.
  Widget _buildRockefellerCabinetNavButtons() {
    return ListenableBuilder(
      listenable: _timeController,
      builder: (context, _) {
        final npcService = sl<NPCService>();
        final roc = npcService.npcById('rockefeller');
        final hour = _timeController.dateTime.hour;
        final day = _timeController.weekdayIndex;
        final rockefellerHere = roc != null &&
            npcService.getCurrentLocationId(roc, hour, day) ==
                LocationsData.cityBcRockefellerCabinet;

        final list = <Widget>[];
        if (rockefellerHere) {
          final t = sl<LocaleController>().t;
          final step = _worldState.rockefellerNikeOfficeStep;
          if (step == RockefellerQuests.officeStepIntro) {
            list.add(_navBtn(t('rockefeller_nike_btn_ask_job'), () {
              setState(() {
                _worldState.rockefellerNikeOfficeStep =
                    RockefellerQuests.officeStepOffer;
                _ui.setEventImagePath(
                  'lib/assets/location/biznes_centr/rokfeller_first.jpg',
                );
                newsMessage = t('rockefeller_nike_quest_step2_news');
              });
              _saveService.autosave();
            }));
          } else if (step == RockefellerQuests.officeStepOffer) {
            list.add(_navBtn(t('rockefeller_nike_btn_agree'), () {
              setState(() {
                _worldState.rockefellerNikeOfficeStep =
                    RockefellerQuests.officeStepAccepted;
                _ui.setEventImagePath(
                  'lib/assets/location/biznes_centr/rokfeller_first.jpg',
                );
                newsMessage = t('rockefeller_nike_quest_step3_news');
              });
              _saveService.autosave();
            }));
            list.add(const SizedBox(height: 8));
            list.add(_navBtn(t('rockefeller_nike_btn_think'), () {
              setState(() {
                _worldState.rockefellerNikeOfficeStep =
                    RockefellerQuests.officeStepInactive;
                _exitRockefellerQuestToCityOverview();
              });
              _saveService.autosave();
            }));
          } else if (step == RockefellerQuests.officeStepAccepted) {
            list.add(_navBtn(t('rockefeller_nike_btn_leave'), () {
              setState(() {
                _worldState.rockefellerNikeOfficeStep =
                    RockefellerQuests.officeStepInactive;
                _worldState.rockefellerNikeWorkStarted = true;
                _exitRockefellerQuestToCityOverview();
              });
              _saveService.autosave();
            }));
          } else {
            final noCherie005 = !_questFlag(
              'cherie_quest_005',
              'complete',
            );
            final onlyDate = _timeController.onlyDate;
            final canAskNo005 =
                RockefellerQuests.canShowAskJobWhileCherie005Incomplete(
              world: _worldState,
              gameDateDdMmYyyy: onlyDate,
              hour: hour,
            );
            if (noCherie005) {
              if (canAskNo005) {
                list.add(_navBtn(t('rockefeller_nike_btn_ask_job'), () {
                  setState(() {
                    newsMessage =
                        t('rockefeller_nike_quest_cherie005_not_complete_news');
                    _ui.setEventImagePath(null);
                    _worldState.rockefellerCherie005IncompleteAskLastDateKey =
                        onlyDate;
                  });
                  _saveService.autosave();
                }));
                list.add(const SizedBox(height: 8));
              }
            } else {
              list.add(_navBtn(t('rockefeller_nike_btn_ask_job'), () {
                setState(() {
                  newsMessage = t('rockefeller_nike_quest_office_idle_news');
                  _ui.setEventImagePath(null);
                });
              }));
              list.add(const SizedBox(height: 8));
            }
            list.add(_navBtn(t('rockefeller_nike_btn_leave'), () {
              setState(() {
                _ui.setEventImagePath(null);
                _selectedNpcIdInRoom = null;
                newsMessage = '';
                _showRockefellerCabinetView = false;
                _showRockefellerReceptionView = false;
              });
            }));
          }
        } else {
          void closeAndGo(String zone, String room, bool isInsideRoom) {
            setState(() {
              _friendHouseStreetFacade = false;
              _semSummonedAtFriendFacade = false;
              _semTalkSubmenuActive = false;
              _semParentsTalkActive = false;
              _showMomOfficeView = false;
              _showRockefellerCabinetView = false;
              _showRockefellerReceptionView = false;
              _nav.spendMoveEnergy();
              _addTravelTime("CITY", zone);
              currentZone = zone;
              currentRoom = room;
              this.isInsideRoom = isInsideRoom;
              if (zone != 'STREET') {
                currentStreetHouse = null;
              }
              isStatsOpen = false;
              isBackpackOpen = false;
              newsMessage = LocationsData.getLocationDisplayName(room);
              if (zone == 'STREET') {
                _tryStartSashaMorningRunOnStreetOverview();
              }
            });
          }

          list.add(_navBtn("ДІМ", () => closeAndGo("HOME", LocationsData.corridor, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn("ВУЛ. ШЕВЧЕНКА", () => closeAndGo("STREET", LocationsData.street, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn("КОЛЕДЖ", () => closeAndGo("COLLEGE", LocationsData.collegeHall, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn("Бідний р-н", () => closeAndGo("POOR_DISTRICT", LocationsData.poorDistrictOverview, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn("Мажорщина", () => closeAndGo("POOR_VILLAGE", LocationsData.poorVillageOverview, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn("На море", () => closeAndGo("OUT_OF_TOWN", LocationsData.outOfTownOverview, false)));
          list.add(const SizedBox(height: 8));
          list.add(_navBtn('Назад', () => setState(() {
                _showRockefellerCabinetView = false;
                _showRockefellerReceptionView = false;
              })));
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: list,
          ),
        );
      },
    );
  }

  // --- Quest UI Isolation Runtime (Sem/Juniper/Danielle cluster) ---

  QuestRuntimeRegistry get _questUiRegistry => sl<QuestRuntimeRegistry>();

  QuestUiArbitrationResult _questUiArbitration = QuestUiArbitrationResult.empty;

  bool get _useQuestUiIsolation => sl<SettingsController>().useQuestUiIsolation;

  String? get _questUiOwnerFlowId =>
      _questUiArbitration.hasOwner ? _questUiArbitration.ownerFlowId : null;

  void _syncQuestUiArbitration() {
    if (!_useQuestUiIsolation) {
      _questUiArbitration = QuestUiArbitrationResult.empty;
      return;
    }
    _purgeQuestUiMisplacedFlows();
    JuniperQuest003OfferHelp.syncStuckStepIfBelowCatchThreshold(_worldState);
    _syncJuniperQuest003OfferHelpPendingUi();
    _ensureJuniperQuest003HallFollowUpUiCoherent();
    _ensureJuniperQuest002Step1UiCoherent();
    final context = _buildQuestUiContext();
    _questUiArbitration = QuestUiArbiter.resolve(
      _questUiRegistry.flows,
      context,
    );
    assert(
      QuestUiArbiter.satisfiesSingleOwnerInvariant(_questUiArbitration),
      'Quest UI arbitration must have at most one owner',
    );
  }

  void _purgeQuestUiMisplacedFlows() {
    if (!_useQuestUiIsolation) return;
    _purgeSemJuniperRoomIntroIfMisplaced();
    _purgeJuniperManuelKompromatIfMisplaced();
    _purgeJuniperQuest002Step1IfMisplaced();
    _purgeJuniperQuest003IfMisplaced();
    _purgeJuniperQuest003HallIfMisplaced();
    _purgeJuniperSemRoomSexIfBlockedOrMisplaced();
    if (_juniperShowerUiActive &&
        !(currentZone == 'STREET' &&
            currentStreetHouse == LocationsData.friendHouse &&
            isInsideRoom &&
            JuniperShowerVideos.isInFriendBathroom(currentRoom))) {
      _clearJuniperShowerUiOnly();
    }
    if (_spyOnSemParentsUiActive && !_isInFriendParentsRoom()) {
      _finishSpyOnSemParentsToCorridor();
    }
  }

  QuestUiContext _buildQuestUiContext() {
    return QuestUiContext(
      zone: currentZone,
      streetHouse: currentStreetHouse,
      insideRoom: isInsideRoom,
      room: currentRoom,
      hour: _timeController.dateTime.hour,
      weekdayIndex: _timeController.weekdayIndex,
      gameDateKey: _timeController.onlyDate,
      danielleSpyCaughtUiActive: _danielleSpyCaughtUiActive,
      spyOnSemParentsUiActive: _spyOnSemParentsUiActive,
      semJuniperIntroUiActive: _semJuniperIntroUiActive,
      juniperShowerUiActive: _juniperShowerUiActive,
      juniperSemRoomSexUiActive: _juniperSemRoomSexUiActive,
      juniperQuest003UiActive: _juniperQuest003UiActive,
      juniperQuest003HallUiActive: _juniperQuest003HallUiActive,
      juniperQuest003HallFollowUpActive:
          JuniperQuest003.isHallFollowUpActive(_worldState),
      juniperQuest003HallSceneDone: _worldState.juniperQuest003HallSceneDone,
      juniperQuest002Step1UiActive: _juniperQuest002Step1UiActive,
      juniperManuelKompromatPhase: _juniperManuelKompromatPhase,
      juniperManuelKompromatStep1Coherent: _isJuniperManuelKompromatStep1UiCoherent(),
      juniperManuelKompromatStep2Coherent: _isJuniperManuelKompromatStep2UiCoherent(),
      juniperManuelKompromatStep2AfterFleeCoherent:
          _isJuniperManuelKompromatStep2AfterFleeUiCoherent(),
      juniperManuelKompromatStep3Coherent: _isJuniperManuelKompromatStep3UiCoherent(),
      juniperManuelKompromatStep4Coherent: _isJuniperManuelKompromatStep4UiCoherent(),
      semGirlsTalkActive: _semGirlsTalkActive,
      semGirlsSisterTalkActive: _semGirlsSisterTalkActive,
      semGirlsHintTalkActive: _semGirlsHintTalkActive,
      semGirlsFollowUpActive: _semGirlsFollowUpActive,
      semParentsTalkActive: _semParentsTalkActive,
      semTalkSubmenuActive: _semTalkSubmenuActive,
      friendHouseStreetFacade: _friendHouseStreetFacade,
      semSummonedAtFriendFacade: _semSummonedAtFriendFacade,
      danielleSpyCaughtCoherent: _danielleSpyCaughtUiActive,
      spyOnSemParentsCoherent: _spyOnSemParentsUiActive && _isInFriendParentsRoom(),
      semJuniperIntroCoherent: SemJuniperRoomIntro.isSceneActive(
        introUiActive: _semJuniperIntroUiActive,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ),
      juniperShowerCoherent: _juniperShowerUiActive &&
          currentZone == 'STREET' &&
          currentStreetHouse == LocationsData.friendHouse &&
          isInsideRoom &&
          JuniperShowerVideos.isInFriendBathroom(currentRoom),
      juniperSemRoomSexCoherent: _juniperSemRoomSexUiActive &&
          currentZone == 'STREET' &&
          currentStreetHouse == LocationsData.friendHouse &&
          isInsideRoom &&
          JuniperSemRoomSexVideos.isInSemRoom(currentRoom),
      juniperQuest003HallCoherent:
          JuniperQuest003.isHallFollowUpInHallLocation(
            world: _worldState,
            zone: currentZone,
            streetHouse: currentStreetHouse,
            insideRoom: isInsideRoom,
            room: currentRoom,
          ) ||
          (_juniperQuest003HallUiActive &&
              JuniperQuest003.isInFriendHall(
                zone: currentZone,
                streetHouse: currentStreetHouse,
                insideRoom: isInsideRoom,
                room: currentRoom,
              )),
      juniperQuest003LoungeCoherent: JuniperQuest003.isLoungeVideoSceneActive(
        uiActive: _juniperQuest003UiActive,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ),
      juniperQuest003LoungeOfferCoherent: JuniperQuest003.isLoungeOfferUiCoherent(
        arousal: _playerStats.arousal,
        maxArousal: _playerStats.player.maxArousal,
        loungeUiActive: _juniperQuest003UiActive,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ),
      juniperQuest003CorridorCoherent: JuniperQuest003.isCorridorHallSoundsHintContext(
        world: _worldState,
        zone: currentZone,
        streetHouse: currentStreetHouse,
        insideRoom: isInsideRoom,
        room: currentRoom,
      ),
      juniperQuest002Step1Coherent: _juniperQuest002Step1UiActive &&
          JuniperQuest002Naslidku.isStep1UiCoherent(
            step1UiActive: true,
            activeNpcs: _getActiveNPCsInCurrentRoom(),
          ),
      semGirlsTalkCoherent: _semTalkContextActive &&
          (_semGirlsTalkActive ||
              _semGirlsSisterTalkActive ||
              _semGirlsHintTalkActive ||
              _semGirlsFollowUpActive),
      semParentsTalkCoherent:
          _semParentsTalkActive && _friendHouseStreetFacade,
      semFacadeTalkCoherent: _friendHouseStreetFacade &&
          _semSummonedAtFriendFacade &&
          !isInsideRoom &&
          currentZone == 'STREET' &&
          currentStreetHouse == null,
    );
  }

  bool _isQuestUiIsolationOwner(String flowId) =>
      _useQuestUiIsolation && _questUiOwnerFlowId == flowId;

  bool _hasQuestUiIsolationClusterOwner() =>
      _useQuestUiIsolation && _questUiArbitration.hasOwner;

  Widget? _questUiIsolationActionPanelIfAny() {
    if (!_useQuestUiIsolation || !_questUiArbitration.hasOwner) return null;
    return _questFlowActionPanel(_questUiArbitration.ownerFlowId!);
  }

  Widget? _questFlowActionPanel(String flowId) {
    switch (flowId) {
      case QuestFlowIds.danielleSpyCaught:
        final tCaught = sl<LocaleController>().t;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _navBtn(
                tCaught('danielle_spy_caught_confirm'),
                _finishDanielleSpyCaughtQuest,
              ),
            ],
          ),
        );
      case QuestFlowIds.semJuniperIntro:
        return _semJuniperIntroPriorityActionPanelIfAny();
      case QuestFlowIds.juniperShower:
        return _juniperShowerIsolationActionPanel();
      case QuestFlowIds.juniperSemRoomSex:
        return _juniperSemRoomSexIsolationActionPanel();
      case QuestFlowIds.juniperManuelKompromat:
        return _juniperManuelKompromatStep2AfterFleePriorityActionPanelIfAny();
      case QuestFlowIds.juniperQuest003Corridor:
        return null;
      case QuestFlowIds.juniperQuest003Hall:
        return _juniperQuest003HallDuringVideoPriorityActionPanelIfAny();
      case QuestFlowIds.juniperQuest003Lounge:
        return _juniperQuest003DuringVideoPriorityActionPanelIfAny();
      case QuestFlowIds.juniperQuest002Step1:
        return _juniperQuest002Step1PriorityActionPanelIfAny();
      case QuestFlowIds.semGirlsTalk:
        return _semGirlsTalkPriorityActionPanelIfAny();
      case QuestFlowIds.spyOnSemParents:
        return _spyOnSemParentsIsolationActionPanel();
      default:
        return null;
    }
  }

  Widget _juniperShowerIsolationActionPanel() {
    final tShower = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_juniperShowerTier == 1 || _juniperShowerTier == 2) ...[
            _navBtn(
              tShower('danielle_spy_parents_continue_watching'),
              _juniperShowerTier == 1
                  ? _juniperShowerWatchMoreAfterVideo1
                  : _juniperShowerWatchMoreAfterVideo2,
            ),
            const SizedBox(height: 8),
          ],
          _navBtn(
            tShower('danielle_spy_parents_leave'),
            _finishJuniperShowerScene,
          ),
        ],
      ),
    );
  }

  Widget _juniperSemRoomSexIsolationActionPanel() {
    final tSex = sl<LocaleController>().t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_juniperSemRoomSexTier >= 1 && _juniperSemRoomSexTier <= 3) ...[
            _navBtn(
              tSex(JuniperSemRoomSexVideos.l10nWatchMore),
              _juniperSemRoomSexWatchMore,
            ),
            const SizedBox(height: 8),
          ],
          _navBtn(
            tSex('danielle_spy_parents_leave'),
            _finishJuniperSemRoomSexScene,
          ),
        ],
      ),
    );
  }

  Widget _spyOnSemParentsIsolationActionPanel() {
    final t = sl<LocaleController>().t;
    final stealth = _playerStats.player.stealth_mode;
    final children = <Widget>[];
    switch (_spyParentsPhase) {
      case DanielleSpyParentsPhase.door:
        if (stealth >= DanielleSpyParentsQuest.peek2MinStealth) {
          children.add(
            _navBtn(
              t('danielle_spy_parents_peek'),
              () => setState(() => _applyDanielleSpyWatchTier(1)),
            ),
          );
          children.add(const SizedBox(height: 8));
        }
        break;
      case DanielleSpyParentsPhase.watchVideo1:
        if (stealth >= DanielleSpyParentsQuest.peek3MinStealth) {
          children.add(
            _navBtn(
              t('danielle_spy_parents_watch_more'),
              _danielleSpyWatchMoreAfterVideo1,
            ),
          );
          children.add(const SizedBox(height: 8));
        }
        break;
      case DanielleSpyParentsPhase.watchVideo2:
        children.add(
          _navBtn(
            t('danielle_spy_parents_watch_more'),
            _danielleSpyWatchMoreAfterVideo2,
          ),
        );
        children.add(const SizedBox(height: 8));
      case DanielleSpyParentsPhase.watchVideo3:
        break;
    }
    children.add(
      _navBtn(t('danielle_spy_parents_leave'), _finishSpyOnSemParentsToCorridor),
    );
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

  String _spyOnSemParentsIsolationDialogMessage() {
    final t = sl<LocaleController>().t;
    return switch (_spyParentsPhase) {
      DanielleSpyParentsPhase.door => t('danielle_spy_parents_dialogue'),
      DanielleSpyParentsPhase.watchVideo1 ||
      DanielleSpyParentsPhase.watchVideo2 ||
      DanielleSpyParentsPhase.watchVideo3 =>
        t(DanielleSpyParentsQuest.afterPeekDialogueKeyForTier(
          switch (_spyParentsPhase) {
            DanielleSpyParentsPhase.watchVideo1 => 1,
            DanielleSpyParentsPhase.watchVideo2 => 2,
            _ => 3,
          },
        )),
    };
  }

  Widget? _questUiIsolationDialogIfAny() {
    if (!_useQuestUiIsolation || !_questUiArbitration.hasOwner) return null;
    final flowId = _questUiArbitration.ownerFlowId!;
    final t = sl<LocaleController>().t;

    switch (flowId) {
      case QuestFlowIds.danielleSpyCaught:
        return GameDialogPanel(
          message: t(
            DanielleSpyCaughtQuest.dialogueL10nKey(_worldState),
          ),
          highlightNames: const [],
          navButtons: [_questFlowActionPanel(flowId)!],
        );
      case QuestFlowIds.semJuniperIntro:
        return GameDialogPanel(
          message: _semJuniperIntroDialogueMessage(),
          highlightNames: const ['Juniper', 'Sem', 'Джуніпер'],
          navButtons: [
            _questFlowActionPanel(flowId) ?? const SizedBox.shrink(),
          ],
        );
      case QuestFlowIds.juniperShower:
        return GameDialogPanel(
          message: _messageWithSelectedNpcStripLine(''),
          highlightNames: const ['Juniper'],
          navButtons: [_questFlowActionPanel(flowId)!],
        );
      case QuestFlowIds.juniperSemRoomSex:
        return GameDialogPanel(
          message: _messageWithSelectedNpcStripLine(''),
          highlightNames: const ['Juniper'],
          navButtons: [_questFlowActionPanel(flowId)!],
        );
      case QuestFlowIds.spyOnSemParents:
        return GameDialogPanel(
          message: _spyOnSemParentsIsolationDialogMessage(),
          highlightNames: const [],
          navButtons: [_questFlowActionPanel(flowId)!],
        );
      case QuestFlowIds.juniperQuest002Step1:
        return GameDialogPanel(
          message: t(JuniperQuest002Naslidku.l10nStep1Dialogue),
          highlightNames: const ['Juniper', 'Джуніпер'],
          navButtons: [
            _questFlowActionPanel(flowId) ?? const SizedBox.shrink(),
          ],
        );
      case QuestFlowIds.juniperQuest003Corridor:
        return GameDialogPanel(
          message: t(JuniperQuest003.l10nCorridorHallSounds),
          highlightNames: const [],
          greenEventStyle: true,
          navButtons: [_buildActionPanel(skipQuestUiIsolation: true)],
        );
      case QuestFlowIds.juniperQuest003Hall:
        return GameDialogPanel(
          message: t(JuniperQuest003.l10nHallDialogue),
          highlightNames: const ['Juniper', 'Джуніпер'],
          navButtons: [
            _questFlowActionPanel(flowId) ?? const SizedBox.shrink(),
          ],
        );
      case QuestFlowIds.juniperQuest003Lounge:
        final loungePanel = _questFlowActionPanel(flowId);
        if (loungePanel == null) return null;
        final offerStep = JuniperQuest003OfferHelp.activeStep(_worldState);
        final offerKey =
            JuniperQuest003OfferHelp.dialogueL10nKeyForStep(offerStep);
        final loungeMessage = offerKey != null
            ? t(offerKey)
            : _messageWithSelectedNpcStripLine(newsMessage);
        return GameDialogPanel(
          message: loungeMessage,
          highlightNames: const ['Juniper', 'Джуніпер'],
          navButtons: [loungePanel],
        );
      default:
        return null;
    }
  }

  bool _isQuestUiIsolationScriptedDialogForNews() {
    if (!_useQuestUiIsolation || !_questUiArbitration.hasOwner) return false;
    return _questUiArbitration.ownerFlowId != QuestFlowIds.semFacadeTalk;
  }

  bool _shouldAllowLegacyClusterActionPanel(String flowId) {
    if (!_useQuestUiIsolation) return true;
    if (!_hasQuestUiIsolationClusterOwner()) return true;
    return _isQuestUiIsolationOwner(flowId);
  }

  bool _shouldShowLegacyClusterDialog(String flowId) =>
      !_useQuestUiIsolation || _isQuestUiIsolationOwner(flowId);
}
