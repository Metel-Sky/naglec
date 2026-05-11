import 'package:flutter/material.dart';
import 'company_room_layout.dart';

/// Gleam Team: фон + 2 вікна (Проєкти, Кабінет).
class GleamTeamCompanyView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onProjectsTap;
  final VoidCallback onCabinetTap;

  const GleamTeamCompanyView({
    super.key,
    this.onBack,
    required this.onProjectsTap,
    required this.onCabinetTap,
  });

  static const String _backgroundImagePath = 'lib/assets/location/houses/company/clining.png';

  @override
  Widget build(BuildContext context) {
    return CompanyRoomLayout(
      backgroundImagePath: _backgroundImagePath,
      topWindow: CompanyWindowButton(
        imagePath: 'lib/assets/location/houses/company/clining.png',
        label: 'Проєкти',
        onTap: onProjectsTap,
      ),
      bottomWindow: CompanyWindowButton(
        imagePath: 'lib/assets/location/houses/company/clining.png',
        label: 'Кабінет',
        onTap: onCabinetTap,
      ),
    );
  }
}
