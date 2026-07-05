import 'dart:math';

import '../../data/locations_room_data.dart';
import '../../services/game_world_state.dart';
import '../juniper/juniper_kitchen_videos.dart';
import '../juniper/juniper_npc.dart';
import 'sem_quests.dart';

/// QUEST: sem_quest_001 — вечірні візити Juniper у будинку Sem (3 тижні після старту стосунків).
abstract final class SemJuniperEveningVisits {
  SemJuniperEveningVisits._();

  static const int weekLengthDays = 7;
  static const int totalWeeks = 3;

  /// 18:00–22:59 (звичайні дні) або до 23:59 у пн/ср/пт/нд.
  static const int visitHourStart = 18;
  static const int visitHourEndDefault = 22;
  static const int visitHourEndLate = 23;

  /// Субота та неділя 12:00–17:59 — Juniper у кімнаті Sem (після старту стосунків).
  static const int weekendSemRoomHourStart = 12;
  static const int weekendSemRoomHourEndExclusive = 18;

  /// Пн, ср, пт, нд — до 23:00; о 22:00–22:59 фіксовано душ.
  static const List<int> lateVisitWeekdays = [0, 2, 4, 6];
  /// Вт, чт, сб — 18:00–18:59 на кухні.
  static const List<int> fixedKitchenWeekdays = [1, 3, 5];
  static const int fixedKitchenHour = 18;

  static const String roomVideo01 =
      'lib/assets/npcs/juniper/junip_sem_room_01.mp4';
  static const String roomVideo02 =
      'lib/assets/npcs/juniper/junip_sem_room_02.mp4';

  /// Тиждень 1: вт, чт, сб, нд.
  static const List<int> week1Weekdays = [1, 3, 5, 6];

  /// Тиждень 2: пн, ср, пт, сб, нд.
  static const List<int> week2Weekdays = [0, 2, 4, 5, 6];

  /// Тиждень 3: кожен день.
  static const List<int> week3Weekdays = [0, 1, 2, 3, 4, 5, 6];

  /// Сб–Нд: роумінг (без душу в рандомі; нд о 22:00 — окремий слот душу).
  static const List<String> weekendRoamRoomIds = [
    LocationsData.friendCorridor,
    LocationsData.friendKitchen,
    LocationsData.friendHall,
    LocationsData.friendLounge,
    LocationsData.friendRoom,
    LocationsData.friendPool,
  ];

  static int? datingWeekIndex(GameWorldState world, String gameDateKey) {
    if (!world.semJuniperDating) return null;
    final start = world.semJuniperDatingStartDateKey;
    if (start == null || start.isEmpty) return null;
    final days = SemQuest001.daysSinceDateKey(start, gameDateKey);
    if (days < 0) return null;
    if (days < weekLengthDays) return 1;
    if (days < weekLengthDays * 2) return 2;
    if (days < weekLengthDays * totalWeeks) return 3;
    return null;
  }

  static List<int> weekdaysForWeek(int week) {
    switch (week) {
      case 1:
        return week1Weekdays;
      case 2:
        return week2Weekdays;
      case 3:
        return week3Weekdays;
      default:
        return const [];
    }
  }

  static bool hasLateVisit(int weekdayIndex) =>
      lateVisitWeekdays.contains(weekdayIndex);

  static int visitHourEndFor(int weekdayIndex) =>
      hasLateVisit(weekdayIndex) ? visitHourEndLate : visitHourEndDefault;

  static const int scheduledShowerHour = 22;

  static bool isSaturday(int weekdayIndex) => weekdayIndex == 5;

  static bool isSunday(int weekdayIndex) => weekdayIndex == 6;

  static bool isWeekend(int weekdayIndex) =>
      isSaturday(weekdayIndex) || isSunday(weekdayIndex);

  static bool isWeekendSemRoomWindow(int weekdayIndex, int hour) {
    if (!isWeekend(weekdayIndex)) return false;
    return hour >= weekendSemRoomHourStart &&
        hour < weekendSemRoomHourEndExclusive;
  }

  /// Juniper у кімнаті Sem у вихідні 12:00–17:59 після [GameWorldState.semJuniperDating].
  static bool isWeekendSemRoomPresenceActive(
    GameWorldState world,
    int weekdayIndex,
    int hour,
  ) {
    if (!world.semJuniperDating) return false;
    return isWeekendSemRoomWindow(weekdayIndex, hour);
  }

  static bool isFixedKitchenHour(int weekdayIndex, int hour) =>
      fixedKitchenWeekdays.contains(weekdayIndex) && hour == fixedKitchenHour;

  /// Пн, ср, пт — одна випадкова година на кухні (18–21).
  static bool hasRandomKitchenTrip(int weekdayIndex) =>
      weekdayIndex == 0 || weekdayIndex == 2 || weekdayIndex == 4;

  static bool isVisitWindow(
    GameWorldState world,
    String gameDateKey,
    int weekdayIndex,
    int hour,
  ) =>
      hour >= visitHourStart && hour <= visitHourEndFor(weekdayIndex);

  static bool isActive(
    GameWorldState world,
    String gameDateKey,
    int weekdayIndex,
    int hour,
  ) {
    final week = datingWeekIndex(world, gameDateKey);
    if (week == null) return false;
    if (!isVisitWindow(world, gameDateKey, weekdayIndex, hour)) return false;
    return weekdaysForWeek(week).contains(weekdayIndex);
  }

  /// Одна година на добу (пн/ср/пт, 18–21): кухня; решта — [friendRoom].
  static int weekdayKitchenTripHour(String gameDateKey) {
    final rng = Random(gameDateKey.hashCode + 0x6a756e69);
    return visitHourStart +
        rng.nextInt(visitHourEndDefault - visitHourStart);
  }

  static String _weekendRoamRoom(String gameDateKey, int hour) {
    final seed = gameDateKey.hashCode + hour * 31 + 0x6a756e77;
    return weekendRoamRoomIds[Random(seed).nextInt(weekendRoamRoomIds.length)];
  }

  static String? _scheduledShowerOrLateRoom(int weekdayIndex, int hour) {
    if (!hasLateVisit(weekdayIndex)) return null;
    if (hour == scheduledShowerHour) return LocationsData.friendBathroom;
    if (hour == visitHourEndLate) return LocationsData.friendRoom;
    return null;
  }

  /// Поточна кімната Juniper у будинку Sem під час візиту.
  static String? locationAtHour({
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
    GameWorldState? world,
  }) {
    if (world != null &&
        isWeekendSemRoomPresenceActive(world, weekdayIndex, hour)) {
      return LocationsData.friendRoom;
    }
    if (hour < visitHourStart || hour > visitHourEndFor(weekdayIndex)) {
      return null;
    }

    final showerOrLateRoom = _scheduledShowerOrLateRoom(weekdayIndex, hour);
    if (showerOrLateRoom != null) return showerOrLateRoom;

    if (isFixedKitchenHour(weekdayIndex, hour)) {
      return LocationsData.friendKitchen;
    }

    if (isSaturday(weekdayIndex)) {
      return _weekendRoamRoom(gameDateKey, hour);
    }
    if (isSunday(weekdayIndex) && hour < scheduledShowerHour) {
      return _weekendRoamRoom(gameDateKey, hour);
    }

    if (hasRandomKitchenTrip(weekdayIndex) &&
        hour == weekdayKitchenTripHour(gameDateKey)) {
      return LocationsData.friendKitchen;
    }
    return LocationsData.friendRoom;
  }

  static bool isActiveInRoom({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (streetHouse != LocationsData.friendHouse ||
        zone != 'STREET' ||
        !insideRoom) {
      return false;
    }
    if (isWeekendSemRoomPresenceActive(world, weekdayIndex, hour)) {
      return LocationsData.migrateLegacyRoomId(room) ==
          LocationsData.friendRoom;
    }
    if (!isActive(world, gameDateKey, weekdayIndex, hour)) return false;
    final visitRoom = locationAtHour(
      gameDateKey: gameDateKey,
      weekdayIndex: weekdayIndex,
      hour: hour,
      world: world,
    );
    if (visitRoom == null) return false;
    return LocationsData.migrateLegacyRoomId(room) == visitRoom;
  }

  static bool hasEveningClipForRoom(String roomId) {
    final norm = LocationsData.migrateLegacyRoomId(roomId);
    return norm == LocationsData.friendRoom ||
        norm == LocationsData.friendKitchen;
  }

  /// У кімнаті Sem відео лише якщо Sem теж у кімнаті; на кухні — завжди.
  static bool shouldPlayEveningClipForRoom({
    required String roomId,
    required String? semLocationId,
  }) {
    final norm = LocationsData.migrateLegacyRoomId(roomId);
    if (norm != LocationsData.friendRoom) return true;
    if (semLocationId == null) return false;
    return LocationsData.migrateLegacyRoomId(semLocationId) ==
        LocationsData.friendRoom;
  }

  static String actionLabelForRoom(String roomId) {
    final norm = LocationsData.migrateLegacyRoomId(roomId);
    return switch (norm) {
      LocationsData.friendKitchen => 'На кухні',
      LocationsData.friendBathroom => 'У душі',
      LocationsData.friendRoom => 'У кімнаті Sem',
      LocationsData.friendCorridor => 'У коридорі',
      LocationsData.friendHall => 'У залі',
      LocationsData.friendLounge => 'У вітальні',
      LocationsData.friendPool => 'Біля басейну',
      _ => 'У будинку Sem',
    };
  }

  static String dailyClipPath(String gameDateKey, String roomId) {
    final norm = LocationsData.migrateLegacyRoomId(roomId);
    if (norm == LocationsData.friendKitchen) {
      return JuniperKitchenVideos.randomVideoPath();
    }
    final seed = gameDateKey.hashCode + 'juniper_room_clip'.hashCode;
    return Random(seed).nextBool() ? roomVideo01 : roomVideo02;
  }

  static String juniperAvatarPath() => kJuniperAvatarPath;
}

/// QUEST: sem_quest_001 — ранні візити Juniper (7+ днів після натяку, якщо ГG не питав на фасаді).
abstract final class SemJuniperEarlyVisits {
  SemJuniperEarlyVisits._();

  static bool isUnlocked({
    required GameWorldState world,
    required String gameDateKey,
  }) =>
      SemQuest001.isJuniperAtSemDue(world: world, gameDateKey: gameDateKey) &&
      !world.semJuniperFollowUpDone;

  static bool isActive(
    GameWorldState world,
    String gameDateKey,
    int weekdayIndex,
    int hour,
  ) {
    if (!isUnlocked(world: world, gameDateKey: gameDateKey)) return false;
    if (!SemJuniperEveningVisits.isVisitWindow(
      world,
      gameDateKey,
      weekdayIndex,
      hour,
    )) {
      return false;
    }
    return SemJuniperEveningVisits.week1Weekdays.contains(weekdayIndex);
  }

  static bool isActiveInRoom({
    required GameWorldState world,
    required String gameDateKey,
    required int weekdayIndex,
    required int hour,
    required String zone,
    required String? streetHouse,
    required bool insideRoom,
    required String room,
  }) {
    if (streetHouse != LocationsData.friendHouse ||
        zone != 'STREET' ||
        !insideRoom) {
      return false;
    }
    if (!isActive(world, gameDateKey, weekdayIndex, hour)) return false;
    final visitRoom = SemJuniperEveningVisits.locationAtHour(
      gameDateKey: gameDateKey,
      weekdayIndex: weekdayIndex,
      hour: hour,
      world: world,
    );
    if (visitRoom == null) return false;
    return LocationsData.migrateLegacyRoomId(room) == visitRoom;
  }
}
