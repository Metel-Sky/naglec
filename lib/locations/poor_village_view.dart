import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/room_npc_scene_template.dart';

class PoorVillageView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;
  final String? selectedNpcIdInRoom;
  final bool suppressRoomNpcRaster;

  const PoorVillageView({
    super.key,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    required this.onNPCTap,
    this.selectedNpcIdInRoom,
    this.suppressRoomNpcRaster = false,
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
    if (LocationsData.poorVillageRoomIds.contains(widget.currentRoom)) {
      return _buildHouseRoomsGrid(widget.currentRoom);
    }

    final npcService = sl<NPCService>();
    final h = widget.timeController.dateTime.hour;
    final day = widget.timeController.weekdayIndex;
    final dt = widget.timeController.dateTime;

    var chosen = NpcRoomScenePicker.pickDisplayedNpc(
      npcService: npcService,
      roomId: widget.currentRoom,
      hour: h,
      weekday: day,
      dateTime: dt,
      selectedNpcIdInRoom: widget.selectedNpcIdInRoom,
    );
    if (widget.suppressRoomNpcRaster) chosen = null;

    final roomData = LocationsData.poorVillageRooms[widget.currentRoom];
    final bg = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);
    final npcRaster = chosen == null
        ? null
        : NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);

    return RoomNpcSceneTemplate.clippedRoomWithNpcOverlay(
      roomBackgroundPath: bg,
      npcRasterAssetPath: npcRaster,
      npcRasterFallbackPath: chosen?.npc.avatarPath,
      onTap: () {
        if (chosen != null) widget.onNPCTap(chosen.npc);
      },
    );
  }

  /// Сітка 6 слотів Мажорщини (2×3): дім завуча, дім Каті, дім Amia тощо.
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

  /// Сітка 6 кімнат усередині будинку в Мажорщині.
  Widget _buildHouseRoomsGrid(String houseId) {
    final roomIds = LocationsData.getPoorVillageRoomIdsForHouse(houseId);
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
              roomData?.imagePath ?? 'lib/assets/location/home_gg/rooms/kitchen.jpg',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withValues(alpha: 0.4)),
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
