import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/inventory_controller.dart';
import '../services/locale_controller.dart';
import '../services/player_stats_controller.dart';
import '../services/service_locator.dart';
import '../theme/game_theme.dart';

class BackpackView extends StatelessWidget {
  final InventoryController inventory;
  final PlayerStatsController playerStats;
  final VoidCallback onChanged;

  const BackpackView({
    super.key,
    required this.inventory,
    required this.playerStats,
    required this.onChanged,
  });

  /// Частка від [PlayerModel.maxEnergy], яку відновлює предмет, або null — не їжа/напій.
  static double? _energyFractionForItemId(String id) {
    switch (id) {
      case 'energy':
      case 'energy_drink':
        return 0.2;
      case 'snickers':
        return 0.1;
      default:
        return null;
    }
  }

  void _showUseDialog(BuildContext context, GameItem item) {
    final t = sl<LocaleController>().t;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item.name,
          textAlign: TextAlign.center,
        ),
        content: Text(
          t('backpack_use_question'),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('shop_no')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _applyUse(context, item);
            },
            child: Text(t('shop_yes')),
          ),
        ],
      ),
    );
  }

  void _applyUse(BuildContext context, GameItem item) {
    final fraction = _energyFractionForItemId(item.id);
    final t = sl<LocaleController>().t;
    if (fraction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('backpack_item_not_usable')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    playerStats.changeEnergy(playerStats.player.maxEnergy * fraction);
    inventory.removeItem(item.id);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueItems = inventory.uniqueItemsWithCount;
    const totalSlots = 40;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        final hasItem = index < uniqueItems.length;
        final entry = hasItem ? uniqueItems[index] : null;
        final item = entry?.$1;
        final count = entry?.$2 ?? 0;

        return GestureDetector(
          onTap: () {
            if (hasItem && item != null) {
              _showUseDialog(context, item);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasItem && item != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.imagePath != null && item.imagePath!.isNotEmpty
                            ? Image.asset(
                                item.imagePath!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.inventory_2, color: GameTheme.textGreen),
                                ),
                              )
                            : const Center(child: Icon(Icons.inventory_2, color: GameTheme.textGreen)),
                      ),
                      if (item.id == 'compromat')
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                      if (item.id == 'usb_compromat')
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }
}
