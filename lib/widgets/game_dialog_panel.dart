import 'package:flutter/material.dart';
import '../theme/game_theme.dart';
import 'news_panel.dart';

class GameDialogPanel extends StatelessWidget {
  final String message;
  /// Рядок над [message] у червоному (попередження).
  final String? messageRedWarning;
  /// Опційна кнопка (або інший віджет) під текстом у блоці повідомлення.
  final Widget? messageTrailing;
  /// Підсвітка імен у діалозі (наприклад активний NPC).
  final List<String> highlightNames;
  /// Зелений стиль основного тексту (підказка квесту / івенту).
  final bool greenEventStyle;
  final List<Widget> navButtons;

  const GameDialogPanel({
    super.key,
    required this.message,
    this.messageRedWarning,
    this.messageTrailing,
    this.highlightNames = const [],
    this.greenEventStyle = false,
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
          child: NewsPanel(
            customMessage: message,
            redWarningPrefix: messageRedWarning,
            trailing: messageTrailing,
            highlightNames: highlightNames,
            greenEventStyle: greenEventStyle,
          ),
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