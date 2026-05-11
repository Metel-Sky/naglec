import 'package:flutter/material.dart';

import 'company/company_room_layout.dart';

/// Автосалон: фон + 2 вікна-кнопки (торговий зал і майстерня), як у колл-центрі.
class CarDealershipCompanyView extends StatelessWidget {
  final VoidCallback? onShowroomTap;
  final VoidCallback? onWorkshopTap;

  const CarDealershipCompanyView({
    super.key,
    this.onShowroomTap,
    this.onWorkshopTap,
  });

  static const String _backgroundImagePath = 'lib/assets/location/houses/auto_centr.jpeg';

  @override
  Widget build(BuildContext context) {
    return CompanyRoomLayout(
      backgroundImagePath: _backgroundImagePath,
      topWindow: CompanyWindowButton(
        imagePath: _backgroundImagePath,
        label: 'Торговий зал',
        onTap: onShowroomTap,
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: _backgroundImagePath,
        label: 'Майстерня',
        onTap: onWorkshopTap,
      ),
    );
  }
}
