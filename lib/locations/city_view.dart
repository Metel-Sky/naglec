import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../data/locations_room_data.dart';
import '../npcs/cherie/cherie_quests.dart';
import '../services/service_locator.dart';
import '../services/npc_service.dart';
import '../models/npc_model.dart';
import '../services/game_time_controller.dart';
import '../widgets/room_npc_scene_template.dart';
import '../widgets/video_scene_widget.dart';
import '../widgets/laptop_shop_view.dart' show ShopProduct;
import 'company/logistics_company_view.dart';
import 'company/logistics_boss_office_view.dart';
import 'company/gleam_team_company_view.dart';
import 'company/call_center_company_view.dart';
import 'company/call_center_operators_hall_view.dart';
import 'company/call_center_boss_office_view.dart';
import 'company/rockefeller_company_view.dart';
import 'car_dealership_company_view.dart';
import 'park_view.dart';
import 'trc/electronics/trc_electronics_shop_view.dart';
import 'trc/gift_shop/trc_gift_shop_view.dart';
import 'trc/general_shop/trc_general_shop_view.dart';
import 'trc/grid/trc_mall_grid.dart';
import 'trc/pharmacy/trc_pharmacy_view.dart';
import 'trc/restaurant/trc_restaurant_view.dart';
import 'trc/sex_shop/trc_sex_shop_view.dart';

class CityView extends StatefulWidget {
  final String currentRoom;
  final bool isInsideRoom;
  final Function(String) onRoomTap;
  final VoidCallback onBack;
  final GameTimeController timeController;
  final Function(NPCModel) onNPCTap;
  /// Якщо задано й ГГ у магазині ТРЦ — показується інтерфейс магазину замість кімнати.
  final List<ShopProduct>? mallShopProducts;
  final String? mallShopTitle;
  final void Function(ShopProduct)? onMallShopProductTap;
  /// При натисканні «Офіс мами» у логістиці — відкрити відео на весь екран і показати 3 кнопки в меню.
  final VoidCallback? onLogisticsOfficeTap;
  /// Офіс Рокфеллера в БЦ — повноекранний інтер’єр + панель дій, як у логістиці.
  final VoidCallback? onRockefellerCabinetTap;
  /// Приймальня компанії Рокфеллера — повноекранний кадр.
  final VoidCallback? onRockefellerReceptionTap;
  /// Якщо в кімнаті 2+ NPC (наприклад автосалон) — id обраного в лівій панелі; null = той самий вибір по seed, що й у [MainGameNpcAvatarStrip].
  final String? selectedNpcIdInRoom;
  /// Під час авто-сцени — без растру/відео NPC у кімнаті, лише фон.
  final bool suppressRoomNpcRaster;
  /// Якщо true — у офісі Cherie не показувати повноекранний цикл tc_1 під сцену (відео лише в оверлеї івенту).
  final bool suppressCherieGiftShopOfficeTc1Background;

  const CityView({
    super.key,
    required this.currentRoom,
    required this.isInsideRoom,
    required this.onRoomTap,
    required this.onBack,
    required this.timeController,
    required this.onNPCTap,
    this.mallShopProducts,
    this.mallShopTitle,
    this.onMallShopProductTap,
    this.onLogisticsOfficeTap,
    this.onRockefellerCabinetTap,
    this.onRockefellerReceptionTap,
    this.selectedNpcIdInRoom,
    this.suppressRoomNpcRaster = false,
    this.suppressCherieGiftShopOfficeTc1Background = false,
  });

  @override
  State<CityView> createState() => _CityViewState();
}

class _CityViewState extends State<CityView> {
  /// Як у [HomeView]: один вибір на календарний день гри для цієї кімнати.
  static int _dailySeed(DateTime dt, String location) {
    final dayPart = dt.year * 10000 + dt.month * 100 + dt.day;
    return dayPart * 31 + location.hashCode;
  }

  /// Кандидати для сцени в [roomId], узгоджено з `getCurrentLocationId` (як у гілці нижче).
  List<({NPCModel npc, SchedulePoint point})> _filteredCandidatesForRoom(
    String roomId,
  ) {
    final npcService = sl<NPCService>();
    final h = widget.timeController.dateTime.hour;
    final day = widget.timeController.weekdayIndex;
    final raw = npcService.getCandidatesInRoom(roomId, h, day);
    return raw
        .where(
          (e) => npcService.getCurrentLocationId(e.npc, h, day) == roomId,
        )
        .toList();
  }

  /// Растр NPC для нижнього оверлею в [ParkView] / [CompanyRoomLayout].
  Widget _parkNpcRasterBottomOverlay({
    required String primaryPath,
    String? fallbackPath,
  }) {
    return Image.asset(
      primaryPath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) {
        final fb = fallbackPath?.trim();
        if (fb != null && fb.isNotEmpty && fb != primaryPath) {
          return Image.asset(
            fb,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.person, color: Colors.white24, size: 56),
            ),
          );
        }
        return const Center(
          child: Icon(Icons.person, color: Colors.white24, size: 56),
        );
      },
    );
  }

  /// Магазини ТРЦ з інтерфейсом «ноутбук» (не ресторан — він окремо).
  Widget? _buildTrcLaptopMallShopIfReady() {
    if (widget.mallShopProducts == null || widget.onMallShopProductTap == null) {
      return null;
    }
    final products = widget.mallShopProducts!;
    final onProductTap = widget.onMallShopProductTap!;
    switch (widget.currentRoom) {
      case LocationsData.cityMallShop:
        return TrcGeneralShopView(
          products: products,
          onProductTap: onProductTap,
        );
      case LocationsData.cityMallPharmacy:
        return TrcPharmacyView(
          products: products,
          onProductTap: onProductTap,
        );
      case LocationsData.cityMallGiftShop:
        return TrcGiftShopView(
          products: products,
          onProductTap: onProductTap,
          onOfficeTap: () => widget.onRoomTap(LocationsData.cityMallGiftShopOffice),
          onWarehouseTap: () => widget.onRoomTap(LocationsData.cityMallGiftShopWarehouse),
        );
      case LocationsData.cityMallSexShop:
        return TrcSexShopView(
          products: products,
          onProductTap: onProductTap,
        );
      case LocationsData.cityMallElectronics:
        return TrcElectronicsShopView(
          products: products,
          onProductTap: onProductTap,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isInsideRoom) {
      if (widget.currentRoom == LocationsData.cityBusinessCenter) {
        return _buildBusinessCenterGrid();
      }
      if (widget.currentRoom == LocationsData.cityMall) {
        return TrcMallGrid(onRoomTap: widget.onRoomTap);
      }
      if (widget.currentRoom == LocationsData.cityEliteResidential) {
        return _buildEliteResidentialGrid();
      }
      if (LocationsData.cityEliteResidentialRoomIds.contains(widget.currentRoom)) {
        return _buildEliteApartmentInnerGrid(widget.currentRoom);
      }
      if (widget.currentRoom == LocationsData.cityVipGym) {
        return _buildVipGymGrid();
      }
      return _buildRoomsGrid();
    }

    if (widget.currentRoom == LocationsData.cityBcLogistics) {
      return LogisticsCompanyView(
        onBossOfficeTap: () =>
            widget.onRoomTap(LocationsData.cityBcLogisticsBossOffice),
        onOfficeTap: widget.onLogisticsOfficeTap,
      );
    }
    if (widget.currentRoom == LocationsData.cityBcLogisticsBossOffice) {
      return const LogisticsBossOfficeView();
    }
    if (widget.currentRoom == LocationsData.cityBcGleamTeam) {
      return GleamTeamCompanyView(
        onProjectsTap: () => widget.onRoomTap(LocationsData.cityBcGleamTeamProjects),
        onCabinetTap: () => widget.onRoomTap(LocationsData.cityBcGleamTeamCabinet),
      );
    }
    if (widget.currentRoom == LocationsData.cityBcCallCenter) {
      return CallCenterCompanyView(
        onOperatorsHallTap: () => widget.onRoomTap(LocationsData.cityBcCallCenterOperatorsHall),
        onBossOfficeTap: () => widget.onRoomTap(LocationsData.cityBcCallCenterBossOffice),
      );
    }
    if (widget.currentRoom == LocationsData.cityCarDealership) {
      return CarDealershipCompanyView(
        onShowroomTap: () => widget.onRoomTap(LocationsData.cityCarDealershipShowroom),
        onWorkshopTap: () => widget.onRoomTap(LocationsData.cityCarDealershipWorkshop),
      );
    }
    if (widget.currentRoom == LocationsData.cityBcCallCenterOperatorsHall) {
      return const CallCenterOperatorsHallView();
    }
    if (widget.currentRoom == LocationsData.cityBcCallCenterBossOffice) {
      return const CallCenterBossOfficeView();
    }
    if (widget.currentRoom == LocationsData.cityBcRockefellerOffice) {
      final npcService = sl<NPCService>();
      final int h = widget.timeController.dateTime.hour;
      final dt = widget.timeController.dateTime;
      final day = widget.timeController.weekdayIndex;
      final roc = npcService.npcById('rockefeller');
      final rockefellerHere = roc != null &&
          npcService.getCurrentLocationId(roc, h, day) ==
              LocationsData.cityBcRockefellerCabinet;

      final candidates = npcService.getCandidatesInRoom(widget.currentRoom, h, day);
      String? npcRasterOverlay;
      NPCModel? activeNPC;
      if (candidates.isNotEmpty && !widget.suppressRoomNpcRaster) {
        final ({NPCModel npc, SchedulePoint point}) chosen = candidates.length == 1
            ? candidates.first
            : () {
                if (widget.selectedNpcIdInRoom != null) {
                  for (final c in candidates) {
                    if (c.npc.id == widget.selectedNpcIdInRoom) return c;
                  }
                }
                return candidates[
                    Random(_dailySeed(dt, widget.currentRoom))
                        .nextInt(candidates.length)];
              }();
        npcRasterOverlay =
            NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);
        activeNPC = chosen.npc;
      }

      final NPCModel? tapTarget = rockefellerHere ? roc : activeNPC;

      return RockefellerCompanyView(
        rockefellerInOffice: rockefellerHere,
        npcRasterAssetPath: rockefellerHere ? null : npcRasterOverlay,
        npcRasterFallbackPath: rockefellerHere ? null : activeNPC?.avatarPath,
        onNpcTap: tapTarget != null
            ? () => widget.onNPCTap(tapTarget)
            : null,
        onCabinetTap: widget.onRockefellerCabinetTap,
        onReceptionTap: widget.onRockefellerReceptionTap,
      );
    }
    if (widget.currentRoom == LocationsData.cityPark) {
      // Раніше тут був лише [ParkView] без оверлею NPC — ліва смуга могла показувати NPC,
      // а картинки на огляді парку не було.
      final room = LocationsData.cityPark;
      Widget? npcOverlay;
      VoidCallback? onBgTap;
      if (!widget.suppressRoomNpcRaster) {
        final candidates = _filteredCandidatesForRoom(room);
        if (candidates.isNotEmpty) {
          final dt = widget.timeController.dateTime;
          final ({NPCModel npc, SchedulePoint point}) chosen =
              candidates.length == 1
                  ? candidates.first
                  : () {
                      if (widget.selectedNpcIdInRoom != null) {
                        for (final c in candidates) {
                          if (c.npc.id == widget.selectedNpcIdInRoom) {
                            return c;
                          }
                        }
                      }
                      return candidates[
                          Random(_dailySeed(dt, room))
                              .nextInt(candidates.length)];
                    }();
          final raster =
              NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);
          final av = chosen.npc.avatarPath?.trim();
          final primary = (raster != null && raster.isNotEmpty)
              ? raster
              : (av != null && av.isNotEmpty ? av : '');
          if (primary.isNotEmpty) {
            npcOverlay = _parkNpcRasterBottomOverlay(
              primaryPath: primary,
              fallbackPath: chosen.npc.avatarPath,
            );
          }
          onBgTap = () => widget.onNPCTap(chosen.npc);
        }
      }
      return ParkView(
        onRoomTap: widget.onRoomTap,
        npcBottomOverlay: npcOverlay,
        onMainBackgroundTap: onBgTap,
      );
    }
    if (widget.currentRoom == LocationsData.cityMallCinema) {
      return TrcRestaurantView(
        onHallTap: () => widget.onRoomTap(LocationsData.cityMallRestaurantHall),
        onVipTap: () => widget.onRoomTap(LocationsData.cityMallRestaurantVip),
      );
    }

    final trcLaptopShop = _buildTrcLaptopMallShopIfReady();
    if (trcLaptopShop != null) return trcLaptopShop;

    final currentRoomNorm = LocationsData.migrateLegacyRoomId(widget.currentRoom);
    final int h = widget.timeController.dateTime.hour;
    final dt = widget.timeController.dateTime;
    final weekday = widget.timeController.weekdayIndex;
    final npcService = sl<NPCService>();
    final cherieNpc = npcService.npcById('cherie');
    final cherieInGiftShopOffice = cherieNpc != null &&
        currentRoomNorm == LocationsData.cityMallGiftShopOffice &&
        npcService.getCurrentLocationId(cherieNpc, h, weekday) ==
            LocationsData.cityMallGiftShopOffice;
    final candidates = _filteredCandidatesForRoom(widget.currentRoom);

    String? specialBackground;
    String? npcRasterOverlay;
    NPCModel? activeNPC;
    ({NPCModel npc, SchedulePoint point})? chosenPair;

    if (candidates.isNotEmpty && !widget.suppressRoomNpcRaster) {
      final ({NPCModel npc, SchedulePoint point}) chosen = candidates.length == 1
          ? candidates.first
          : () {
              if (widget.selectedNpcIdInRoom != null) {
                for (final c in candidates) {
                  if (c.npc.id == widget.selectedNpcIdInRoom) return c;
                }
              }
              return candidates[Random(_dailySeed(dt, widget.currentRoom)).nextInt(candidates.length)];
            }();
      chosenPair = chosen;
      final sp = chosen.point.spritePath.trim();
      if (sp.isNotEmpty && NpcRoomScenePicker.isVideoAssetPath(sp)) {
        specialBackground = sp;
      }
      npcRasterOverlay =
          NpcRoomScenePicker.npcRasterOverlayPath(chosen.npc, chosen.point);
      activeNPC = chosen.npc;
    }

    final roomData = LocationsData.cityRooms[currentRoomNorm];
    /// Міські кімнати без магазинної сітки: фон + NPC знизу (обраний у смузі або за seed).
    final bool useNpcOverlayScene =
        LocationsData.isCityRoomNpcBottomOverlayScene(currentRoomNorm);

    if (useNpcOverlayScene) {
      final cherieOfficeFullVideo = !widget.suppressCherieGiftShopOfficeTc1Background &&
          cherieInGiftShopOffice &&
          currentRoomNorm == LocationsData.cityMallGiftShopOffice;
      if (cherieOfficeFullVideo) {
        return GestureDetector(
          onTap: () => widget.onNPCTap(cherieNpc),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: VideoSceneWidget(videoPath: CherieQuest001.tc1Webm),
          ),
        );
      }
      final bg = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);
      final rileyLanaPair = currentRoomNorm == LocationsData.cityEliteApartment2Bedroom
          ? NpcRoomScenePicker.rileyLanaBedroomPair(candidates)
          : null;
      if (rileyLanaPair != null) {
        final leftRaster = NpcRoomScenePicker.npcRasterOverlayPath(
          rileyLanaPair.left.npc,
          rileyLanaPair.left.point,
        );
        final rightRaster = NpcRoomScenePicker.npcRasterOverlayPath(
          rileyLanaPair.right.npc,
          rileyLanaPair.right.point,
        );
        if (leftRaster != null && rightRaster != null) {
          return RoomNpcSceneTemplate.clippedRoomWithDualNpcOverlay(
            roomBackgroundPath: bg,
            leftNpcRasterAssetPath: leftRaster,
            leftNpcRasterFallbackPath: rileyLanaPair.left.npc.avatarPath,
            rightNpcRasterAssetPath: rightRaster,
            rightNpcRasterFallbackPath: rileyLanaPair.right.npc.avatarPath,
            leftFlipHorizontally: rileyLanaPair.left.npc.id == 'lana',
            rightFlipHorizontally: rileyLanaPair.right.npc.id == 'lana',
            onTapLeft: () => widget.onNPCTap(rileyLanaPair.left.npc),
            onTapRight: () => widget.onNPCTap(rileyLanaPair.right.npc),
          );
        }
      }
      String? npcRaster = npcRasterOverlay;
      // Sasha у парковому кафе — завжди офіціантка (дублює kSashaCafeWaiterPath у sasha_npc.dart).
      if (chosenPair != null &&
          chosenPair.npc.id == 'sasha' &&
          widget.currentRoom == LocationsData.cityParkCafe) {
        npcRaster = 'lib/assets/npcs/sasha/sasha_waiter.png';
      }
      final flipLanaPortrait = currentRoomNorm == LocationsData.cityEliteApartment2Bedroom &&
          chosenPair?.npc.id == 'lana';
      return RoomNpcSceneTemplate.clippedRoomWithNpcOverlay(
        roomBackgroundPath: bg,
        npcRasterAssetPath: npcRaster,
        npcRasterFallbackPath: chosenPair?.npc.avatarPath,
        flipHorizontally: flipLanaPortrait,
        onTap: () {
          if (activeNPC != null) widget.onNPCTap(activeNPC);
        },
      );
    }

    // Для всіх локацій міста: якщо у NPC растр, показуємо його як оверлей (логіка коледжу).
    if (npcRasterOverlay != null && npcRasterOverlay.isNotEmpty) {
      final bg = NpcRoomScenePicker.roomBackgroundPath(roomData?.imagePath);
      final flipLanaPortrait = currentRoomNorm == LocationsData.cityEliteApartment2Bedroom &&
          chosenPair?.npc.id == 'lana';
      return RoomNpcSceneTemplate.clippedRoomWithNpcOverlay(
        roomBackgroundPath: bg,
        npcRasterAssetPath: npcRasterOverlay,
        npcRasterFallbackPath: chosenPair?.npc.avatarPath,
        flipHorizontally: flipLanaPortrait,
        onTap: () {
          if (activeNPC != null) widget.onNPCTap(activeNPC);
        },
      );
    }

    final String finalMedia =
        specialBackground ?? roomData?.imagePath ?? 'lib/assets/location/home_gg/rooms/kitchen.jpg';

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
    return RoomNpcSceneTemplate.layerBackground(path);
  }

  /// Сітка 4 слотів бізнес-центру (2×2). Розміри як у будинку кориша — слоти на весь блок.
  Widget _buildBusinessCenterGrid() {
    final roomIds = LocationsData.cityBusinessCenterRoomIds;
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
          // У бізнес-центрі назви компаній є на картинках, тому не показуємо текстовий лейбл.
          children: roomIds.map((roomId) => _roomCard(roomId, darken: false, showLabel: false)).toList(),
        );
      },
    );
  }

  /// Сітка 6 слотів VIP тренажерного (2×3): рецепція, зал, секція боротьби, спа, сауна, массажний кабінет.
  Widget _buildVipGymGrid() {
    final roomIds = LocationsData.cityVipGymRoomIds;
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

  /// Сітка 6 слотів елітного ЖК (2×3): Квартира 1–6. Слоти на весь блок.
  Widget _buildEliteResidentialGrid() {
    final roomIds = LocationsData.cityEliteResidentialRoomIds;
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

  /// Сітка кімнат у квартирі елітного ЖК (2×3): кухня, ванна, зал, спальня, кімната + тераса / сауна / басейн / офіс.
  Widget _buildEliteApartmentInnerGrid(String apartmentId) {
    final roomIds = LocationsData.cityEliteInnerRoomIdsForApartment(apartmentId);
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

  /// Сітка 6 слотів міста (2×3). Слоти на весь блок.
  Widget _buildRoomsGrid() {
    final roomIds = LocationsData.cityRoomIds;
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

  Widget _roomCard(String roomId, {bool darken = true, bool showLabel = true}) {
    final roomData = LocationsData.cityRooms[roomId];
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
            if (darken) Container(color: Colors.black.withValues(alpha: 0.4)),
            if (showLabel)
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
