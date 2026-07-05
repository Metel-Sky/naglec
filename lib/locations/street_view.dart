import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/npc_service.dart';
import '../services/service_locator.dart';
import '../models/npc_model.dart';
import '../models/room_models.dart';
import '../npcs/juniper/juniper_npc.dart';
import '../npcs/sem/sem_juniper_room_intro.dart';
import '../npcs/sem/sem_juniper_evening_visits.dart';
import '../services/game_time_controller.dart';
import '../widgets/room_npc_scene_template.dart';
import '../widgets/video_scene_widget.dart';

class StreetView extends StatelessWidget {
  /// Якщо не null — ми всередині одного з 4 будинків (показуємо 9 слотів як у домі гг)
  final String? currentStreetHouse;
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;
  /// Для кількох NPC у кімнаті — збіг з [MainGameNpcAvatarStrip].
  final String? selectedNpcIdInRoom;
  /// Під час авто-сцени — без растру NPC у кімнаті, лише фон.
  final bool suppressRoomNpcRaster;

  /// Вечірній кліп Juniper (1 раз на добу) — лише на поточному заході в кімнату.
  final bool semJuniperEveningClipShowOnThisVisit;

  /// Екран «біля дверей» дому кориша (лише фото; кнопки — у локаційному меню).
  final bool friendHouseStreetFacade;
  final ValueChanged<bool> onFriendHouseStreetFacadeChanged;

  /// Сцена intro Alex ↔ Juniper у кімнаті Sem (відео через [StreetView], не EventInteractionOverlay).
  final bool semJuniperIntroActive;

  const StreetView({
    super.key,
    required this.currentStreetHouse,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    required this.onNPCTap,
    this.selectedNpcIdInRoom,
    this.suppressRoomNpcRaster = false,
    this.semJuniperEveningClipShowOnThisVisit = false,
    this.semJuniperIntroActive = false,
    required this.friendHouseStreetFacade,
    required this.onFriendHouseStreetFacadeChanged,
  });

  void _onStreetGridHouseTap(String roomId) {
    if (roomId == LocationsData.friendHouse) {
      onFriendHouseStreetFacadeChanged(true);
    } else {
      onRoomTap(roomId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Під’їзд до дому кориша: повний блок — фото будинку та кнопки
    if (currentStreetHouse == null &&
        !isInsideRoom &&
        friendHouseStreetFacade) {
      return _buildFriendHouseStreetFacade();
    }

    // Всередині будинку на вулиці: власна сітка кімнат для цього будинку
    if (currentStreetHouse != null) {
      final houseRooms = LocationsData.getRoomsForStreetHouse(currentStreetHouse);
      if (!isInsideRoom) return _buildHouseRoomsGrid(houseRooms);
      return _buildRoomContent(houseRooms?[currentRoom]);
    }
    // На вулиці: сітка 4 будинки
    if (!isInsideRoom) return _buildRoomsGrid();

    final roomData = LocationsData.streetRooms[currentRoom];
    return _buildRoomContent(roomData);
  }

  Widget _buildFriendHouseStreetFacade() {
    final roomData = LocationsData.streetRooms[LocationsData.friendHouse];
    final path = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(RoomNpcSceneTemplate.defaultClipRadius),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: GameTheme.bgDark,
          alignment: Alignment.center,
          child: Icon(Icons.home, color: Colors.white.withValues(alpha: 0.4), size: 64),
        ),
      ),
    );
  }

  Widget _buildRoomContent(RoomData? roomData) {
    final npcService = sl<NPCService>();
    final dateKey = timeController.onlyDate;
    final h = timeController.dateTime.hour;
    final day = timeController.weekdayIndex;
    final dt = timeController.dateTime;
    final roomNorm = LocationsData.migrateLegacyRoomId(currentRoom);

    final candidates = suppressRoomNpcRaster
        ? <({NPCModel npc, SchedulePoint point})>[]
        : npcService.getCandidatesInRoom(currentRoom, h, day);

    final bg = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);

    if (semJuniperIntroActive &&
        currentStreetHouse == LocationsData.friendHouse &&
        roomNorm == LocationsData.friendRoom) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(RoomNpcSceneTemplate.defaultClipRadius),
        child: VideoSceneWidget(
          videoPath: SemJuniperRoomIntro.videoPath,
          loop: true,
          fallbackImagePath: roomData?.imagePath,
        ),
      );
    }

    if (semJuniperEveningClipShowOnThisVisit &&
        currentStreetHouse == LocationsData.friendHouse) {
      final visitRoom = SemJuniperEveningVisits.locationAtHour(
        gameDateKey: dateKey,
        weekdayIndex: day,
        hour: h,
      );
      if (visitRoom != null &&
          SemJuniperEveningVisits.hasEveningClipForRoom(visitRoom) &&
          visitRoom == roomNorm) {
        final clip = SemJuniperEveningVisits.dailyClipPath(dateKey, visitRoom);
        NPCModel? juniperNpc;
        for (final c in candidates) {
          if (c.npc.id == kJuniperNpcId) {
            juniperNpc = c.npc;
            break;
          }
        }
        return GestureDetector(
          onTap: () {
            if (juniperNpc != null) onNPCTap(juniperNpc);
          },
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(RoomNpcSceneTemplate.defaultClipRadius),
            child: KeyedSubtree(
              key: ValueKey('juniper_evening_clip_${dateKey}_$roomNorm'),
              child: RoomNpcSceneTemplate.layerBackground(
                clip,
                fallbackImagePath: roomData?.imagePath,
              ),
            ),
          ),
        );
      }
    }

    var chosen = NpcRoomScenePicker.pickDisplayedNpc(
      npcService: npcService,
      roomId: currentRoom,
      hour: h,
      weekday: day,
      dateTime: dt,
      selectedNpcIdInRoom: selectedNpcIdInRoom,
    );
    if (suppressRoomNpcRaster) chosen = null;

    String? specialBackground;
    NPCModel? activeNpc;
    if (chosen != null) {
      final sp = chosen.point.spritePath.trim();
      if (sp.isNotEmpty && NpcRoomScenePicker.isVideoAssetPath(sp)) {
        specialBackground = sp;
        activeNpc = chosen.npc;
      }
    }

    final finalMedia = specialBackground ?? bg;
    if (NpcRoomScenePicker.isVideoAssetPath(finalMedia)) {
      return GestureDetector(
        onTap: () {
          if (activeNpc != null) onNPCTap(activeNpc);
        },
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(RoomNpcSceneTemplate.defaultClipRadius),
          child: RoomNpcSceneTemplate.layerBackground(
            finalMedia,
            fallbackImagePath: roomData?.imagePath,
          ),
        ),
      );
    }

    final npcRaster = chosen == null
        ? null
        : NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);

    return RoomNpcSceneTemplate.clippedRoomWithNpcOverlay(
      roomBackgroundPath: bg,
      npcRasterAssetPath: npcRaster,
      npcRasterFallbackPath: chosen?.npc.avatarPath,
      onTap: () {
        if (chosen != null) onNPCTap(chosen.npc);
      },
    );
  }

  /// Сітка кімнат всередині будинку на вулиці (власні дані будинку; у будинку кориша — 6 кімнат)
  Widget _buildHouseRoomsGrid(Map<String, RoomData>? houseRooms) {
    if (houseRooms == null || currentStreetHouse == null) return const SizedBox();
    final roomIds = LocationsData.getRoomIdsForStreetHouse(currentStreetHouse);
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
      onTap: () => onRoomTap(roomId),
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
      onTap: () => _onStreetGridHouseTap(roomId),
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
