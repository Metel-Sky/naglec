import 'package:flutter/material.dart';
import 'company/company_room_layout.dart';
import '../data/locations_room_data.dart';

/// Вид парку: фонове зображення + 2 вікна справа — Кафе та Кав'ярня (за принципом компаній).
class ParkView extends StatelessWidget {
  final Function(String) onRoomTap;
  /// Силует NPC знизу (як у [CompanyRoomLayout.npcBottomOverlay]), коли в парку є присутні NPC.
  final Widget? npcBottomOverlay;
  /// Тап по основному фону (не по кнопках «Кафе» / «Кав'ярня»).
  final VoidCallback? onMainBackgroundTap;

  const ParkView({
    super.key,
    required this.onRoomTap,
    this.npcBottomOverlay,
    this.onMainBackgroundTap,
  });

  static const String _backgroundImagePath = 'lib/assets/location/houses/park.jpg';

  @override
  Widget build(BuildContext context) {
    return CompanyRoomLayout(
      backgroundImagePath: _backgroundImagePath,
      topWindow: CompanyWindowButton(
        imagePath: _backgroundImagePath,
        label: 'Кафе',
        onTap: () => onRoomTap(LocationsData.cityParkCafe),
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: _backgroundImagePath,
        label: "Кав'ярня",
        onTap: () => onRoomTap(LocationsData.cityParkCoffee),
      ),
      npcBottomOverlay: npcBottomOverlay,
      onMainBackgroundTap: onMainBackgroundTap,
    );
  }
}
