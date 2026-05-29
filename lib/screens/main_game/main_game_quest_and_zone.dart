part of '../main_game_screen.dart';

/// Квести й час, контент зон, права панель дій і навігація по зонах.
mixin MainGameQuestFlows on MainGameScreenStateBase, MomGameFlow, CherieGameFlow, PiperGameFlow, MainGameNpcFinance {
  bool get _useQuestRuntimeV2 => sl<SettingsController>().useQuestRuntimeV2;

  bool get _questRuntimeMirrorMode =>
      sl<SettingsController>().questRuntimeMirrorMode;

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
    return 'street_${sh}_${currentRoom}_${dt.year}_${dt.month}_${dt.day}_${dt.hour}_${_timeController.weekdayIndex}';
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
      _tryStartDanielleSpyParentsAfterRoomEntry();
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
      _ensurePiperQuest001SnitchAckUiCoherent();
      _tryStartPiperQuest001Step3IfNeeded();
      _ensurePiperQuest001Step3TeacherCallUiCoherent();
      _tryStartPiperQuest001Step4IfNeeded();
      _ensurePiperQuest001Step4CorridorUiCoherent();
      _tryStartPiperQuest001Step5IfNeeded();
      _ensurePiperQuest001Step5PunishmentUiCoherent();
      _tryStartPiperHallWeekendEventIfNeeded(name);
      _ensurePiperHallWeekendEventUiCoherent();
      _ensureCherieQuest002HomeHallUiCoherent();
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

  void _tryStartDanielleSpyParentsAfterRoomEntry() {
    final inParents = currentZone == 'STREET' &&
        currentStreetHouse == LocationsData.friendHouse &&
        isInsideRoom &&
        currentRoom == LocationsData.friendParentsRoom;

    if (_spyOnSemParentsUiActive && !inParents) {
      _clearDanielleSpyParentsUiOnly();
    }

    if (_spyOnSemParentsUiActive) return;
    if (!inParents) return;

    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    if (!DanielleSpyParentsQuest.canTrigger(
          world: _worldState,
          npcService: sl<NPCService>(),
          playerStats: _playerStats,
          hourAfterEntry: hour,
          weekdayIndex: day,
        )) {
      return;
    }
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
                  videoPath: 'lib/assets/gg/ups_first_1.webm',//відео дрочки
                  onClose: () => setState(() => _showMasturbateVideo = false),
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
            suppressRoomNpcRaster: _danielleSpyCaughtUiActive,
            onNPCTap: (npc) {
              setState(() => _selectedNpcIdInRoom = npc.id);
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
                _danielleSpyCaughtUiActive || piperLibraryEavesdrop,
            piperLibraryEavesdropActive: piperLibraryEavesdrop,
            onNPCTap: (npc) {
              setState(() {
                _selectedNpcIdInRoom = npc.id;
                if (npc.id == 'den') {
                  _resetDenLocalUi();
                  newsMessage = _getDenDialogueText(npc);
                } else if (npc.id == 'loshok') {
                  _ui.setEventImagePath(null);
                  newsMessage = '';
                } else if (npc.id == 'nicole') {
                  _ui.setEventImagePath(null);
                  newsMessage = '';
                } else if (npc.id == 'dekan') {
                  _ui.setEventImagePath(null);
                  newsMessage = '';
                }
              });
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: VideoSceneWidget(key: ValueKey('mom_office_$videoPath'), videoPath: videoPath),
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
            suppressRoomNpcRaster: _danielleSpyCaughtUiActive,
            suppressCherieGiftShopOfficeTc1Background:
                _suppressCherieGiftShopOfficeTc1Underlay,
            onRoomTap: _handleRoomEntry,
            onLogisticsOfficeTap: () {
              final npcService = sl<NPCService>();
              final ludaList = npcService.allNPCs.where((n) => n.id == 'luda').toList();
              final hour = _timeController.dateTime.hour;
              final day = _timeController.weekdayIndex;
              final isLudaAtWork = ludaList.isNotEmpty &&
                  npcService.getCurrentLocationId(ludaList.first, hour, day) == LocationsData.cityBcLogistics;
              setState(() {
                if (isLudaAtWork) {
                  _showLogisticsOfficeVideo = true;
                } else {
                  final momList = npcService.allNPCs.where((n) => n.id == 'mom').toList();
                  final NPCModel? mom = momList.isEmpty ? null : momList.first;
                  final isMomAtWork = mom != null && npcService.getCurrentLocationId(mom, hour, day) == LocationsData.cityBcLogisticsMomOffice;
                  if (isMomAtWork) {
                    _momOfficeUseButtonImage = false;
                    if (Random().nextBool()) {
                      _momOfficeVideoIndex = null;
                    } else {
                      _momOfficeVideoIndex = Random().nextInt(3) + 1;
                    }
                  } else {
                    _momOfficeUseButtonImage = true;
                    _momOfficeVideoIndex = null;
                  }
                  _showMomOfficeView = true;
                }
              });
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
                _selectedNpcIdInRoom = npc.id;
                if (npc.id == 'rockefeller') {
                  _ui.setEventImagePath(null);
                  newsMessage = '';
                }
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
            suppressRoomNpcRaster: _danielleSpyCaughtUiActive,
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
              setState(() => _selectedNpcIdInRoom = npc.id);
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
            suppressRoomNpcRaster: _danielleSpyCaughtUiActive,
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
              setState(() => _selectedNpcIdInRoom = npc.id);
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
            suppressRoomNpcRaster: _danielleSpyCaughtUiActive,
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
              setState(() => _selectedNpcIdInRoom = npc.id);
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
            suppressRoomNpcRaster: _danielleSpyCaughtUiActive,
            friendHouseStreetFacade: _friendHouseStreetFacade,
            onFriendHouseStreetFacadeChanged: (visible) => setState(() {
              _friendHouseStreetFacade = visible;
              if (!visible) {
                _semSummonedAtFriendFacade = false;
                _semFriendHouseTalkActive = false;
                _semParentsTalkActive = false;
              }
            }),
            onRoomTap: _handleRoomEntry,
            onBack: () {
              _timeController.addMinutes(5);
              setState(() {
                if (currentStreetHouse != null && isInsideRoom) {
                  isInsideRoom = false;
                  currentRoom = LocationsData.getFirstRoomIdForStreetHouse(currentStreetHouse) ?? LocationsData.corridor;
                } else if (currentStreetHouse != null) {
                  currentStreetHouse = null;
                  currentRoom = LocationsData.street;
                  isInsideRoom = false;
                } else {
                  isInsideRoom = false;
                  currentRoom = LocationsData.street;
                }
              });
            },
            timeController: _timeController,
            onNPCTap: (npc) {
              setState(() => _selectedNpcIdInRoom = npc.id);
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
        _semSummonedAtFriendFacade = false;
        _semFriendHouseTalkActive = false;
        _semParentsTalkActive = false;
      });
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

      _nav.setZoneAndRoom(_nav.currentZone, LocationsData.friendCorridor);
      _nav.setIsInsideRoom(false);
      newsMessage = LocationsData.getLocationDisplayName(
        LocationsData.friendCorridor,
      );
      _saveService.autosave();
    });
  }

  Widget _navBtn(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: GameTheme.actionButtonStyle(color: GameTheme.textBlack),
      onPressed: () {
        if (isNpcGalleryOpen ||
            _selectedNpcForProfile != null ||
            isBackpackOpen ||
            isStatsOpen) {
          setState(_dismissNpcGalleryIfOpen);
        }
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

  /// Кнопки переходу між зонами: Дім → (на огляді Мажорщини «Місто») → Вул. Шевченка → Коледж → (з дому «В МІСТО») → Бідний р-н → Мажорщина → На море.
  void _appendStandardWorldTravelButtons(List<Widget> actionWidgets) {
    if (currentZone != "HOME") {
      actionWidgets.add(        _navBtn("ДІМ", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "HOME");
        setState(() {
          if (currentZone == "STREET") {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semFriendHouseTalkActive = false;
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
          _semFriendHouseTalkActive = false;
          _semParentsTalkActive = false;
          currentZone = "STREET";
          currentStreetHouse = null;
          currentRoom = LocationsData.street;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
          _tryStartSashaMorningRunOnStreetOverview();
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
            _semFriendHouseTalkActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "COLLEGE";
          currentRoom = LocationsData.collegeHall;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
        });
      }));
      actionWidgets.add(const SizedBox(height: 8));
    }
    if (currentZone == "HOME") {
      actionWidgets.add(_navBtn("В МІСТО", () {
        _nav.spendMoveEnergy();
        _addTravelTime(currentZone, "CITY");
        setState(() {
          currentZone = "CITY";
          currentRoom = LocationsData.cityOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
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
            _semFriendHouseTalkActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "POOR_DISTRICT";
          currentRoom = LocationsData.poorDistrictOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
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
            _semFriendHouseTalkActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "POOR_VILLAGE";
          currentRoom = LocationsData.poorVillageOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
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
            _semFriendHouseTalkActive = false;
            _semParentsTalkActive = false;
          }
          currentZone = "OUT_OF_TOWN";
          currentRoom = LocationsData.outOfTownOverview;
          isInsideRoom = false;
          isStatsOpen = false;
          isBackpackOpen = false;
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
        if (_playerStats.money < 10) {
          showInsufficientMoneyDialog(context);
          return;
        }
        _playerStats.changeMoney(-10);
        SashaEvents.applyMorningRunGiveMoney(
          sasha: sashaNpc,
          dollarsGiven: 10,
        );
        setState(() {
          _sashaMorningRunPhase = SashaMorningRunPhase.afterPaid;
          newsMessage = SashaEvents.morningRunAfterPaidTalk;
          sashaNpc.setVar(
            SashaEvents.morningRunStepVar,
            SashaEvents.stepForPhase(SashaMorningRunPhase.afterPaid),
          );
        });
        _saveService.autosave();
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

  Widget _buildActionPanel() {
    return ListenableBuilder(
      listenable: Listenable.merge([_timeController, _playerStats, _ui]),
      builder: (context, _) {
        _syncMomEvent002KitchenRecheckIfNeeded();
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
            // Для всіх інших NPC — стандартні кнопки взаємодії (навіть якщо ще не тапнули по смузі NPC).
            actionWidgets.add(
              NpcInteractionButtons(
                key: ValueKey(npc.id),
                npc: npc,
                location: currentRoom,
                hour: hour,
                onUpdate: () => setState(() {
                  _dismissNpcGalleryIfOpen();
                }),
                onBack: _handleBackTap,
                onActionExecuted: (label, npc) =>
                    _handleNpcActionExecuted(label, npc),
                onFinanceGiveMoney: () => _npcFinanceGiveMoney(npc),
                onFinanceAskLoan: () => _npcFinanceAskLoan(npc),
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
              ),
            );
          }
          }
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
                    setState(_dismissNpcGalleryIfOpen);
                  }
                  final loot = RoomSearchLootService.rollHomeFamilyBedroom(
                    currentRoomNorm,
                    Random(),
                    _worldState,
                  );
                  if (loot == null) {
                    DismissibleInfoOverlay.show(context, t('room_search_nothing'));
                    return;
                  }
                  if (loot.money > 0) {
                    _playerStats.changeMoney(loot.money);
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
                    setState(_dismissNpcGalleryIfOpen);
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
                    setState(_dismissNpcGalleryIfOpen);
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
            if (_semFriendHouseTalkActive) {
              actionWidgets.add(_navBtn(t('friend_house_btn_leave'), () {
                setState(() {
                  _semFriendHouseTalkActive = false;
                  newsMessage = t('friend_house_summon_news');
                });
              }));
            } else if (_semParentsTalkActive) {
              actionWidgets.add(_navBtn(t('friend_house_btn_leave'), () {
                final sem = findSemNpc(npcService.allNPCs);
                if (sem != null) SemParentsTalkEvent.markComplete(sem);
                _saveService.autosave();
                setState(() {
                  _semParentsTalkActive = false;
                  _friendHouseStreetFacade = false;
                  _semSummonedAtFriendFacade = false;
                  _semFriendHouseTalkActive = false;
                  currentZone = 'STREET';
                  currentStreetHouse = null;
                  currentRoom = LocationsData.street;
                  isInsideRoom = false;
                  newsMessage = t(SemParentsTalkEvent.l10nAfterStreetKey);
                });
              }));
            } else {
              if (!_semSummonedAtFriendFacade) {
                actionWidgets.add(_navBtn(t('friend_house_btn_call_sem'), () {
                  final h = _timeController.dateTime.hour;
                  final d = _timeController.weekdayIndex;
                  _timeController.addMinutes(5);
                  if (!npcService.isSemAtFriendHouseForDoorSummon(h, d)) {
                    setState(() => newsMessage = t('friend_house_sem_cannot_call'));
                    return;
                  }
                  setState(() {
                    _semSummonedAtFriendFacade = true;
                    newsMessage = t('friend_house_summon_news');
                  });
                }));
                actionWidgets.add(const SizedBox(height: 8));
              } else if (semNpc != null) {
                final sem = semNpc;
                actionWidgets.add(_navBtn('Поговорити', () {
                  final h = _timeController.dateTime.hour;
                  final d = _timeController.weekdayIndex;
                  if (!npcService.isSemAtFriendHouseForDoorSummon(h, d)) {
                    setState(() => newsMessage = t('friend_house_sem_cannot_call'));
                    return;
                  }
                  _timeController.addMinutes(5);
                  sem.setVar('phone_unlocked', true);
                  setState(() {
                    _semFriendHouseTalkActive = true;
                    newsMessage = t('friend_house_sem_talk_dialogue');
                  });
                }));
                actionWidgets.add(const SizedBox(height: 8));
                if (SemParentsTalkEvent.canShowAskButton(sem)) {
                  actionWidgets.add(_navBtn(t(SemParentsTalkEvent.l10nAskButtonKey), () {
                    _timeController.addMinutes(SemParentsTalkEvent.minutesOnOpenDialogue);
                    setState(() {
                      _semParentsTalkActive = true;
                      newsMessage = t(SemParentsTalkEvent.l10nDialogueKey);
                    });
                  }));
                  actionWidgets.add(const SizedBox(height: 8));
                }
                actionWidgets.add(_navBtn(t('friend_house_sem_invite_porn'), () {}));
                actionWidgets.add(const SizedBox(height: 8));
              }
              actionWidgets.add(_navBtn(t('friend_house_btn_enter'), () {
                setState(() {
                  _friendHouseStreetFacade = false;
                  _semSummonedAtFriendFacade = false;
                  _semFriendHouseTalkActive = false;
                  _semParentsTalkActive = false;
                });
                _handleRoomEntry(LocationsData.friendHouse);
              }));
              actionWidgets.add(const SizedBox(height: 8));
              actionWidgets.add(_navBtn(t('friend_house_btn_leave'), () {
                setState(() {
                  _friendHouseStreetFacade = false;
                  _semSummonedAtFriendFacade = false;
                  _semFriendHouseTalkActive = false;
                  _semParentsTalkActive = false;
                });
              }));
            }
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

  /// Кнопки зон (як [_appendStandardWorldTravelButtons]) + «Назад» останньою.
  Widget _buildMomOfficeNavButtons() {
    return ListenableBuilder(
      listenable: _timeController,
      builder: (context, _) {
        final list = <Widget>[];
        void closeAndGo(String zone, String room, bool isInsideRoom) {
          setState(() {
            _friendHouseStreetFacade = false;
            _semSummonedAtFriendFacade = false;
            _semFriendHouseTalkActive = false;
            _semParentsTalkActive = false;
            _showMomOfficeView = false;
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
              // EVENT №2 Саші: якщо це перенесення на «вул. Шевченка», пробуємо старт.
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
        list.add(_navBtn('Назад', () => setState(() => _showMomOfficeView = false)));
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

  /// Офіс Рокфеллера: дії з NPC (якщо він у офісі) + навігація по зонах, як у [_buildMomOfficeNavButtons].
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
              _semFriendHouseTalkActive = false;
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
}
