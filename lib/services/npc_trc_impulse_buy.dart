import 'dart:math';

import '../data/npc_economy_config.dart';
import '../locations/trc/gift_shop/mall_gift_shop.dart';
import '../locations/trc/general_shop/mall_shop.dart';
import '../locations/trc/sex_shop/mall_sex_shop.dart';
import '../models/npc_model.dart';
import '../widgets/laptop_shop_view.dart';

/// Імпульсні покупки непрацюючих NPC у ТРЦ: **магазин подарунків**, **загальний магазин**, **секс-шоп**.
/// Ціна товару лише в коридорі **[minPrice]–[maxPrice]** ($200–$800); сума не перевищує гаманець NPC.
///
/// Викликай не частіше **раз на тиждень** на NPC (відповідає [NpcEconomyService]).
class NpcTrcImpulseBuy {
  NpcTrcImpulseBuy._();

  static const int minPrice = 200;
  static const int maxPrice = 800;

  static List<ShopProduct> _inPriceRange(
    Iterable<ShopProduct> products,
    int lo,
    int hi,
  ) =>
      products.where((p) => p.price >= lo && p.price <= hi).toList(growable: false);

  /// Товари магазину подарунків (`city_mall_gift_shop`) у діапазоні цін.
  static List<ShopProduct> giftShopProducts(int lo, int hi) =>
      _inPriceRange(MallGiftShop.products, lo, hi);

  /// Загальний магазин ТРЦ (`city_mall_shop`).
  static List<ShopProduct> generalShopProducts(int lo, int hi) =>
      _inPriceRange(MallShop.products, lo, hi);

  /// Секс-шоп (`city_mall_sex_shop`).
  static List<ShopProduct> sexShopProducts(int lo, int hi) =>
      _inPriceRange(MallSexShop.products, lo, hi);

  /// Об’єднаний каталог для резервного вибору.
  static List<ShopProduct> allEligibleProducts(int lo, int hi) => <ShopProduct>[
        ...giftShopProducts(lo, hi),
        ...generalShopProducts(lo, hi),
        ...sexShopProducts(lo, hi),
      ];

  static Random _rng(String npcId, DateTime gameDate, int sequence) {
    final dayKey =
        gameDate.year * 10000 + gameDate.month * 100 + gameDate.day;
    final seed = Object.hash(npcId, dayKey, sequence);
    return Random(seed);
  }

  /// Детермінований вибір: спочатку випадковий тип магазину (1 з 3), потім товар з його вітрини.
  /// [maxAffordable] обмежує верх ціни (гаманець NPC), але не нижче [minPrice].
  /// Якщо на вітрині немає позицій у діапазоні, береться об’єднаний список.
  static ShopProduct? pickProduct({
    required String npcId,
    required DateTime gameDate,
    required int sequence,
    int? maxAffordable,
  }) {
    final cap = min(maxPrice, maxAffordable ?? maxPrice);
    if (cap < minPrice) return null;
    final rng = _rng(npcId, gameDate, sequence);
    final perShop = [
      giftShopProducts(minPrice, cap),
      generalShopProducts(minPrice, cap),
      sexShopProducts(minPrice, cap),
    ];
    var candidates = perShop[rng.nextInt(3)];
    if (candidates.isEmpty) {
      candidates = allEligibleProducts(minPrice, cap);
    }
    if (candidates.isEmpty) {
      return null;
    }
    return candidates[rng.nextInt(candidates.length)];
  }

  /// Списати гроші та додати предмет (типово на 7 днів ігрового часу — зникає з інвентаря NPC).
  static void grantPurchasedItem({
    required NPCModel npc,
    required ShopProduct product,
    required DateTime gameNow,
    required int sequence,
    Duration possessionDuration = const Duration(days: 7),
  }) {
    npc.money = (npc.money - product.price)
        .clamp(NpcEconomyConfig.moneyMin, NpcEconomyConfig.moneyMax);
    final expires = gameNow.add(possessionDuration);
    final itemId =
        'trc_impulse_${npc.id}_${gameNow.year}_${gameNow.month}_${gameNow.day}_$sequence';
    npc.items.removeWhere((i) => i.id == itemId);
    npc.items.add(
      NpcOwnedItem(
        id: itemId,
        name: product.name,
        imagePath: product.imagePath,
        expiresAtIso: expires.toIso8601String(),
      ),
    );
  }

  /// Вибір товару + застосування. Повертає обраний товар або `null`, якщо каталог порожній.
  static ShopProduct? pickAndApply({
    required NPCModel npc,
    required DateTime gameNow,
    required int sequence,
    int? maxAffordable,
  }) {
    final product = pickProduct(
      npcId: npc.id,
      gameDate: gameNow,
      sequence: sequence,
      maxAffordable: maxAffordable,
    );
    if (product == null) return null;
    grantPurchasedItem(
      npc: npc,
      product: product,
      gameNow: gameNow,
      sequence: sequence,
    );
    return product;
  }
}
