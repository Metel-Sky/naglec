import '../../data/locations_room_data.dart';
import '../../services/npc_service.dart';
import 'sem_events.dart';

/// Результат перевірки «Позвати Сема» біля фасаду будинку кориша.
final class SemDoorSummonCheck {
  const SemDoorSummonCheck._({required this.canSummon, this.blockL10nKey});

  const SemDoorSummonCheck.summonable() : this._(canSummon: true);

  const SemDoorSummonCheck.blocked(String l10nKey)
      : this._(canSummon: false, blockL10nKey: l10nKey);

  final bool canSummon;
  final String? blockL10nKey;
}

/// Умови виклику Sem до дверей: вдома + не спить; інакше — l10n з місцем перебування.
abstract final class SemDoorSummon {
  SemDoorSummon._();

  /// Слот розкладу Sem «Спить» (23–6 через північ).
  static bool isSleepHour(int hour) => hour >= 23 || hour <= 6;

  static SemDoorSummonCheck check(
    NPCService npcService,
    int hour,
    int weekdayIndex,
  ) {
    if (isSleepHour(hour)) {
      return const SemDoorSummonCheck.blocked('friend_house_sem_away_sleeping');
    }

    final sem = findSemNpc(npcService.allNPCs);
    if (sem == null) {
      return const SemDoorSummonCheck.blocked('friend_house_sem_away_city');
    }

    final loc = npcService.getCurrentLocationId(sem, hour, weekdayIndex);
    if (LocationsData.isFriendHouseInteriorRoom(loc)) {
      return const SemDoorSummonCheck.summonable();
    }

    return SemDoorSummonCheck.blocked(_awayL10nKeyForLocation(loc));
  }

  static String _awayL10nKeyForLocation(String? loc) {
    if (loc == null) return 'friend_house_sem_away_city';
    final id = LocationsData.migrateLegacyRoomId(loc);
    if (id == LocationsData.collegeHall ||
        LocationsData.collegeRoomIds.contains(id)) {
      return 'friend_house_sem_away_college';
    }
    if (id == LocationsData.poorDistrictGym ||
        id == LocationsData.cityVipGym ||
        LocationsData.cityVipGymRoomIds.contains(id)) {
      return 'friend_house_sem_away_gym';
    }
    if (id == LocationsData.cityPark ||
        LocationsData.cityParkRoomIds.contains(id)) {
      return 'friend_house_sem_away_park';
    }
    return 'friend_house_sem_away_city';
  }
}
