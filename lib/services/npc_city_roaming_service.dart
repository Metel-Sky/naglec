import 'dart:math';

import '../data/locations_room_data.dart';

/// Роумінг «гуляє містом» для NPC:
/// - парк/кафе/кав'ярня
/// - ТРЦ (будь-яка кімната)
/// - VIP зал (без рецепції та секції боротьби)
/// - «На морі» (набережна, пляж, пристань, клуб + бар/туалет)
/// - магазин у бідному районі
class NpcCityRoamingService {
  NpcCityRoamingService._();

  static List<String> _buildRoamingPool() {
    final pool = <String>[
      LocationsData.cityPark,
      LocationsData.cityParkCafe,
      LocationsData.cityParkCoffee,
      ...LocationsData.cityMallRoomIds,
      ...LocationsData.cityVipGymRoomIds.where(
        (id) =>
            id != LocationsData.cityVipGymReception &&
            id != LocationsData.cityVipGymWrestling,
      ),
      LocationsData.outOfTownPromenade,
      LocationsData.outOfTownBeach,
      LocationsData.outOfTownPier,
      LocationsData.outOfTownClub,
      ...LocationsData.outOfTownClubRoomIds,
      LocationsData.poorDistrictShop,
    ];
    final unique = <String>[];
    for (final id in pool) {
      if (!unique.contains(id)) unique.add(id);
    }
    return unique;
  }

  static String? pickRoamingLocation({
    required String npcId,
    required int weekdayIndex,
    required int hour,
  }) {
    final pool = _buildRoamingPool();
    if (pool.isEmpty) return null;
    final seed =
        (weekdayIndex * 24 + hour) * 31 + npcId.hashCode + 'city_roaming'.hashCode;
    return pool[Random(seed).nextInt(pool.length)];
  }
}
