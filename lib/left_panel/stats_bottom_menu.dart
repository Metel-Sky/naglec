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

        // Кнопка Налаштування
        Expanded(
          child: _buildIconButton(
            icon: Icons.settings_outlined,
            onTap: () {
              print("Налаштування натиснуто");
            },
          ),
        ),
        const SizedBox(width: 8),

        // Кнопка Персонажа (ГГ)
        Expanded(
          child: GestureDetector(
            onTap: onPersonTap,
            child: Container(
              decoration: GameTheme.cardDecoration(radius: 15),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double imageSize = constraints.maxHeight * 0.8; // 80% висоти

                    return Image.asset(
                      "lib/assets/gg.png", // ШЛЯХ ДО ТВОЄЇ КАРТИНКИ ГГ
                      height: imageSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Якщо картинки немає — покажемо запасну іконку
                        return Icon(
                            Icons.person_outline,
                            size: imageSize,
                            color: GameTheme.bgDark
                        );
                      },
                    );
                  },
                ),
              ),
            ),
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