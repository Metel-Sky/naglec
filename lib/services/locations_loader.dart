import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/room_models.dart';

/// Завантажує дані локацій з location.json і надає їх через геттери.
/// Викликати [load] один раз при старті додатку (наприклад у main).
class LocationsLoader {
  static Map<String, RoomData>? _homeRooms;
  static Map<String, RoomData>? _collegeRooms;
  static Map<String, RoomData>? _streetRooms;
  static Map<String, Map<String, RoomData>>? _streetHouseRooms;
  static Map<String, RoomData>? _cityRooms;
  static Map<String, RoomData>? _poorDistrictRooms;
  static Map<String, RoomData>? _poorVillageRooms;
  static Map<String, RoomData>? _outOfTownRooms;
  static Map<String, RoomData>? _officeRooms;

  static List<String>? _homeRoomIds;
  static List<String>? _collegeRoomIds;
  static List<String>? _streetRoomIds;
  static Map<String, List<String>>? _streetRoomIdsForHouse;
  static Map<String, String>? _streetFirstRoomIdForHouse;
  static List<String>? _cityRoomIds;
  static List<String>? _cityBusinessCenterRoomIds;
  static List<String>? _cityMallRoomIds;
  static List<String>? _cityParkRoomIds;
  static List<String>? _cityEliteResidentialRoomIds;
  static List<String>? _cityVipGymRoomIds;
  static List<String>? _cityCarDealershipRoomIds;
  static List<String>? _cityGleamTeamRoomIds;
  static List<String>? _cityLogisticsRoomIds;
  static List<String>? _poorDistrictRoomIds;
  static List<String>? _poorDistrictStripBarRoomIds;
  static List<String>? _poorVillageRoomIds;
  static List<String>? _outOfTownRoomIds;
  static List<String>? _outOfTownClubRoomIds;

  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  static Future<void> load(AssetBundle bundle) async {
    if (_loaded) return;
    final String raw = await bundle.loadString('assets/data/location.json');
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;

    Map<String, String> displayNameEn = {};
    try {
      final rawEn = await bundle.loadString('assets/data/location_display_en.json');
      final decoded = jsonDecode(rawEn);
      if (decoded is Map<String, dynamic>) {
        for (final e in decoded.entries) {
          if (e.value is String) displayNameEn[e.key] = e.value as String;
        }
      }
    } catch (_) {}

    _homeRooms = _parseRooms(json['home']?['rooms'], displayNameEn);
    _homeRoomIds = _parseStringList(json['home']?['roomIds']);

    _collegeRooms = _parseRooms(json['college']?['rooms'], displayNameEn);
    _collegeRoomIds = _parseStringList(json['college']?['roomIds']);

    final street = json['street'] as Map<String, dynamic>?;
    _streetRooms = _parseRooms(street?['rooms'], displayNameEn);
    _streetRoomIds = _parseStringList(street?['roomIds']);
    _streetHouseRooms = _parseHouseRooms(street?['houseRooms'], displayNameEn);
    _streetRoomIdsForHouse = _parseRoomIdsForHouse(street?['roomIdsForHouse']);
    _streetFirstRoomIdForHouse = _parseFirstRoomIdForHouse(street?['firstRoomIdForHouse']);

    final city = json['city'] as Map<String, dynamic>?;
    _cityRooms = _parseRooms(city?['rooms'], displayNameEn);
    _cityRoomIds = _parseStringList(city?['cityRoomIds']);
    _cityBusinessCenterRoomIds = _parseStringList(city?['cityBusinessCenterRoomIds']);
    _cityMallRoomIds = _parseStringList(city?['cityMallRoomIds']);
    _cityParkRoomIds = _parseStringList(city?['cityParkRoomIds']);
    _cityEliteResidentialRoomIds = _parseStringList(city?['cityEliteResidentialRoomIds']);
    _cityVipGymRoomIds = _parseStringList(city?['cityVipGymRoomIds']);
    _cityCarDealershipRoomIds = _parseStringList(city?['cityCarDealershipRoomIds']);
    _cityGleamTeamRoomIds = _parseStringList(city?['cityGleamTeamRoomIds']);
    _cityLogisticsRoomIds = _parseStringList(city?['cityLogisticsRoomIds']);

    _poorDistrictRooms = _parseRooms(json['poorDistrict']?['rooms'], displayNameEn);
    _poorDistrictRoomIds = _parseStringList(json['poorDistrict']?['roomIds']);
    _poorDistrictStripBarRoomIds =
        _parseStringList(json['poorDistrict']?['poorDistrictStripBarRoomIds']);

    _poorVillageRooms = _parseRooms(json['poorVillage']?['rooms'], displayNameEn);
    _poorVillageRoomIds = _parseStringList(json['poorVillage']?['roomIds']);

    _outOfTownRooms = _parseRooms(json['outOfTown']?['rooms'], displayNameEn);
    _outOfTownRoomIds = _parseStringList(json['outOfTown']?['roomIds']);
    _outOfTownClubRoomIds = _parseStringList(json['outOfTown']?['outOfTownClubRoomIds']);

    _officeRooms = _parseRooms(json['office']?['rooms'], displayNameEn);

    _loaded = true;
  }

  static Map<String, RoomData> _parseRooms(
    dynamic roomsJson,
    Map<String, String> displayNameEn,
  ) {
    final map = <String, RoomData>{};
    if (roomsJson is! Map<String, dynamic>) return map;
    for (final e in roomsJson.entries) {
      final r = e.value;
      if (r is! Map<String, dynamic>) continue;
      final en = displayNameEn[e.key];
      map[e.key] = RoomData(
        displayName: r['displayName'] as String? ?? e.key,
        displayNameEn: (en != null && en.isNotEmpty) ? en : null,
        imagePath: r['imagePath'] as String? ?? '',
        description: r['description'] as String? ?? '',
        isLocked: r['isLocked'] as bool? ?? false,
      );
    }
    return map;
  }

  static List<String> _parseStringList(dynamic list) {
    if (list is! List<dynamic>) return [];
    return list.map((e) => e.toString()).toList();
  }

  static Map<String, Map<String, RoomData>> _parseHouseRooms(
    dynamic houseRoomsJson,
    Map<String, String> displayNameEn,
  ) {
    final map = <String, Map<String, RoomData>>{};
    if (houseRoomsJson is! Map<String, dynamic>) return map;
    for (final e in houseRoomsJson.entries) {
      map[e.key] = _parseRooms(e.value, displayNameEn);
    }
    return map;
  }

  static Map<String, List<String>> _parseRoomIdsForHouse(dynamic json) {
    final map = <String, List<String>>{};
    if (json is! Map<String, dynamic>) return map;
    for (final e in json.entries) {
      map[e.key] = _parseStringList(e.value);
    }
    return map;
  }

  static Map<String, String> _parseFirstRoomIdForHouse(dynamic json) {
    final map = <String, String>{};
    if (json is! Map<String, dynamic>) return map;
    for (final e in json.entries) {
      if (e.value is String) map[e.key] = e.value as String;
    }
    return map;
  }

  // --- Getters ---
  static Map<String, RoomData> get homeRooms => _homeRooms ?? {};
  static Map<String, RoomData> get collegeRooms => _collegeRooms ?? {};
  static Map<String, RoomData> get streetRooms => _streetRooms ?? {};
  static Map<String, Map<String, RoomData>> get streetHouseRooms => _streetHouseRooms ?? {};
  static Map<String, RoomData> get cityRooms => _cityRooms ?? {};
  static Map<String, RoomData> get poorDistrictRooms => _poorDistrictRooms ?? {};
  static Map<String, RoomData> get poorVillageRooms => _poorVillageRooms ?? {};
  static Map<String, RoomData> get outOfTownRooms => _outOfTownRooms ?? {};
  static Map<String, RoomData> get officeRooms => _officeRooms ?? {};

  static List<String> get homeRoomIds => _homeRoomIds ?? [];
  static List<String> get collegeRoomIds => _collegeRoomIds ?? [];
  static List<String> get streetRoomIds => _streetRoomIds ?? [];
  static List<String> get cityRoomIds => _cityRoomIds ?? [];
  static List<String> get cityBusinessCenterRoomIds => _cityBusinessCenterRoomIds ?? [];
  static List<String> get cityMallRoomIds => _cityMallRoomIds ?? [];
  static List<String> get cityParkRoomIds => _cityParkRoomIds ?? [];
  static List<String> get cityEliteResidentialRoomIds => _cityEliteResidentialRoomIds ?? [];
  static List<String> get cityVipGymRoomIds => _cityVipGymRoomIds ?? [];
  static List<String> get cityCarDealershipRoomIds => _cityCarDealershipRoomIds ?? [];
  static List<String> get cityGleamTeamRoomIds => _cityGleamTeamRoomIds ?? [];
  static List<String> get cityLogisticsRoomIds => _cityLogisticsRoomIds ?? [];
  static List<String> get poorDistrictRoomIds => _poorDistrictRoomIds ?? [];
  static List<String> get poorDistrictStripBarRoomIds =>
      _poorDistrictStripBarRoomIds ?? [];
  static List<String> get poorVillageRoomIds => _poorVillageRoomIds ?? [];
  static List<String> get outOfTownRoomIds => _outOfTownRoomIds ?? [];
  static List<String> get outOfTownClubRoomIds => _outOfTownClubRoomIds ?? [];

  static List<String> getRoomIdsForStreetHouse(String? houseId) {
    if (houseId == null) return [];
    return _streetRoomIdsForHouse?[houseId] ?? [];
  }
  static String? getFirstRoomIdForStreetHouse(String? houseId) {
    if (houseId == null) return null;
    return _streetFirstRoomIdForHouse?[houseId];
  }
}
