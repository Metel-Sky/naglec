import 'package:get_it/get_it.dart';
import 'game_time_controller.dart';
import 'inventory_controller.dart';
import 'npc_service.dart';
import 'player_stats_controller.dart';

// Створюємо екземпляр GetIt
final GetIt sl = GetIt.instance;

// Функція для налаштування та реєстрації сервісів
void setupServiceLocator() {

  // Реєструємо NPCService (тільки якщо він ще не зареєстрований)
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