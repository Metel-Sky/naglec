// ignore_for_file: avoid_print
/// Колишній refactor.py — небезпечний одноразовий рефакторинг екрану; передається шлях до dart-файлу.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/refactor_main_game_screen_state.dart <filepath>');
    exit(64);
  }
  refactor(File(args.first));
}

void refactor(File filepath) {
  var content = filepath.readAsStringSync(encoding: utf8);

  const startStr = 'final GameWorldState _worldState = sl<GameWorldState>();\n';
  const endStr = '  /// Кнопка «Назад» у верхній панелі ([MainGameHeader]).';

  const gettersSetters = r'''
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

  int? get _momOfficeVideoIndex => _ui.momOfficeVideoIndex;
  set _momOfficeVideoIndex(int? v) => _ui.setMomOfficeVideoIndex(v);

  bool get _momOfficeUseButtonImage => _ui.momOfficeUseButtonImage;
  set _momOfficeUseButtonImage(bool v) => _ui.setMomOfficeUseButtonImage(v);

  String get newsMessage => _ui.newsMessage;
  set newsMessage(String v) => _ui.setNewsMessage(v);

  bool get _isExhausted => _ui.isExhausted;

  bool get _showMomRoomCoverBlanketVideo => _ui.showMomRoomCoverBlanketVideo;
  set _showMomRoomCoverBlanketVideo(bool v) => _ui.setShowMomRoomCoverBlanketVideo(v);

  String? get _eventVideoPath => _ui.eventVideoPath;
  VoidCallback? get _eventVideoOnComplete => _ui.eventVideoOnComplete;
  String? get _eventVideoPendingButton => _ui.eventVideoPendingButton;
  VoidCallback? get _eventVideoOnButtonPressed => _ui.eventVideoOnButtonPressed;
  String? get _eventImagePath => _ui.eventImagePath;
  bool get _eventVideoMuted => _ui.eventVideoMuted;
  bool get _eventVideoFullScreen => _ui.eventVideoFullScreen;
  bool get _eventVideoCloseWhenCompleted => _ui.eventVideoCloseWhenCompleted;

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

  static const String _momOfficeImagePath = 'lib/assets/npcs/mom/video/mom_office/mom_work_place.jpg';
  static const String _momOfficeButtonImagePath = 'lib/assets/location/biznes_centr/logistic/cab_mom.jpg';
  static const List<String> _momOfficeVideoPaths = [
    'lib/assets/npcs/mom/video/mom_office/work_01.mp4',
    'lib/assets/npcs/mom/video/mom_office/work_02.mp4',
    'lib/assets/npcs/mom/video/mom_office/work_03.mp4',
  ];
''';

  final idxStart = content.indexOf(startStr);
  final idxEnd = content.indexOf(endStr);
  if (idxStart != -1 && idxEnd != -1) {
    content = content.substring(0, idxStart + startStr.length) +
        '\n' +
        gettersSetters +
        '\n' +
        content.substring(idxEnd);
  }

  final newHandleRoom = 'void _handleRoomEntry(String name) {\n    _nav.handleRoomEntry(name);\n  }';
  content = content.replaceFirstMapped(
    RegExp(r'void _handleRoomEntry[\s\S]*?void refreshGame\(\)'),
    (m) => '$newHandleRoom\n\n  void refreshGame()',
  );

  content = content.replaceFirstMapped(
    RegExp(r'void _handleBackTap\(\) \{[\s\S]*?Widget _buildFullScreenMainPanelOverlay\(\)'),
    (m) =>
        'void _handleBackTap() {\n    _nav.handleBackTap();\n  }\n\n  /// Галерея NPC, профіль з галереї, рюкзак, характеристики ГГ — останній шар у внутрішньому Stack (без смуги NPC поверх).\n  Widget _buildFullScreenMainPanelOverlay()',
  );

  content = content.replaceAll(
    RegExp(r'void _syncWorldState\(\) \{.*?\n  \}', dotAll: true),
    '',
  );
  content = content.replaceAll(
    RegExp(r'void _spendMoveEnergy\(\) \{.*?\n  \}', dotAll: true),
    '',
  );
  content = content.replaceAll(
    RegExp(
      r'void _addTravelTime.*?\} else \{\n      _timeController\.addMinutes\(10\);\n    \}\n  \}',
      dotAll: true,
    ),
    '',
  );

  const buildStart = 'return Screenshot(';
  const buildNew = 'return ListenableBuilder(\n      listenable: Listenable.merge([_ui, _nav]),\n      builder: (context, _) {\n        return Screenshot(';
  content = content.replaceAll(buildStart, buildNew);

  const buildEndMarker = '    );\n  }\n\n  void _handleBackTap() {';
  const buildEndReplacement = '    );\n      }\n    );\n  }\n\n  void _handleBackTap() {';
  content = content.replaceAll(buildEndMarker, buildEndReplacement);

  content = content.replaceAll('_eventImagePath = null;', '_ui.setEventImagePath(null);');
  content = content.replaceAll('_eventImagePath = ', '_ui.setEventImagePath(');

  filepath.writeAsStringSync(content, encoding: utf8);
}
