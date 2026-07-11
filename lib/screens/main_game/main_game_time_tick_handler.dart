part of '../main_game_screen.dart';

mixin MainGameTimeTickHandler on MainGameScreenStateBase, MomGameFlow, PiperGameFlow, MainGameQuestFlows {
  void _onTimeChanged() {
    setState(() {
      _syncMomEvent002KitchenRecheckIfNeeded();
      _syncPiperQuest001DailyIfNeeded();
      NpcEconomyService.syncWithGameClock(
        sl<NPCService>(),
        _worldState,
        _timeController.dateTime,
      );
      final npcService = sl<NPCService>();
      final financeDayKey = npcFinanceGameDayKey(_timeController.dateTime);
      if (_worldState.lastNpcFinanceGameDayKey == null) {
        _worldState.lastNpcFinanceGameDayKey = financeDayKey;
      } else if (_worldState.lastNpcFinanceGameDayKey != financeDayKey) {
        NpcFinanceService.onGameDayAdvanced(
          _worldState,
          npcService,
          _playerStats,
          _timeController.dateTime,
        );
        _worldState.lastNpcFinanceGameDayKey = financeDayKey;
      }
      for (final npc in npcService.allNPCs) {
        if (!isSecondaryNpc(npc) && npc.gender == NpcGender.male) {
          NpcFinanceService.tryMaleAutoRepay(_worldState, npc, _playerStats);
        }
      }
      GgEvent001Stojak.resetDailyAtSixIfNeeded(
        _worldState,
        npcService,
        _timeController.dateTime,
      );
      GgHygiene.syncDayTick(_worldState, _timeController.dateTime);
      JuniperQuest003.syncDayTick(
        _worldState,
        gameDateKey: _timeController.onlyDate,
      );
      JuniperQuest003OfferHelp.syncColdShoulderExpiry(
        _worldState,
        gameDateKey: _timeController.onlyDate,
      );
      npcService.resetSondoxTriggersAtMorning(_timeController.dateTime);
      if (_collegeToiletUnderwearSaleActive &&
          !_isCollegeToiletGuysBreakWindow()) {
        _resetCollegeToiletUnderwearSaleUi();
      }
      final hour = _timeController.dateTime.hour;
      final day = _timeController.weekdayIndex;
      _syncSemJuniperArcOnRoomEntry();
      _syncActiveLocationAfterTimeChange();
      _showCollegeLessonStartDialogIfNeeded();
      final animatorSlotKey = CherieQuest001.giftShopAnimatorShiftSlotKey(
        _timeController.dateTime,
        _timeController.weekdayIndex,
      );
      final pendingFinish = _worldState.giftShopAnimatorPendingFinishDateKey;
      if (pendingFinish != null && pendingFinish != animatorSlotKey) {
        if (_worldState.cherieAnimatorWorkVideoCount > 0) {
          _worldState.cherieAnimatorWorkVideoCount--;
        }
        _worldState.giftShopAnimatorPendingFinishDateKey = null;
      }

      // Якщо ніч (22–7) і ми в кімнаті мами/сестер при низьких стосунках — викидаємо в коридор.
      final isHomeNpcRoom = currentZone == 'HOME' &&
          isInsideRoom &&
          (currentRoom == 'mom_room' || currentRoom == 'elsa_room' || currentRoom == 'piper_room');
      if (isHomeNpcRoom) {
        HomeDoorAccess.ensureWeekInitialized(_worldState, _timeController.dateTime);
        final ownerNpcId = currentRoom == 'mom_room'
            ? 'mom'
            : currentRoom == 'elsa_room'
                ? 'elsa'
                : 'piper';
        final ownerList = npcService.allNPCs.where((n) => n.id == ownerNpcId).toList();
        final ownerNpc = ownerList.isEmpty ? null : ownerList.first;

        if (ownerNpc != null) {
          final isNight = hour >= 22 || hour < 7;
          if (isNight && ownerNpc.relationship < 800) {
            final keyGrantedBySearch = switch (currentRoom) {
              LocationsData.momRoom => _worldState.homeRoomSearchKeyMomGranted,
              LocationsData.elsaRoom => _worldState.homeRoomSearchKeyElsaGranted,
              LocationsData.piperRoom => _worldState.homeRoomSearchKeyPiperGranted,
              _ => false,
            };
            final hasRoomKey = keyGrantedBySearch ||
                HomeDoorAccess.hasAnyRoomKeyFor(currentRoom, _inventory);
            if (!hasRoomKey) {
              // Повторюємо логіку HomeDoorAccess: якщо це «відкрита» ніч для цієї жінки — не викидаємо.
              final openDay = currentRoom == 'mom_room'
                  ? _worldState.momDoorOpenWeekday
                  : currentRoom == 'elsa_room'
                      ? _worldState.elsaDoorOpenWeekday
                      : _worldState.piperDoorOpenWeekday;
              if (openDay != null && day == openDay) {
                // У цю ніч можна залишатися в кімнаті.
              } else if (canPlayerPickHomeNightLock(_inventory, _playerStats)) {
                // Як при вході: відмичка + курс злому або злам замків 100.
              } else {
                isInsideRoom = false;
                currentRoom = LocationsData.corridor;
                isLaptopOpen = false;
                _isWatchingPornInLaptop = false;
                _isWatchingElsaVideoInLaptop = false;
                newsMessage = LocationsData.getLocationDisplayName(LocationsData.corridor);
              }
            }
          }
        }
      }

      // У домі друга (Сем): 23–7, кімнати батьків і Саші — та сама логіка, що мама вдома ГГ.
      final isSemFriendNpcRoom = currentZone == 'STREET' &&
          currentStreetHouse == LocationsData.friendHouse &&
          isInsideRoom &&
          (currentRoom == LocationsData.friendParentsRoom ||
              currentRoom == LocationsData.friendSisterRoom);
      if (isSemFriendNpcRoom) {
        HomeDoorAccess.ensureWeekInitialized(_worldState, _timeController.dateTime);
        final ownerNpcId = currentRoom == LocationsData.friendParentsRoom
            ? 'danielle'
            : 'sasha';
        final ownerList = npcService.allNPCs.where((n) => n.id == ownerNpcId).toList();
        final ownerNpc = ownerList.isEmpty ? null : ownerList.first;

        if (ownerNpc != null) {
          final isNight = hour >= 23 || hour < 7;
          if (isNight && ownerNpc.relationship < 800) {
            final openDay = currentRoom == LocationsData.friendParentsRoom
                ? _worldState.friendHouseDanielleDoorOpenWeekday
                : _worldState.friendHouseSashaDoorOpenWeekday;
            if (openDay != null && day == openDay) {
              // У цю ніч можна залишатися в кімнаті.
            } else if (canPlayerPickHomeNightLock(_inventory, _playerStats)) {
              // Та сама відмичка + уроки / злам замків, що й удома.
            } else {
              isInsideRoom = false;
              currentRoom = LocationsData.friendCorridor;
              isLaptopOpen = false;
              _isWatchingPornInLaptop = false;
              _isWatchingElsaVideoInLaptop = false;
              newsMessage =
                  LocationsData.getLocationDisplayName(LocationsData.friendCorridor);
            }
          }
        }
      }

      if (_showLogisticsOfficeVideo) {
        final ludaList = npcService.allNPCs.where((n) => n.id == 'luda').toList();
        final ludaAtWork = ludaList.isNotEmpty &&
            npcService.getCurrentLocationId(ludaList.first, hour, day) == LocationsData.cityBcLogistics;
        if (!ludaAtWork) {
          _openMomOfficeViewForCurrentTime();
        }
      }

      if (_showMomOfficeView) {
        _syncMomOfficeViewState(pickNewVideoIfMissing: false);
      }

      _maybeStartDanielleSpyCaughtAutoInRoom();
      _tryAutoStartSashaHallComunicateVideo();
      _syncSashaHallNewsMessageIfInEvent();
      _tryResumeSashaMorningRunIfInProgress();
      _syncSashaMorningRunNewsMessageIfInEvent();

      final cherieForDayCounter = npcService.npcById('cherie');
      final cherieForOffice = cherieForDayCounter;
      CherieQuest001.tickNextQuestDayCounterIfNeeded(
        world: _worldState,
        questOneAgreed: cherieForDayCounter != null &&
            cherieForDayCounter
                    .getVar(CherieQuest001.giftShopWorkAnimatorVar) ==
                true,
        now: _timeController.dateTime,
      );
      CherieQuest002.tickMassageLegsCooldownMonday(
        world: _worldState,
        now: _timeController.dateTime,
        weekdayIndex: day,
      );
      if (CherieQuest002.shouldResetOfficeSessionBecauseCherieLeft(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
        hour: hour,
        weekdayIndex: day,
        cherie: cherieForOffice,
        npcService: npcService,
      )) {
        _abortCherieQuest002ProgressAndUi(applySaturdaySundayBlock: false);
        _saveService.autosave();
      }

      if (CherieQuest003.shouldResetOfficeSessionBecauseCherieLeft(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
        hour: hour,
        weekdayIndex: day,
        cherie: cherieForOffice,
        npcService: npcService,
      )) {
        _abortCherieQuest003ProgressAndUi();
        _saveService.autosave();
      }

      if (CherieQuest004.shouldResetOfficeSessionBecauseCherieLeft(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
        hour: hour,
        weekdayIndex: day,
        cherie: cherieForOffice,
        npcService: npcService,
      )) {
        _abortCherieQuest004ProgressAndUi();
        _saveService.autosave();
      }

      if (CherieQuest005.shouldResetOfficeSessionBecauseCherieLeft(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
        hour: hour,
        weekdayIndex: day,
        cherie: cherieForOffice,
        npcService: npcService,
      )) {
        _abortCherieQuest005ProgressAndUi();
        _saveService.autosave();
      }

      if (CherieQuest006.shouldResetOfficeSessionBecauseCherieLeft(
        world: _worldState,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
        hour: hour,
        weekdayIndex: day,
        cherie: cherieForOffice,
        npcService: npcService,
      )) {
        _abortCherieQuest006ProgressAndUi();
        _saveService.autosave();
      }

      if (CherieQuest001.shouldResetOfficeSessionBecauseCherieLeft(
        phase: _ui.cherieQuest001OfficePhase,
        currentZone: currentZone,
        isInsideRoom: isInsideRoom,
        currentRoom: currentRoom,
        hour: hour,
        weekdayIndex: day,
        cherie: npcService.npcById('cherie'),
        npcService: npcService,
      )) {
        _resetCherieOfficeAnimatorQuestSession(
          abortGiftShopAnimatorShift: _isGiftShopAnimatorShiftFlowActive(),
        );
      }

      if (currentZone == 'CITY' &&
          isInsideRoom &&
          currentRoom == LocationsData.cityMallGiftShopOffice &&
          _worldState.cherieAnimatorIntroStep != 0 &&
          (cherieForOffice == null ||
              npcService.getCurrentLocationId(cherieForOffice, hour, day) !=
                  LocationsData.cityMallGiftShopOffice)) {
        _resetCherieOfficeAnimatorQuestSession(
          abortGiftShopAnimatorShift: true,
        );
      }

      // Як у залі з Сашею: після промотки часу в кабінеті, коли Cherie з’являється в розкладі.
      if (currentZone == 'CITY' &&
          isInsideRoom &&
          currentRoom == LocationsData.cityMallGiftShopOffice &&
          _ui.cherieQuest001OfficePhase ==
              CherieQuest001OfficePhase.inactive) {
        final startedQ2 = _tryStartCherieQuest002OfficeIfNeeded(
          LocationsData.cityMallGiftShopOffice,
        );
        if (!startedQ2) {
          _tryResumeCherieQuest003OfficeIfNeeded(
            LocationsData.cityMallGiftShopOffice,
          );
          if (!CherieQuest002.isActiveMidFlow(_worldState)) {
            _tryStartCherieQuest005OfficeIfNeeded(
              LocationsData.cityMallGiftShopOffice,
            );
            if (!CherieQuest005.isActiveMidFlow(_worldState)) {
              _tryStartCherieQuest006OfficeIfNeeded(
                LocationsData.cityMallGiftShopOffice,
              );
            }
            if (!CherieQuest005.isActiveMidFlow(_worldState) &&
                !CherieQuest006.isActiveMidFlow(_worldState)) {
              _tryStartCherieQuest004OfficeIfNeeded(
                LocationsData.cityMallGiftShopOffice,
              );
            }
          }
          _tryResumeCherieQuest005OfficeIfNeeded(
            LocationsData.cityMallGiftShopOffice,
          );
          _tryResumeCherieQuest006OfficeIfNeeded(
            LocationsData.cityMallGiftShopOffice,
          );
          _tryResumeCherieQuest004OfficeIfNeeded(
            LocationsData.cityMallGiftShopOffice,
          );
          _tryStartCherieGiftShopOfficeAnimatorQuestIfNeeded(
            LocationsData.cityMallGiftShopOffice,
          );
          _tryStartCherieAnimatorShiftIntroIfNeeded(
            LocationsData.cityMallGiftShopOffice,
          );
        }
      }

      if (isInsideRoom) {
        final room = currentRoom;
        if (room == LocationsData.cityMallGiftShop ||
            room == LocationsData.cityMallGiftShopOffice ||
            room == LocationsData.cityMallGiftShopWarehouse) {
          _selectedNpcIdInRoom = null;
        }
        if (_danielleSpyCaughtUiActive) {
          _clearDanielleSpyCaughtUiOnly();
        }
        _tryStartSashaMorningRunOnStreetOverview();
        _tryStartCherieGiftShopOfficeAnimatorQuestIfNeeded(room);
        _tryStartCherieAnimatorShiftIntroIfNeeded(room);
        _resumeCherieAnimatorIntroIfInProgress(room);
        if (currentZone == 'HOME' &&
            LocationsData.migrateLegacyRoomId(room) == LocationsData.hall) {
          _tryStartMomQuest001HallIfNeeded(room);
          _maybeResumeMomQuest001AfterLoad();
        }
        if (currentZone == 'HOME' &&
            LocationsData.migrateLegacyRoomId(room) == LocationsData.kitchen) {
          _tryStartMomEvent002KitchenIfNeeded(room);
          _maybeResumeMomEvent002AfterLoad(room);
          _ensureMomEvent002KitchenPaymentUiCoherent();
        }
        if (currentZone == 'COLLEGE' &&
            LocationsData.migrateLegacyRoomId(room) == LocationsData.canteen) {
          _tryStartPiperQuest001Step1IfNeeded(room);
          _ensurePiperQuest001LibraryDialogUiCoherent();
        }
        if (currentZone == 'HOME' && isInsideRoom) {
          _tryStartPiperQuest001Step2IfNeeded();
          _tryStartPiperQuest001Step3IfNeeded();
          _ensurePiperQuest001Step3TeacherCallUiCoherent();
          _tryStartPiperQuest001Step5IfNeeded();
          _ensurePiperQuest001Step5PunishmentUiCoherent();
          _ensurePiperQuest001Step6ClosureUiCoherent();
        }
        if (currentZone == 'HOME') {
          _ensurePiperQuest001Step2ApproachUiCoherent();
          _ensurePiperGgVoluntaryPunishUiCoherent();
          _ensurePiperQuest001SnitchAckUiCoherent();
          _tryStartPiperQuest001Step4IfNeeded();
          _ensurePiperQuest001Step4CorridorUiCoherent();
        }
        if (currentZone == 'HOME' && isInsideRoom) {
          _ensurePiperHallWeekendEventUiCoherent();
        }
      }
      _maybeAbortCherieQuest002WrongLocation();
      _maybeAbortCherieQuest003WrongLocation();
      _maybeAbortCherieQuest004WrongLocation();
      _maybeAbortCherieQuest005WrongLocation();
      _maybeAbortCherieQuest006WrongLocation();
      _maybeAbortCherieMassageFunEventWrongLocation();
      _maybeAbortMomQuest001WrongLocation();
      _maybeAbortMomEvent002WrongLocation();
      _ensureCherieQuest002HomeHallUiCoherent();
      _ensureSemJuniperIntroUiCoherent();
      _ensureJuniperManuelKompromatUiCoherent();
      _syncQuestUiArbitration();
      _resetNewsMessageIfOutsideQuestEventContext();
    });
  }
}
