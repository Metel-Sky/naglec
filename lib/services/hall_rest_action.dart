import '../data/locations_room_data.dart';
import '../services/game_time_controller.dart';
import '../services/game_world_state.dart';
import '../services/player_stats_controller.dart';
import '../services/save_service.dart';
import '../services/service_locator.dart';

/// Відпочинок у житловому залі: +1 година, +10% енергії; лічильник для майбутніх квестів/івентів.
abstract final class HallRestAction {
  HallRestAction._();

  static const double energyFraction = 0.10;

  static bool canUse({
    required bool isInsideRoom,
    required String currentRoom,
  }) {
    if (!isInsideRoom) return false;
    return LocationsData.isResidentialHallRoom(currentRoom);
  }

  static void apply({
    required GameWorldState world,
    required PlayerStatsController playerStats,
    required GameTimeController timeController,
  }) {
    timeController.addHour();
    playerStats.changeEnergy(playerStats.player.maxEnergy * energyFraction);
    world.hallRestCount++;
    _tryTriggerQuestOrEventAfterRest(world);
    sl<SaveService>().autosave();
  }

  /// Зарезервовано: періодичний запуск квестів/івентів після відпочинку в залі.
  static void _tryTriggerQuestOrEventAfterRest(GameWorldState world) {}
}
