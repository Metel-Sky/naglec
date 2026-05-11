import 'package:flutter/material.dart';


/// Комната керівника в колл-центрі (поки без окремих дій).
class CallCenterBossOfficeView extends StatelessWidget {
  const CallCenterBossOfficeView({super.key});

  static const String _backgroundImagePath = 'lib/assets/location/houses/company/coll-centr.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_backgroundImagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black.withValues(alpha: 0.25)),
        ],
      ),
    );
  }
}

