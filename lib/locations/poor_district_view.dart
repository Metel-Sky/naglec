import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../services/player_stats_controller.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/insufficient_money_dialog.dart';
import '../widgets/room_npc_scene_template.dart';

class PoorDistrictView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;
  final String? selectedNpcIdInRoom;
  /// Під час авто-сцени — без растру NPC у кімнаті, лише фон.
  final bool suppressRoomNpcRaster;

  const PoorDistrictView({
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
  State<PoorDistrictView> createState() => _PoorDistrictViewState();
}

class _PoorDistrictViewState extends State<PoorDistrictView> {
  static const String _poorDistrictGymExerciseImage =
      'lib/assets/location/poor_district/zhim_lezha.jpg';

  /// Під час тренування — інша картинка; скидається при виході з качалки.
  bool _poorDistrictGymExercising = false;

  @override
  void didUpdateWidget(PoorDistrictView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoom == LocationsData.poorDistrictGym &&
        widget.currentRoom != LocationsData.poorDistrictGym) {
      _poorDistrictGymExercising = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInsideRoom && widget.currentRoom == LocationsData.poorDistrictOverview) {
      return _buildRoomsGrid();
    }
    if (widget.currentRoom == LocationsData.poorDistrictResidentialOverview) {
      return _buildHousesGrid();
    }
    if (widget.currentRoom == LocationsData.poorDistrictStripBar) {
      return _buildStripBarGrid();
    }
    if (widget.currentRoom == LocationsData.poorDistrictGym) {
      return _buildPoorDistrictGym();
    }
    if (widget.currentRoom == LocationsData.poorDistrictHouse1 ||
        widget.currentRoom == LocationsData.poorDistrictHouse2) {
      return _buildApartmentsGrid(widget.currentRoom);
    }
    final apartmentRoomIds = LocationsData.getPoorDistrictRoomIdsForApartment(widget.currentRoom);
    if (apartmentRoomIds.isNotEmpty) {
      return _buildRoomsGridForApartment(apartmentRoomIds);
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

    final roomData = LocationsData.poorDistrictRooms[widget.currentRoom];
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

  /// Качалка: «Займатись» → zhim_lezha; «Закінчити» → фон залу, +2 год, −10 $, +2 сили.
  Widget _buildPoorDistrictGym() {
    final npcService = sl<NPCService>();
    final h = widget.timeController.dateTime.hour;
    final day = widget.timeController.weekdayIndex;
    final dt = widget.timeController.dateTime;
    final roomData = LocationsData.poorDistrictRooms[widget.currentRoom];
    final gymBg = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);
    final bgPath =
        _poorDistrictGymExercising ? _poorDistrictGymExerciseImage : gymBg;

    ({NPCModel npc, SchedulePoint point})? chosen;
    if (!_poorDistrictGymExercising && !widget.suppressRoomNpcRaster) {
      chosen = NpcRoomScenePicker.pickDisplayedNpc(
        npcService: npcService,
        roomId: widget.currentRoom,
        hour: h,
        weekday: day,
        dateTime: dt,
        selectedNpcIdInRoom: widget.selectedNpcIdInRoom,
      );
    }
    final npcRaster = chosen == null
        ? null
        : NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);
    final rawNpc = npcRaster;
    final hasNpc = rawNpc != null &&
        rawNpc.isNotEmpty &&
        !rawNpc.endsWith('.mp4') &&
        !rawNpc.endsWith('.webm');

    return ClipRRect(
      borderRadius: BorderRadius.circular(RoomNpcSceneTemplate.defaultClipRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final overlayHeight = maxH.isFinite
              ? maxH * RoomNpcSceneTemplate.npcOverlayHeightFraction
              : 400.0;

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: RoomNpcSceneTemplate.layerBackground(bgPath),
              ),
              if (hasNpc && chosen != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: overlayHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(chosen!.npc),
                    child: Image.asset(
                      rawNpc,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) {
                        final fb = chosen!.npc.avatarPath?.trim();
                        if (fb != null && fb.isNotEmpty) {
                          return Image.asset(
                            fb,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.bottomCenter,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (c, e, s) => const SizedBox.shrink(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _poorDistrictGymExercising
                        ? ElevatedButton(
                            style: GameTheme.actionButtonStyle(),
                            onPressed: () => _finishPoorDistrictGymWorkout(context),
                            child: const Text('Закінчити'),
                          )
                        : ElevatedButton(
                            style: GameTheme.actionButtonStyle(),
                            onPressed: () =>
                                setState(() => _poorDistrictGymExercising = true),
                            child: const Text('Займатись'),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _finishPoorDistrictGymWorkout(BuildContext context) {
    final stats = sl<PlayerStatsController>();
    if (stats.money < 10) {
      showInsufficientMoneyDialog(context);
      return;
    }
    widget.timeController.addMinutes(120);
    stats.changeMoney(-10);
    stats.changeEnergy(-20);
    stats.changePhysicalFitness(2);
    setState(() => _poorDistrictGymExercising = false);
  }

  /// Сітка 6 слотів бідного району (2×3): качалка, магазин, стріп бар, темний провулок, спальні будинки, готель.
  Widget _buildRoomsGrid() {
    final roomIds = LocationsData.poorDistrictRoomIds;
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

  /// Сітка 2 будинків (спальні будинки).
  Widget _buildHousesGrid() {
    final houseIds = LocationsData.poorDistrictResidentialHouseIds;
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12.0;
        const int crossCount = 2;
        final cellWidth = (constraints.maxWidth - spacing) / crossCount;
        final cellHeight = constraints.maxHeight;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: houseIds.map((id) => _roomCard(id)).toList(),
        );
      },
    );
  }

  /// Сітка 2 кімнат стріп-бару: VIP зал і туалет.
  Widget _buildStripBarGrid() {
    final roomIds = LocationsData.poorDistrictStripBarRoomIds;
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12.0;
        const int crossCount = 2;
        final cellWidth = (constraints.maxWidth - spacing) / crossCount;
        final cellHeight = constraints.maxHeight;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: roomIds.map((id) => _roomCard(id)).toList(),
        );
      },
    );
  }

  /// Сітка 3 квартир у будинку.
  Widget _buildApartmentsGrid(String houseId) {
    final apartmentIds = LocationsData.getPoorDistrictApartmentIds(houseId);
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12.0;
        const int crossCount = 3;
        final cellWidth = (constraints.maxWidth - (spacing * (crossCount - 1))) / crossCount;
        final cellHeight = constraints.maxHeight;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: apartmentIds.map((id) => _roomCard(id)).toList(),
        );
      },
    );
  }

  /// Сітка 4 кімнат у квартирі.
  Widget _buildRoomsGridForApartment(List<String> roomIds) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12.0;
        const int crossCount = 2;
        final rowCount = (roomIds.length / crossCount).ceil();
        final cellWidth = (constraints.maxWidth - spacing) / crossCount;
        final cellHeight = (constraints.maxHeight - (spacing * (rowCount - 1))) / rowCount;
        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: roomIds.map((id) => _roomCard(id)).toList(),
        );
      },
    );
  }

  Widget _roomCard(String roomId) {
    final roomData = LocationsData.poorDistrictRooms[roomId];
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
