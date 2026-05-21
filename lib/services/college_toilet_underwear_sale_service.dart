import 'dart:math';

import '../models/item_model.dart';

/// Продаж знайдених речей (білизна з власницею, журнали) в туалеті коледжу (12:30–12:59).
class CollegeToiletUnderwearSaleService {
  static const String saleContext = 'college_toilet_sale';

  static const List<String> ownerIds = ['elsa', 'piper', 'mom'];

  static const List<String> journalItemIds = [
    'journal_wom',
    'playboy',
    'ero_book',
    'porn_jur',
  ];

  static String? ownerIdFromItemId(String itemId) {
    for (final id in ownerIds) {
      if (itemId.endsWith('_$id')) return id;
    }
    return null;
  }

  static bool isJournalItem(GameItem item) =>
      journalItemIds.contains(item.id);

  /// Штраф «спалили» лише для білизни з позначеною власницею в id.
  static bool canTriggerExposure(GameItem item) =>
      !isJournalItem(item) && ownerIdFromItemId(item.id) != null;

  static bool isSellableItem(GameItem item) =>
      ownerIdFromItemId(item.id) != null || isJournalItem(item);

  static List<GameItem> sellableItems(Iterable<GameItem> items) {
    final seen = <String>{};
    final result = <GameItem>[];
    for (final item in items) {
      if (!isSellableItem(item)) continue;
      if (seen.add(item.id)) result.add(item);
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  static int priceForItem(GameItem item, String dateKey) {
    final ownerId = ownerIdFromItemId(item.id);
    final seedStr = ownerId != null
        ? '$dateKey|${item.id}|$ownerId|$saleContext'
        : '$dateKey|${item.id}|$saleContext';
    final seed = seedStr.hashCode & 0x7fffffff;
    return 10 + Random(seed).nextInt(66);
  }

  static double exposureChancePercent(int price) {
    if (price <= 20) return 3;
    if (price <= 35) return 7;
    if (price <= 50) return 13;
    if (price <= 65) return 21;
    return 30;
  }

  static String riskLabel(int price) {
    if (price <= 35) return 'низький';
    if (price <= 55) return 'середній';
    return 'високий';
  }

  static String ownerDisplayName(String ownerId) => switch (ownerId) {
        'elsa' => 'Ельза',
        'piper' => 'Пайпер',
        'mom' => 'мама',
        _ => ownerId,
      };

  static bool rollExposure(int price, Random rng) {
    final chance = exposureChancePercent(price);
    return rng.nextInt(100) < chance;
  }
}
