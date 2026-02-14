import 'package:flutter/material.dart';
import 'package:naglec/screens/save_load_screen.dart';
import 'package:naglec/services/service_locator.dart';
import 'package:screenshot/screenshot.dart';
import '../data/locations_room_data.dart';
import '../models/npc_model.dart';
import '../services/npc_service.dart';
import '../services/save_service.dart';
import '../theme/game_theme.dart';
import '../left_panel/main_left_sidebar.dart';
import '../widgets/game_dialog_panel.dart';
import '../widgets/backpack_view.dart';
import '../locations/home_view.dart';
import '../locations/college_view.dart';
import '../locations/street_view.dart';
import '../services/game_time_controller.dart';
import '../services/inventory_controller.dart';
import '../services/player_stats_controller.dart';
import '../services/game_world_state.dart';
import 'player_stats_screen.dart';

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  // 1. Отримай доступ до сервісу
  final _saveService = sl<SaveService>();
  final InventoryController _inventory = sl<InventoryController>();
  final GameTimeController _timeController = sl<GameTimeController>();
  final PlayerStatsController _playerStats = sl<PlayerStatsController>();
  final GameWorldState _worldState = sl<GameWorldState>();

  String currentZone = "HOME";
  String currentRoom = LocationsData.corridor;
  bool isInsideRoom = false;
  bool isBackpackOpen = false;
  bool isStatsOpen = false; // <-- ДОДАНО: Змінна стану для характеристик
  String newsMessage = "Ласкаво просимо...";

  @override
  void initState() {
    super.initState();
    // Підтягуємо збережений стан світу (локація гг)
    currentZone = _worldState.currentZone;
    currentRoom = _worldState.currentRoom;
    isInsideRoom = _worldState.isInsideRoom;
  }

  void _syncWorldState() {
    _worldState.currentZone = currentZone;
    _worldState.currentRoom = currentRoom;
    _worldState.isInsideRoom = isInsideRoom;
  }

  void _handleRoomEntry(String name) {
    final roomData = currentZone == "COLLEGE"
        ? LocationsData.collegeRooms[name]
        : currentZone == "STREET"
            ? LocationsData.streetRooms[name]
            : LocationsData.homeRooms[name];
    setState(() {
      if (roomData != null && roomData.isLocked) {
        newsMessage = "Двері в кімнату зачинені. ${roomData.description}";
        return;
      }
      currentRoom = name;
      isInsideRoom = true;
      isBackpackOpen = false;
      isStatsOpen = false;
      _timeController.addMinutes(10);
      newsMessage = "Ви увійшли в $name.";
    });
    _syncWorldState();
    _saveService.saveGame(0);
  }

  void refreshGame() {
    setState(() {
      // Це змусить віджет перемалюватися з новими даними з сервісів
    });
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо доступ до контролера скріншотів із нашого сервісу збереження
    final screenshotController = sl<SaveService>().screenshotController;

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
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
                      ? "Я майже звичайний хлопець, але у мене є бонуси..."
                      : "Ви повернулись до гри.";
                }),
                onRefresh: () => setState(() {}),
                // Знайди у своєму коді обробник натискання на шестерню (onDebugMenuTap)
                onDebugMenuTap: () {
                  // Navigator.popUntil повертає додаток до найпершого маршруту в стеку (StartScreen)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 70,
                      child: Container(
                        decoration: BoxDecoration(
                            color: GameTheme.bgDark,
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 10),
                            Expanded(child: _buildMainContent()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      flex: 27,
                      child: GameDialogPanel(
                        message: newsMessage,
                        navButtons: [_buildActionPanel()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Кнопка Назад
        if (isInsideRoom || isBackpackOpen || isStatsOpen)
          _buildBackButton(),

        // Блок ДНЯ ТИЖНЯ (змінює тільки індекс)
        _timeControlBlock(
          label: _timeController.dayName,
          onPlus: () => setState(() => _timeController.nextDayName()),
          onMinus: () => setState(() => _timeController.prevDayName()),
        ),

        // Блок ДАТИ (змінює тільки календарне число)
        _timeControlBlock(
          label: _timeController.onlyDate,
          onPlus: () => setState(() => _timeController.addDay()),
          onMinus: () => setState(() => _timeController.subDay()),
        ),

        const SizedBox(width: 10),

        // 3. БЛОК ЧАСУ (залишаємо як був, він у тебе гарний)
        Container(
          padding: const EdgeInsets.symmetric( vertical: 4),
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _miniBtn("--", () => setState(() => _timeController.subHour())),
              _miniBtn("-", () => setState(() => _timeController.subMinute())),
              const SizedBox(width: 10),
              Text(
                _timeController.formattedTime,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 10),
              _miniBtn("+", () => setState(() => _timeController.addMinutes(5))),
              _miniBtn("++", () => setState(() => _timeController.addHour())),
            ],
          ),
        ),

        const Spacer(),

        // Назва локації
        Text(
          isStatsOpen
              ? "ХАРАКТЕРИСТИКИ   "
              : (currentZone == "COLLEGE"
                  ? "КОЛЕДЖ (${LocationsData.getRoomDisplayName(currentRoom, isCollege: true)})"
                  : currentZone == "STREET"
                      ? "ВУЛИЦЯ (${LocationsData.getRoomDisplayName(currentRoom, isStreet: true)})"
                      : "ДІМ (${LocationsData.getRoomDisplayName(currentRoom, isCollege: false)})"),
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }

  // Допоміжний віджет для блоку з кнопками +/-
  Widget _timeControlBlock({required String label, required VoidCallback onPlus, required VoidCallback onMinus}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _miniBtn("-", onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
          _miniBtn("+", onPlus),
        ],
      ),
    );
  }

  // Маленька стильна кнопка для хедера
  Widget _miniBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Винесений метод кнопки назад для чистоти коду
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            isInsideRoom = false;
            isBackpackOpen = false;
            isStatsOpen = false;
            if (currentZone == "STREET") {
              currentRoom = LocationsData.street;
              newsMessage = "Ви повернулися на вулицю";
            } else if (currentZone == "COLLEGE") {
              currentRoom = LocationsData.collegeHall;
              newsMessage = "Ви повернулися до холу";
            } else {
              currentRoom = LocationsData.corridor;
              newsMessage = "Ви повернулися до коридору";
            }
            _syncWorldState();
          }),
          borderRadius: BorderRadius.circular(50),
          child: const SizedBox(
            width: 34,
            height: 34,
            child: Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 22)),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (isBackpackOpen) {
      return BackpackView(inventory: _inventory, onNotify: (msg) => setState(() => newsMessage = msg));
    }

    if (isStatsOpen) {
      return PlayerStatsView(playerStats: _playerStats);
    }

    if (currentZone == "HOME") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return HomeView(
            key: ValueKey("home_${currentRoom}_${_timeController.dateTime.hour}"),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            onRoomTap: _handleRoomEntry,
            onBack: () => setState(() { isInsideRoom = false; currentRoom = LocationsData.corridor; _syncWorldState(); }),
            timeController: _timeController,
            onNPCTap: (npc) { setState(() {}); },
          );
        },
      );
    }

    if (currentZone == "COLLEGE") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return CollegeView(
            key: ValueKey("college_${currentRoom}_${_timeController.dateTime.hour}"),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            onRoomTap: _handleRoomEntry,
            onBack: () => setState(() { isInsideRoom = false; currentRoom = LocationsData.collegeHall; _syncWorldState(); }),
            timeController: _timeController,
            onNPCTap: (npc) { setState(() {}); },
          );
        },
      );
    }

    if (currentZone == "STREET") {
      return ListenableBuilder(
        listenable: _timeController,
        builder: (context, _) {
          return StreetView(
            key: ValueKey("street_${currentRoom}_${_timeController.dateTime.hour}"),
            currentRoom: currentRoom,
            isInsideRoom: isInsideRoom,
            onRoomTap: _handleRoomEntry,
            onBack: () => setState(() { isInsideRoom = false; currentRoom = LocationsData.street; _syncWorldState(); }),
            timeController: _timeController,
            onNPCTap: (npc) { setState(() {}); },
          );
        },
      );
    }

    return Center(child: Text("ЛОКАЦІЯ: $currentZone", style: const TextStyle(color: Colors.white)));
  }

  List<Widget> _buildNavigationButtons() {
    final list = <Widget>[];
    if (currentZone != "HOME") {
      list.add(_navBtn("Дім", () => setState(() {
        currentZone = "HOME";
        currentRoom = LocationsData.corridor;
        isInsideRoom = false;
        isStatsOpen = false;
        isBackpackOpen = false;
        _syncWorldState();
      })));
    }
    if (currentZone != "CITY") {
      list.add(_navBtn("В місто", () => setState(() {
        currentZone = "CITY";
        isStatsOpen = false;
        isBackpackOpen = false;
        _syncWorldState();
      })));
    }
    if (currentZone != "STREET") {
      list.add(_navBtn("На вулицю", () => setState(() {
        currentZone = "STREET";
        currentRoom = LocationsData.street;
        isInsideRoom = false;
        isStatsOpen = false;
        isBackpackOpen = false;
        _syncWorldState();
      })));
    }
    if (currentZone != "COLLEGE") {
      list.add(_navBtn("Коледж", () => setState(() {
        currentZone = "COLLEGE";
        currentRoom = LocationsData.collegeHall;
        isInsideRoom = false;
        isStatsOpen = false;
        isBackpackOpen = false;
        _syncWorldState();
      })));
    }
    return list;
  }

  Widget _navBtn(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: GameTheme.actionButtonStyle(color: GameTheme.textBlack),
      onPressed: onTap,
      child: Text(text), // Жирним він стане автоматично через GameTheme
    );
  }

  Widget _buildActionPanel() {
    return ListenableBuilder(
      listenable: _timeController,
      builder: (context, _) {
        final int hour = _timeController.dateTime.hour;
        final int day = _timeController.weekdayIndex;

        // 1. Отримуємо список NPC з сервісу
        final List<NPCModel> npcs = sl<NPCService>().getNPCsInRoom(currentRoom, hour, day);

        // 2. Фільтруємо активних для поточної кімнати та часу
        final List<NPCModel> activeNPCs = npcs.where((npc) {
          return npc.schedule.any((point) {
            bool timeMatches = (point.hourStart <= point.hourEnd)
                ? (hour >= point.hourStart && hour < point.hourEnd)
                : (hour >= point.hourStart || hour < point.hourEnd);
            return point.location == currentRoom && timeMatches;
          });
        }).toList();

        // 3. Створюємо список віджетів всередині білдера
        List<Widget> actionWidgets = [];

        if (isInsideRoom && activeNPCs.isNotEmpty) {
          final npc = activeNPCs.first;
          final actions = npc.getAvailableActions(
            location: currentRoom,
            hour: hour,
            onUpdate: () => setState(() {}),
          );

          for (var action in actions) {
            actionWidgets.add(
              ElevatedButton(
                style: GameTheme.actionButtonStyle(),
                onPressed: action.onExecute,
                child: Text(action.label.toUpperCase(), textAlign: TextAlign.center),
              ),
            );
            actionWidgets.add(const SizedBox(height: 8));
          }

          actionWidgets.add(
            ElevatedButton(
              style: GameTheme.actionButtonStyle(color: Colors.redAccent),
              onPressed: () => setState(() => isInsideRoom = false),
              child: const Text("← НАЗАД", textAlign: TextAlign.center),
            ),
          );
        } else {
          // На вулиці всередині будинку — спочатку кнопка назад на вулицю
          if (currentZone == "STREET" && isInsideRoom) {
            actionWidgets.add(ElevatedButton(
              style: GameTheme.actionButtonStyle(color: Colors.redAccent),
              onPressed: () => setState(() {
                isInsideRoom = false;
                currentRoom = LocationsData.street;
                _syncWorldState();
              }),
              child: const Text("← НАЗАД НА ВУЛИЦЮ", textAlign: TextAlign.center),
            ));
            actionWidgets.add(const SizedBox(height: 8));
          }
          // Звичайна навігація: кнопку поточної локації не показуємо
          if (currentZone != "HOME") {
            actionWidgets.add(_navBtn("ДІМ", () => setState(() {
              currentZone = "HOME";
              currentRoom = LocationsData.corridor;
              isInsideRoom = false;
              isStatsOpen = false;
              isBackpackOpen = false;
              _syncWorldState();
            })));
            actionWidgets.add(const SizedBox(height: 8));
          }
          if (currentZone != "CITY") {
            actionWidgets.add(_navBtn("В МІСТО", () => setState(() {
              currentZone = "CITY";
              isStatsOpen = false;
              isBackpackOpen = false;
              _syncWorldState();
            })));
            actionWidgets.add(const SizedBox(height: 8));
          }
          if (currentZone != "STREET") {
            actionWidgets.add(_navBtn("НА ВУЛИЦЮ", () => setState(() {
              currentZone = "STREET";
              currentRoom = LocationsData.street;
              isInsideRoom = false;
              isStatsOpen = false;
              isBackpackOpen = false;
              _syncWorldState();
            })));
            actionWidgets.add(const SizedBox(height: 8));
          }
          if (currentZone != "COLLEGE") {
            actionWidgets.add(_navBtn("КОЛЕДЖ", () => setState(() {
              currentZone = "COLLEGE";
              currentRoom = LocationsData.collegeHall;
              isInsideRoom = false;
              isStatsOpen = false;
              isBackpackOpen = false;
              _syncWorldState();
            })));
          }
        }

        // 4. Повертаємо контейнер зі списком, який тепер бачить actionWidgets
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: actionWidgets,
          ),
        );
      },
    );
  }
} // КІНЕЦЬ КЛАСУ _MainGameScreenState