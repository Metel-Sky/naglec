import 'package:flutter/material.dart';
import '../services/player_stats_controller.dart';
import '../services/service_locator.dart';
import '../services/locale_controller.dart';
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
    final localeCtrl = sl<LocaleController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.cardDecoration(radius: 15),
      child: ListenableBuilder(
        listenable: localeCtrl,
        builder: (context, _) {
          final t = localeCtrl.t;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatWithCheats(
                t('left_stat_energy'),
                stats.energyStatus,
                () => stats.changeEnergy(-25),
                () => stats.changeEnergy(25),
              ),
              _buildStatWithCheats(
                t('left_stat_arousal'),
                stats.arousalStatus,
                () => stats.changeArousal(-33),
                () => stats.changeArousal(33),
              ),
              _buildMoneyWithCheats(t('left_stat_money')),
            ],
          );
        },
      ),
    );
  }

  // Чіти для ЕНЕРГІЇ та ЗБУДЖЕННЯ
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
  Widget _buildMoneyWithCheats(String moneyLabel) {
    return Row(
      children: [
        Text(moneyLabel, style: const TextStyle(color: GameTheme.bgDark, fontWeight: FontWeight.bold, fontSize: 16)),
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