part of '../main_game_screen.dart';

class MainGameScreenState extends MainGameScreenStateBase
    with MomGameFlow, CherieGameFlow, PiperGameFlow, MainGameNpcFinance, MainGameQuestFlows, MainGameTimeTickHandler {
  @override
  void initState() {
    super.initState();
    // Підтягуємо збережений стан світу (локація гг)
    currentZone = _worldState.currentZone;
    final migratedRoom = LocationsData.migrateLegacyRoomId(_worldState.currentRoom);
    if (migratedRoom != _worldState.currentRoom) {
      _worldState.currentRoom = migratedRoom;
    }
    currentRoom = migratedRoom;
    isInsideRoom = _worldState.isInsideRoom;
    currentStreetHouse = _worldState.currentStreetHouse;
    // Кожна зміна часу — перевірка активного екрану (хто в локації)
    _timeController.addListener(_onTimeChanged);
    _nav.addListener(_syncDanielleSpyCaughtUiWithNav);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeRestoreCherieAnimatorIntroStep5AfterLoad();
      if (!mounted) return;
      setState(() {
        _maybeResumeCherieQuest002AfterLoad();
        _maybeResumeCherieQuest003AfterLoad();
        _maybeResumeCherieQuest004AfterLoad();
        _maybeResumeCherieQuest005AfterLoad();
        _maybeResumeCherieQuest006AfterLoad();
        _maybeResumeMomQuest001AfterLoad();
        _maybeResumeMomEvent002AfterLoad(currentRoom);
        _ensureMomEvent002KitchenPaymentUiCoherent();
        _maybeResumePiperQuest001AfterLoad();
        _ensurePiperQuest001LibraryDialogUiCoherent();
        _ensurePiperQuest001Step2ApproachUiCoherent();
        _ensurePiperQuest001SnitchAckUiCoherent();
        _ensurePiperQuest001Step3TeacherCallUiCoherent();
        _tryStartPiperQuest001Step4IfNeeded();
        _ensurePiperQuest001Step4CorridorUiCoherent();
        _ensurePiperQuest001Step5PunishmentUiCoherent();
        _maybeResumePiperHallWeekendEventAfterLoad();
        _ensurePiperHallWeekendEventUiCoherent();
        _maybeResumeCherieMassageFunEventAfterLoad();
        _maybeStartDanielleSpyCaughtAutoInRoom();
        _tryAutoStartSashaHallComunicateVideo();
        _syncSashaHallNewsMessageIfInEvent();
        _tryResumeSashaMorningRunIfInProgress();
        _syncSashaMorningRunNewsMessageIfInEvent();
      });
    });
  }

  @override
  void dispose() {
    _timeController.removeListener(_onTimeChanged);
    _nav.removeListener(_syncDanielleSpyCaughtUiWithNav);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо доступ до контролера скріншотів із нашого сервісу збереження
    final screenshotController = sl<SaveService>().screenshotController;

    return ListenableBuilder(
      listenable: Listenable.merge([_ui, _nav, _playerStats, sl<LocaleController>()]),
      builder: (context, _) {
        return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: GameTheme.screenBg,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ListenableBuilder(
                listenable: _playerStats,
                builder: (context, _) => MainLeftSidebar(
                  playerStats: _playerStats,
                  onNpcGalleryTap: () => setState(() {
                    if (isNpcGalleryOpen) {
                      isNpcGalleryOpen = false;
                      _selectedNpcForProfile = null;
                    } else {
                      isNpcGalleryOpen = true;
                      _selectedNpcForProfile = null;
                      isBackpackOpen = false;
                      isStatsOpen = false;
                      isPhoneOpen = false;
                      _showFlyersVideo = false;
                      _showConstructionVideo = false;
                    }
                  }),
                  onBackpackTap: () => setState(() {
                    isBackpackOpen = !isBackpackOpen;
                    isStatsOpen = false;
                    isNpcGalleryOpen = false;
                    _selectedNpcForProfile = null;
                    isPhoneOpen = false;
                    _showFlyersVideo = false;
                    _showConstructionVideo = false;
                    newsMessage = isBackpackOpen ? 'Рюкзак' : '';
                  }),
                  onPhoneTap: () => setState(() {
                    isPhoneOpen = true;
                    isBackpackOpen = false;
                    isStatsOpen = false;
                    isNpcGalleryOpen = false;
                  }),
                  onSaveTap: () async {
                    setState(() {
                      isBackpackOpen = false;
                      isStatsOpen = false;
                      isNpcGalleryOpen = false;
                      _selectedNpcForProfile = null;
                      isPhoneOpen = false;
                      _showFlyersVideo = false;
                      _showConstructionVideo = false;
                      newsMessage = '';
                    });
                    // Прев’ю для слотів: знімок поки гра не перекрита меню збережень.
                    await sl<SaveService>().capturePreviewForSaveMenu();
                    if (!context.mounted) return;
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (context) => const SaveLoadScreen()),
                    );
                    if (result == true && mounted) setState(() {});
                  },
                  onPersonTap: () => setState(() {
                    isStatsOpen = !isStatsOpen;
                    isBackpackOpen = false;
                    isNpcGalleryOpen = false;
                    _selectedNpcForProfile = null;
                    isPhoneOpen = false;
                    _showFlyersVideo = false;
                    _showConstructionVideo = false;
                    // Щоб не показувати опис ГГ у діалоговому вікні, коли відкриті стати.
                    newsMessage = '';
                  }),
                  onRefresh: () => setState(_dismissNpcGalleryIfOpen),
                  onBeforeSettingsNavigation: () => setState(_dismissNpcGalleryIfOpen),
                  // Знайди у своєму коді обробник натискання на шестерню (onDebugMenuTap)
                  onDebugMenuTap: () {
                    setState(_dismissNpcGalleryIfOpen);
                    // Головне меню — маршрут `/menu` (`/` — лише LoadingScreen).
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/menu', (route) => false);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fullScreenMainPanelOpen = isNpcGalleryOpen ||
                        _selectedNpcForProfile != null ||
                        isBackpackOpen ||
                        isStatsOpen;
                    return Stack(
                      children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 70,
                          child: Container(
                            decoration: BoxDecoration(
                                color: GameTheme.bgDark,
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                MainGameHeader(
                                  timeController: _timeController,
                                  showBackButton: _headerShowsBackButton,
                                  onBack: _handleBackTap,
                                  locationParts: mainGameHeaderLocationParts(
                                    currentZone: currentZone,
                                    currentRoom: currentRoom,
                                    currentStreetHouse: currentStreetHouse,
                                  ),
                                  isNpcGalleryOpen: isNpcGalleryOpen,
                                  isStatsOpen: isStatsOpen,
                                  onNextDayName: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.nextDayName();
                                  }),
                                  onPrevDayName: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.prevDayName();
                                  }),
                                  onAddDay: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.addDay();
                                  }),
                                  onSubDay: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.subDay();
                                  }),
                                  onSubHour: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.subHour();
                                  }),
                                  onSubMinute: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.subMinute();
                                  }),
                                  onAddMinutes5: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.addMinutes(5);
                                  }),
                                  onAddHour: () => setState(() {
                                    _dismissNpcGalleryIfOpen();
                                    _timeController.addHour();
                                  }),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      if (_eventVideoPath == null &&
                                          _eventVideoPendingButton == null &&
                                          (_eventImagePath == null ||
                                              _danielleSpyCaughtUiActive)) ...[
                                        ListenableBuilder(
                                          listenable: _timeController,
                                          builder: (context, _) {
                                            final activeNPCs = _getActiveNPCsInCurrentRoom();
                                            final shouldShowNpcStrip =
                                                CityNpcLocationsUiRules
                                                    .shouldShowNpcAvatarStrip(
                                              roomId: currentRoom,
                                              activeNPCs: activeNPCs,
                                            );
                                            return Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                _buildMainContent(),
                                                if (_danielleSpyCaughtUiActive &&
                                                    !fullScreenMainPanelOpen)
                                                  Positioned.fill(
                                                    child: IgnorePointer(
                                                      child: LayoutBuilder(
                                                        builder: (context, c) {
                                                          final maxH = c.maxHeight;
                                                          final overlayH = maxH.isFinite
                                                              ? maxH *
                                                                  RoomNpcSceneTemplate
                                                                      .npcOverlayHeightFraction
                                                              : 400.0;
                                                          return Align(
                                                            alignment:
                                                                Alignment.bottomCenter,
                                                            child: SizedBox(
                                                              height: overlayH,
                                                              width: double.infinity,
                                                              child: Image.asset(
                                                                DanielleSpyCaughtQuest
                                                                    .imagePath,
                                                                fit: BoxFit.contain,
                                                                alignment: Alignment
                                                                    .bottomCenter,
                                                                errorBuilder: (ctx, _,
                                                                    __) {
                                                                  return Center(
                                                                    child: Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(12),
                                                                      child: Text(
                                                                        sl<LocaleController>()
                                                                            .t(
                                                                              'asset_load_failed_short',
                                                                            )
                                                                            .replaceAll(
                                                                              '%s',
                                                                              DanielleSpyCaughtQuest
                                                                                  .imagePath,
                                                                            ),
                                                                        textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                        style:
                                                                            const TextStyle(
                                                                          color: Colors
                                                                              .white70,
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                // Ліва смуга вибору NPC — 2+ персонажі; магазин подарунків ТРЦ: тільки хто в кімнаті,
                                                // але без авто-підсвітки (щоб вибрав гравець).
                                                if (isInsideRoom &&
                                                    !fullScreenMainPanelOpen &&
                                                    shouldShowNpcStrip &&
                                                    !_danielleSpyCaughtUiActive)
                                                  Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    bottom: 0,
                                                    child: MainGameNpcAvatarStrip(
                                                      activeNPCs: activeNPCs,
                                                      selectedNpcIdInRoom: _selectedNpcIdInRoom,
                                                      currentZone: currentZone,
                                                      currentRoom: currentRoom,
                                                      selectionAutoSelectEnabled: CityNpcLocationsUiRules
                                                          .shouldAutoSelectNpcInAvatarStrip(
                                                        currentRoom,
                                                      ),
                                                      onNpcTap: (npc) => setState(
                                                        () => _handleRoomNpcTap(npc),
                                                      ),
                                                    ),
                                                  ),
                                                if (_showMasturbateVideo &&
                                                    !isLaptopOpen &&
                                                    !fullScreenMainPanelOpen) ...[
                                                  Positioned.fill(
                                                    child: Container(color: Colors.black54),
                                                  ),
                                                  Positioned.fill(
                                                    child: MasturbateVideoOverlay(
                                                      videoPath: 'lib/assets/gg/ups_first_1.webm',
                                                      closeWhenCompleted: true,
                                                      onClose: () => setState(() => _showMasturbateVideo = false),
                                                    ),
                                                  ),
                                                ],
                                                if (_friendHouseStreetFacade &&
                                                    _semSummonedAtFriendFacade &&
                                                    currentZone == 'STREET' &&
                                                    currentStreetHouse == null &&
                                                    !isInsideRoom &&
                                                    !fullScreenMainPanelOpen)
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Align(
                                                      alignment: Alignment.bottomCenter,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius.vertical(
                                                            top: Radius.circular(8),
                                                          ),
                                                          child: Image.asset(
                                                            kSemAvatarPath,
                                                            alignment: Alignment.bottomCenter,
                                                            fit: BoxFit.contain,
                                                            height: 423,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ] else ...[
                                        EventInteractionOverlay(
                                          eventVideoPath: _eventVideoPath,
                                          eventVideoMuted: _eventVideoMuted,
                                          eventVideoFullScreen: _eventVideoFullScreen,
                                          eventVideoCloseWhenCompleted: _eventVideoCloseWhenCompleted,
                                          eventVideoLoop: _eventVideoLoop ||
                                              (_spyOnSemParentsUiActive &&
                                                  (_spyParentsPhase ==
                                                          DanielleSpyParentsPhase
                                                              .watchVideo1 ||
                                                      _spyParentsPhase ==
                                                          DanielleSpyParentsPhase
                                                              .watchVideo2 ||
                                                      _spyParentsPhase ==
                                                          DanielleSpyParentsPhase
                                                              .watchVideo3)) ||
                                              _sashaMorningRunUiActive ||
                                              (_sashaComunicateInHallUiActive &&
                                                  (_sashaComunicatePhase ==
                                                          ComunicateSashaInHallPhase
                                                              .videoAndTalk ||
                                                      _sashaComunicatePhase ==
                                                          ComunicateSashaInHallPhase
                                                              .moneyChoice)),
                                          eventVideoOnComplete: () => _eventVideoOnComplete?.call(),
                                          eventVideoPendingButton: _eventVideoPendingButton,
                                          eventVideoOnButtonPressed: () {
                                            _eventVideoOnButtonPressed?.call();
                                            setState(() {
                                              _eventVideoPendingButton = null;
                                              _eventVideoOnButtonPressed = null;
                                            });
                                          },
                                          eventImagePath: _eventImagePath,
                                        ),
                                      ],
                                      if (fullScreenMainPanelOpen)
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: ColoredBox(
                                              color: GameTheme.bgDark,
                                              child: _buildFullScreenMainPanelOverlay(),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 27,
                          child: ListenableBuilder(
                            listenable: Listenable.merge([
                              _timeController,
                              _ui,
                              _playerStats,
                            ]),
                            builder: (context, _) {
                              if (_showMomOfficeView) {
                                final isImageOrVideo12 = _momOfficeVideoIndex == null ||
                                    _momOfficeVideoIndex == 1 ||
                                    _momOfficeVideoIndex == 2;
                                return GameDialogPanel(
                                  message: 'Кабінет мами',
                                  navButtons: isImageOrVideo12
                                      ? [_buildMomOfficeNavButtons()]
                                      : [
                                          _navBtn('Назад', () => setState(() => _showMomOfficeView = false)),
                                        ],
                                );
                              }
                              if (_showRockefellerReceptionView) {
                                return GameDialogPanel(
                                  message: newsMessage.isNotEmpty
                                      ? newsMessage
                                      : sl<LocaleController>()
                                          .t('rockefeller_reception_news'),
                                  navButtons: [_buildRockefellerReceptionNavButtons()],
                                );
                              }
                              if (_showRockefellerCabinetView) {
                                return GameDialogPanel(
                                  message: newsMessage.isNotEmpty
                                      ? newsMessage
                                      : 'Rockefeller Group',
                                  navButtons: [_buildRockefellerCabinetNavButtons()],
                                );
                              }
                              if (_showLogisticsOfficeVideo) {
                                if (_approachedSecretary) {
                                  final npcService = sl<NPCService>();
                                  final ludaList = npcService.allNPCs.where((n) => n.id == 'luda').toList();
                                  final luda = ludaList.isEmpty ? null : ludaList.first;
                                  final hour = _timeController.dateTime.hour;
                                  return GameDialogPanel(
                                    message: 'Офіс',
                                    navButtons: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (luda != null)
                                            NpcInteractionButtons(
                                              key: ValueKey(luda.id),
                                              npc: luda,
                                              location: LocationsData.cityBcLogistics,
                                              hour: hour,
                                              onUpdate: () => setState(_dismissNpcGalleryIfOpen),
                                              onActionExecuted: (label, npc) =>
                                                  _handleNpcActionExecuted(label, npc),
                                              onFinanceGiveMoney: () => _npcFinanceGiveMoney(luda),
                                              onFinanceAskLoan: () => _npcFinanceAskLoan(luda),
                                              onFinanceGiveLoan: () => _npcFinanceGiveLoan(luda),
                                              onFinanceRepayGgDebt:
                                                  NpcFinanceService.ggOwesNpc(_worldState, luda.id) > 0
                                                      ? () => _npcFinanceRepayGgDebt(luda)
                                                      : null,
                                              onFinanceAskAboutDebt: NpcFinanceService.showAskAboutDebtButton(
                                                _worldState,
                                                luda.id,
                                              )
                                                  ? () => _npcFinanceAskAboutDebt(luda)
                                                  : null,
                                              onFinanceOfferAlternatives:
                                                  NpcFinanceService.showOfferAlternativesButton(
                                                w: _worldState,
                                                npcId: luda.id,
                                                gender: luda.gender,
                                                gameNow: _timeController.dateTime,
                                              )
                                                  ? () => _npcFinanceOfferAlternatives(luda)
                                                  : null,
                                            ),
                                          if (luda != null) const SizedBox(height: 8),
                                          _navBtn('Назад', () => setState(() => _approachedSecretary = false)),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return GameDialogPanel(
                                  message: 'Офіс',
                                  navButtons: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _navBtn('Піти в кабінет мами', () {
                                          setState(() {
                                            _showLogisticsOfficeVideo = false;
                                            _approachedSecretary = false;
                                            final npcService = sl<NPCService>();
                                            final momList = npcService.allNPCs.where((n) => n.id == 'mom').toList();
                                            final NPCModel? mom = momList.isEmpty ? null : momList.first;
                                            final hour = _timeController.dateTime.hour;
                                            final day = _timeController.weekdayIndex;
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
                                          });
                                        }),
                                        const SizedBox(height: 8),
                                        _navBtn('Підійти до секретарки', () => setState(() => _approachedSecretary = true)),
                                        const SizedBox(height: 8),
                                        _navBtn('Назад', () => setState(() {
                                          _showLogisticsOfficeVideo = false;
                                          _approachedSecretary = false;
                                        })),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              if (_isCherieMassageFunEventScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isCherieQuest002ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isCherieQuest003ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isCherieQuest004ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isCherieQuest005ScriptedDialogActive()) {
                                final tQ5 = sl<LocaleController>().t;
                                return GameDialogPanel(
                                  message: newsMessage,
                                  messageRedWarning:
                                      _worldState.cherieQuest005Step == 5
                                          ? tQ5(
                                              'cherie_quest_005_step4_1_warning',
                                            )
                                          : null,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isCherieQuest006ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isMomQuest001ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isPiperQuest001SnitchAckScene()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const ['Piper', 'Пайпер'],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isMomEvent002ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isPiperQuest001ScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const ['Piper', 'Пайпер'],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_isPiperHallWeekendEventScriptedDialogActive()) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const ['Piper', 'Пайпер'],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_danielleSpyCaughtUiActive) {
                                final tCaught = sl<LocaleController>().t;
                                return GameDialogPanel(
                                  message: tCaught(
                                    DanielleSpyCaughtQuest.dialogueL10nKey(
                                      _worldState,
                                    ),
                                  ),
                                  highlightNames: const [],
                                  navButtons: [
                                    _navBtn(
                                      tCaught('danielle_spy_caught_confirm'),
                                      _finishDanielleSpyCaughtQuest,
                                    ),
                                  ],
                                );
                              }
                              if (_spyOnSemParentsUiActive) {
                                final tSpy = sl<LocaleController>().t;
                                final st = _playerStats.player.stealth_mode;
                                switch (_spyParentsPhase) {
                                  case DanielleSpyParentsPhase.door:
                                    final canPeekDoor =
                                        st >=
                                            DanielleSpyParentsQuest.peek2MinStealth;
                                    return GameDialogPanel(
                                      message: tSpy('danielle_spy_parents_dialogue'),
                                      highlightNames: const [],
                                      navButtons: [
                                        if (canPeekDoor) ...[
                                          _navBtn(
                                            tSpy('danielle_spy_parents_peek'),
                                            () => setState(
                                              () => _applyDanielleSpyWatchTier(1),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        _navBtn(
                                          tSpy('danielle_spy_parents_leave'),
                                          _finishSpyOnSemParentsToCorridor,
                                        ),
                                      ],
                                    );
                                  case DanielleSpyParentsPhase.watchVideo1:
                                    final canMore =
                                        st >=
                                            DanielleSpyParentsQuest.peek3MinStealth;
                                    return GameDialogPanel(
                                      message: tSpy(
                                        DanielleSpyParentsQuest
                                            .afterPeekDialogueKeyForTier(1),
                                      ),
                                      highlightNames: const [],
                                      navButtons: [
                                        if (canMore) ...[
                                          _navBtn(
                                            tSpy('danielle_spy_parents_watch_more'),
                                            _danielleSpyWatchMoreAfterVideo1,
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        _navBtn(
                                          tSpy('danielle_spy_parents_leave'),
                                          _finishSpyOnSemParentsToCorridor,
                                        ),
                                      ],
                                    );
                                  case DanielleSpyParentsPhase.watchVideo2:
                                    return GameDialogPanel(
                                      message: tSpy(
                                        DanielleSpyParentsQuest
                                            .afterPeekDialogueKeyForTier(2),
                                      ),
                                      highlightNames: const [],
                                      navButtons: [
                                        _navBtn(
                                          tSpy('danielle_spy_parents_watch_more'),
                                          _danielleSpyWatchMoreAfterVideo2,
                                        ),
                                        const SizedBox(height: 8),
                                        _navBtn(
                                          tSpy('danielle_spy_parents_leave'),
                                          _finishSpyOnSemParentsToCorridor,
                                        ),
                                      ],
                                    );
                                  case DanielleSpyParentsPhase.watchVideo3:
                                    return GameDialogPanel(
                                      message: tSpy(
                                        DanielleSpyParentsQuest
                                            .afterPeekDialogueKeyForTier(3),
                                      ),
                                      highlightNames: const [],
                                      navButtons: [
                                        _navBtn(
                                          tSpy('danielle_spy_parents_leave'),
                                          _finishSpyOnSemParentsToCorridor,
                                        ),
                                      ],
                                    );
                                }
                              }
                              if (_worldState.cherieAnimatorIntroStep >= 1 &&
                                  _worldState.cherieAnimatorIntroStep <= 4 &&
                                  !CherieQuest003.isActiveMidFlow(_worldState) &&
                                  !CherieQuest004.isActiveMidFlow(_worldState) &&
                                  !CherieQuest005.isActiveMidFlow(_worldState) &&
                                  !CherieQuest006.isActiveMidFlow(_worldState) &&
                                  currentZone == 'CITY' &&
                                  isInsideRoom &&
                                  LocationsData.migrateLegacyRoomId(currentRoom) ==
                                      LocationsData.cityMallGiftShopOffice) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              if (_ui.cherieAnimatorShiftTc2DialogPending) {
                                return GameDialogPanel(
                                  message: newsMessage,
                                  highlightNames: const [],
                                  navButtons: [_buildActionPanel()],
                                );
                              }
                              final showFlyersOffer = currentZone == "CITY" &&
                                  currentRoom == LocationsData.cityOverview &&
                                  _worldState.flyersJobOfferPending;
                              final showConstructionOffer = currentZone == "CITY" &&
                                  currentRoom == LocationsData.cityOverview &&
                                  _worldState.constructionJobOfferPending;
                              final showCallCenterOffer = currentZone == "CITY" &&
                                  currentRoom == LocationsData.cityBcCallCenterOperatorsHall &&
                                  _worldState.callCenterJobOfferPending;
                              final showGiftShopAnimatorOffer = currentZone == "CITY" &&
                                  isInsideRoom &&
                                  LocationsData.migrateLegacyRoomId(currentRoom) ==
                                      LocationsData.cityMallGiftShopOffice &&
                                  _worldState.giftShopAnimatorJobOfferPending &&
                                  !_isCherieQuest002ScriptedDialogActive() &&
                                  !_isCherieQuest003ScriptedDialogActive() &&
                                  !_isCherieQuest004ScriptedDialogActive() &&
                                  !_isCherieQuest005ScriptedDialogActive() &&
                                  !_isCherieQuest006ScriptedDialogActive();
                              final dt = _timeController.dateTime;
                              final inJobTimeWindow = dt.hour >= 8 &&
                                  dt.hour < 13 &&
                                  _timeController.weekdayIndex <= 4;
                              final todayKey = '${dt.year}-${dt.month}-${dt.day}';
                              final canDoFlyersToday = _worldState.lastFlyersDateKey != todayKey;
                              final canDoConstructionToday = _worldState.lastConstructionDateKey != todayKey;
                              final canDoCallCenterToday = _worldState.lastCallCenterDateKey != todayKey;
                              final flyersMessage = showFlyersOffer ? sl<LocaleController>().t('flyers_offer_message') : null;
                              final constructionMessage = showConstructionOffer ? sl<LocaleController>().t('construction_offer_message') : null;
                              final callCenterMessage = showCallCenterOffer ? sl<LocaleController>().t('call_center_offer_message') : null;
                              final giftShopAnimatorMessage = showGiftShopAnimatorOffer
                                  ? sl<LocaleController>().t('gift_shop_job_offer_message')
                                  : null;
                              final messages = [
                                if (giftShopAnimatorMessage != null) giftShopAnimatorMessage,
                                if (flyersMessage != null) flyersMessage,
                                if (constructionMessage != null) constructionMessage,
                                if (callCenterMessage != null) callCenterMessage,
                              ];
                              var combinedMessage = messages.isNotEmpty
                                  ? messages.join(' ')
                                  : (_isQuestOrEventScriptedDialogForNews()
                                      ? newsMessage
                                      : (_selectedNpcIdInRoom != null
                                          ? ''
                                          : newsMessage));
                              List<String> dialogueHighlightNames;
                              final locPanel = sl<LocaleController>();
                              if (messages.isEmpty) {
                                NPCModel? selNpc;
                                final sid = _selectedNpcIdInRoom;
                                if (sid != null) {
                                  try {
                                    selNpc = sl<NPCService>().allNPCs.firstWhere((n) => n.id == sid);
                                  } catch (_) {
                                    selNpc = null;
                                  }
                                }
                                if (selNpc == null &&
                                    currentZone == 'HOME' &&
                                    isInsideRoom &&
                                    LocationsData.migrateLegacyRoomId(currentRoom) ==
                                        LocationsData.kitchen &&
                                    dt.hour == 7) {
                                  final npcService = sl<NPCService>();
                                  final mom = npcService.npcById('mom');
                                  if (mom != null &&
                                      npcService.getCurrentLocationId(
                                            mom,
                                            dt.hour,
                                            _timeController.weekdayIndex,
                                          ) ==
                                          LocationsData.kitchen) {
                                    selNpc = mom;
                                  }
                                }
                                final maxA = _playerStats.player.maxArousal;
                                final sn = selNpc;
                                final stojakHere = sn != null &&
                                    GgEvent001Stojak.stojakDialogApplies(
                                      sn,
                                      _playerStats.arousal,
                                      maxA,
                                    );
                                if (stojakHere) {
                                  combinedMessage = locPanel.t('gg_event_001_stojak_body');
                                  dialogueHighlightNames = const [];
                                } else {
                                  combinedMessage =
                                      _messageWithSelectedNpcStripLine(combinedMessage);
                                  dialogueHighlightNames = _dialogueHighlightNames(
                                    dt.hour,
                                    _timeController.weekdayIndex,
                                  );
                                }
                              } else {
                                dialogueHighlightNames = const [];
                              }
                              // Дві окремі кнопки: флаєри та будівництво (коли обидві вакансії прийняті — обидві кнопки в місті).
                              final List<Widget> jobButtons = [];
                              if (showFlyersOffer && inJobTimeWindow && canDoFlyersToday) {
                                if (jobButtons.isNotEmpty) jobButtons.add(const SizedBox(height: 8));
                                jobButtons.add(
                                  FractionallySizedBox(
                                    widthFactor: 0.4,
                                    alignment: Alignment.centerLeft,
                                    child: _buildFlyersButton(),
                                  ),
                                );
                              }
                              if (showConstructionOffer && inJobTimeWindow && canDoConstructionToday) {
                                if (jobButtons.isNotEmpty) jobButtons.add(const SizedBox(height: 8));
                                jobButtons.add(
                                  FractionallySizedBox(
                                    widthFactor: 0.4,
                                    alignment: Alignment.centerLeft,
                                    child: _buildConstructionButton(),
                                  ),
                                );
                              }
                              if (showCallCenterOffer && inJobTimeWindow && canDoCallCenterToday) {
                                if (jobButtons.isNotEmpty) jobButtons.add(const SizedBox(height: 8));
                                jobButtons.add(
                                  FractionallySizedBox(
                                    widthFactor: 0.4,
                                    alignment: Alignment.centerLeft,
                                    child: _buildCallCenterButton(),
                                  ),
                                );
                              }
                              final galleryOrProfileOpen =
                                  isNpcGalleryOpen || _selectedNpcForProfile != null;
                              Widget? panelMessageTrailing;
                              if (!galleryOrProfileOpen) {
                                if (jobButtons.isNotEmpty) {
                                  panelMessageTrailing = Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: jobButtons,
                                  );
                                }
                              }
                              return GameDialogPanel(
                                message: combinedMessage,
                                highlightNames: dialogueHighlightNames,
                                messageTrailing: panelMessageTrailing,
                                navButtons: galleryOrProfileOpen
                                    ? const <Widget>[]
                                    : [_buildActionPanel()],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    if (isPhoneOpen) ...[
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => isPhoneOpen = false),
                          child: Container(color: Colors.black54),
                        ),
                      ),
                      Center(
                        child: ListenableBuilder(
                          listenable: _timeController,
                          builder: (context, _) => PhoneView(
                            onClose: () => setState(() => isPhoneOpen = false),
                            timeController: _timeController,
                          ),
                        ),
                      ),
                    ],
                    if (_showFlyersVideo) ...[
                      FlyersVideoOverlay(
                        maxWidth: constraints.maxWidth * 0.6,
                        maxHeight: constraints.maxHeight * 0.6,
                        onClose: () {
                          final dt = _timeController.dateTime;
                          _timeController.addMinutes(180);
                          _playerStats.changeMoney(50);
                          _playerStats.changeEnergy(-20);
                          _worldState.lastFlyersDateKey = '${dt.year}-${dt.month}-${dt.day}';
                          _saveService.autosave();
                          setState(() => _showFlyersVideo = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(sl<LocaleController>().t('flyers_done')),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    if (_showConstructionVideo) ...[
                      ConstructionVideoOverlay(
                        maxWidth: constraints.maxWidth * 0.6,
                        maxHeight: constraints.maxHeight * 0.6,
                        onClose: () {
                          final dt = _timeController.dateTime;
                          _timeController.addMinutes(180);
                          _playerStats.changeMoney(80);
                          _playerStats.changeEnergy(-40);
                          _worldState.lastConstructionDateKey = '${dt.year}-${dt.month}-${dt.day}';
                          _saveService.autosave();
                          setState(() => _showConstructionVideo = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(sl<LocaleController>().t('construction_done')),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    if (_isExhausted) ...[
                      ExhaustionDialogOverlay(
                        onGoHome: _goHomeToRoomGgFromExhaustion,
                      ),
                    ],
                  ],
                );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
      }
    );
  }
}
