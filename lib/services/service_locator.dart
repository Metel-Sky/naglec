import 'package:get_it/get_it.dart';
import 'game_time_controller.dart';
import 'inventory_controller.dart';
import 'locale_controller.dart';
import 'npc_service.dart';
import 'settings_controller.dart';
import 'player_stats_controller.dart';
import 'save_service.dart';
import 'game_world_state.dart';
import 'game_ui_state_controller.dart';
import 'game_navigation_controller.dart';
import '../quests/runtime/legacy_world_quest_state_repository.dart';
import '../quests/runtime/quest_effect_runner.dart';
import '../quests/runtime/quest_runtime.dart';
import '../quests/runtime/quest_state_repository.dart';
import '../quests/runtime/sasha_event_runtime.dart';
import '../quests/runtime/ui/quest_ui_isolation.dart';
import '../npcs/sasha/sasha_quest_definitions.dart';
import '../npcs/cherie/cherie_quest_definitions.dart';

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

  // Мова гри (uk, en, ru)
  if (!sl.isRegistered<LocaleController>()) {
    sl.registerLazySingleton<LocaleController>(() => LocaleController());
  }

  // Налаштування (гучність, чити)
  if (!sl.isRegistered<SettingsController>()) {
    sl.registerLazySingleton<SettingsController>(() => SettingsController());
  }
  // UI Статус
  if (!sl.isRegistered<GameUiStateController>()) {
    sl.registerLazySingleton<GameUiStateController>(() => GameUiStateController());
  }

  // Навігація в грі
  if (!sl.isRegistered<GameNavigationController>()) {
    sl.registerLazySingleton<GameNavigationController>(
      () => GameNavigationController(
        sl<GameTimeController>(),
        sl<GameUiStateController>(),
        sl<GameWorldState>(),
        sl<PlayerStatsController>(),
        sl<InventoryController>(),
        sl<SaveService>(),
        sl<NPCService>(),
      ),
    );
  }

  if (!sl.isRegistered<QuestStateRepository>()) {
    sl.registerLazySingleton<QuestStateRepository>(
      () => LegacyWorldQuestStateRepository(sl<GameWorldState>()),
    );
  }

  if (!sl.isRegistered<QuestRuntime>()) {
    sl.registerLazySingleton<QuestRuntime>(
      () {
        final runtime = QuestRuntime(stateRepository: sl<QuestStateRepository>());
        for (final definition in SashaQuestDefinitions.all) {
          runtime.register(definition);
        }
        for (final definition in CherieQuestDefinitions.all) {
          runtime.register(definition);
        }
        return runtime;
      },
    );
  }

  if (!sl.isRegistered<QuestEffectRunner>()) {
    sl.registerLazySingleton<QuestEffectRunner>(
      () => QuestEffectRunner(
        timeController: sl<GameTimeController>(),
        playerStats: sl<PlayerStatsController>(),
        navigation: sl<GameNavigationController>(),
        saveService: sl<SaveService>(),
      ),
    );
  }

  if (!sl.isRegistered<SashaEventRuntime>()) {
    sl.registerLazySingleton<SashaEventRuntime>(() => const SashaEventRuntime());
  }

  if (!sl.isRegistered<QuestRuntimeRegistry>()) {
    sl.registerLazySingleton<QuestRuntimeRegistry>(() {
      final registry = QuestRuntimeRegistry();
      registry.registerAll(SemJuniperDanielleFlows.all());
      return registry;
    });
  }
}

/// Скидає весь стан гри для нової гри (стати, час, локація, NPC, інвентар)
void resetGameState() {
  sl<PlayerStatsController>().reset();
  sl<GameTimeController>().reset();
  sl<GameWorldState>().reset();
  sl<NPCService>().reset();
  sl<InventoryController>().reset();
  sl<GameUiStateController>().closeAllPanels();
  sl<GameNavigationController>().syncFromWorldState();
}

/// Нова гра: скидання + автосейв (слот 8), щоб холодний старт і «Продовжити» не брали старий сейв.
Future<void> startNewGameSession() async {
  resetGameState();
  await sl<SaveService>().autosave();
}