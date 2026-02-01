import 'package:flutter/material.dart';
import 'package:naglec/services/service_locator.dart';
import '../data/locations_room_data.dart';
import '../theme/game_theme.dart';
import '../left_panel/main_left_sidebar.dart';
import '../widgets/game_dialog_panel.dart';
import '../widgets/backpack_view.dart';
import '../locations/home_view.dart';
import '../services/game_time_controller.dart';
import '../services/inventory_controller.dart';
import '../services/player_stats_controller.dart';
import 'player_stats_screen.dart'; // Переконайся, що там клас PlayerStatsView (без Scaffold)

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  final InventoryController _inventory = sl<InventoryController>();
  final GameTimeController _timeController = sl<GameTimeController>();
  final PlayerStatsController _playerStats = sl<PlayerStatsController>();

  String currentZone = "HOME";
  String currentRoom = "Коридор";
  bool isInsideRoom = false;
  bool isBackpackOpen = false;
  bool isStatsOpen = false; // <-- ДОДАНО: Змінна стану для характеристик
  String newsMessage = "Ласкаво просимо...";

  void _handleRoomEntry(String name) {
    final roomData = LocationsData.homeRooms[name];
    setState(() {
      if (roomData != null && roomData.isLocked) {
        newsMessage = "Двері в кімнату зачинені. ${roomData.description}";
        return;
      }
      currentRoom = name;
      isInsideRoom = true;
      isBackpackOpen = false;
      isStatsOpen = false; // Закриваємо стати при вході в кімнату
      _timeController.addMinutes(5);
      newsMessage = "Ви увійшли в $name.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.screenBg,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            MainLeftSidebar(
              playerStats: _playerStats,
              onBackpackTap: () => setState(() {
                isBackpackOpen = !isBackpackOpen;
                isStatsOpen = false;
                newsMessage = isBackpackOpen ? "Відкрито рюкзак." : "Ви повернулись.";
              }),
              onPersonTap: () => setState(() {
                isStatsOpen = !isStatsOpen;
                isBackpackOpen = false;
                newsMessage = isStatsOpen
                    ? "Я майже звичайний хлопець, але у мене є бонуси, природа нагородила мене значним членом і неабияким розумом!"
                    : "Ви повернулись до гри.";
              }),
              onRefresh: () => setState(() {}),
              onDebugMenuTap: () => Navigator.pop(context),


            ), // <-- ТУТ БУЛА ПРОПУЩЕНА КОМА
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 70,
                    child: Container(
                      decoration: BoxDecoration(
                          color: GameTheme.bgDark,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 10),
                          Expanded(child: _buildMainContent()), // Виклик головного контенту
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 27,
                    child: GameDialogPanel(
                      message: newsMessage,
                      navButtons: _buildNavigationButtons(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if ((isInsideRoom || isStatsOpen || isBackpackOpen)) IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => setState(() {
            isInsideRoom = false;
            isStatsOpen = false;
            isBackpackOpen = false;
            currentRoom = "Коридор";
          }),
        ),
        Text(" ${_timeController.formattedDate} | ${_timeController.formattedTime} ",
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(isStatsOpen ? "ХАРАКТЕРИСТИКИ" : "ДІМ ($currentRoom)",
            style: const TextStyle(fontSize: 18, color: Colors.white)),
      ],
    );
  }

  Widget _buildMainContent() {
    // 1. Пріоритет рюкзаку
    if (isBackpackOpen) {
      return BackpackView(inventory: _inventory, onNotify: (msg) => setState(() => newsMessage = msg));
    }

    // 2. Пріоритет характеристикам
    if (isStatsOpen) {
      // Тут має бути твій віджет PlayerStatsView, який ми малювали
      return PlayerStatsView(playerStats: _playerStats);
    }

    // 3. Локація HOME
    if (currentZone == "HOME") {
      return HomeView(
        currentRoom: currentRoom,
        isInsideRoom: isInsideRoom,
        onRoomTap: _handleRoomEntry,
        onBack: () => setState(() { isInsideRoom = false; currentRoom = "Коридор"; }),
      );
    }

    return Center(child: Text("ЛОКАЦІЯ: $currentZone", style: const TextStyle(color: Colors.white)));
  }

  List<Widget> _buildNavigationButtons() {
    return [
      _navBtn("Дім", () => setState(() {
        currentZone = "HOME";
        isStatsOpen = false;
        isBackpackOpen = false;
      })),
      _navBtn("В місто", () => setState(() => currentZone = "CITY")),
    ];
  }

  Widget _navBtn(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
          width: double.infinity,
          height: 35,
          child: ElevatedButton(onPressed: onTap, child: Text(text, style: const TextStyle(fontSize: 12)))
      ),
    );
  }
}