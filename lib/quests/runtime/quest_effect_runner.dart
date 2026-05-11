import '../../services/game_navigation_controller.dart';
import '../../services/game_time_controller.dart';
import '../../services/player_stats_controller.dart';
import '../../services/save_service.dart';

class QuestEffectRunner {
  QuestEffectRunner({
    required GameTimeController timeController,
    required PlayerStatsController playerStats,
    required GameNavigationController navigation,
    required SaveService saveService,
  })  : _timeController = timeController,
        _playerStats = playerStats,
        _navigation = navigation,
        _saveService = saveService;

  final GameTimeController _timeController;
  final PlayerStatsController _playerStats;
  final GameNavigationController _navigation;
  final SaveService _saveService;

  void addMinutes(int minutes) => _timeController.addMinutes(minutes);

  void changeMoney(int delta) => _playerStats.changeMoney(delta);

  void setZoneAndRoom(String zone, String room) {
    _navigation.setZoneAndRoom(zone, room);
  }

  void setIsInsideRoom(bool value) => _navigation.setIsInsideRoom(value);

  Future<void> autosave() => _saveService.autosave();
}
