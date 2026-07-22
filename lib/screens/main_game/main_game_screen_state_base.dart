part of '../main_game_screen.dart';

abstract class MainGameScreenStateBase extends State<MainGameScreen> {
  /// Енергія для зміни аніматором (офіс ТРЦ), квест Чері.
  static const int kGiftShopAnimatorEnergyCost = 40;

  // 1. Отримай доступ до сервісу
  final _saveService = sl<SaveService>();
  final InventoryController _inventory = sl<InventoryController>();
  final GameTimeController _timeController = sl<GameTimeController>();
  final PlayerStatsController _playerStats = sl<PlayerStatsController>();
  final GameWorldState _worldState = sl<GameWorldState>();
  final QuestRuntime _questRuntime = sl<QuestRuntime>();
  final QuestStateRepository _questStateRepository = sl<QuestStateRepository>();
  final SashaEventRuntime _sashaEventRuntime = sl<SashaEventRuntime>();


  GameUiStateController get _ui => sl<GameUiStateController>();
  GameNavigationController get _nav => sl<GameNavigationController>();

  String get currentZone => _nav.currentZone;
  String get currentRoom => _nav.currentRoom;
  bool get isInsideRoom => _nav.isInsideRoom;
  String? get currentStreetHouse => _nav.currentStreetHouse;
  set currentStreetHouse(String? v) => _nav.setCurrentStreetHouse(v);
  set currentRoom(String v) => _nav.setZoneAndRoom(_nav.currentZone, v);
  set currentZone(String v) => _nav.setZoneAndRoom(v, _nav.currentRoom);
  set isInsideRoom(bool v) => _nav.setIsInsideRoom(v);

  bool get isBackpackOpen => _ui.isBackpackOpen;
  set isBackpackOpen(bool v) => _ui.setBackpackOpen(v);

  bool get isStatsOpen => _ui.isStatsOpen;
  set isStatsOpen(bool v) => _ui.setStatsOpen(v);

  bool get isNpcGalleryOpen => _ui.isNpcGalleryOpen;
  set isNpcGalleryOpen(bool v) => _ui.setNpcGalleryOpen(v);

  NPCModel? get _selectedNpcForProfile => _ui.selectedNpcForProfile;
  set _selectedNpcForProfile(NPCModel? v) => _ui.setSelectedNpcForProfile(v);

  String? get _selectedNpcIdInRoom => _ui.selectedNpcIdInRoom;
  set _selectedNpcIdInRoom(String? v) => _ui.setSelectedNpcIdInRoom(v);

  bool get isPhoneOpen => _ui.isPhoneOpen;
  set isPhoneOpen(bool v) => _ui.setPhoneOpen(v);

  bool get isLaptopOpen => _ui.isLaptopOpen;
  set isLaptopOpen(bool v) => _ui.setLaptopOpen(v);

  bool get _isWatchingPornInLaptop => _ui.isWatchingPornInLaptop;
  set _isWatchingPornInLaptop(bool v) => _ui.setWatchingPornInLaptop(v);

  bool get _showMasturbateVideo => _ui.showMasturbateVideo;
  set _showMasturbateVideo(bool v) => _ui.setShowMasturbateVideo(v);

  String get _masturbateVideoPath => _ui.effectiveMasturbateVideoPath;
  set _masturbateVideoPath(String? v) => _ui.setMasturbateVideoPath(v);

  bool get _isWatchingElsaVideoInLaptop => _ui.isWatchingElsaVideoInLaptop;
  set _isWatchingElsaVideoInLaptop(bool v) => _ui.setWatchingElsaVideoInLaptop(v);

  bool get _showFlyersVideo => _ui.showFlyersVideo;
  set _showFlyersVideo(bool v) => _ui.setShowFlyersVideo(v);

  bool get _showConstructionVideo => _ui.showConstructionVideo;
  set _showConstructionVideo(bool v) => _ui.setShowConstructionVideo(v);

  bool get _showLogisticsOfficeVideo => _ui.showLogisticsOfficeVideo;
  set _showLogisticsOfficeVideo(bool v) => _ui.setShowLogisticsOfficeVideo(v);

  bool get _approachedSecretary => _ui.approachedSecretary;
  set _approachedSecretary(bool v) => _ui.setApproachedSecretary(v);

  bool get _showMomOfficeView => _ui.showMomOfficeView;
  set _showMomOfficeView(bool v) => _ui.setShowMomOfficeView(v);

  bool get _showRockefellerCabinetView => _ui.showRockefellerCabinetView;
  set _showRockefellerCabinetView(bool v) =>
      _ui.setShowRockefellerCabinetView(v);

  bool get _showRockefellerReceptionView => _ui.showRockefellerReceptionView;
  set _showRockefellerReceptionView(bool v) =>
      _ui.setShowRockefellerReceptionView(v);

  int? get _momOfficeVideoIndex => _ui.momOfficeVideoIndex;
  set _momOfficeVideoIndex(int? v) => _ui.setMomOfficeVideoIndex(v);

  bool get _momOfficeUseButtonImage => _ui.momOfficeUseButtonImage;
  set _momOfficeUseButtonImage(bool v) => _ui.setMomOfficeUseButtonImage(v);

  String get newsMessage => _ui.newsMessage;
  set newsMessage(String v) => _ui.setNewsMessage(v);

  bool get _isExhausted => _ui.isExhausted;
  set _isExhausted(bool v) => _ui.setIsExhausted(v);

  String? get _eventVideoPath => _ui.eventVideoPath;
  set _eventVideoPath(String? v) => _ui.setEventVideoPath(v);

  /// Відео intro Juniper — у [StreetView] через [VideoSceneWidget], не тут.
  String? get _overlayEventVideoPath {
    final path = _eventVideoPath;
    if (path == null) return null;
    if (InRoomVideoPlayback.ownsKnownEventVideoPath(path)) return null;
    return path;
  }

  VoidCallback? get _eventVideoOnComplete => _ui.eventVideoOnComplete;
  set _eventVideoOnComplete(VoidCallback? v) => _ui.setEventVideoOnComplete(v);
  String? get _eventVideoPendingButton => _ui.eventVideoPendingButton;
  set _eventVideoPendingButton(String? v) => _ui.setEventVideoPendingButtonOnly(v);
  VoidCallback? get _eventVideoOnButtonPressed => _ui.eventVideoOnButtonPressed;
  set _eventVideoOnButtonPressed(VoidCallback? v) => _ui.setEventVideoOnButtonPressedOnly(v);
  String? get _eventImagePath => _ui.eventImagePath;
  bool get _eventVideoMuted => _ui.eventVideoMuted;
  set _eventVideoMuted(bool v) => _ui.setEventVideoMuted(v);
  bool get _eventVideoFullScreen => _ui.eventVideoFullScreen;
  set _eventVideoFullScreen(bool v) => _ui.setEventVideoFullScreen(v);
  bool get _eventVideoCloseWhenCompleted => _ui.eventVideoCloseWhenCompleted;
  set _eventVideoCloseWhenCompleted(bool v) => _ui.setEventVideoCloseWhenCompleted(v);
  bool get _eventVideoLoop => _ui.eventVideoLoop;
  set _eventVideoLoop(bool v) => _ui.setEventVideoLoop(v);
  Duration? get _eventVideoMinWatchDuration => _ui.eventVideoMinWatchDuration;
  set _eventVideoMinWatchDuration(Duration? v) =>
      _ui.setEventVideoMinWatchDuration(v);
  VoidCallback? get _eventVideoOnMinWatchReached =>
      _ui.eventVideoOnMinWatchReached;
  set _eventVideoOnMinWatchReached(VoidCallback? v) =>
      _ui.setEventVideoOnMinWatchReached(v);
  double get _eventVideoPlaybackRate => _ui.eventVideoPlaybackRate;
  set _eventVideoPlaybackRate(double v) => _ui.setEventVideoPlaybackRate(v);

  DenIntroUiPhase get _denIntroUiPhase => _ui.denIntroUiPhase;
  set _denIntroUiPhase(DenIntroUiPhase v) => _ui.setDenIntroUiPhase(v);

  bool get _denStage2InProgress => _ui.denStage2InProgress;
  set _denStage2InProgress(bool v) => _ui.setDenStage2InProgress(v);

  DenSecondUiPhase get _denSecondUiPhase => _ui.denSecondUiPhase;
  set _denSecondUiPhase(DenSecondUiPhase v) => _ui.setDenSecondUiPhase(v);

  DenThirdUiPhase get _denThirdUiPhase => _ui.denThirdUiPhase;
  set _denThirdUiPhase(DenThirdUiPhase v) => _ui.setDenThirdUiPhase(v);

  DenAfterUiPhase get _denAfterUiPhase => _ui.denAfterUiPhase;
  set _denAfterUiPhase(DenAfterUiPhase v) => _ui.setDenAfterUiPhase(v);

  static const String momOfficeFallbackImagePath =
      'lib/assets/npcs/mom/mom_work_place.jpg';
  static const String _momOfficeImagePath = momOfficeFallbackImagePath;
  static const String _momOfficeButtonImagePath = 'lib/assets/location/biznes_centr/logistic/cab_mom.jpg';
  static const List<String> _momOfficeVideoPaths = [
    'lib/assets/npcs/mom/video/work_01.mp4',
    'lib/assets/npcs/mom/video/work_02.mp4',
    'lib/assets/npcs/mom/video/work_03.mp4',
  ];

  bool _isMomAtLogisticsOfficeNow() {
    final mom = sl<NPCService>().npcById('mom');
    if (mom == null) return false;
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    return sl<NPCService>().getCurrentLocationId(mom, hour, day) ==
        LocationsData.cityBcLogisticsMomOffice;
  }

  /// Кабінет мами: якщо мама на роботі — завжди одне з work_01…03; інакше статичний кадр.
  void _syncMomOfficeViewState({bool pickNewVideoIfMissing = true}) {
    final isMomAtWork = _isMomAtLogisticsOfficeNow();
    _momOfficeUseButtonImage = !isMomAtWork;
    if (isMomAtWork) {
      if (pickNewVideoIfMissing || _momOfficeVideoIndex == null) {
        _momOfficeVideoIndex = Random().nextInt(_momOfficeVideoPaths.length) + 1;
      }
    } else {
      _momOfficeVideoIndex = null;
    }
  }

  void _openMomOfficeViewForCurrentTime() {
    _showLogisticsOfficeVideo = false;
    _approachedSecretary = false;
    _syncMomOfficeViewState();
    _showMomOfficeView = true;
  }

  /// Вихід з кабінету мами: назад до приймальні (якщо Luda на роботі) або холу логістики.
  void _exitMomOfficeView() {
    _showMomOfficeView = false;
    final luda = sl<NPCService>().npcById('luda');
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final isLudaAtWork = luda != null &&
        sl<NPCService>().getCurrentLocationId(luda, hour, day) ==
            LocationsData.cityBcLogistics;
    if (isLudaAtWork) {
      _showLogisticsOfficeVideo = true;
      _approachedSecretary = false;
    } else {
      _showLogisticsOfficeVideo = false;
      _approachedSecretary = false;
    }
  }

  bool _isMomOfficeKompromatVideoActive() {
    final index = _momOfficeVideoIndex;
    if (index == null) return false;
    if (index == 3) return true;
    return _momOfficeVideoPaths[index - 1].contains('work_03');
  }

  bool _isMomOfficeCompromatAlreadySaved() =>
      _worldState.hasMomOfficeCompromatVideo3;

  bool _saveMomOfficeCompromatFromVideo3() {
    if (_isMomOfficeCompromatAlreadySaved()) {
      return false;
    }
    if (_inventory.count('usb_empty') > 0) {
      _inventory.removeItem('usb_empty');
      _inventory.addItem(GameItems.usbCompromat);
    }
    _worldState.hasMomOfficeCompromatVideo3 = true;
    if (!_worldState.compromatNpcIds.contains('mom')) {
      _worldState.compromatNpcIds.add('mom');
    }
    _saveService.autosave();
    return true;
  }

  /// Вхід у «Офіс мами»: спочатку приймальня / секретарка Luda (якщо на роботі), потім кабінет.
  void _enterLogisticsMomOfficeFlow() {
    final luda = sl<NPCService>().npcById('luda');
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    final isLudaAtWork = luda != null &&
        sl<NPCService>().getCurrentLocationId(luda, hour, day) ==
            LocationsData.cityBcLogistics;
    if (isLudaAtWork) {
      _showMomOfficeView = false;
      _approachedSecretary = false;
      _showLogisticsOfficeVideo = true;
    } else {
      _openMomOfficeViewForCurrentTime();
    }
  }

  bool _friendHouseStreetFacade = false;
  /// Sem показано біля дверей після успішного «Позвати Сема» на цьому фасаді.
  bool _semSummonedAtFriendFacade = false;
  /// Відкритий діалог «Поговорити» з Sem біля дверей (у меню лише «Піти»).
  bool _semTalkSubmenuActive = false;
  /// Івент «Розмова про батьків»: діалог + лише «Піти» до виходу на вул. Шевченка.
  bool _semParentsTalkActive = false;

  /// sem_quest_001: діалог «про дівчат» на фасаді.
  bool _semGirlsTalkActive = false;
  /// sem_quest_001: підрозділ «про сестру» під час розмови «про дівчат».
  bool _semGirlsSisterTalkActive = false;
  /// sem_quest_001: підрозділ «натякнути шукати дівчину».
  bool _semGirlsHintTalkActive = false;
  bool _juniperPalivoApologyTalkActive = false;
  bool _juniperQuest002Step1UiActive = false;

  /// QUEST: juniper_quest_003 — «Вздрочнути і піти» у гостиній Sem.
  bool _juniperQuest003UiActive = false;
  int _juniperQuest003PlaybackTick = 0;
  String? _juniperQuest003VideoPath;
  bool _juniperQuest003HallUiActive = false;
  int _juniperQuest003HallPlaybackTick = 0;
  String? _juniperQuest003HallVideoPath;

  /// sem_quest_001: follow-up «ну шо, знайшов когось?» на фасаді.
  bool _semGirlsFollowUpActive = false;

  void _resetSemTalkFlowUi({bool clearSummoned = true}) {
    _semTalkSubmenuActive = false;
    _semGirlsTalkActive = false;
    _semGirlsSisterTalkActive = false;
    _semGirlsHintTalkActive = false;
    _semGirlsFollowUpActive = false;
    _semParentsTalkActive = false;
    if (clearSummoned) _semSummonedAtFriendFacade = false;
  }

  /// sem_quest_001: сцена знайомства з Juniper у кімнаті Sem.
  bool _semJuniperIntroUiActive = false;
  bool _semJuniperIntroSkippedPath = false;

  /// sem_quest_001: вечірній кліп Juniper у кімнаті (кожен вхід / перемотка часу).
  bool _semJuniperEveningClipShowOnThisVisit = false;
  int _juniperEveningClipPlaybackTick = 0;
  String? _juniperEveningClipVideoPath;

  /// sem_quest_001: сцена душу Juniper (3 відео, кнопки «Продовжити» / «Піти»).
  bool _juniperShowerUiActive = false;
  int _juniperShowerTier = 1;
  int _juniperShowerSetIndex = 0;
  int _juniperShowerPlaybackTick = 0;
  /// Відео душу Juniper — у [StreetView] через [VideoSceneWidget], не EventInteractionOverlay.
  String? _juniperShowerVideoPath;

  /// sem_quest_001: 4 відео у кімнаті Sem (суб 12:00 / нд 16:00).
  bool _juniperSemRoomSexUiActive = false;
  int _juniperSemRoomSexTier = 1;
  int _juniperSemRoomSexPlaybackTick = 0;
  String? _juniperSemRoomSexVideoPath;

  /// QUEST: juniper_quest_001 — in-room kompromat (крок 1 ванна / крок 2 зал / after flee вітальня / крок 3 ванна).
  JuniperManuelKompromatPhase _juniperManuelKompromatPhase =
      JuniperManuelKompromatPhase.inactive;
  int _juniperManuelKompromatPlaybackTick = 0;
  String? _juniperManuelKompromatVideoPath;

  bool get _juniperManuelKompromatUiActive =>
      _juniperManuelKompromatPhase ==
          JuniperManuelKompromatPhase.step1Video ||
      _juniperManuelKompromatPhase ==
          JuniperManuelKompromatPhase.step1AfterRecord;

  bool get _juniperManuelKompromatAfterRecord =>
      _juniperManuelKompromatPhase ==
      JuniperManuelKompromatPhase.step1AfterRecord;

  bool get _juniperManuelKompromatStep2UiActive =>
      _juniperManuelKompromatPhase ==
      JuniperManuelKompromatPhase.step2Video;

  bool get _juniperManuelKompromatStep2AfterFleeUiActive =>
      _juniperManuelKompromatPhase ==
      JuniperManuelKompromatPhase.step2AfterFlee;

  bool get _juniperManuelKompromatStep3UiActive =>
      _juniperManuelKompromatPhase ==
          JuniperManuelKompromatPhase.step3Video ||
      _juniperManuelKompromatPhase ==
          JuniperManuelKompromatPhase.step3AfterRecord;

  bool get _juniperManuelKompromatStep3AfterRecord =>
      _juniperManuelKompromatPhase ==
      JuniperManuelKompromatPhase.step3AfterRecord;

  bool get _juniperManuelKompromatStep4UiActive =>
      _juniperManuelKompromatPhase ==
          JuniperManuelKompromatPhase.step4Video ||
      _juniperManuelKompromatPhase ==
          JuniperManuelKompromatPhase.step4AfterRecord;

  bool get _juniperManuelKompromatStep4AfterRecord =>
      _juniperManuelKompromatPhase ==
      JuniperManuelKompromatPhase.step4AfterRecord;

  /// Картинка + діалог «spyOnSemParents» біля кімнати батьків.
  bool _spyOnSemParentsUiActive = false;
  DanielleSpyParentsPhase _spyParentsPhase = DanielleSpyParentsPhase.door;
  bool _danielleSpyCaughtUiActive = false;

  void _clearJuniperShowerUiOnly() {
    _juniperShowerUiActive = false;
    _juniperShowerTier = 1;
    _juniperShowerSetIndex = 0;
    _juniperShowerVideoPath = null;
  }

  void _clearJuniperQuest003UiOnly() {
    _juniperQuest003UiActive = false;
    _juniperQuest003VideoPath = null;
  }

  void _clearJuniperQuest003HallUiOnly() {
    _juniperQuest003HallUiActive = false;
    _juniperQuest003HallVideoPath = null;
  }

  void _clearInRoomVideoOverlayBlockers() {
    _clearJuniperShowerUiOnly();
    _ui.setEventImagePath(null);
    _eventVideoPath = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
  }

  InRoomVideoSceneHandle _launchInRoomVideo({
    required String videoPath,
    required int previousPlaybackTick,
    bool loop = true,
    bool allowEventImageOverlay = false,
  }) =>
      InRoomVideoSceneLauncher.launch(
        videoPath: videoPath,
        previousPlaybackTick: previousPlaybackTick,
        clearOverlayBlockers: _clearInRoomVideoOverlayBlockers,
        overlayEventVideoPath: _overlayEventVideoPath,
        eventVideoPendingButton: _eventVideoPendingButton,
        eventImagePath: _eventImagePath,
        allowEventImageOverlay: allowEventImageOverlay,
        loop: loop,
      );

  // --- Sasha: comunicate_sasha_in_zal ---
  bool _sashaComunicateInHallUiActive = false;
  ComunicateSashaInHallPhase _sashaComunicatePhase =
      ComunicateSashaInHallPhase.intro;

  // --- Sasha: morning run (event №2) ---
  bool _sashaMorningRunUiActive = false;
  SashaMorningRunPhase _sashaMorningRunPhase = SashaMorningRunPhase.intro;

  /// Останній крок cherie_quest_002, для якого викликано [_applyCherieQuest002OfficePatch].
  int? _cherieQuest002PresentationSyncedStep;

  /// Останній крок cherie_quest_003, для якого викликано [_applyCherieQuest003Patch].
  int? _cherieQuest003PresentationSyncedStep;

  /// Останній крок cherie_quest_004, для якого викликано [_applyCherieQuest004Patch].
  int? _cherieQuest004PresentationSyncedStep;

  /// Гілка [GameWorldState.cherieQuest004Branch], синхронізована з UI (відбої massage_no тощо).
  int? _cherieQuest004PresentationSyncedBranch;

  /// [GameWorldState.cherieQuest004LegsMassagePhase] після [_applyCherieQuest004Patch].
  bool? _cherieQuest004PresentationSyncedLegsMassagePhase;

  /// Останній крок cherie_quest_005, для якого викликано [_applyCherieQuest005Patch].
  int? _cherieQuest005PresentationSyncedStep;

  /// Останній крок cherie_quest_006, для якого викликано [_applyCherieQuest006Patch].
  int? _cherieQuest006PresentationSyncedStep;

  /// Режим продажу білизни в туалеті коледжу (12:30–12:59).
  bool _collegeToiletUnderwearSaleActive = false;

  /// Id предмета, обраного для підтвердження продажу в туалеті коледжу.
  String? _collegeToiletUnderwearSalePendingItemId;

  /// Останній крок cherie_event_004 після [_applyCherieMassageFunEventPatch].
  int? _cherieMassageFunEventPresentationSyncedStep;

  /// Останній крок mom_quest_001 після [_applyMomQuest001Patch].
  int? _momQuest001PresentationSyncedStep;
  String? _momQuest001VideoPath;
  int _momQuest001VideoTick = 0;
  bool _momQuest001VideoLoop = true;

  /// Останній крок mom_event_002 після [_applyMomEvent002Patch].
  int? _momEvent002PresentationSyncedStep;

  /// Останній показаний діалог старту пари, щоб не дублювати AlertDialog на кожен rebuild/tick.
  String? _collegeLessonPromptKey;

  /// Кнопка «Назад» у верхній панелі ([MainGameHeader]).
  bool get _headerShowsBackButton =>
      isLaptopOpen ||
      isInsideRoom ||
      isBackpackOpen ||
      isStatsOpen ||
      isNpcGalleryOpen ||
      _sashaMorningRunUiActive ||
      (currentZone == "STREET" && currentStreetHouse != null) ||
      (currentZone == "CITY" &&
          (_showLogisticsOfficeVideo ||
              _showMomOfficeView ||
              _showRockefellerCabinetView ||
              _showRockefellerReceptionView ||
              currentRoom == LocationsData.cityBusinessCenter ||
              currentRoom == LocationsData.cityMall ||
              currentRoom == LocationsData.cityEliteResidential ||
              LocationsData.cityEliteResidentialRoomIds.contains(currentRoom) ||
              currentRoom == LocationsData.cityVipGym ||
              currentRoom == LocationsData.cityPark ||
              LocationsData.cityParkRoomIds.contains(currentRoom))) ||
      currentZone == "POOR_DISTRICT" ||
      currentZone == "POOR_VILLAGE" ||
      currentZone == "OUT_OF_TOWN";

  void _resetDenLocalUi() {
    _denIntroUiPhase = DenIntroUiPhase.initial;
    _denStage2InProgress = false;
    _denSecondUiPhase = DenSecondUiPhase.initial;
    _denThirdUiPhase = DenThirdUiPhase.initial;
    _denAfterUiPhase = DenAfterUiPhase.initial;
    _ui.setEventImagePath(null);
    _eventVideoMuted = false;
    _eventVideoFullScreen = false;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoLoop = false;
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
  }

  void _exitDenEventToCorridor({bool add30Minutes = false}) {
    setState(() {
      if (add30Minutes) {
        _timeController.addMinutes(30);
      }
      _resetDenLocalUi();
      _selectedNpcIdInRoom = null;
      if (currentZone == "COLLEGE") {
        isInsideRoom = false;
        currentRoom = LocationsData.collegeHall;
      }
      newsMessage = '';
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _ui.setEventImagePath(null);
      _eventVideoCloseWhenCompleted = true;
      _eventVideoLoop = false;
    });
  }

  void _exitLoshokToCorridor() {
    setState(() {
      _ui.setEventImagePath(null);
      _selectedNpcIdInRoom = null;
      newsMessage = '';
    });
  }

  /// Завершує івент №2 Саші (sasha_event_002) і повертає інтерфейс у «вулицю».
  /// Якщо [incrementTimesCompleted] = true — додає +1 до лічильника завершень івенту.
  void _exitSashaMorningRunEventToStreetOverview({
    required bool incrementTimesCompleted,
  }) {
    final npcService = sl<NPCService>();
    final sasha = npcService.allNPCs.where((n) => n.id == 'sasha').toList();
    final sashaNpc = sasha.isEmpty ? null : sasha.first;

    if (!mounted) return;
    setState(() {
      _sashaMorningRunUiActive = false;
      _sashaMorningRunPhase = SashaMorningRunPhase.intro;

      _ui.setEventImagePath(null);
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoCloseWhenCompleted = true;
      _eventVideoMuted = false;
      _eventVideoFullScreen = false;
      _eventVideoLoop = false;

      _selectedNpcIdInRoom = null;
      _friendHouseStreetFacade = false;
      _resetSemTalkFlowUi();

      // Повертаємо гравця в «вулицю» (сітка будинків).
      currentZone = 'STREET';
      currentStreetHouse = null;
      currentRoom = LocationsData.street;
      isInsideRoom = false;

      newsMessage = LocationsData.getLocationDisplayName(LocationsData.street);

      if (sashaNpc != null) {
        // Після завершення — скидаємо проміжний крок.
        sashaNpc.setVar(SashaEvents.morningRunStepVar, 0);
        if (incrementTimesCompleted) {
          SashaEvents.incrementMorningRunTimesCompleted(sashaNpc);
        }
      }
    });
    _saveService.autosave();
  }

  String _getDenDialogueText(NPCModel den) {
    return getDenDialogueText(
      den: den,
      introPhase: _denIntroUiPhase,
      secondInProgress: _denStage2InProgress,
      secondPhase: _denSecondUiPhase,
      thirdPhase: _denThirdUiPhase,
      afterPhase: _denAfterUiPhase,
    );
  }

  /// Час переміщення: 5 хв у межах будинку/коледжу/міста; дім↔вулиця Шевченка — 5 хв; між іншими локаціями — 30 хв.
  ///
  /// Під час активних кроків cherie_quest_003 час на дорогу не списується (див. `.cursor/rules/quest-scripted-travel.mdc`).
  void _addTravelTime(String fromZone, String toZone) {
    if (CherieQuest003.suppressTravelTime(_worldState)) {
      return;
    }
    if (CherieQuest004.suppressTravelTime(_worldState)) {
      return;
    }
    if (CherieQuest005.suppressTravelTime(_worldState)) {
      return;
    }
    if (CherieMassageFunEvent.suppressTravelTime(_worldState)) {
      return;
    }
    if (fromZone == toZone) {
      _timeController.addMinutes(5);
      return;
    }
    if ((fromZone == "HOME" && toZone == "STREET") || (fromZone == "STREET" && toZone == "HOME")) {
      _timeController.addMinutes(5);
      return;
    }
    _timeController.addMinutes(30);
  }

  /// Сон ГG: +8 год, енергія 100%, збудження −20. false — ще не втомився (energy ≥ 50).
  bool _applyGgNightSleep() {
    final p = _playerStats.player;
    if (p.energy >= 50) {
      if (mounted) {
        final snackWidth = MediaQuery.sizeOf(context).width / 3;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sl<LocaleController>().t('room_sleep_not_tired'),
              textAlign: TextAlign.center,
            ),
            behavior: SnackBarBehavior.floating,
            width: snackWidth,
          ),
        );
      }
      return false;
    }
    _timeController.addMinutes(8 * 60);
    _playerStats.changeEnergy(p.maxEnergy - p.energy);
    _playerStats.changeArousal(-20);
    return true;
  }

  /// Сон у кімнаті ГG.
  void _onSleepInRoom() {
    if (!_applyGgNightSleep()) return;
    _saveService.autosave();
    setState(() {});
  }

  bool _canShowFriendHouseOvernightButton() {
    if (currentZone != 'STREET') return false;
    if (currentStreetHouse != LocationsData.friendHouse) return false;
    if (!isInsideRoom) return false;
    return FriendHouseOvernight.canOffer(
      npcService: sl<NPCService>(),
      hour: _timeController.dateTime.hour,
    );
  }

  /// Ночівля в гостьовій ([LocationsData.friendLounge]): той самий сон, що в кімнаті ГG.
  void _onFriendHouseOvernightStay() {
    if (!_canShowFriendHouseOvernightButton()) return;
    if (!_applyGgNightSleep()) return;
    setState(() {
      currentZone = 'STREET';
      currentStreetHouse = LocationsData.friendHouse;
      currentRoom = LocationsData.friendLounge;
      isInsideRoom = true;
      _worldState.currentZone = currentZone;
      _worldState.currentStreetHouse = currentStreetHouse;
      _worldState.currentRoom = currentRoom;
      _worldState.isInsideRoom = true;
      newsMessage = LocationsData.getLocationDisplayName(
        LocationsData.friendLounge,
      );
      isLaptopOpen = false;
      _isWatchingPornInLaptop = false;
      _isWatchingElsaVideoInLaptop = false;
      _selectedNpcIdInRoom = null;
    });
    _saveService.autosave();
  }

  /// Вихід з кімнати будинку Sem на рівень вище (сітка кімнат / коридор).
  void _exitFriendHouseInteriorToCorridor() {
    _nav.setZoneAndRoom(_nav.currentZone, LocationsData.friendCorridor);
    _nav.setIsInsideRoom(false);
    newsMessage = LocationsData.getLocationDisplayName(
      LocationsData.friendCorridor,
    );
  }

  void _finishSemJuniperIntro() {
    if (!mounted) return;
    SemJuniperRoomIntro.markComplete(
      _worldState,
      sl<GameTimeController>().onlyDate,
      skippedFacadePath: _semJuniperIntroSkippedPath,
    );
    final juniper = sl<NPCService>().npcById(kJuniperNpcId);
    juniper?.setVar('phone_unlocked', true);
    setState(() {
      _semJuniperIntroUiActive = false;
      _semJuniperIntroSkippedPath = false;
      _ui.setEventImagePath(null);
      _selectedNpcIdInRoom = null;
      _exitFriendHouseInteriorToCorridor();
    });
    _saveService.autosave();
  }

  /// Модальне вікно після знаходження предмета (обшук тощо): картинка, назва, OK.
  void _showFoundItemDialog(BuildContext context, GameItem item) {
    final t = sl<LocaleController>().t;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: item.imagePath != null && item.imagePath!.trim().isNotEmpty
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
                      child: Image.asset(
                        item.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.inventory_2,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : const Icon(Icons.inventory_2, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('dialog_ok')),
          ),
        ],
      ),
    );
  }

  void _applyDanielleSpyParentsTier3Rewards() {
    DanielleSpyParentsQuest.applySpyOnSemParentsTier3Rewards(
      _worldState,
      _playerStats,
      sl<NPCService>().allNPCs,
    );
  }

  void _finishSpyOnSemParentsToCorridor() {
    if (_spyParentsPhase == DanielleSpyParentsPhase.watchVideo3) {
      _applyDanielleSpyParentsTier3Rewards();
      if (_worldState.danielleSpyCaughtConfrontationDone) {
        final next = _worldState.danielleSpyCaughtConfrontationCount + 1;
        _worldState.danielleSpyCaughtConfrontationCount = next.clamp(
          0,
          DanielleSpyCaughtQuest.repeatCounterMax,
        );
        // Після першої розмови: підглядання доступне щодня у будні.
        // Розмова повертається лише коли накопичено поріг повторів.
        _worldState.spyOnSemParentsDone =
            _worldState.danielleSpyCaughtConfrontationCount >=
            DanielleSpyCaughtQuest.repeatSpyThreshold;
      } else {
        // Перше повне підглядання веде до першої розмови.
        _worldState.spyOnSemParentsDone = true;
      }
    }

    if (!mounted) return;
    setState(() {
      _spyOnSemParentsUiActive = false;
      _spyParentsPhase = DanielleSpyParentsPhase.door;
      _ui.setEventImagePath(null);
      _eventVideoPath = null;
      _eventVideoOnComplete = null;
      _eventVideoPendingButton = null;
      _eventVideoOnButtonPressed = null;
      _eventVideoLoop = false;
      _exitFriendHouseInteriorToCorridor();
      _saveService.autosave();
    });
  }

  void _finishDanielleSpyCaughtQuest() {
    if (!mounted || !_danielleSpyCaughtUiActive) return;
    DanielleSpyCaughtQuest.applyCompletionRewards(
      _worldState,
      _playerStats,
      sl<NPCService>().allNPCs,
    );
    _timeController.addMinutes(5);
    setState(() {
      _danielleSpyCaughtUiActive = false;
      newsMessage = LocationsData.getLocationDisplayName(currentRoom);
      _saveService.autosave();
    });
  }

  /// Список NPC, які зараз у поточній кімнаті (для вибору при 2+ NPC).
  /// Обраний гравцем — перший; решта — стабільний порядок за id.
  List<NPCModel> _getActiveNPCsInCurrentRoom() {
    if (!isInsideRoom) return [];
    if (currentRoom == LocationsData.cityMallGiftShop) {
      return _giftShopWanderingStripNpcs();
    }
    final npcService = sl<NPCService>();
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;

    final inRoom = npcService.getNPCsInRoom(currentRoom, hour, day);
    final present = inRoom.where((npc) {
      final point = npcService.representativeSchedulePoint(
        npc,
        currentRoom,
        hour,
        day,
      );
      if (point != null && point.spritePath.trim().isNotEmpty) return true;
      final av = npc.avatarPath?.trim();
      return av != null && av.isNotEmpty;
    }).toList();

    if (present.isEmpty) return [];
    if (present.length == 1) return present;

    List<NPCModel> ordered;
    if (currentRoom == LocationsData.cityEliteApartment2Bedroom) {
      ordered = <NPCModel>[];
      for (final id in ['lana', 'riley']) {
        for (final n in present) {
          if (n.id == id) {
            ordered.add(n);
            break;
          }
        }
      }
      for (final n in present) {
        if (n.id != 'riley' && n.id != 'lana') {
          ordered.add(n);
        }
      }
      if (ordered.isEmpty) ordered = List<NPCModel>.from(present);
    } else {
      ordered = List<NPCModel>.from(present)
        ..sort((a, b) => a.id.compareTo(b.id));
    }

    final selectedId = _selectedNpcIdInRoom;
    if (selectedId != null &&
        ordered.any((n) => n.id == selectedId)) {
      return [
        ...ordered.where((n) => n.id == selectedId),
        ...ordered.where((n) => n.id != selectedId),
      ];
    }

    if (currentZone == 'COLLEGE' && currentRoom == LocationsData.collegeCorridor) {
      final loshok = ordered.where((n) => n.id == 'loshok').toList();
      final others = ordered.where((n) => n.id != 'loshok').toList();
      return [...others, ...loshok];
    }

    return ordered;
  }

  /// Коли в кімнаті кілька NPC — явний вибір першого, щоб смуга, центр і кнопки збігались.
  void _syncDefaultNpcSelectionInRoomIfNeeded() {
    if (!isInsideRoom) return;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);
    if (!CityNpcLocationsUiRules.shouldAutoSelectNpcInAvatarStrip(roomNorm)) {
      return;
    }
    final activeNPCs = _getActiveNPCsInCurrentRoom();
    if (activeNPCs.isEmpty) {
      _selectedNpcIdInRoom = null;
      return;
    }
    final selectedId = _selectedNpcIdInRoom;
    if (selectedId != null && activeNPCs.any((n) => n.id == selectedId)) {
      return;
    }
    _selectedNpcIdInRoom = activeNPCs.first.id;
  }

  /// Магазин подарунків (ТРЦ): показуємо тільки тих, хто в кімнаті «по факту»
  /// (як визначає [NPCService]), і не додаємо інших.
  List<NPCModel> _giftShopWanderingStripNpcs() {
    final npcService = sl<NPCService>();
    final hour = _timeController.dateTime.hour;
    final day = _timeController.weekdayIndex;
    const room = LocationsData.cityMallGiftShop;

    final actuallyHere = npcService.getNPCsInRoom(room, hour, day);
    return actuallyHere.where((n) {
      if (isSecondaryNpc(n)) return false;
      final path = n.avatarPath;
      return path != null && path.isNotEmpty;
    }).toList();
  }

  Future<void> _handleNpcActionExecuted(
    String actionLabel,
    NPCModel npc, {
    String? dialogueL10nKey,
  }) async {
    if (dialogueL10nKey != null) {
      setState(() {
        newsMessage = sl<LocaleController>().t(dialogueL10nKey);
      });
    }
    if (actionLabel != 'Подарувати') return;
    await _openGiftBackpackForNpc(npc);
  }

  Future<void> _openGiftBackpackForNpc(NPCModel npc) async {
    final uniqueItems = _inventory.uniqueItemsWithCount;
    if (uniqueItems.isEmpty) {
      setState(() {
        newsMessage = 'У рюкзаку немає предметів для подарунку.';
      });
      return;
    }

    final picked = await showDialog<GameItem>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameTheme.bgDark,
        title: const Text('Вибери предмет для подарунку', style: TextStyle(color: Colors.white)),
        actionsAlignment: MainAxisAlignment.center,
        content: SizedBox(
          width: 520,
          height: 360,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: uniqueItems.length,
            itemBuilder: (context, index) {
              final entry = uniqueItems[index];
              final item = entry.$1;
              final count = entry.$2;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(dialogContext).pop(item),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: item.imagePath != null && item.imagePath!.isNotEmpty
                              ? Image.asset(
                                  item.imagePath!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.inventory_2, color: Colors.white70),
                                )
                              : const Icon(Icons.inventory_2, color: Colors.white70),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Закрити', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );

    if (picked == null) return;
    await _confirmGiftItemToNpc(npc: npc, item: picked);
  }

  Future<void> _confirmGiftItemToNpc({
    required NPCModel npc,
    required GameItem item,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameTheme.bgDark,
        title: const Text('Підтвердження', style: TextStyle(color: Colors.white)),
        content: Text(
          'Подарувати ${item.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 120,
            child: TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Ні', style: TextStyle(color: Colors.white70)),
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: GameTheme.actionButtonStyle(),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Так'),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (_inventory.count(item.id) <= 0) return;

    _inventory.removeItem(item.id);
    final expiresAtIso = _giftExpiryIsoForItem(item);
    npc.items.add(
      NpcOwnedItem(
        id: item.id,
        name: item.name,
        imagePath: item.imagePath,
        expiresAtIso: expiresAtIso,
      ),
    );
    _saveService.autosave();
    setState(() {
      newsMessage = 'Предмет "${item.name}" подаровано ${npc.name}.';
    });
  }

  String? _giftExpiryIsoForItem(GameItem item) {
    if (item.id != 'ab_fitness') return null;
    final purchasedIso = _worldState.vipGymCardPurchasedAtIso;
    final purchasedAt = purchasedIso != null ? DateTime.tryParse(purchasedIso) : null;
    final base = purchasedAt ?? _timeController.dateTime;
    return base.add(const Duration(days: 30)).toIso8601String();
  }

  static const int _mallShopMaxPerItem = 5;

  void _showMallPurchaseConfirm(ShopProduct product) {
    final t = sl<LocaleController>().t;
    final price = product.price;
    final name = product.name;
    showDialog<bool>(
      context: context,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: AlertDialog(
            title: Center(child: Text(name)),
            content: Center(child: Text(t('shop_confirm_purchase'))),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(t('shop_no')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(t('shop_yes')),
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      final inventory = sl<InventoryController>();
      if (!product.purchasableOnce && inventory.count(product.id) >= _mallShopMaxPerItem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('shop_max_five')), behavior: SnackBarBehavior.floating),
        );
        return;
      }
      if (_playerStats.money < price) {
        showInsufficientMoneyDialog(context);
        return;
      }
      _playerStats.changeMoney(-price);
      inventory.addItem(GameItem(
        id: product.id,
        name: product.name,
        description: product.name,
        imagePath: product.imagePath,
      ));
      _saveService.autosave();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('shop_bought')), behavior: SnackBarBehavior.floating),
        );
      }
    });
  }

  void refreshGame() {
    setState(() {});
  }

  /// Галерея, профіль з галереї, рюкзак, характеристики — закрити перед дією в інших блоках UI.
  void _dismissNpcGalleryIfOpen() {
    isNpcGalleryOpen = false;
    _selectedNpcForProfile = null;
    isBackpackOpen = false;
    isStatsOpen = false;
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

  Widget _actionPanelSection(List<Widget> children) {
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

  String t(String key) => sl<LocaleController>().t(key);

}
