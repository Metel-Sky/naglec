import 'package:flutter/material.dart';
import 'company_room_layout.dart';

/// Вікно колл-центру: фонове зображення + 2 вікна-кнопки справа (30% ширини).
class CallCenterCompanyView extends StatelessWidget {
  final VoidCallback? onBack;
  /// При натисканні «Зал операторів» — перейти в кімнату залу.
  final VoidCallback? onOperatorsHallTap;
  /// При натисканні «Кімната керівника» — перейти в кімнату керівника.
  final VoidCallback? onBossOfficeTap;

  const CallCenterCompanyView({
    super.key,
    this.onBack,
    this.onOperatorsHallTap,
    this.onBossOfficeTap,
  });

  /// Шлях до фону головного вікна — змінюй тут.
  static const String _backgroundImagePath = 'lib/assets/location/houses/company/coll-centr.png';

  @override
  Widget build(BuildContext context) {
    return CompanyRoomLayout(
      backgroundImagePath: _backgroundImagePath,
      topWindow: CompanyWindowButton(
        imagePath: 'lib/assets/location/houses/company/coll-centr.png',
        label: 'Зал операторів',
        onTap: onOperatorsHallTap,
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: 'lib/assets/location/houses/company/coll-centr.png',
        label: 'Кімната керівника',
        onTap: onBossOfficeTap,
      ),
    );
  }
}
