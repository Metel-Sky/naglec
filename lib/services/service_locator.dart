import 'package:get_it/get_it.dart';
import 'game_time_controller.dart';
import 'inventory_controller.dart';
import 'npc_service.dart';
import 'player_stats_controller.dart';
import 'save_service.dart'; // <--- ДОДАНО ІМПОРТ

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
}