import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../services/inventory_controller.dart';
import '../services/game_world_state.dart';
import '../services/save_service.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/room_npc_scene_template.dart';
import '../npcs/mom/mom_room_hours.dart';
import '../npcs/mom/mom_video_func.dart' as mom_vf;
import '../services/locale_controller.dart';

class HomeView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  /// Якщо в кімнаті 2+ NPC — id обраного в лівій панелі; null = показувати обраного по seed.
  final String? selectedNpcIdInRoom;
  final Function(NPCModel) onNPCTap;
  /// Кнопки в кімнаті ГГ (ноутбук, сейф, будильник, спати)
  final VoidCallback? onOpenLaptop;
  final VoidCallback? onOpenSafe;
  final VoidCallback? onSetAlarm;
  final VoidCallback? onSleep;
  /// Під час авто-сцени (напр. «спалився») — без растру/відео NPC у кімнаті, лише фон.
  final bool suppressRoomNpcRaster;

  const HomeView({
    super.key,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    this.selectedNpcIdInRoom,
    required this.onNPCTap,
    this.suppressRoomNpcRaster = false,
    this.onOpenLaptop,
    this.onOpenSafe,
    this.onSetAlarm,
    this.onSleep,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  VoidCallback? get _onOpenLaptop => widget.onOpenLaptop;
  VoidCallback? get _onOpenSafe => widget.onOpenSafe;
  VoidCallback? get _onSetAlarm => widget.onSetAlarm;
  VoidCallback? get _onSleep => widget.onSleep;
  String _t(String key) => sl<LocaleController>().t(key);

  /// Seed для вибору NPC / медіа в кімнаті: один раз на календарний день гри (дата + кімната).
  static int _dailySeed(DateTime dt, String location) {
    final dayPart = dt.year * 10000 + dt.month * 100 + dt.day;
    return dayPart * 31 + location.hashCode;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Якщо ми не в кімнаті — малюємо сітку вибору
    if (!widget.isInsideRoom) return _buildRoomsGrid();

    // 2. Отримуємо список NPC в цій кімнаті
    final npcService = sl<NPCService>();
    final int day = widget.timeController.weekdayIndex;
    final List<NPCModel> npcsInRoom = npcService.getNPCsInRoom(
      widget.currentRoom,
      widget.timeController.dateTime.hour,
      day,
    );

    // 3. Збираємо всіх NPC у цій кімнаті з непорожнім sprite; якщо кілька — обираємо одного на годину (детермінований рандом).
    // [representativeSchedulePoint] — роумінг коледжу (маркер college_hall vs фактична аудиторія) тощо.
    String? specialBackground;
    String? npcRasterOverlay;
    NPCModel? activeNPC;
    final int h = widget.timeController.dateTime.hour;
    final dt = widget.timeController.dateTime;
    final world = sl<GameWorldState>();
    final List<({NPCModel npc, SchedulePoint point})> candidates = [];

    for (var npc in npcsInRoom) {
      var point = npcService.representativeSchedulePoint(
        npc,
        widget.currentRoom,
        h,
        day,
      );
      // Якщо точка розкладу не зібралась, але мама фактично в mom_room і має динамічне відео —
      // підставляємо синтетичну точку з порожнім sprite (як у розкладі 22–23 / sleep).
      if (point == null &&
          npc.id == 'mom' &&
          widget.currentRoom == LocationsData.momRoom &&
          momRoomDynamicEveningMediaHour(h) &&
          npcService.getCurrentLocationId(npc, h, day) == LocationsData.momRoom) {
        point = SchedulePoint(
          hourStart: h,
          hourEnd: h,
          location: LocationsData.momRoom,
          actionLabel: '',
          spritePath: '',
        );
      }
      if (point == null) continue;
      final useDynamicEvening = npc.id == 'mom' &&
          widget.currentRoom == LocationsData.momRoom &&
          momRoomDynamicEveningMediaHour(h) &&
          point.spritePath.trim().isEmpty;
      if (point.spritePath.isNotEmpty || useDynamicEvening) {
        candidates.add((npc: npc, point: point));
      }
    }

    if (candidates.isNotEmpty && !widget.suppressRoomNpcRaster) {
      final chosen = candidates.length == 1
          ? candidates.first
          : () {
              if (widget.selectedNpcIdInRoom != null) {
                final match = candidates.where((c) => c.npc.id == widget.selectedNpcIdInRoom).firstOrNull;
                if (match != null) return match;
              }
              final pickSeed = _dailySeed(dt, widget.currentRoom);
              return candidates[Random(pickSeed).nextInt(candidates.length)];
            }();
      final sp = chosen.point.spritePath.trim();
      if (sp.isNotEmpty && NpcRoomScenePicker.isVideoAssetPath(sp)) {
        specialBackground = sp;
      } else if (sp.isNotEmpty) {
        npcRasterOverlay = NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);
      }
      activeNPC = chosen.npc;
    }

    // Seed для медіа: один раз на добу для цієї кімнати (календарний день гри).
    final mediaSeed = _dailySeed(dt, widget.currentRoom) + 9999;
    // Мама на кухні: ранок (7) — відео сніданку.
    // Вечірні відео на кухні вимкнено (використовується статичний фон кімнати).
    if (activeNPC?.id == 'mom' &&
        widget.currentRoom == 'kitchen') {
      if (h == 7) {
        final kitchenSeed = world.kitchenVisitSeed ?? mediaSeed;
        specialBackground = mom_vf.momKitchenMorningSeeded(kitchenSeed);
      }
    }
    // Мама у кімнаті: 23–6 — три sleep; 22–23 і 6–7 — два pereodevaetsa.
    // Зв’язку з activeNPC недостатньо: representativeSchedulePoint інколи null → тоді беремо розклад напряму.
    final momNpc = npcService.npcById('mom');
    final momNightVideoHere = momNpc != null &&
        widget.currentRoom == LocationsData.momRoom &&
        momRoomDynamicEveningMediaHour(h) &&
        npcService.getCurrentLocationId(momNpc, h, day) == LocationsData.momRoom;
    if (momNightVideoHere) {
      final momSeed = world.momRoomNightVisitSeed ?? mediaSeed;
      specialBackground = momRoomSleepTrioHour(h)
          ? mom_vf.momRoomEveningVideoListSeeded(momSeed)
          : mom_vf.momRoomMorningVideoListSeeded(momSeed);
      activeNPC ??= momNpc;
    }
    // Мама у ванній 8–9
    if (activeNPC?.id == 'mom' &&
        widget.currentRoom == 'bathroom') {
      if (h >= 8 && h < 9) {
        specialBackground = mom_vf.momShowerMorningVideosSeeded(mediaSeed);
      }
    }
    // 4. Визначаємо фінальний шлях до медіа
    final roomData = LocationsData.homeRooms[widget.currentRoom];
    final String finalMedia = specialBackground ?? roomData?.imagePath ?? 'lib/assets/location/home_gg/rooms/kitchen.jpg';

    // 5. Повертаємо контент кімнати
    final bool useNpcOverlayScene =
        npcRasterOverlay != null && npcRasterOverlay.isNotEmpty && !NpcRoomScenePicker.isVideoAssetPath(finalMedia);
    final Widget mediaContent = useNpcOverlayScene
        ? RoomNpcSceneTemplate.clippedRoomWithNpcOverlay(
            roomBackgroundPath: NpcRoomScenePicker.roomBackgroundPath(finalMedia),
            npcRasterAssetPath: npcRasterOverlay,
            npcRasterFallbackPath: activeNPC?.avatarPath,
            onTap: () {
              if (activeNPC != null) widget.onNPCTap(activeNPC);
            },
          )
        : GestureDetector(
            onTap: () {
              if (activeNPC != null) widget.onNPCTap(activeNPC);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildMediaContent(finalMedia),
            ),
          );

    // У кімнаті ГГ — три кнопки внизу (стиль як у меню локацій)
    if (widget.currentRoom == LocationsData.roomGg) {
      return Stack(
        fit: StackFit.expand,
        children: [
          mediaContent,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(child: _roomGgButton(_t('room_gg_laptop'), _onOpenLaptop)),
                    const SizedBox(width: 8),
                    Expanded(child: _roomGgButton(_t('room_gg_safe'), _onOpenSafe)),
                    const SizedBox(width: 8),
                    Expanded(child: _roomGgButton(_t('room_gg_alarm'), _onSetAlarm)),
                    const SizedBox(width: 8),
                    Expanded(child: _roomGgButton(_t('room_gg_sleep'), _onSleep)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // У кімнаті мами або сестер: якщо нікого немає й у ГГ є міні-камера — кнопка «Встановити камеру»
    const cameraableRooms = [
      LocationsData.elsaRoom,
      LocationsData.piperRoom,
    ];
    final hasSpyCamera = sl<InventoryController>().items.any((e) => e.id == 'spy_camera');
    final canInstallCamera = cameraableRooms.contains(widget.currentRoom) &&
        npcsInRoom.isEmpty &&
        hasSpyCamera &&
        !world.installedSpyCameraRooms.contains(widget.currentRoom);
    if (canInstallCamera) {
      return Stack(
        fit: StackFit.expand,
        children: [
          mediaContent,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: GameTheme.mainGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        sl<InventoryController>().removeItem('spy_camera');
                        world.installedSpyCameraRooms.add(widget.currentRoom);
                        sl<SaveService>().autosave();
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            _t('room_install_camera'),
                            style: const TextStyle(
                              color: GameTheme.textBlack,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return mediaContent;
  }

  /// Кнопка в кімнаті ГГ: сірий фон, при натисканні — ripple поверх (через Ink, не Container).
  Widget _roomGgButton(String label, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: GameTheme.mainGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onPressed ?? () {},
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.black.withValues(alpha: 0.2),
          highlightColor: Colors.black.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: GameTheme.textBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(String path) {
    return RoomNpcSceneTemplate.layerBackground(path);
  }

  // --- СІТКА КІМНАТ ---
  Widget _buildRoomsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 12.0;
        double cellWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        double cellHeight = (constraints.maxHeight - (spacing * 2)) / 3;

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: cellWidth / cellHeight,
          children: LocationsData.homeRoomIds.map((roomId) => _roomCard(roomId)).toList(),
        );
      },
    );
  }

  Widget _roomCard(String roomId) {
    final roomData = LocationsData.homeRooms[roomId];
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
              child: Text(
                displayName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}