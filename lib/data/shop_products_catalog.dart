import 'dart:convert';

import 'package:flutter/services.dart';

import '../widgets/laptop_shop_view.dart';

/// Єдиний каталог товарів магазинів (`assets/data/shop_products.json`).
///
/// Викликати [load] під час старту гри (після [WidgetsFlutterBinding.ensureInitialized]),
/// до відкриття ноутбука чи ТРЦ.
class ShopProductsCatalog {
  ShopProductsCatalog._();

  static const String assetPath = 'assets/data/shop_products.json';

  /// Ключ магазину в JSON для інтернет-магазину в ноутбуці.
  static const String laptopShopKey = 'laptop';

  static Map<String, Map<String, dynamic>>? _shops;

  static Future<void> load(AssetBundle bundle) async {
    if (_shops != null) return;
    final raw = await bundle.loadString(assetPath);
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final shopsRaw = root['shops'];
    if (shopsRaw is! Map<String, dynamic>) {
      throw FormatException('shop_products.json: поле "shops" має бути об’єктом');
    }
    _shops = shopsRaw.map(
      (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
    );
  }

  /// Для тестів / hot restart у девелопменті.
  static void debugReset() {
    _shops = null;
  }

  static List<ShopProduct> productsFor(String shopKey) {
    final shops = _shops;
    if (shops == null) {
      throw StateError(
        'ShopProductsCatalog.load() має бути викликаний перед доступом до товарів.',
      );
    }
    final entry = shops[shopKey];
    if (entry == null) return [];
    final items = entry['items'] as List<dynamic>? ?? [];
    return items.map(_parseProduct).toList();
  }

  static String titleFor(String shopKey) {
    final shops = _shops;
    if (shops == null) {
      throw StateError(
        'ShopProductsCatalog.load() має бути викликаний перед доступом до назв магазинів.',
      );
    }
    final entry = shops[shopKey];
    if (entry == null) return '';
    return entry['title'] as String? ?? '';
  }

  static ShopProduct _parseProduct(dynamic e) {
    final m = e as Map<String, dynamic>;
    return ShopProduct(
      id: m['id'] as String,
      name: m['name'] as String,
      price: (m['price'] as num).toInt(),
      imagePath: m['imagePath'] as String?,
      purchasableOnce: m['purchasableOnce'] == true,
    );
  }
}
