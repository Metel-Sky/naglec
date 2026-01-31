import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class StatsBottomMenu extends StatelessWidget {
  final VoidCallback onBackpackTap;
  final VoidCallback onPersonTap; // 1. Додаємо новий параметр для ГГ

  const StatsBottomMenu({
    super.key,
    required this.onBackpackTap,
    required this.onPersonTap, // 2. Робимо його обов'язковим
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Кнопка Персонажа (ГГ)
        Expanded(
          child: _buildIconButton(
            icon: Icons.person_outline,
            onTap: onPersonTap, // 3. Викликаємо передану функцію замість print
          ),
        ),

        const SizedBox(width: 8),

        // Кнопка Налаштування
        Expanded(
          child: _buildIconButton(
            icon: Icons.settings_outlined,
            onTap: () {
              print("Налаштування натиснуто");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: GameTheme.cardDecoration(radius: 15),
        child: Center(
          child: Icon(
            icon,
            size: 40,
            color: GameTheme.bgDark,
          ),
        ),
      ),
    );
  }
}