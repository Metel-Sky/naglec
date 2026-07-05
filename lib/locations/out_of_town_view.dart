import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/npc_room_scene_resolver.dart';
import '../widgets/room_npc_scene_template.dart';

class OutOfTownView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;
  final String? selectedNpcIdInRoom;
  final bool suppressRoomNpcRaster;

  const OutOfTownView({
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
  State<OutOfTownView> createState() => _OutOfTownViewState();
}

class _OutOfTownViewState extends State<OutOfTownView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isInsideRoom && widget.currentRoom == LocationsData.outOfTownOverview) {
      return _buildRoomsGrid();
    }
    if (widget.isInsideRoom && widget.currentRoom == LocationsData.outOfTownClub) {
      return _buildClubRoomsGrid();
    }

    final npcService = sl<NPCService>();
    final h = widget.timeController.dateTime.hour;
    final day = widget.timeController.weekdayIndex;
    final dt = widget.timeController.dateTime;

    final layers = NpcRoomSceneResolver.resolve(
      npcService: npcService,
      roomId: widget.currentRoom,
      hour: h,
      weekday: day,
      dateTime: dt,
      selectedNpcIdInRoom: widget.selectedNpcIdInRoom,
      suppressRoomNpcRaster: widget.suppressRoomNpcRaster,
    );

    final roomData = LocationsData.outOfTownRooms[widget.currentRoom];
    final bg = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);
    final npcRaster = layers.npcRasterOverlay;
    final activeNpc = layers.activeNpc;

    return RoomNpcSceneTemplate.clippedRoomWithNpcOverlay(
      roomBackgroundPath: bg,
      npcRasterAssetPath: npcRaster,
      npcRasterFallbackPath: activeNpc?.avatarPath,
      onTap: () {
        if (activeNpc != null) widget.onNPCTap(activeNpc);
      },
    );
  }

  /// Сітка 4 слотів «На море» (2×2): набережна, пляж, клуб, пристань.
  Widget _buildRoomsGrid() {
    final roomIds = LocationsData.outOfTownRoomIds;
    const int crossCount = 2;
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
    final roomData = LocationsData.outOfTownRooms[roomId];
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

  /// Клуб «На морі»: 2 підлокації (бар, туалет), як вкладені кімнати.
  Widget _buildClubRoomsGrid() {
    final roomIds = LocationsData.outOfTownClubRoomIds;
    const int crossCount = 2;
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12.0;
        final double cellWidth = (constraints.maxWidth - spacing) / crossCount;
        final double cellHeight = constraints.maxHeight;
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
}
