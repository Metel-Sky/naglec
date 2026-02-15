import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../models/npc_model.dart';
import '../models/room_models.dart';
import '../services/game_time_controller.dart';
import '../widgets/video_scene_widget.dart';

class StreetView extends StatefulWidget {
  /// Якщо не null — ми всередині одного з 4 будинків (показуємо 9 слотів як у домі гг)
  final String? currentStreetHouse;
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;

  const StreetView({
    super.key,
    required this.currentStreetHouse,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    required this.onNPCTap,
  });

  @override
  State<StreetView> createState() => _StreetViewState();
}

class _StreetViewState extends State<StreetView> {
  @override
  Widget build(BuildContext context) {
    // Всередині будинку на вулиці: власна сітка 9 кімнат для цього будинку
    if (widget.currentStreetHouse != null) {
      final houseRooms = LocationsData.getRoomsForStreetHouse(widget.currentStreetHouse);
      if (!widget.isInsideRoom) return _buildHouseRoomsGrid(houseRooms);
      return _buildRoomContent(houseRooms?[widget.currentRoom]);
    }
    // На вулиці: сітка 4 будинки
    if (!widget.isInsideRoom) return _buildRoomsGrid();

    final roomData = LocationsData.streetRooms[widget.currentRoom];
    return _buildRoomContent(roomData);
  }

  Widget _buildRoomContent(RoomData? roomData) {
    final List<NPCModel> npcsInRoom = sl<NPCService>().getNPCsInRoom(
      widget.currentRoom,
      widget.timeController.dateTime.hour,
      widget.timeController.weekdayIndex,
    );

    String? specialBackground;
    NPCModel? activeNPC;

    for (var npc in npcsInRoom) {
      try {
        final point = npc.schedule.firstWhere((p) {
          int h = widget.timeController.dateTime.hour;
          bool timeMatches = (p.hourStart <= p.hourEnd)
              ? (h >= p.hourStart && h < p.hourEnd)
              : (h >= p.hourStart || h < p.hourEnd);
          return p.location == widget.currentRoom && timeMatches;
        });
        if (point.spritePath.isNotEmpty) {
          specialBackground = point.spritePath;
          activeNPC = npc;
          break;
        }
      } catch (_) {}
    }

    final String finalMedia = specialBackground ?? roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg';

    return GestureDetector(
      onTap: () {
        if (activeNPC != null) widget.onNPCTap(activeNPC);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: _buildMediaContent(finalMedia),
      ),
    );
  }

  Widget _buildMediaContent(String path) {
    if (path.endsWith('.mp4') || path.endsWith('.webm')) {
      return VideoSceneWidget(videoPath: path);
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[900],
        child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 50)),
      ),
    );
  }

  /// Сітка кімнат всередині будинку на вулиці (власні дані будинку; у будинку кориша — 6 кімнат)
  Widget _buildHouseRoomsGrid(Map<String, RoomData>? houseRooms) {
    if (houseRooms == null || widget.currentStreetHouse == null) return const SizedBox();
    final roomIds = LocationsData.getRoomIdsForStreetHouse(widget.currentStreetHouse);
    if (roomIds.isEmpty) return const SizedBox();
    final crossCount = 3;
    final rowCount = (roomIds.length / crossCount).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 12.0;
        double cellWidth = (constraints.maxWidth - (spacing * (crossCount - 1))) / crossCount;
        double cellHeight = (constraints.maxHeight - (spacing * (rowCount - 1))) / rowCount;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: roomIds.map((roomId) => _houseRoomCard(roomId, houseRooms)).toList(),
        );
      },
    );
  }

  Widget _houseRoomCard(String roomId, Map<String, RoomData> houseRooms) {
    final roomData = houseRooms[roomId];
    final displayName = roomData?.displayName ?? roomId;
    return GestureDetector(
      onTap: () => widget.onRoomTap(roomId),
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 10),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.4)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Сітка з 4 будинками (2x2)
  Widget _buildRoomsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 12.0;
        int crossCount = 2;
        double cellWidth = (constraints.maxWidth - (spacing * (crossCount - 1))) / crossCount;
        double cellHeight = (constraints.maxHeight - spacing) / 2;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: LocationsData.streetRoomIds.map((roomId) => _roomCard(roomId)).toList(),
        );
      },
    );
  }

  Widget _roomCard(String roomId) {
    final roomData = LocationsData.streetRooms[roomId];
    final displayName = roomData?.displayName ?? roomId;
    return GestureDetector(
      onTap: () => widget.onRoomTap(roomId),
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 10),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              roomData?.imagePath ?? 'lib/assets/home_gg/rooms/default.jpg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.4)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
