import 'package:flutter/material.dart';

/// Шаблон картки товару в інтернет-магазині.
///
/// Складається з двох блоків:
/// 1. Верхній — білий прямокутник із зображенням товару (або іконкою, якщо картинки немає).
/// 2. Нижній — білий прямокутник із ціною.
///
/// Натискання на **картинку або ціну** викликає [onPriceTap] (діалог підтвердження купівлі).
///
/// Як додати новий товар:
/// 1. У [lib/screens/laptop_screen.dart] у масиві [_shopProducts] додай елемент:
///    ```dart
///    ShopProduct(
///      id: 'унікальний_id',
///      name: 'Назва товару',
///      price: 1234,
///      imagePath: Assets.itemsНазваФайлу,  // з lib/generated/assets.dart, або null
///    ),
///    ```
/// 2. Картинки беруться з папки lib/assets/items/ — після додавання файлу
///    перегенеруй assets (або додай константу вручну в generated/assets.dart),
///    потім використовуй Assets.itemsІмяФайлу.
/// 3. [ShopProductCard] не змінювати — він лише відображає один товар;
///    список товарів задається в [LaptopShopView] через [products].
class ShopProductCard extends StatelessWidget {
  /// Шлях до картинки товару (наприклад, з [Assets]). Якщо null або порожній — показується іконка замість фото.
  final String? imagePath;

  /// Назва товару (використовується в діалозі підтвердження купівлі, тут не виводиться).
  final String name;

  /// Ціна в грошових одиницях; відображається у вигляді "$ 5000".
  final int price;

  /// Викликається при натисканні на блок із ціною (наприклад, показати діалог "Підтверджуєте купівлю?").
  final VoidCallback onPriceTap;

  const ShopProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imagePath,
    required this.onPriceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPriceTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Верхній блок: зображення товару ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imagePath != null && imagePath!.isNotEmpty
                      ? Image.asset(imagePath!, fit: BoxFit.contain)
                      : Center(
                          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey[600]),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // --- Нижній блок: ціна ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '\$ $price',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
