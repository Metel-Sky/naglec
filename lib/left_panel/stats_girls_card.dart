import 'package:flutter/material.dart';
import '../theme/game_theme.dart';


class StatsGirlsCard extends StatelessWidget {
  const StatsGirlsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: GameTheme.cardDecoration(radius: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: const Center(
          // Коли будуть ассети, замінимо на Image.asset('assets/girls.png')
          child: Icon(
              Icons.people_alt,
              size: 60,
              color: Colors.black87
          ),
        ),
      ),
    );
  }
}