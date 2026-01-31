import 'package:flutter/material.dart';
import 'package:naglec/main.dart';
import '../data/locations_room_data.dart';
import '../left_panel/stats_bottom_menu.dart';
import '../left_panel/stats_girls_card.dart';
import '../left_panel/stats_main_menu.dart';
import '../services/game_time_controller.dart';
import '../services/inventory_controller.dart';
import '../services/player_stats_controller.dart';
import '../models/item_model.dart';
import '../theme/game_theme.dart';
import '../left_panel/stats_header_card.dart';
import '../services/character_controller.dart';

class HomeCorridor extends StatefulWidget {
  const HomeCorridor({super.key});

  @override
  State<HomeCorridor> createState() => _HomeCorridorState();
}

class _HomeCorridorState extends State<HomeCorridor> {
  // 1. Ініціалізація контролерів
  final CharacterController _character = CharacterController();
  final InventoryController _inventory = InventoryController();
  final GameTimeController _timeController = GameTimeController();
  final PlayerStatsController _playerStats = PlayerStatsController();

  bool isStatsOpen = false;
  bool isBackpackOpen = false;
  String currentRoom = "Коридор";
  bool isInsideRoom = false;
  String newsMessage = "Ласкаво просимо до гри...";

  // 2. Метод відкриття рюкзака==================================================
  void _openBackpack() {
    setState(() {
      isBackpackOpen = !isBackpackOpen; // Перемикач: відкрити/закрити
      if (isBackpackOpen) {
        isInsideRoom = false; // Виходимо з кімнати, якщо були в ній
        newsMessage = "Ви відкрили рюкзак...";
      }
    });
  }

  void _openStats() {
    setState(() {
      isStatsOpen = !isStatsOpen;
      if (isStatsOpen) {
        isBackpackOpen = false;
        isInsideRoom = false;
        newsMessage = "Ви переглядаєте характеристики персонажа";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.screenBg,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ЛІВА ПАНЕЛЬ======================================================
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 250, maxWidth: 300),
              child: Column(
                children: [
                  _buildDebugButton(context),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: GameTheme.bgDark,
                      ),
                      child: Column(
                        children: [
                          // Хедер зі статами====================================
                          Expanded(
                            flex: 23,
                            child: StatsHeaderCard(
                              stats: _playerStats,
                              onStatsChanged: () => setState(() {}),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Головне меню (Рюкзак тут)==========================
                          Expanded(
                            flex: 30,
                            child: StatsMainMenu(
                              onBackpackTap: _openBackpack,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Нижнє меню
                          Expanded(
                              flex: 30,
                              child: StatsBottomMenu(
                                onBackpackTap: _openBackpack,
                                onPersonTap: _openStats,
                              )
                          ),
                          const SizedBox(height: 10),
                          const Expanded(flex: 23, child: StatsGirlsCard()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ПРАВА ЧАСТИНА (Ігрове поле)======================================
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        color: GameTheme.bgDark,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (isInsideRoom) _buildBackButton(),
                              const SizedBox(width: 15),
                              _debugTimeBtn("-", () => setState(() => _timeController.subDay())),
                              Text(
                                " ДАТА: ${_timeController.formattedDate} ",
                                style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold),
                              ),
                              _debugTimeBtn("+", () => setState(() => _timeController.addDay())),
                              const SizedBox(width: 15),
                              const Text(" ЧАС:  ", style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                              _debugTimeBtn("- ", () => setState(() => _timeController.subHour())),
                              Text(
                                _timeController.formattedTime,
                                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                              ),
                              _debugTimeBtn(" +", () => setState(() => _timeController.addHour())),

                              const Spacer(),
                              Text(
                                "ДІМ ($currentRoom)",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 15),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Expanded(
                            child: isBackpackOpen
                                ? _buildBackpackGrid() // Якщо рюкзак відкритий — показуємо комірки рюкзака
                                : (isInsideRoom ? _buildRoomView() : _buildRoomsGrid()), // Інакше показуємо кімнату або сітку кімнат
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // НИЖНЯ ПАНЕЛЬ (Новини та Навігація)
                  Expanded(
                    flex: 27,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: NewsPanel(customMessage: newsMessage),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: GameTheme.bgDark,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _navButton("На вулицю"),
                                _navButton("В місто"),
                                _navButton("Пригород"),
                                _navButton("Спальний р-н"),
                                _navButton("Коледж"),
                                _navButton("В місто"),
                                _navButton("Пригород"),
                                _navButton("Спальний р-н"),
                                _navButton("Коледж"),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  // --- ДОПОМІЖНІ ВІДЖЕТИ ---

  Widget _buildBackpackGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8, // Кількість комірок в ряд, як на скріні
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1, // Квадратні комірки 1:1
      ),
      itemCount: 40, // Наприклад, 40 слотів всього
      itemBuilder: (context, index) {
        // Перевіряємо, чи є в цьому слоті предмет
        bool hasItem = index < _inventory.items.length;
        final item = hasItem ? _inventory.items[index] : null;

        return GestureDetector(
          onTap: () {
            if (hasItem) {
              setState(() => newsMessage = "${item!.name}: ${item.description}");
            }
          },
          child: Container(
            width: 50, // Розмір комірки
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Сірий колір як на скріні
              borderRadius: BorderRadius.circular(12), // Заокруглені кути
            ),
            child: hasItem
                ? Center(child: Icon(Icons.inventory_2, color: GameTheme.textGreen))
                : null, // Порожня комірка
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => setState(() {
        isInsideRoom = false;
        currentRoom = "Коридор";
      }),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildRoomView() {
    // Отримуємо дані про поточну кімнату
    final roomData = LocationsData.homeRooms[currentRoom];

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.asset(
        // Переконайся, що шлях у roomData правильний (наприклад, 'assets/images/room.jpg')
        roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Додаємо обробку помилки, якщо файл не знайдено
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: GameTheme.bgDark,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: Colors.white24),
                  const SizedBox(height: 10),
                  Text("Файл не знайдено:\n${roomData?.imagePath}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Розраховуємо відступи та розміри
        double spacing = 12.0;
        // Ділимо ширину на 3 колони з урахуванням проміжків
        double cellWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        // Ділимо висоту на 3 рядки
        double cellHeight = (constraints.maxHeight - (spacing * 2)) / 3;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(), // Вимикаємо скрол всередині
          crossAxisCount: 3,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          // Співвідношення сторін тепер динамічне:
          childAspectRatio: cellWidth / cellHeight,
          children: [
            _roomCard("Кімната гг"), _roomCard("Кухня"), _roomCard("Ванна"),
            _roomCard("Кімната мами"), _roomCard("Кімната Кіри"), _roomCard("Кімната Ріти"),
            _roomCard("Зал"), _roomCard("Подвірʼя"), _roomCard("Підвал"),
          ],
        );
      },
    );
  }

  Widget _roomCard(String name) {
    final roomData = LocationsData.homeRooms[name];

    return GestureDetector(
      onTap: () {
        setState(() {
          currentRoom = name;
          isInsideRoom = true;

          // ОБОВ'ЯЗКОВО ДОДАЙ ЦІ ДВА РЯДКИ:
          isBackpackOpen = false;
          isStatsOpen = false;

          _timeController.addMinutes(5);

          final roomData = LocationsData.homeRooms[name];

          if (name == "Кімната гг") {
            _inventory.addItem(const GameItem(
              id: "condoms_pack",
              name: "Пачка презервативів",
              description: "Упаковка на 10 шт. Про всяк випадок...",
            ));
            newsMessage = "Ти знайшов пачку презервативів у себе в кімнаті.";
          }
// 2. Додаємо перевірку: якщо кімната заблокована
          else if (roomData != null && roomData.isLocked) {
            newsMessage = roomData.description; // Виведе "Підвал зараз закритий, ключі у мами."
          }
// 3. Якщо кімната не заблокована і це не Кімната гг
          else {
            newsMessage = "Ви увійшли в $name.";
          }
        });
      },
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 10),
        clipBehavior: Clip.antiAlias, // Щоб картинка не вилазила за радіус
        child: Stack(
          fit: StackFit.expand,
          children: [
            // КАРТИНКА КІМНАТИ
            Image.asset(
              roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: GameTheme.mainGrey,
                child: const Icon(Icons.image_not_supported, color: Colors.white24),
              ),
            ),
            // ТЕМНИЙ ГРАДІЄНТ (щоб текст було видно)
            Container(color: Colors.black.withOpacity(0.4)),
            // НАЗВА КІМНАТИ
            Center(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GameTheme.mainGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 35, // Фіксована висота, щоб влізло більше кнопок
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: GameTheme.mainGrey,
            foregroundColor: GameTheme.textBlack,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: EdgeInsets.zero, // Прибираємо внутрішні відступи
          ),
          onPressed: () {
            print("Перехід: $text");
          },
          child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildDebugButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.7)),
        onPressed: () => Navigator.pop(context),
        child: const Text("DEBUG: В МЕНЮ", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _debugTimeBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(label, style: const TextStyle(color: GameTheme.textGreen, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCharacterStatsView() {
    final p = _character.player;
    return Container(
      padding: const EdgeInsets.all(20),
      color: GameTheme.bgDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ПЕРСОНАЖ: ${p.name.toUpperCase()}", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          const Divider(color: GameTheme.textGreen),
          const SizedBox(height: 20),
          _statRow("Інтелект", p.intellect, Icons.psychology),
          _statRow("Харизма", p.charisma, Icons.auto_awesome),
          _statRow("Сила", p.strength, Icons.fitness_center),
          const Spacer(),
          Text("Гроші: ${p.money} \$", style: const TextStyle(fontSize: 20, color: Colors.yellow)),
        ],
      ),
    );
  }

  Widget _statRow(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: GameTheme.textGreen, size: 30),
          const SizedBox(width: 15),
          Text("$label:", style: const TextStyle(color: Colors.white70, fontSize: 18)),
          const Spacer(),
          Text("$value", style: const TextStyle(color: GameTheme.textGreen, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

}