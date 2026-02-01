import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import '../main.dart';
import 'news_panel.dart'; // Для доступу до NewsPanel, якщо вона там

class GameDialogPanel extends StatelessWidget {
  final String message;
  final List<Widget> navButtons;

  const GameDialogPanel({
    super.key,
    required this.message,
    required this.navButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Блок новин/діалогів
        Expanded(
          flex: 3,
          child: NewsPanel(customMessage: message),
        ),
        const SizedBox(width: 12),
        // Блок швидкої навігації
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: GameTheme.bgDark,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: navButtons,
            ),
          ),
        ),
      ],
    );
  }
}