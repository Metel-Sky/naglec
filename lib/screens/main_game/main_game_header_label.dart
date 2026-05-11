import '../../data/locations_room_data.dart';

/// Частини заголовка локації: завжди [zoneLabel]; опційно короткий підпис у дужках.
class MainGameHeaderLocationParts {
  const MainGameHeaderLocationParts({
    required this.zoneLabel,
    this.parenthesesDetail,
  });

  final String zoneLabel;
  /// Якщо null — показуємо лише [zoneLabel] без дужок.
  final String? parenthesesDetail;
}

MainGameHeaderLocationParts _partsWithOptionalParens(String zone, String subName) {
  if (subName.isEmpty) return MainGameHeaderLocationParts(zoneLabel: zone);
  final shortSubName = subName.trim().split(RegExp(r'\s+')).first;
  if (shortSubName.isEmpty) return MainGameHeaderLocationParts(zoneLabel: zone);
  return MainGameHeaderLocationParts(
    zoneLabel: zone,
    parenthesesDetail: shortSubName,
  );
}

/// Детермінує зону та (за потреби) текст для дужок під верхньою панеллю гри.
///
/// Для коледжу, міста, вул. Шевченка, бідного р-ну та «на море» — лише назва зони, без дужок.
/// Для дому та Мажорщини — «ЗОНА (короткий підлокації)»; якщо не вміщається в панель, [MainGameHeader] ховає дужки.
MainGameHeaderLocationParts mainGameHeaderLocationParts({
  required String currentZone,
  required String currentRoom,
  String? currentStreetHouse,
}) {
  switch (currentZone) {
    case 'COLLEGE':
      return const MainGameHeaderLocationParts(zoneLabel: 'КОЛЕДЖ');
    case 'CITY':
      return const MainGameHeaderLocationParts(zoneLabel: 'МІСТО');
    case 'STREET':
      return const MainGameHeaderLocationParts(zoneLabel: 'ВУЛИЦЯ');
    case 'POOR_DISTRICT':
      return const MainGameHeaderLocationParts(zoneLabel: 'БІДНИЙ Р-Н');
    case 'OUT_OF_TOWN':
      return const MainGameHeaderLocationParts(zoneLabel: 'НА МОРЕ');
    case 'POOR_VILLAGE':
      return _partsWithOptionalParens(
        'МАЖОРЩИНА',
        LocationsData.getRoomDisplayName(currentRoom, isPoorVillage: true),
      );
    case 'HOME':
    default:
      return _partsWithOptionalParens(
        'ДІМ',
        LocationsData.getRoomDisplayName(currentRoom, isCollege: false),
      );
  }
}
