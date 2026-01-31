import 'package:flutter/material.dart';
import '../services/player_stats_controller.dart';
import '../theme/game_theme.dart';

class StatsHeaderCard extends StatelessWidget {
  final PlayerStatsController stats;
  final VoidCallback onStatsChanged;

  const StatsHeaderCard({
    super.key,
    required this.stats,
    required this.onStatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.cardDecoration(radius: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatWithCheats(
            "Стан:",
            stats.energyStatus,
                () => stats.changeEnergy(-25),
                () => stats.changeEnergy(25),
          ),
          _buildStatWithCheats(
            "Збудження:",
            stats.arousalStatus,
                () => stats.changeArousal(-33),
                () => stats.changeArousal(33),
          ),
          _buildMoneyWithCheats(),
        ],
      ),
    );
  }

  // Чіти для СТАНУ та ЗБУДЖЕННЯ
  Widget _buildStatWithCheats(String label, String value, VoidCallback onSub, VoidCallback onAdd) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: GameTheme.bgDark, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 4),
        _debugBtn("- ", onSub),
        Text(value, style: const TextStyle(color: GameTheme.textGreen, fontWeight: FontWeight.bold, fontSize: 16)),
        _debugBtn(" +", onAdd),
      ],
    );
  }

  // Чіти для ГРОШЕЙ (-- - + ++)
  Widget _buildMoneyWithCheats() {
    return Row(
      children: [
        const Text("Гроші: ", style: TextStyle(color: GameTheme.bgDark, fontWeight: FontWeight.bold, fontSize: 16)),
        _debugBtn(" -- ", () => stats.changeMoney(-10000)),
        _debugBtn(" - ", () => stats.changeMoney(-1000)),
        Text(
          "\$ ${stats.money}",
          style: const TextStyle(color: GameTheme.textGreen, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _debugBtn(" + ", () => stats.changeMoney(1000)),
        _debugBtn(" ++ ", () => stats.changeMoney(10000)),
      ],
    );
  }

  Widget _debugBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        onStatsChanged();
      },
      child: Text(
        label,
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}