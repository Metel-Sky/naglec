import 'package:flutter/material.dart';

import '../../company/company_room_layout.dart';

/// Ресторан у ТРЦ: фон + 2 підлокації (як у логістичній компанії).
class TrcRestaurantView extends StatelessWidget {
  const TrcRestaurantView({
    super.key,
    required this.onHallTap,
    required this.onVipTap,
  });

  final VoidCallback onHallTap;
  final VoidCallback onVipTap;

  static const String _backgroundImagePath =
      'lib/assets/location/houses/restoran.jpg';
  static const String _hallPreviewPath =
      'lib/assets/location/houses/restoran_zal.jpg';
  static const String _vipPreviewPath =
      'lib/assets/location/houses/restoran_vip_zal.jpg';

  @override
  Widget build(BuildContext context) {
    return CompanyRoomLayout(
      backgroundImagePath: _backgroundImagePath,
      topWindow: CompanyWindowButton(
        imagePath: _hallPreviewPath,
        label: 'Зал',
        onTap: onHallTap,
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: _vipPreviewPath,
        label: 'VIP',
        onTap: onVipTap,
      ),
    );
  }
}
