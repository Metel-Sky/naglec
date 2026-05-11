import 'dart:math';
import '../data/locations_room_data.dart';
import '../models/item_model.dart';
import 'game_world_state.dart';
import 'inventory_controller.dart';
import 'npc_service.dart';
import 'player_stats_controller.dart';

/// Відмичка + (5 уроків курсу злому **або** «злам замків» 100).
bool canPlayerPickHomeNightLock(
  InventoryController inventory,
  PlayerStatsController playerStats,
) {
  if (inventory.count('otmichka') <= 0) return false;
  if (playerStats.lockpickLessonsCompleted >= 5) return true;
  if (playerStats.player.lockpicking >= 100) return true;
  return false;
}

/// Чи зараз нічний час (22:00–7:00): двері мами та сестер зачиняються.
bool _isNightTime(int hour) => hour >= 22 || hour < 7;

/// У домі друга Сема: 23:00–6:59 — кімнати батьків і Саші зачинені (розклад сну).
bool _isSemFriendHouseNightLock(int hour) => hour >= 23 || hour < 7;

/// Керування «нічними дверима» вдома (мама, сестри, в майбутньому — інші жінки).
class HomeDoorAccess {
  /// Понеділок поточного тижня за грою (DateTime.weekday: 1 = понеділок).
  static String _weekKey(DateTime gameDate) {
    final daysFromMonday = gameDate.weekday - 1;
    final monday = gameDate.subtract(Duration(days: daysFromMonday));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  /// Раз на тиждень обирає дні, коли двері жінок уночі відчинені.
  static void ensureWeekInitialized(GameWorldState worldState, DateTime gameDate) {
    final weekKey = _weekKey(gameDate);
    if (worldState.lastDoorWeekKey == weekKey) return;
    final r = Random();
    worldState.lastDoorWeekKey = weekKey;
    worldState.momDoorOpenWeekday = r.nextInt(7);
    worldState.elsaDoorOpenWeekday = r.nextInt(7);
    worldState.piperDoorOpenWeekday = r.nextInt(7);
    worldState.friendHouseDanielleDoorOpenWeekday = r.nextInt(7);
    worldState.friendHouseSashaDoorOpenWeekday = r.nextInt(7);
  }

  /// День тижня (0–6), коли двері цієї кімнати відчинені вночі.
  static int? openWeekdayForRoom(String roomId, GameWorldState worldState) {
    if (roomId == LocationsData.momRoom) return worldState.momDoorOpenWeekday;
    if (roomId == LocationsData.elsaRoom) return worldState.elsaDoorOpenWeekday;
    if (roomId == LocationsData.piperRoom) return worldState.piperDoorOpenWeekday;
    if (roomId == LocationsData.friendParentsRoom) {
      return worldState.friendHouseDanielleDoorOpenWeekday;
    }
    if (roomId == LocationsData.friendSisterRoom) {
      return worldState.friendHouseSashaDoorOpenWeekday;
    }
    return null;
  }

  /// Id NPC-власника кімнати (для майбутнього розширення на інших жінок).
  static String? ownerNpcIdForRoom(String roomId) {
    switch (roomId) {
      case 'mom_room':
        return 'mom';
      case 'elsa_room':
        return 'elsa';
      case 'piper_room':
        return 'piper';
      default:
        return null;
    }
  }

  /// Персональний ключ кімнати (якщо існує в ігрових предметах).
  static String? keyItemIdForRoom(String roomId) {
    switch (roomId) {
      case 'mom_room':
        return 'keys_mom_room';
      case 'elsa_room':
        return 'key_elsa_room';
      case 'piper_room':
        return 'key_piper_room';
      default:
        return null;
    }
  }

  /// Підтримка legacy-id ключів зі старих сейвів.
  static List<String> keyItemIdsForRoom(String roomId) {
    switch (roomId) {
      case 'mom_room':
        return const ['keys_mom_room', 'key_mom_room', 'mom_room_key', 'room_key'];
      case 'elsa_room':
        return const ['key_elsa_room', 'keys_elsa_room', 'elsa_room_key', 'room_key'];
      case 'piper_room':
        return const ['key_piper_room', 'keys_piper_room', 'piper_room_key', 'room_key'];
      default:
        final single = keyItemIdForRoom(roomId);
        return single == null ? const [] : [single];
    }
  }

  static bool hasAnyRoomKeyFor(
    String roomId,
    InventoryController inventory,
  ) {
    final allowed = keyItemIdsForRoom(roomId)
        .map((e) => e.trim().toLowerCase())
        .toSet();
    for (final GameItem item in inventory.items) {
      final id = item.id.trim().toLowerCase();
      if (allowed.contains(id)) return true;

      // Legacy/fuzzy підтримка сейвів зі старими id.
      if (id == 'roomkey' || id == 'room-key') return true;
      if (id.contains('key') || id.contains('keys')) {
        switch (roomId) {
          case 'mom_room':
            if (id.contains('mom')) return true;
            break;
          case 'elsa_room':
            if (id.contains('elsa')) return true;
            break;
          case 'piper_room':
            if (id.contains('piper')) return true;
            break;
        }
      }
    }
    return false;
  }
}

/// Перевірка: чи двері в кімнату зачинені (ночні двері мами/сестер або ванна, коли хтось всередині).
/// Кожен понеділок рандомно визначається день тижня (0–6), коли двері кожної жінки відчинені.
(bool, String?) checkHomeRoomLocked({
  required String roomId,
  required int hour,
  required int weekdayIndex,
  required DateTime gameDate,
  required GameWorldState worldState,
  required NPCService npcService,
  required InventoryController inventory,
  required PlayerStatsController playerStats,
}) {
  final canOpenWithLockpick = canPlayerPickHomeNightLock(inventory, playerStats);

  // Ванна: якщо хтось у ванній — зачинені, окрім 1 з 6 випадків або відмичка + курс/100
  if (roomId == LocationsData.bathroom) {
    final inBathroom = npcService.getNPCsInRoom(LocationsData.bathroom, hour, weekdayIndex);
    if (inBathroom.isNotEmpty) {
      if (canOpenWithLockpick) {
        return (false, null);
      }
      final slot = weekdayIndex * 24 + hour;
      if (slot % 6 == 0) {
        return (false, null);
      }
      return (true, 'Зачинено.');
    }
    return (false, null);
  }

  // Кімната мами/сестер: нічні двері з тижневим «вікном відкритих дверей».
  final ownerNpcId = HomeDoorAccess.ownerNpcIdForRoom(roomId);
  if (ownerNpcId == null) return (false, null);

  // Ключ від кімнати (включно з legacy-id) — пріоритетно відкриває у будь-який час.
  final keyGrantedBySearch = switch (roomId) {
    LocationsData.elsaRoom => worldState.homeRoomSearchKeyElsaGranted,
    LocationsData.piperRoom => worldState.homeRoomSearchKeyPiperGranted,
    LocationsData.momRoom => worldState.homeRoomSearchKeyMomGranted,
    _ => false,
  };
  final hasRoomKey = keyGrantedBySearch || HomeDoorAccess.hasAnyRoomKeyFor(roomId, inventory);
  if (hasRoomKey) return (false, null);

  final npcList = npcService.allNPCs.where((n) => n.id == ownerNpcId).toList();
  final ownerNpc = npcList.isEmpty ? null : npcList.first;
  if (ownerNpc == null) return (false, null);

  // Високі стосунки: двері більше не зачиняються.
  if (ownerNpc.relationship >= 800) return (false, null);

  final isSemFriendNpcRoom = roomId == LocationsData.friendParentsRoom ||
      roomId == LocationsData.friendSisterRoom;
  final nightLocked = isSemFriendNpcRoom
      ? _isSemFriendHouseNightLock(hour)
      : _isNightTime(hour);
  // Якщо зараз не «ніч замку» для цієї кімнати — двері відчинені.
  if (!nightLocked) return (false, null);

  // Ініціалізуємо тижневі «відкриті ночі» для жінок.
  HomeDoorAccess.ensureWeekInitialized(worldState, gameDate);
  final openDay = HomeDoorAccess.openWeekdayForRoom(roomId, worldState);
  if (openDay != null && weekdayIndex == openDay) {
    return (false, null);
  }

  // Відмичка + (курс/100) дозволяє відкрити навіть вночі.
  if (canOpenWithLockpick) return (false, null);

  return (true, 'Зачинено.');
}
