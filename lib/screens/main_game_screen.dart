import 'package:flutter/material.dart';
import '../data/locations_room_data.dart';
import '../locations/home_view.dart';
import '../theme/game_theme.dart';
import '../left_panel/main_left_sidebar.dart';
import '../widgets/game_dialog_panel.dart'; // Твій новий віджет
import '../services/game_time_controller.dart';
import '../services/inventory_controller.dart';
import '../services/player_stats_controller.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  // Контролери тепер живуть ТУТ
  final InventoryController _inventory = InventoryController();
  final GameTimeController _timeController = GameTimeController();
  final PlayerStatsController _playerStats = PlayerStatsController();

  // Стан гри
  String currentZone = "HOME"; // Зона (HOME, CITY, COLLEGE)
  String currentRoom = "Коридор"; // Кімната всередині зони
  bool isInsideRoom = false;
  String newsMessage = "Ласкаво просимо до гри...";


  void _handleRoomEntry(String name) {
    final roomData = LocationsData.homeRooms[name];

    setState(() {
      if (roomData != null && roomData.isLocked) {
        newsMessage = "Двері в кімнату зачинені. ${roomData.description}";
        return;
      }

      currentRoom = name;
      isInsideRoom = true;
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
            // КОНСТАНТА 1: ЛІВА ПАНЕЛЬ
            MainLeftSidebar(
              playerStats: _playerStats,
              onBackpackTap: () => setState(() => newsMessage = "Відкрито рюкзак"),
              onPersonTap: () => setState(() => newsMessage = "Відкрито характеристики"),
              onRefresh: () => setState(() {}),
              onDebugMenuTap: () => Navigator.pop(context),
            ),

            const SizedBox(width: 12),

            // ПРАВА ЧАСТИНА
            Expanded(
              child: Column(
                children: [
                  // ЦЕНТРАЛЬНА ІГРОВА ЗОНА (Будемо її наповнювати)
                  Expanded(
                    flex: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        color: GameTheme.bgDark,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _buildActiveZone(), // Метод, що змінює контент
                    ),
                  ),

                  const SizedBox(height: 12),

                  // КОНСТАНТА 2: НИЖНЯ ПАНЕЛЬ
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



  // Кнопки навігації (теж константи)
  List<Widget> _buildNavigationButtons() {
    return [
      _navBtn("Дім", () => setState(() => currentZone = "HOME")),
      _navBtn("В місто", () => setState(() => currentZone = "CITY")),
      _navBtn("Коледж", () => setState(() => currentZone = "COLLEGE")),
    ];
  }

  Widget _navBtn(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildActiveZone() {
    if (currentZone == "HOME") {
      return HomeView(
        currentRoom: currentRoom,
        isInsideRoom: isInsideRoom,
        onBack: () => setState(() {
          isInsideRoom = false;
          currentRoom = "Коридор";
          newsMessage = "Ви повернулися в коридор.";
        }),
        onRoomTap: (name) => _handleRoomEntry(name),
      );
    }
    return Center(child: Text("ЛОКАЦІЯ: $currentZone"));
  }

}