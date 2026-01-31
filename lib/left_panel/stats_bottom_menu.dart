import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class StatsBottomMenu extends StatelessWidget {
  // Ми залишаємо цей параметр, щоб не було помилок у коридорі,
  // навіть якщо не використовуємо його тут прямо зараз.
  final VoidCallback onBackpackTap;

  const StatsBottomMenu({
    super.key,
    required this.onBackpackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Кнопка Персонажа
        Expanded(
          child: _buildIconButton(
            icon: Icons.person_outline,
            onTap: () {
              print("Профіль персонажа");
            },
          ),
        ),

        const SizedBox(width: 8),

        // ПОВЕРТАЄМО НАЛАШТУВАННЯ (Шестерню)
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
            color: GameTheme.bgDark, // Твій фірмовий зелений
          ),
        ),
      ),
    );
  }
}