import 'package:flutter/material.dart';
import '../screens/save_load_screen.dart'; // Додай цей імпорт
import '../theme/game_theme.dart';

class StatsBottomMenu extends StatelessWidget {
  final VoidCallback onBackpackTap;
  final VoidCallback onPersonTap;
  final VoidCallback onRefresh;      // Додано
  final VoidCallback onDebugMenuTap; // Додано

  const StatsBottomMenu({
    super.key,
    required this.onBackpackTap,
    required this.onPersonTap,
    required this.onRefresh,      // Додано
    required this.onDebugMenuTap,  // Додано
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Кнопка Налаштування (Шестерня)
        Expanded(
          child: _buildIconButton(
            icon: Icons.settings_outlined,
            onTap: () async {
              // Відкриваємо слоти завантаження
              final bool? loaded = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaveLoadScreen(isLoadingMode: true)),
              );
              // Якщо завантажили гру — сигналізуємо вгору
              if (loaded == true) onRefresh();
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
                    double imageSize = constraints.maxHeight * 0.8;
                    return Image.asset(
                      "lib/assets/gg.png",
                      height: imageSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person_outline,
                        size: imageSize,
                        color: GameTheme.bgDark,
                      ),
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
          child: Icon(icon, size: 40, color: GameTheme.bgDark),
        ),
      ),
    );
  }
}