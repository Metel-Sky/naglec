import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
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
          child: // Це твоя кнопка налаштувань (шестірня)
          _buildIconButton(
            icon: Icons.settings_outlined,
            onTap: () async {
              // 1. Відкриваємо налаштування і чекаємо результат
              final bool? needRefresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

              // 2. Якщо завантаження пройшло успішно (повернули true)
              if (needRefresh == true && context.mounted) {
                // ШУКАЄМО ГОЛОВНИЙ ЕКРАН І ОНОВЛЮЄМО ЙОГО
                // Це спрацює, навіть якщо ми в Stateless віджеті
                context.findAncestorStateOfType<State<StatefulWidget>>()?.setState(() {});

                // АБО, якщо ти знаєш точну назву стану (це надійніше):
                // context.findAncestorStateOfType<any_state_name>()?.setState(() {});
              }
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