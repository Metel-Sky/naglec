import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class NewsPanel extends StatelessWidget {
  final String customMessage;

  const NewsPanel({
    super.key,
    this.customMessage = "Ласкаво просимо...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GameTheme.bgDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        customMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}