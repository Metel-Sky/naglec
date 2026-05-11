import 'package:flutter/material.dart';

import '../data/shop_products_catalog.dart';
import 'shop_product_card.dart';

/// Модель товару в інтернет-магазині.
class ShopProduct {
  final String id;
  final String name;
  final int price;
  final String? imagePath;
  /// Якщо true — товар можна купити лише один раз; після купівлі зникає з магазину й потрапляє в рюкзак.
  final bool purchasableOnce;

  const ShopProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imagePath,
    this.purchasableOnce = false,
  });
}

/// Сітка карток товарів без кнопки «Назад» — для вбудовування в складні макети (наприклад ТРЦ магазин подарунків).
class ShopProductGrid extends StatelessWidget {
  const ShopProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.padding = const EdgeInsets.all(8),
  });

  final List<ShopProduct> products;
  final void Function(ShopProduct product) onProductTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Wrap(
        spacing: 11.0,
        runSpacing: 11.0,
        children: [
          for (final product in products)
            SizedBox(
              width: 134,
              child: ShopProductCard(
                name: product.name,
                price: product.price,
                imagePath: product.imagePath,
                onPriceTap: () => onProductTap(product),
              ),
            ),
        ],
      ),
    );
  }
}

/// Віджет інтернет-магазину в ноутбуці: кнопка «Назад» + сітка карток товарів.
class LaptopShopView extends StatelessWidget {
  /// Товари ноутбука — `assets/data/shop_products.json`, ключ [ShopProductsCatalog.laptopShopKey].
  static List<ShopProduct> get shopProducts =>
      ShopProductsCatalog.productsFor(ShopProductsCatalog.laptopShopKey);

  final List<ShopProduct> products;
  final VoidCallback? onBack;
  final String? backLabel;
  final void Function(ShopProduct product) onProductTap;
  /// Без рядка «Назад» (ТРЦ-магазини — вихід через верхню панель).
  final bool hideBackButton;

  const LaptopShopView({
    super.key,
    required this.products,
    required this.onProductTap,
    this.hideBackButton = false,
    this.onBack,
    this.backLabel,
  }) : assert(
          hideBackButton || (onBack != null && backLabel != null),
          'Потрібні onBack і backLabel, якщо hideBackButton == false',
        );

  @override
  Widget build(BuildContext context) {
    if (hideBackButton) {
      return ShopProductGrid(products: products, onProductTap: onProductTap);
    }
    final back = onBack!;
    final label = backLabel!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: back,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.95), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ShopProductGrid(products: products, onProductTap: onProductTap),
        ),
      ],
    );
  }
}
