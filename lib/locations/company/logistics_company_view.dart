import 'package:flutter/material.dart';
import 'company_room_layout.dart';

/// Вікно логістичної компанії: фонове зображення + 2 вікна-кнопки справа (30% ширини).
class LogisticsCompanyView extends StatelessWidget {
  final VoidCallback? onBack;
  /// Вхід у офіс шефа (підкімната БЦ).
  final VoidCallback? onBossOfficeTap;
  /// При натисканні «Офіс мами» — відкрити відео на весь екран і показати кнопки в локаційному меню.
  final VoidCallback? onOfficeTap;

  const LogisticsCompanyView({
    super.key,
    this.onBack,
    this.onBossOfficeTap,
    this.onOfficeTap,
  });

  /// Шлях до фону головного вікна — змінюй тут, щоб змінити фон.
  static const String _backgroundImagePath = 'lib/assets/location/biznes_centr/logistic/stroi_city.jpg';

  @override
  Widget build(BuildContext context) {
    return CompanyRoomLayout(
      backgroundImagePath: _backgroundImagePath,
      topWindow: CompanyWindowButton(
        imagePath: 'lib/assets/location/biznes_centr/logistic/cab_boss.jpg',
        label: 'Офіс шефа',
        onTap: onBossOfficeTap ?? () {},
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: 'lib/assets/location/biznes_centr/logistic/cab_mom.jpg',
        label: 'Офіс мами',
        onTap: onOfficeTap ?? () {},
      ),
    );
  }
}
