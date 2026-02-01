import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';

class HomeView extends StatelessWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap; // Повідомляємо "батька" про натискання
  final VoidCallback onBack;      // Повідомляємо про кнопку "Назад"

  const HomeView({
    super.key,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return isInsideRoom ? _buildRoomImage() : _buildRoomsGrid();
  }

  // СІТКА КІМНАТ
  Widget _buildRoomsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 12.0;
        double cellWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        double cellHeight = (constraints.maxHeight - (spacing * 2)) / 3;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
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

  // КАРТКА КІМНАТИ
  Widget _roomCard(String name) {
    final roomData = LocationsData.homeRooms[name];

    return GestureDetector(
      onTap: () => onRoomTap(name),
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 10),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
            ),
            Container(color: Colors.black.withOpacity(0.4)),
            Center(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ВИГЛЯД ВСЕРЕДИНІ КІМНАТИ
  Widget _buildRoomImage() {
    final roomData = LocationsData.homeRooms[currentRoom];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: onBack,
          ),
        ),
      ],
    );
  }
}