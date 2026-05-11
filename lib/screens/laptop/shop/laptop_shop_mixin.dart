import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import '../../../services/game_time_controller.dart';
import '../../../services/game_world_state.dart';
import '../../../services/inventory_controller.dart';
import '../../../services/player_stats_controller.dart';
import '../../../services/save_service.dart';
import '../../../services/service_locator.dart';
import '../../../widgets/insufficient_money_dialog.dart';
import '../../../widgets/laptop_shop_view.dart';
import '../laptop_screen_state_base.dart';

mixin LaptopShopMixin on LaptopScreenStateBase {
  static const int shopMaxPerItem = 5;

  @override
  Widget buildShopView() {
    final inventory = sl<InventoryController>();
    final products = LaptopShopView.shopProducts.where((p) {
      final cnt = inventory.count(p.id);
      if (p.purchasableOnce) return cnt == 0;
      return cnt < shopMaxPerItem;
    }).toList();
    return LaptopShopView(
      products: products,
      backLabel: t('laptop_study_back'),
      onBack: () => setState(() => showShopSubmenu = false),
      onProductTap: showPurchaseConfirm,
    );
  }

  void showPurchaseConfirm(ShopProduct product) {
    final price = product.price;
    final name = product.name;

    showDialog<bool>(
      context: context,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: AlertDialog(
            title: Center(child: Text(name)),
            content: Center(child: Text(t('shop_confirm_purchase'))),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(t('shop_no')),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(t('shop_yes')),
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      final inventory = sl<InventoryController>();
      if (!product.purchasableOnce &&
          inventory.count(product.id) >= shopMaxPerItem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('shop_max_five')),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final playerStats = sl<PlayerStatsController>();
      if (playerStats.money < price) {
        showInsufficientMoneyDialog(context);
        return;
      }
      playerStats.changeMoney(-price);
      inventory.addItem(GameItem(
        id: product.id,
        name: product.name,
        description: product.name,
        imagePath: product.imagePath,
      ));
      if (product.id == 'ab_fitness') {
        final purchasedAt = sl<GameTimeController>().dateTime;
        sl<GameWorldState>().vipGymCardPurchasedAtIso =
            purchasedAt.toIso8601String();
      }
      sl<SaveService>().autosave();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('shop_bought')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}
