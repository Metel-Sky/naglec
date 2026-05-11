import 'package:flutter/material.dart';

/// Офіс шефа в логістичній компанії (БЦ).
class LogisticsBossOfficeView extends StatelessWidget {
  const LogisticsBossOfficeView({super.key});

  static const String _backgroundImagePath =
      'lib/assets/location/biznes_centr/logistic/cab_boss.jpg';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_backgroundImagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}
