import 'package:flutter/material.dart';
import '../models/npc_model.dart';
import '../npcs/den/den_events.dart';
import '../npcs/cherie/cherie_quests.dart';

class GameUiStateController extends ChangeNotifier {
  bool _isBackpackOpen = false;
  bool get isBackpackOpen => _isBackpackOpen;

  bool _isStatsOpen = false;
  bool get isStatsOpen => _isStatsOpen;

  bool _isNpcGalleryOpen = false;
  bool get isNpcGalleryOpen => _isNpcGalleryOpen;

  NPCModel? _selectedNpcForProfile;
  NPCModel? get selectedNpcForProfile => _selectedNpcForProfile;

  String? _selectedNpcIdInRoom;
  String? get selectedNpcIdInRoom => _selectedNpcIdInRoom;

  bool _isPhoneOpen = false;
  bool get isPhoneOpen => _isPhoneOpen;

  bool _isLaptopOpen = false;
  bool get isLaptopOpen => _isLaptopOpen;

  bool _isWatchingPornInLaptop = false;
  bool get isWatchingPornInLaptop => _isWatchingPornInLaptop;

  bool _showMasturbateVideo = false;
  bool get showMasturbateVideo => _showMasturbateVideo;

  bool _isWatchingElsaVideoInLaptop = false;
  bool get isWatchingElsaVideoInLaptop => _isWatchingElsaVideoInLaptop;

  bool _showFlyersVideo = false;
  bool get showFlyersVideo => _showFlyersVideo;

  bool _showConstructionVideo = false;
  bool get showConstructionVideo => _showConstructionVideo;

  bool _showLogisticsOfficeVideo = false;
  bool get showLogisticsOfficeVideo => _showLogisticsOfficeVideo;

  bool _approachedSecretary = false;
  bool get approachedSecretary => _approachedSecretary;

  bool _showMomOfficeView = false;
  bool get showMomOfficeView => _showMomOfficeView;

  /// Повноекранний офіс Рокфеллера (ТРК/БЦ), як [showMomOfficeView] для логістики.
  bool _showRockefellerCabinetView = false;
  bool get showRockefellerCabinetView => _showRockefellerCabinetView;

  /// Повноекранна приймальня компанії Рокфеллера в БЦ.
  bool _showRockefellerReceptionView = false;
  bool get showRockefellerReceptionView => _showRockefellerReceptionView;

  int? _momOfficeVideoIndex;
  int? get momOfficeVideoIndex => _momOfficeVideoIndex;

  bool _momOfficeUseButtonImage = false;
  bool get momOfficeUseButtonImage => _momOfficeUseButtonImage;

  String _newsMessage = "Ласкаво просимо...";
  String get newsMessage => _newsMessage;

  bool _isExhausted = false;
  bool get isExhausted => _isExhausted;

  String? _eventVideoPath;
  String? get eventVideoPath => _eventVideoPath;

  VoidCallback? _eventVideoOnComplete;
  VoidCallback? get eventVideoOnComplete => _eventVideoOnComplete;

  String? _eventVideoPendingButton;
  String? get eventVideoPendingButton => _eventVideoPendingButton;

  VoidCallback? _eventVideoOnButtonPressed;
  VoidCallback? get eventVideoOnButtonPressed => _eventVideoOnButtonPressed;

  String? _eventImagePath;
  String? get eventImagePath => _eventImagePath;

  bool _eventVideoMuted = false;
  bool get eventVideoMuted => _eventVideoMuted;

  bool _eventVideoFullScreen = false;
  bool get eventVideoFullScreen => _eventVideoFullScreen;

  bool _eventVideoCloseWhenCompleted = true;
  bool get eventVideoCloseWhenCompleted => _eventVideoCloseWhenCompleted;

  bool _eventVideoLoop = false;
  bool get eventVideoLoop => _eventVideoLoop;

  DenIntroUiPhase _denIntroUiPhase = DenIntroUiPhase.initial;
  DenIntroUiPhase get denIntroUiPhase => _denIntroUiPhase;

  bool _denStage2InProgress = false;
  bool get denStage2InProgress => _denStage2InProgress;

  DenSecondUiPhase _denSecondUiPhase = DenSecondUiPhase.initial;
  DenSecondUiPhase get denSecondUiPhase => _denSecondUiPhase;

  DenThirdUiPhase _denThirdUiPhase = DenThirdUiPhase.initial;
  DenThirdUiPhase get denThirdUiPhase => _denThirdUiPhase;

  DenAfterUiPhase _denAfterUiPhase = DenAfterUiPhase.initial;
  DenAfterUiPhase get denAfterUiPhase => _denAfterUiPhase;

  CherieQuest001OfficePhase _cherieQuest001OfficePhase =
      CherieQuest001OfficePhase.inactive;
  CherieQuest001OfficePhase get cherieQuest001OfficePhase =>
      _cherieQuest001OfficePhase;

  /// Один івент «кінець зміни»: від «Закінчити працювати» до фінального «Піти» (відео tc_2 + діалог).
  bool _cherieAnimatorShiftTc2SequenceActive = false;
  bool get cherieAnimatorShiftTc2SequenceActive =>
      _cherieAnimatorShiftTc2SequenceActive;

  /// Слот зміни для [GameWorldState.lastGiftShopAnimatorDateKey] — застосовується на фінальному «Піти».
  String? _cherieAnimatorPendingShiftSlotKey;
  String? get cherieAnimatorPendingShiftSlotKey =>
      _cherieAnimatorPendingShiftSlotKey;

  /// Після [CherieEvents.animatorShiftEndVideoPath]: показ діалогу + кнопка «Піти».
  bool _cherieAnimatorShiftTc2DialogPending = false;
  bool get cherieAnimatorShiftTc2DialogPending =>
      _cherieAnimatorShiftTc2DialogPending;

  /// Чайові (рандом); гроші й стати нараховуються лише на останньому «Піти».
  int? _cherieAnimatorShiftEarnedTipsForSnack;
  int? get cherieAnimatorShiftEarnedTipsForSnack =>
      _cherieAnimatorShiftEarnedTipsForSnack;

  /// Фінал іде через інтро першої зміни — на «Піти» додати +10 збудження.
  bool _cherieAnimatorShiftRewardFromIntro = false;
  bool get cherieAnimatorShiftRewardFromIntro =>
      _cherieAnimatorShiftRewardFromIntro;

  // Setters
  void setBackpackOpen(bool val) { _isBackpackOpen = val; notifyListeners(); }
  void setStatsOpen(bool val) { _isStatsOpen = val; notifyListeners(); }
  void setNpcGalleryOpen(bool val) { _isNpcGalleryOpen = val; notifyListeners(); }
  void setSelectedNpcForProfile(NPCModel? val) { _selectedNpcForProfile = val; notifyListeners(); }
  void setSelectedNpcIdInRoom(String? val) { _selectedNpcIdInRoom = val; notifyListeners(); }
  void setPhoneOpen(bool val) { _isPhoneOpen = val; notifyListeners(); }
  void setLaptopOpen(bool val) { _isLaptopOpen = val; notifyListeners(); }
  void setWatchingPornInLaptop(bool val) { _isWatchingPornInLaptop = val; notifyListeners(); }
  void setShowMasturbateVideo(bool val) { _showMasturbateVideo = val; notifyListeners(); }
  void setWatchingElsaVideoInLaptop(bool val) { _isWatchingElsaVideoInLaptop = val; notifyListeners(); }
  void setShowFlyersVideo(bool val) { _showFlyersVideo = val; notifyListeners(); }
  void setShowConstructionVideo(bool val) { _showConstructionVideo = val; notifyListeners(); }
  void setShowLogisticsOfficeVideo(bool val) { _showLogisticsOfficeVideo = val; notifyListeners(); }
  void setApproachedSecretary(bool val) { _approachedSecretary = val; notifyListeners(); }
  void setShowMomOfficeView(bool val) { _showMomOfficeView = val; notifyListeners(); }
  void setShowRockefellerCabinetView(bool val) {
    _showRockefellerCabinetView = val;
    notifyListeners();
  }

  void setShowRockefellerReceptionView(bool val) {
    _showRockefellerReceptionView = val;
    notifyListeners();
  }

  void setMomOfficeVideoIndex(int? val) { _momOfficeVideoIndex = val; notifyListeners(); }
  void setMomOfficeUseButtonImage(bool val) { _momOfficeUseButtonImage = val; notifyListeners(); }
  void setNewsMessage(String val) { _newsMessage = val; notifyListeners(); }
  void setIsExhausted(bool val) { _isExhausted = val; notifyListeners(); }

  void setEventVideo({
    required String? path,
    bool muted = false,
    bool fullScreen = false,
    bool closeWhenCompleted = true,
    bool loop = false,
    VoidCallback? onComplete,
    String? pendingButton,
    VoidCallback? onButtonPressed,
  }) {
    _eventVideoPath = path;
    _eventVideoMuted = muted;
    _eventVideoFullScreen = fullScreen;
    _eventVideoCloseWhenCompleted = closeWhenCompleted;
    _eventVideoLoop = path != null && loop;
    _eventVideoOnComplete = onComplete;
    _eventVideoPendingButton = pendingButton;
    _eventVideoOnButtonPressed = onButtonPressed;
    notifyListeners();
  }

  void playFullScreenLoopVideo(String path, {
    VoidCallback? onComplete,
    String? pendingButton,
    VoidCallback? onButtonPressed,
  }) {
    clearEventSubState();
    setEventVideo(
      path: path,
      fullScreen: true,
      loop: true,
      closeWhenCompleted: false, // For looping backgrounds, usually we don't close on complete
      onComplete: onComplete,
      pendingButton: pendingButton,
      onButtonPressed: onButtonPressed,
    );
  }

  void playFullScreenVideo(String path, {
    bool closeWhenCompleted = true,
    VoidCallback? onComplete,
    String? pendingButton,
    VoidCallback? onButtonPressed,
  }) {
    clearEventSubState();
    setEventVideo(
      path: path,
      fullScreen: true,
      loop: false,
      closeWhenCompleted: closeWhenCompleted,
      onComplete: onComplete,
      pendingButton: pendingButton,
      onButtonPressed: onButtonPressed,
    );
  }

  void setEventVideoPendingButton(String? buttonTitle, VoidCallback? onPressed) {
    _eventVideoPendingButton = buttonTitle;
    _eventVideoOnButtonPressed = onPressed;
    notifyListeners();
  }

  void setEventVideoPath(String? val) {
    _eventVideoPath = val;
    if (val == null) _eventVideoLoop = false;
    notifyListeners();
  }

  void setEventVideoLoop(bool val) {
    _eventVideoLoop = val;
    notifyListeners();
  }

  void setEventVideoMuted(bool val) { _eventVideoMuted = val; notifyListeners(); }
  void setEventVideoFullScreen(bool val) { _eventVideoFullScreen = val; notifyListeners(); }
  void setEventVideoCloseWhenCompleted(bool val) { _eventVideoCloseWhenCompleted = val; notifyListeners(); }
  void setEventVideoOnComplete(VoidCallback? val) { _eventVideoOnComplete = val; notifyListeners(); }
  void setEventVideoPendingButtonOnly(String? val) { _eventVideoPendingButton = val; notifyListeners(); }
  void setEventVideoOnButtonPressedOnly(VoidCallback? val) { _eventVideoOnButtonPressed = val; notifyListeners(); }

  void setEventImagePath(String? path) {
    _eventImagePath = path;
    notifyListeners();
  }
  
  /// Повне скидання оверлею івенту (відео + картинка + колбеки).
  void clearEventSubState() {
    _eventVideoPath = null;
    _eventVideoOnComplete = null;
    _eventVideoPendingButton = null;
    _eventVideoOnButtonPressed = null;
    _eventVideoMuted = false;
    _eventVideoFullScreen = false;
    _eventVideoCloseWhenCompleted = true;
    _eventVideoLoop = false;
    _eventImagePath = null;
    notifyListeners();
  }

  void setDenIntroUiPhase(DenIntroUiPhase phase) { _denIntroUiPhase = phase; notifyListeners(); }
  void setDenStage2InProgress(bool val) { _denStage2InProgress = val; notifyListeners(); }
  void setDenSecondUiPhase(DenSecondUiPhase phase) { _denSecondUiPhase = phase; notifyListeners(); }
  void setDenThirdUiPhase(DenThirdUiPhase phase) { _denThirdUiPhase = phase; notifyListeners(); }
  void setDenAfterUiPhase(DenAfterUiPhase phase) { _denAfterUiPhase = phase; notifyListeners(); }

  void setCherieQuest001OfficePhase(CherieQuest001OfficePhase phase) {
    _cherieQuest001OfficePhase = phase;
    notifyListeners();
  }

  void setCherieAnimatorShiftTc2SequenceActive(bool v) {
    _cherieAnimatorShiftTc2SequenceActive = v;
    notifyListeners();
  }

  void setCherieAnimatorPendingShiftSlotKey(String? key) {
    _cherieAnimatorPendingShiftSlotKey = key;
    notifyListeners();
  }

  void setCherieAnimatorShiftTc2DialogPending(bool v) {
    _cherieAnimatorShiftTc2DialogPending = v;
    notifyListeners();
  }

  void setCherieAnimatorShiftEarnedTipsForSnack(int? tips) {
    _cherieAnimatorShiftEarnedTipsForSnack = tips;
    notifyListeners();
  }

  void setCherieAnimatorShiftRewardFromIntro(bool v) {
    _cherieAnimatorShiftRewardFromIntro = v;
    notifyListeners();
  }

  void clearCherieAnimatorShiftTc2Progress() {
    _cherieAnimatorShiftTc2SequenceActive = false;
    _cherieAnimatorPendingShiftSlotKey = null;
    _cherieAnimatorShiftTc2DialogPending = false;
    _cherieAnimatorShiftEarnedTipsForSnack = null;
    _cherieAnimatorShiftRewardFromIntro = false;
    notifyListeners();
  }

  void closeAllPanels() {
    _isBackpackOpen = false;
    _isStatsOpen = false;
    _isNpcGalleryOpen = false;
    _selectedNpcForProfile = null;
    _isPhoneOpen = false;
    _isLaptopOpen = false;
    _isWatchingPornInLaptop = false;
    _showMasturbateVideo = false;
    _isWatchingElsaVideoInLaptop = false;
    notifyListeners();
  }
}
