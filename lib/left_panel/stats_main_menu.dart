import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class StatsMainMenu extends StatelessWidget {
  // Цей рядок МАЄ бути тут
  final VoidCallback onBackpackTap;

  // Конструктор МАЄ приймати цей параметр
  const StatsMainMenu({
    super.key,
    required this.onBackpackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onBackpackTap,
            child: Container(
              decoration: GameTheme.cardDecoration(radius: 15),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Розраховуємо 90% від доступної висоти контейнера
                    double size = (constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight) * 0.9;

                    return Image.asset(
                      "lib/assets/left_panel/bag.png",
                      height: size, // Встановлюємо висоту 80%
                      fit: BoxFit.contain, // Зберігає пропорції (ширина підлаштується автоматично)
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.backpack_outlined,
                          size: size * 0.9, // Навіть іконка підлаштується під розмір
                          color: Colors.white24,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: GameTheme.cardDecoration(radius: 15),
            child: const Center(
              child: Icon(Icons.phone_iphone, size: 45, color: GameTheme.bgDark),
            ),
          ),
        ),
      ],
    );
  }
}