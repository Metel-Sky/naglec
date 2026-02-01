import 'package:get_it/get_it.dart';
import 'game_time_controller.dart';
import 'inventory_controller.dart';
import 'player_stats_controller.dart';

// Створюємо екземпляр GetIt
final GetIt sl = GetIt.instance;

// Функція для налаштування та реєстрації сервісів
void setupServiceLocator() {
  // Реєструємо контролери як "ліниві" синглтони.
  // Це означає, що екземпляр буде створено лише при першому запиті.
  sl.registerLazySingleton<PlayerStatsController>(() => PlayerStatsController());
  sl.registerLazySingleton<GameTimeController>(() => GameTimeController());
  sl.registerLazySingleton<InventoryController>(() => InventoryController());
}
