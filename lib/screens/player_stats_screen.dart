import 'package:flutter/material.dart';
import '../services/player_stats_controller.dart'; // Потрібно буде створити або знайти інстанс
import '../theme/game_theme.dart';

class PlayerStatsScreen extends StatelessWidget {
  final PlayerStatsController playerStatsController;

  const PlayerStatsScreen({super.key, required this.playerStatsController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика персонажа'),
        backgroundColor: GameTheme.mainGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Тут буде зображення та основні характеристики
            const Text('TODO: Додати зображення та інші елементи',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
