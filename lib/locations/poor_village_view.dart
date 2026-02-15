import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/video_scene_widget.dart';

class PoorVillageView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;

  const PoorVillageView({
    super.key,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    required this.onNPCTap,
  });

  @override
  State<PoorVillageView> createState() => _PoorVillageViewState();
}

class _PoorVillageViewState extends State<PoorVillageView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isInsideRoom && widget.currentRoom == LocationsData.poorVillageOverview) {
      return _buildRoomsGrid();
    }

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

    final roomData = LocationsData.poorVillageRooms[widget.currentRoom];
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

  /// Сітка 6 слотів села бідних людей (2×3): дім завуча, дім Каті, дім англічанки тощо.
  Widget _buildRoomsGrid() {
    final roomIds = LocationsData.poorVillageRoomIds;
    const int crossCount = 3;
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
          children: roomIds.map((roomId) => _roomCard(roomId)).toList(),
        );
      },
    );
  }

  Widget _roomCard(String roomId) {
    final roomData = LocationsData.poorVillageRooms[roomId];
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
