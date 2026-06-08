import 'dart:math';
import 'package:flutter/material.dart';
import '../models/room_models.dart';
import '../data/locations_room_data.dart';
import 'game_time_controller.dart';
import 'game_ui_state_controller.dart';
import 'game_world_state.dart';
import 'player_stats_controller.dart';
import 'inventory_controller.dart';
import 'save_service.dart';
import 'npc_service.dart';
import 'door_lock_service.dart';
import '../npcs/den/den_events.dart';
import '../npcs/mom/mom_room_hours.dart';
import '../npcs/piper/piper_quests.dart';
import '../npcs/piper/piper_events.dart';

class GameNavigationController extends ChangeNotifier {
  final GameTimeController _timeController;
  final GameUiStateController _uiStateController;
  final GameWorldState _worldState;
  final PlayerStatsController _playerStats;
  final InventoryController _inventory;
  final SaveService _saveService;
  final NPCService _npcService;

  String _currentZone = "HOME";
  String get currentZone => _currentZone;

  String _currentRoom = LocationsData.corridor;
  String get currentRoom => _currentRoom;

  bool _isInsideRoom = false;
  bool get isInsideRoom => _isInsideRoom;

  String? _currentStreetHouse;
  String? get currentStreetHouse => _currentStreetHouse;

  GameNavigationController(
    this._timeController,
    this._uiStateController,
    this._worldState,
    this._playerStats,
    this._inventory,
    this._saveService,
    this._npcService,
  );

  void setZoneAndRoom(String zone, String room) {
    _currentZone = zone;
    _currentRoom = room;
    _uiStateController.setShowMasturbateVideo(false);
    notifyListeners();
  }

  void setIsInsideRoom(bool val) {
    _isInsideRoom = val;
    notifyListeners();
  }

  void setCurrentStreetHouse(String? house) {
    _currentStreetHouse = house;
    notifyListeners();
  }

  /// Після [GameWorldState.reset] / завантаження з JSON — узгодити кеш навігації зі світом.
  void syncFromWorldState() {
    _currentZone = _worldState.currentZone;
    _currentRoom = _worldState.currentRoom;
    _isInsideRoom = _worldState.isInsideRoom;
    _currentStreetHouse = _worldState.currentStreetHouse;
    notifyListeners();
  }
  
  void spendMoveEnergy() {
    if (_playerStats.player.energy > 5) {
      _playerStats.changeEnergy(-1);
    } else {
      _uiStateController.setIsExhausted(true);
    }
  }

  void _addTravelTime(String fromZone, String toZone) {
    if ((fromZone == "CITY" && toZone == "POOR_DISTRICT") ||
        (fromZone == "POOR_DISTRICT" && toZone == "CITY")) {
      if (_inventory.items.any((e) => e.id == 'car')) {
        _timeController.addMinutes(10);
        _playerStats.changeEnergy(-1);
      } else if (_inventory.items.any((e) => e.id == 'bicycle')) {
        _timeController.addMinutes(15);
        _playerStats.changeEnergy(-3);
      } else {
        _timeController.addMinutes(45);
        _playerStats.changeEnergy(-10);
      }
    } else if ((fromZone == "CITY" && toZone == "OUT_OF_TOWN") ||
               (fromZone == "OUT_OF_TOWN" && toZone == "CITY")) {
      if (_inventory.items.any((e) => e.id == 'car')) {
        _timeController.addMinutes(15);
        _playerStats.changeEnergy(-1);
      } else if (_inventory.items.any((e) => e.id == 'bicycle')) {
        _timeController.addMinutes(30);
        _playerStats.changeEnergy(-5);
      } else {
        _timeController.addMinutes(60);
        _playerStats.changeEnergy(-15);
      }
    } else if ((fromZone == "CITY" && toZone == "POOR_VILLAGE") ||
               (fromZone == "POOR_VILLAGE" && toZone == "CITY")) {
      if (_inventory.items.any((e) => e.id == 'car')) {
        _timeController.addMinutes(20);
        _playerStats.changeEnergy(-2);
      } else if (_inventory.items.any((e) => e.id == 'bicycle')) {
        _timeController.addMinutes(40);
        _playerStats.changeEnergy(-8);
      } else {
        _timeController.addMinutes(90);
        _playerStats.changeEnergy(-20);
      }
    } else {
      _timeController.addMinutes(10);
    }
  }
  
  void handleRoomEntry(String roomId) {
    final name = LocationsData.migrateLegacyRoomId(roomId);
    final isVipGymEntryPoint = name == LocationsData.cityVipGym ||
        LocationsData.cityVipGymRoomIds.contains(name);
    if (_currentZone == "CITY" && isVipGymEntryPoint && !_hasValidVipGymCard()) {
      _uiStateController.setNewsMessage(
          "Потрібен дійсний абонемент в VIP тренажерний зал (30 днів).");
      notifyListeners();
      return;
    }

    if (_currentZone == "STREET" && LocationsData.streetRoomIds.contains(name)) {
      final firstRoom = LocationsData.getFirstRoomIdForStreetHouse(name);
      spendMoveEnergy();
      _timeController.addMinutes(5);
      _currentStreetHouse = name;
      final entryRoomId = firstRoom ?? LocationsData.corridor;
      _currentRoom = entryRoomId;
      _isInsideRoom = false;
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(entryRoomId),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }
    if (_currentZone == "CITY" && name == LocationsData.cityBusinessCenter) {
      spendMoveEnergy();
      _timeController.addMinutes(5);
      _currentRoom = LocationsData.cityBusinessCenter;
      _isInsideRoom = false;
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(LocationsData.cityBusinessCenter),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }
    if (_currentZone == "CITY" && name == LocationsData.cityMall) {
      spendMoveEnergy();
      _timeController.addMinutes(5);
      _currentRoom = LocationsData.cityMall;
      _isInsideRoom = false;
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(LocationsData.cityMall),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }
    if (_currentZone == "CITY" && name == LocationsData.cityEliteResidential) {
      spendMoveEnergy();
      _timeController.addMinutes(5);
      _currentRoom = LocationsData.cityEliteResidential;
      _isInsideRoom = false;
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(LocationsData.cityEliteResidential),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }
    if (_currentZone == "CITY" && name == LocationsData.cityVipGym) {
      spendMoveEnergy();
      _timeController.addMinutes(5);
      _currentRoom = LocationsData.cityVipGym;
      _isInsideRoom = false;
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(LocationsData.cityVipGym),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }
    if (_currentZone == "CITY" &&
        LocationsData.cityEliteResidentialRoomIds.contains(name) &&
        _currentRoom == LocationsData.cityEliteResidential) {
      spendMoveEnergy();
      _timeController.addMinutes(5);
      _currentRoom = name;
      _isInsideRoom = false;
      _uiStateController.setSelectedNpcIdInRoom(null);
      _uiStateController.closeAllPanels();
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(name),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }

    if (_currentZone == "HOME" &&
        (name == LocationsData.bathroom ||
            name == LocationsData.momRoom ||
            name == LocationsData.elsaRoom ||
            name == LocationsData.piperRoom)) {
      final dt = _timeController.dateTime;
      final (isLocked, lockMessage) = checkHomeRoomLocked(
        roomId: name,
        hour: dt.hour,
        weekdayIndex: _timeController.weekdayIndex,
        gameDate: dt,
        worldState: _worldState,
        npcService: _npcService,
        inventory: _inventory,
        playerStats: _playerStats,
      );
      if (isLocked && lockMessage != null) {
        _uiStateController.setNewsMessage(lockMessage);
        notifyListeners();
        return;
      }
    }

    if (_currentZone == "STREET" &&
        _currentStreetHouse == LocationsData.friendHouse &&
        (name == LocationsData.friendParentsRoom ||
            name == LocationsData.friendSisterRoom)) {
      final dt = _timeController.dateTime;
      final (isLocked, lockMessage) = checkHomeRoomLocked(
        roomId: name,
        hour: dt.hour,
        weekdayIndex: _timeController.weekdayIndex,
        gameDate: dt,
        worldState: _worldState,
        npcService: _npcService,
        inventory: _inventory,
        playerStats: _playerStats,
      );
      if (isLocked && lockMessage != null) {
        _uiStateController.setNewsMessage(lockMessage);
        notifyListeners();
        return;
      }
    }

    if (_currentZone == "POOR_DISTRICT" && name == LocationsData.poorDistrictResidential) {
      spendMoveEnergy();
      _currentRoom = LocationsData.poorDistrictResidentialOverview;
      _isInsideRoom = true;
      _uiStateController.closeAllPanels();
      _timeController.addMinutes(5);
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(
          LocationsData.poorDistrictResidentialOverview,
        ),
      );
      _saveService.autosave();
      notifyListeners();
      return;
    }

    RoomData? roomData;
    if (_currentZone == "COLLEGE") {
      roomData = LocationsData.collegeRooms[name];
    } else if (_currentZone == "CITY") {
      roomData = LocationsData.cityRooms[name];
    } else if (_currentZone == "POOR_DISTRICT") {
      roomData = LocationsData.poorDistrictRooms[name];
    } else if (_currentZone == "POOR_VILLAGE") {
      roomData = LocationsData.poorVillageRooms[name];
    } else if (_currentZone == "OUT_OF_TOWN") {
      roomData = LocationsData.outOfTownRooms[name];
    } else if (_currentZone == "STREET" && _currentStreetHouse != null) {
      roomData = LocationsData.getRoomsForStreetHouse(_currentStreetHouse!)?[name];
    } else if (_currentZone == "STREET") {
      roomData = LocationsData.streetRooms[name];
    } else {
      roomData = LocationsData.homeRooms[name];
    }
    
    if (roomData != null && roomData.isLocked) {
      _uiStateController.setNewsMessage('Зачинено.');
      notifyListeners();
      return;
    }
    
    final isCollegeAuditoriumEntry =
        _currentZone == "COLLEGE" && _isCollegeAuditorium(name);
    spendMoveEnergy();
    _currentRoom = name;
    _isInsideRoom = true;
    _uiStateController.setSelectedNpcIdInRoom(null);
    _uiStateController.setDenIntroUiPhase(DenIntroUiPhase.initial);
    _uiStateController.setDenSecondUiPhase(DenSecondUiPhase.initial);
    _uiStateController.setDenThirdUiPhase(DenThirdUiPhase.initial);
    _uiStateController.closeAllPanels();
    if (!isCollegeAuditoriumEntry) {
      _timeController.addMinutes(5);
    }
    final skipDefaultRoomNews = _currentZone == 'HOME' &&
        name == LocationsData.kitchen &&
        (_worldState.momPoolCleanPendingPay || _worldState.momEvent002Step == 3);
    final skipPiperLibraryEavesdropNews = _currentZone == 'COLLEGE' &&
        name == LocationsData.canteen &&
        (_worldState.piperQuest001Step == 1 ||
            PiperQuest001.canAutoStartStep1LibraryScene(
              world: _worldState,
              weekdayIndex: _timeController.weekdayIndex,
              hour: _timeController.dateTime.hour,
              currentZone: _currentZone,
              isInsideRoom: true,
              currentRoom: name,
            ));
    final skipPiperTeacherCallNews = _currentZone == 'HOME' &&
        (name == LocationsData.kitchen || name == LocationsData.hall) &&
        _worldState.piperQuest001Step == 3;
    final skipPiperCorridorScoldingNews = _currentZone == 'HOME' &&
        name == LocationsData.corridor &&
        _worldState.piperQuest001Step == 4;
    final skipPiperStep2ApproachNews = _currentZone == 'HOME' &&
        name == LocationsData.piperRoom &&
        _worldState.piperQuest001Step == 2;
    final skipPiperStep5PunishmentNews =
        _currentZone == 'HOME' && _worldState.piperQuest001Step == 5;
    final skipPiperStep6ClosureNews =
        _currentZone == 'HOME' && _worldState.piperQuest001Step == 6;
    final skipPiperHallWeekendEventNews = _currentZone == 'HOME' &&
        name == LocationsData.hall &&
        _worldState.piperHallEventStep >= 1 &&
        PiperHallWeekendEvents.isActiveScene(
          world: _worldState,
          npcService: _npcService,
          currentZone: _currentZone,
          isInsideRoom: true,
          currentRoom: name,
          weekdayIndex: _timeController.weekdayIndex,
          hour: _timeController.dateTime.hour,
        );
    if (!skipDefaultRoomNews &&
        !skipPiperLibraryEavesdropNews &&
        !skipPiperTeacherCallNews &&
        !skipPiperCorridorScoldingNews &&
        !skipPiperStep2ApproachNews &&
        !skipPiperStep5PunishmentNews &&
        !skipPiperStep6ClosureNews &&
        !skipPiperHallWeekendEventNews) {
      _uiStateController.setNewsMessage(
        LocationsData.getLocationDisplayName(name),
      );
    }
    
    // College den auto-select
    if (_currentZone == "COLLEGE" && _currentRoom == LocationsData.collegeCorridor) {
      final hour = _timeController.dateTime.hour;
      final day = _timeController.weekdayIndex;
      final denList = _npcService.allNPCs.where((n) => n.id == 'den').toList();
      final denNpc = denList.isEmpty ? null : denList.first;
      if (denNpc != null && _npcService.getCurrentLocationId(denNpc, hour, day) == _currentRoom) {
         _uiStateController.setSelectedNpcIdInRoom('den');
      }
    }

    if (_currentZone == "COLLEGE" &&
        name == LocationsData.collegeCorridor &&
        _timeController.dateTime.hour >= 9 &&
        _timeController.dateTime.hour <= 19) {
      final denList = _npcService.allNPCs.where((n) => n.id == 'den').toList();
      final denNpc = denList.isEmpty ? null : denList.first;
      if (denNpc != null && denNpc.getVar(DenEventVars.firstMeetingDone) != true) {
        // Assume getDenDialogueText works here. Wait, _getDenDialogueText is in main_game_screen_state
        // We can just use the constant string if we don't have exactly _getDenDialogueText
        _uiStateController.setNewsMessage("Ден хоче поговорити.");
      }
    }
    
    if (name == LocationsData.kitchen) {
      _worldState.kitchenVisitSeed = Random().nextInt(0x7FFFFFFF);
    }
    if (name == LocationsData.bathroom) {
      _worldState.piperBathroomVisitSeed = Random().nextInt(0x7FFFFFFF);
    }
    if (name == LocationsData.momRoom &&
        momRoomDynamicEveningMediaHour(_timeController.dateTime.hour)) {
      _worldState.momRoomNightVisitSeed = Random().nextInt(0x7FFFFFFF);
    }
    _saveService.autosave();
    notifyListeners();
  }

  bool _hasValidVipGymCard() {
    if (_inventory.count('ab_fitness') <= 0) return false;
    final purchasedIso = _worldState.vipGymCardPurchasedAtIso;
    if (purchasedIso == null || purchasedIso.isEmpty) {
      // Підтримка старих сейвів: якщо картка є, але дата не збережена, вважаємо дійсною.
      return true;
    }
    final purchasedAt = DateTime.tryParse(purchasedIso);
    if (purchasedAt == null) return true;
    final now = _timeController.dateTime;
    final ageDays = now.difference(purchasedAt).inDays;
    return ageDays <= 30;
  }

  bool _isCollegeAuditorium(String room) {
    return room == LocationsData.auditorium1 ||
        room == LocationsData.auditorium2 ||
        room == LocationsData.auditorium3;
  }
  
  void handleBackTap() {
    if (_uiStateController.eventImagePath != null ||
        _uiStateController.eventVideoPath != null) {
      _uiStateController.setDenIntroUiPhase(DenIntroUiPhase.initial);
      _uiStateController.setDenSecondUiPhase(DenSecondUiPhase.initial);
      _uiStateController.setDenThirdUiPhase(DenThirdUiPhase.initial);
      _uiStateController.setSelectedNpcIdInRoom(null);
      _uiStateController.clearEventSubState();
      notifyListeners();
    }
    if (_uiStateController.showMomOfficeView) {
      _uiStateController.setShowMomOfficeView(false);
      final luda = _npcService.npcById('luda');
      final hour = _timeController.dateTime.hour;
      final day = _timeController.weekdayIndex;
      final isLudaAtWork = luda != null &&
          _npcService.getCurrentLocationId(luda, hour, day) ==
              LocationsData.cityBcLogistics;
      if (isLudaAtWork) {
        _uiStateController.setShowLogisticsOfficeVideo(true);
        _uiStateController.setApproachedSecretary(false);
      } else {
        _uiStateController.setShowLogisticsOfficeVideo(false);
        _uiStateController.setApproachedSecretary(false);
      }
      notifyListeners();
      return;
    }
    if (_uiStateController.showRockefellerCabinetView) {
      _uiStateController.setShowRockefellerCabinetView(false);
    }
    if (_uiStateController.showRockefellerReceptionView) {
      _uiStateController.setShowRockefellerReceptionView(false);
    }
    if (_uiStateController.showLogisticsOfficeVideo) {
      _uiStateController.setShowLogisticsOfficeVideo(false);
      _uiStateController.setApproachedSecretary(false);
    }
    if (_uiStateController.isNpcGalleryOpen) {
      if (_uiStateController.selectedNpcForProfile != null) {
        _uiStateController.setSelectedNpcForProfile(null);
      } else {
        _uiStateController.setNpcGalleryOpen(false);
      }
      return;
    }
    if (_uiStateController.isBackpackOpen || _uiStateController.isStatsOpen) {
      _uiStateController.setBackpackOpen(false);
      _uiStateController.setStatsOpen(false);
      return;
    }
    if (_uiStateController.isLaptopOpen) {
      if (_uiStateController.tryLaptopNavigateBack()) {
        notifyListeners();
        return;
      }
      _uiStateController.setLaptopOpen(false);
      _uiStateController.setWatchingPornInLaptop(false);
      _uiStateController.setWatchingElsaVideoInLaptop(false);
    }

    // Зупинити відео «вздрочнути» при «Назад» / виході з кімнати (прапорець інакше лишався true
    // без ноутбука — оверлей лишався в дереві й media_kit грав далі).
    _uiStateController.setShowMasturbateVideo(false);
    _uiStateController.setShowFlyersVideo(false);
    _uiStateController.setShowConstructionVideo(false);
    
    _uiStateController.setBackpackOpen(false);
    _uiStateController.setStatsOpen(false);
    _uiStateController.setNpcGalleryOpen(false);

    final skipBackTime = _currentZone == "COLLEGE" &&
        _isInsideRoom &&
        _isCollegeAuditorium(_currentRoom);
    
    if (skipBackTime) {
      // Вхід/вихід з аудиторій не списує час: час іде лише на саму пару.
    } else if (_currentZone == "STREET" && _currentStreetHouse != null) {
      _timeController.addMinutes(5);
    } else if (_currentZone == "CITY") {
      _timeController.addMinutes(5);
    } else if (_currentZone == "POOR_DISTRICT") {
      if (_isInsideRoom) _timeController.addMinutes(5); else _addTravelTime("POOR_DISTRICT", "CITY");
    } else if (_currentZone == "POOR_VILLAGE") {
      if (_isInsideRoom) _timeController.addMinutes(5); else _addTravelTime("POOR_VILLAGE", "CITY");
    } else if (_currentZone == "OUT_OF_TOWN") {
      if (_isInsideRoom) _timeController.addMinutes(5); else _addTravelTime("OUT_OF_TOWN", "CITY");
    } else {
      _timeController.addMinutes(5);
    }
    
    if (_currentZone == "STREET" && _currentStreetHouse != null) {
      if (_isInsideRoom) {
        _isInsideRoom = false;
        final hallId = LocationsData.getFirstRoomIdForStreetHouse(
              _currentStreetHouse!,
            ) ??
            _currentRoom;
        _currentRoom = hallId;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(hallId),
        );
      } else {
        _currentStreetHouse = null;
        _currentRoom = LocationsData.street;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(LocationsData.street),
        );
      }
    } else if (_currentZone == "CITY") {
      if (_currentRoom == LocationsData.cityBusinessCenter || _currentRoom == LocationsData.cityMall || _currentRoom == LocationsData.cityEliteResidential || _currentRoom == LocationsData.cityVipGym) {
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          LocationsData.getCityEliteApartmentIdForInnerRoom(_currentRoom) != null) {
        _currentRoom = LocationsData.getCityEliteApartmentIdForInnerRoom(_currentRoom)!;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (!_isInsideRoom &&
          LocationsData.cityEliteResidentialRoomIds.contains(_currentRoom)) {
        _currentRoom = LocationsData.cityEliteResidential;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          (_currentRoom == LocationsData.cityBcCallCenterOperatorsHall ||
              _currentRoom == LocationsData.cityBcCallCenterBossOffice)) {
        _currentRoom = LocationsData.cityBcCallCenter;
        _isInsideRoom = true;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          LocationsData.cityGleamTeamRoomIds.contains(_currentRoom)) {
        _currentRoom = LocationsData.cityBcGleamTeam;
        _isInsideRoom = true;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          LocationsData.cityLogisticsRoomIds.contains(_currentRoom)) {
        _currentRoom = LocationsData.cityBcLogistics;
        _isInsideRoom = true;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          LocationsData.cityCarDealershipRoomIds.contains(_currentRoom)) {
        _currentRoom = LocationsData.cityCarDealership;
        _isInsideRoom = true;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom && _currentRoom == LocationsData.cityCarDealership) {
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          LocationsData.cityBusinessCenterRoomIds.contains(_currentRoom)) {
        _currentRoom = LocationsData.cityBusinessCenter;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          (_currentRoom == LocationsData.cityMallRestaurantHall ||
              _currentRoom == LocationsData.cityMallRestaurantVip)) {
        _currentRoom = LocationsData.cityMallCinema;
        _isInsideRoom = true;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom &&
          (_currentRoom == LocationsData.cityMallGiftShopOffice ||
              _currentRoom == LocationsData.cityMallGiftShopWarehouse)) {
        _currentRoom = LocationsData.cityMallGiftShop;
        _isInsideRoom = true;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom && LocationsData.isMallAreaRoom(_currentRoom)) {
        _currentRoom = LocationsData.cityMall;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom && LocationsData.cityParkRoomIds.contains(_currentRoom)) {
        _currentRoom = LocationsData.cityPark;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom && _currentRoom == LocationsData.cityPark) {
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_isInsideRoom) {
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else {
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      }
    } else if (_currentZone == "POOR_DISTRICT") {
      if (_isInsideRoom) {
        final backRoom = LocationsData.getPoorDistrictBackRoom(_currentRoom);
        if (backRoom != null && backRoom != LocationsData.poorDistrictOverview) {
          _currentRoom = backRoom;
          _isInsideRoom = true;
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        } else {
          _currentRoom = LocationsData.poorDistrictOverview;
          _isInsideRoom = false;
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        }
      } else {
        _currentZone = "CITY";
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      }
    } else if (_currentZone == "POOR_VILLAGE") {
      if (_isInsideRoom) {
        final backRoom = LocationsData.getPoorVillageBackRoom(_currentRoom);
        if (backRoom != null && backRoom != LocationsData.poorVillageOverview) {
          _currentRoom = backRoom;
          _isInsideRoom = true;
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        } else {
          _currentRoom = LocationsData.poorVillageOverview;
          _isInsideRoom = false;
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        }
      } else {
        _currentZone = "CITY";
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      }
    } else if (_currentZone == "OUT_OF_TOWN") {
      if (_isInsideRoom) {
        if (LocationsData.outOfTownClubRoomIds.contains(_currentRoom)) {
          _currentRoom = LocationsData.outOfTownClub;
          _isInsideRoom = true;
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        } else {
          _currentRoom = LocationsData.outOfTownOverview;
          _isInsideRoom = false;
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        }
      } else {
        _currentZone = "CITY";
        _currentRoom = LocationsData.cityOverview;
        _isInsideRoom = false;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      }
    } else {
      _isInsideRoom = false;
      if (_currentZone == "STREET") {
        _currentRoom = LocationsData.street;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else if (_currentZone == "COLLEGE") {
        _currentRoom = LocationsData.collegeHall;
        _uiStateController.setNewsMessage(
          LocationsData.getLocationDisplayName(_currentRoom),
        );
      } else {
        _currentRoom = LocationsData.corridor;
        if (_worldState.piperQuest001Step != 4) {
          _uiStateController.setNewsMessage(
            LocationsData.getLocationDisplayName(_currentRoom),
          );
        }
      }
    }
    notifyListeners();
  }
}
