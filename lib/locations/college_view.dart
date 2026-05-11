import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/room_npc_scene_template.dart';
import '../data/college_schedule.dart';
import '../npcs/nicole/nicole_npc.dart';
import '../npcs/amia/amia_npc.dart';
import '../npcs/lisa/lisa_npc.dart';
import '../npcs/dekan/dekan_npc.dart';

class CollegeView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;
  /// Активний NPC для відображення оверлеїв у локаціях, де можуть бути 2+ NPC.
  /// Якщо null — показуємо оверлей як за розкладом.
  final String? activeNpcIdInRoom;
  /// Під час авто-сцени — без оверлеїв NPC у кімнаті, лише фон.
  final bool suppressRoomNpcRaster;

  const CollegeView({
    super.key,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    required this.onNPCTap,
    required this.activeNpcIdInRoom,
    this.suppressRoomNpcRaster = false,
  });

  @override
  State<CollegeView> createState() => _CollegeViewState();
}

class _CollegeViewState extends State<CollegeView> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isInsideRoom) return _buildRoomsGrid();

    final NPCService npcSvc = sl<NPCService>();
    final int h = widget.timeController.dateTime.hour;
    final int day = widget.timeController.weekdayIndex;

    final List<NPCModel> npcsInRoom = npcSvc.getNPCsInRoom(
      widget.currentRoom,
      h,
      day,
    );

    String? specialBackground;
    /// Студенти / Sem: растр знизу 90% як у Amia/Lisa, не на весь екран.
    String? studentSceneRasterOverlay;
    NPCModel? activeNPC;
    final List<({NPCModel npc, SchedulePoint point})> roomSceneCandidates = [];
    bool denActiveInHall = false;
    final bool denShouldAppearInHall =
        widget.currentRoom == LocationsData.collegeCorridor && h >= 9 && h <= 19;
    NPCModel? denNpc;
    final bool isDenActive = widget.activeNpcIdInRoom == 'den';

    bool loshokActiveInHall = false;
    final bool loshokShouldAppearInHall =
        widget.currentRoom == LocationsData.collegeCorridor && h >= 9 && h <= 19;
    NPCModel? loshokNpc;
    final bool isLoshokActive = widget.activeNpcIdInRoom == 'loshok';

    bool nicoleActiveInRoom = false;
    /// Кімнати, де Nicole може бути в будні 9–18 (див. [NPCService.nicoleCollegeRoamingRoom]).
    /// Історія (`auditorium_3`) — під час пар; коридор/директор — на перервах.
    final bool nicoleMayShowPlaceholder = h >= 9 &&
        h <= 18 &&
        ((widget.currentRoom == LocationsData.collegeCorridor ||
                widget.currentRoom == LocationsData.directorOffice) ||
            (widget.currentRoom == LocationsData.auditorium3 &&
                isCollegeLessonHour(h)));
    NPCModel? nicoleNpc;
    final bool isNicoleActive = widget.activeNpcIdInRoom == 'nicole';

    bool amiaActiveInEnglishRoom = false;
    NPCModel? amiaNpc;
    final bool isAmiaActive = widget.activeNpcIdInRoom == 'amia';

    bool lisaActiveInMathRoom = false;
    NPCModel? lisaNpc;
    final bool isLisaActive = widget.activeNpcIdInRoom == 'lisa';

    bool dekanActiveInOffice = false;
    NPCModel? dekanNpc;
    final bool isDekanActive = widget.activeNpcIdInRoom == 'dekan';

    for (var npc in npcsInRoom) {
      if (npc.id == 'nicole') {
        nicoleNpc = npc;
        nicoleActiveInRoom = true;
        continue;
      }
      if (npc.id == 'dekan' && widget.currentRoom == LocationsData.directorOffice) {
        dekanActiveInOffice = true;
        dekanNpc = npc;
        continue;
      }
      // Ден має бути показаний фото (прозоре PNG) поверх фону коридору (або туалету коледжу).
      if (npc.id == 'den') {
        denActiveInHall = widget.currentRoom == LocationsData.collegeCorridor ||
            widget.currentRoom == LocationsData.toilet;
        denNpc = npc;
        continue;
      }

      // Лошок має бути показаний оверлеєм поверх фону коридору (або туалету коледжу).
      if (npc.id == 'loshok') {
        loshokActiveInHall = widget.currentRoom == LocationsData.collegeCorridor ||
            widget.currentRoom == LocationsData.toilet;
        loshokNpc = npc;
        continue;
      }

      // Amia / Lisa — у будь-якій аудиторії (урок у «своїй» або перерва в будь-якій).
      if (npc.id == 'amia' && collegeTeacherBreakRoomIds.contains(widget.currentRoom)) {
        if (npcSvc.getCurrentLocationId(npc, h, day) == widget.currentRoom) {
          amiaActiveInEnglishRoom = true;
          amiaNpc = npc;
        }
        continue;
      }
      if (npc.id == 'lisa' && collegeTeacherBreakRoomIds.contains(widget.currentRoom)) {
        if (npcSvc.getCurrentLocationId(npc, h, day) == widget.currentRoom) {
          lisaActiveInMathRoom = true;
          lisaNpc = npc;
        }
        continue;
      }

      // Роумінг студентів (Sem, сестри тощо): у розкладі маркер college_hall, фактична кімната — аудиторія/перерва.
      // Тільки [NPCService.representativeSchedulePoint] узгоджує це з [getCurrentLocationId].
      final point = npcSvc.representativeSchedulePoint(
        npc,
        widget.currentRoom,
        h,
        day,
      );
      if (point != null && point.spritePath.isNotEmpty) {
        roomSceneCandidates.add((npc: npc, point: point));
      }
    }

    if (roomSceneCandidates.isNotEmpty) {
      final dt = widget.timeController.dateTime;
      final ({NPCModel npc, SchedulePoint point}) chosen =
          roomSceneCandidates.length == 1
              ? roomSceneCandidates.first
              : () {
                  if (widget.activeNpcIdInRoom != null) {
                    for (final c in roomSceneCandidates) {
                      if (c.npc.id == widget.activeNpcIdInRoom) return c;
                    }
                  }
                  final i = Random(
                    NpcRoomScenePicker.hourlySeed(dt, h, widget.currentRoom),
                  ).nextInt(roomSceneCandidates.length);
                  return roomSceneCandidates[i];
                }();
      activeNPC = chosen.npc;
      final sp = chosen.point.spritePath.trim();
      if (sp.isNotEmpty && NpcRoomScenePicker.isRasterAssetPath(sp)) {
        studentSceneRasterOverlay = sp;
      } else if (sp.isNotEmpty && NpcRoomScenePicker.isVideoAssetPath(sp)) {
        specialBackground = sp;
      } else if (sp.isNotEmpty) {
        specialBackground = sp;
      } else {
        final av = chosen.npc.avatarPath?.trim() ?? '';
        if (av.isNotEmpty && NpcRoomScenePicker.isRasterAssetPath(av)) {
          studentSceneRasterOverlay = av;
        }
      }
    }

    final NPCModel amiaModel = npcSvc.allNPCs.firstWhere((n) => n.id == 'amia');
    final NPCModel lisaModel = npcSvc.allNPCs.firstWhere((n) => n.id == 'lisa');
    final NPCModel dekanModel = npcSvc.allNPCs.firstWhere((n) => n.id == 'dekan');

    final bool amiaShouldAppearPlaceholder = isAmiaActive &&
        collegeTeacherBreakRoomIds.contains(widget.currentRoom) &&
        npcSvc.getCurrentLocationId(amiaModel, h, day) == widget.currentRoom &&
        !amiaActiveInEnglishRoom;

    final bool lisaShouldAppearPlaceholder = isLisaActive &&
        collegeTeacherBreakRoomIds.contains(widget.currentRoom) &&
        npcSvc.getCurrentLocationId(lisaModel, h, day) == widget.currentRoom &&
        !lisaActiveInMathRoom;

    final bool dekanShouldAppearPlaceholder = isDekanActive &&
        widget.currentRoom == LocationsData.directorOffice &&
        npcSvc.getCurrentLocationId(dekanModel, h, day) == LocationsData.directorOffice &&
        !dekanActiveInOffice;

    // Для спеціальних оверлеїв (Den/Loshok/Nicole/Dekan/Amia/Lisa)
    // вимикаємо «звичайний» студентський шар, щоб картинки не накладались.
    final bool shouldHideGenericStudentScene = isDenActive ||
        isLoshokActive ||
        isNicoleActive ||
        isDekanActive ||
        isAmiaActive ||
        isLisaActive;
    if (shouldHideGenericStudentScene) {
      specialBackground = null;
      studentSceneRasterOverlay = null;
      activeNPC = null;
    }

    if (widget.suppressRoomNpcRaster) {
      studentSceneRasterOverlay = null;
      specialBackground = null;
      activeNPC = null;
      denActiveInHall = false;
      loshokActiveInHall = false;
      nicoleActiveInRoom = false;
      dekanActiveInOffice = false;
      amiaActiveInEnglishRoom = false;
      lisaActiveInMathRoom = false;
    }

    final roomData = LocationsData.collegeRooms[widget.currentRoom];
    // Відео / нестандартний медіа — повноекранно; растр студентів — фон кімнати + оверлей знизу (як у викладачів).
    final String finalMedia = specialBackground ?? roomData?.imagePath ?? 'lib/assets/location/home_gg/rooms/kitchen.jpg';

    return GestureDetector(
      onTap: () {
        if (activeNPC != null) {
          widget.onNPCTap(activeNPC);
          return;
        }
        // Ден відображається як окремий оверлей, але кнопки справа
        // мають відкриватися і при тапі по ньому (через tap по всій картинці).
        if (denActiveInHall && denNpc != null && isDenActive) {
          widget.onNPCTap(denNpc);
          return;
        }
        if (loshokActiveInHall && loshokNpc != null && isLoshokActive) {
          widget.onNPCTap(loshokNpc);
          return;
        }
        if (nicoleActiveInRoom && nicoleNpc != null && isNicoleActive) {
          widget.onNPCTap(nicoleNpc);
          return;
        }
        if (dekanActiveInOffice && dekanNpc != null && isDekanActive) {
          widget.onNPCTap(dekanNpc);
          return;
        }
        if (amiaActiveInEnglishRoom && amiaNpc != null && isAmiaActive) {
          widget.onNPCTap(amiaNpc);
          return;
        }
        if (lisaActiveInMathRoom && lisaNpc != null && isLisaActive) {
          widget.onNPCTap(lisaNpc);
          return;
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildMediaContent(finalMedia),
                if (studentSceneRasterOverlay != null &&
                    studentSceneRasterOverlay.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (activeNPC != null) widget.onNPCTap(activeNPC);
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.9,
                        width: double.infinity,
                        child: Image.asset(
                          studentSceneRasterOverlay,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (denActiveInHall &&
                    isDenActive &&
                    denNpc?.avatarPath != null &&
                    denNpc!.avatarPath!.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(denNpc!),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.9,
                        child: Image.asset(
                          denNpc.avatarPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (!denActiveInHall && denShouldAppearInHall && isDenActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: constraints.maxHeight * 0.9,
                      child: Image.asset(
                        'lib/assets/npcs/den/den_ava.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                // Лошок показується як оверлей поверх фону (але не як background-сprite).
                if (loshokActiveInHall &&
                    isLoshokActive &&
                    loshokNpc?.avatarPath != null &&
                    loshokNpc!.avatarPath!.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(loshokNpc!),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.9,
                        child: Image.asset(
                          loshokNpc.avatarPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (!loshokActiveInHall &&
                    loshokShouldAppearInHall &&
                    isLoshokActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: constraints.maxHeight * 0.9,
                      child: Image.asset(
                        'lib/assets/npcs/loh/loshok.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                if (nicoleActiveInRoom &&
                    isNicoleActive &&
                    nicoleNpc?.avatarPath != null &&
                    nicoleNpc!.avatarPath!.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(nicoleNpc!),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.9,
                        child: Image.asset(
                          nicoleNpc.avatarPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (!nicoleActiveInRoom &&
                    nicoleMayShowPlaceholder &&
                    isNicoleActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: constraints.maxHeight * 0.9,
                      child: Image.asset(
                        kNicoleAvatarPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                if (dekanActiveInOffice &&
                    isDekanActive &&
                    dekanNpc?.avatarPath != null &&
                    dekanNpc!.avatarPath!.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(dekanNpc!),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.82,
                        width: constraints.maxWidth * 0.48,
                        child: Image.asset(
                          dekanNpc.avatarPath!,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (!dekanActiveInOffice && dekanShouldAppearPlaceholder)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: constraints.maxHeight * 0.82,
                      width: constraints.maxWidth * 0.48,
                      child: Image.asset(
                        kDekanAvatarPath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                // Amia / Lisa — у «своїй» аудиторії на уроках або в одній з кімнат перерви.
                if (amiaActiveInEnglishRoom &&
                    isAmiaActive &&
                    amiaNpc?.avatarPath != null &&
                    amiaNpc!.avatarPath!.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(amiaNpc!),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.9,
                        width: double.infinity,
                        child: Image.asset(
                          amiaNpc.avatarPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (!amiaActiveInEnglishRoom &&
                    amiaShouldAppearPlaceholder &&
                    isAmiaActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: constraints.maxHeight * 0.9,
                      width: double.infinity,
                      child: Image.asset(
                        kAmiaAvatarPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                // Lisa — клас математики: фон audit_2 + персонаж 90%.
                if (lisaActiveInMathRoom &&
                    isLisaActive &&
                    lisaNpc?.avatarPath != null &&
                    lisaNpc!.avatarPath!.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => widget.onNPCTap(lisaNpc!),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: constraints.maxHeight * 0.9,
                        width: double.infinity,
                        child: Image.asset(
                          lisaNpc.avatarPath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                if (!lisaActiveInMathRoom &&
                    lisaShouldAppearPlaceholder &&
                    isLisaActive)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: constraints.maxHeight * 0.9,
                      width: double.infinity,
                      child: Image.asset(
                        kLisaAvatarPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaContent(String path) {
    return RoomNpcSceneTemplate.layerBackground(path);
  }

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
          children: LocationsData.collegeRoomIds.map((roomId) => _roomCard(roomId)).toList(),
        );
      },
    );
  }

  Widget _roomCard(String roomId) {
    final roomData = LocationsData.collegeRooms[roomId];
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
