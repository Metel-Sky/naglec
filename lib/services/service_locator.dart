import 'package:get_it/get_it.dart';
import 'game_time_controller.dart';
import 'inventory_controller.dart';
import 'npc_service.dart';
import 'player_stats_controller.dart';
import 'save_service.dart'; // <--- ДОДАНО ІМПОРТ
import 'game_world_state.dart';

// Створюємо екземпляр GetIt
final GetIt sl = GetIt.instance;

// Функція для налаштування та реєстрації сервісів
void setupServiceLocator() {


  // Реєструємо SaveService (ОБОВ'ЯЗКОВО ДЛЯ ЗБЕРЕЖЕНЬ)
  if (!sl.isRegistered<SaveService>()) {
    sl.registerLazySingleton<SaveService>(() => SaveService());
  }

  // Реєструємо NPCService
  if (!sl.isRegistered<NPCService>()) {
    sl.registerLazySingleton<NPCService>(() => NPCService());
  }

  // Реєструємо PlayerStatsController
  if (!sl.isRegistered<PlayerStatsController>()) {
    sl.registerLazySingleton<PlayerStatsController>(() => PlayerStatsController());
  }

  // Реєструємо GameTimeController
  if (!sl.isRegistered<GameTimeController>()) {
    sl.registerLazySingleton<GameTimeController>(() => GameTimeController());
  }

  // Реєструємо InventoryController
  if (!sl.isRegistered<InventoryController>()) {
    sl.registerLazySingleton<InventoryController>(() => InventoryController());
  }

  // Глобальний стан світу (локація гг тощо)
  if (!sl.isRegistered<GameWorldState>()) {
    sl.registerLazySingleton<GameWorldState>(() => GameWorldState());
  }
}

/// Скидає весь стан гри для нової гри (стати, час, локація, NPC, інвентар)
void resetGameState() {
  sl<PlayerStatsController>().reset();
  sl<GameTimeController>().reset();
  sl<GameWorldState>().reset();
  sl<NPCService>().reset();
  sl<InventoryController>().reset();
}